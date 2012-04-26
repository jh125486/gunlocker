//
//  Model+Helpers.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Model+Helpers.h>

@implementation Weapon (helper)

- (NSString *)description {
    NSString *manufacturer = self.manufacturer.short_name ? self.manufacturer.short_name : self.manufacturer.name;
    NSMutableString *description = [[NSString stringWithFormat:@"%@ %@", manufacturer, self.model] mutableCopy];
    if (self.barrel_length) [description appendFormat:@" (%@\")", self.barrel_length];
    
    return [NSString stringWithString:description];
}

@end


@implementation Trajectory (helper)

-(NSNumber*)energyAtVelocity:(float)v {
    return [NSNumber numberWithDouble:0.5 * (([self.ballistic_profile.bullet_weight intValue]/7000) /(-GRAVITY_FPS)) * pow(v, 2)]; 
}

-(void)calculateTrajectory {    
    double yAtX, vAtX, tAtX, thetaAtX;
    //set values that don't change
        
    double yAtScope = INCHES_to_FEET([self.ballistic_profile.sight_height_inches doubleValue]);
    double vInitial = [self.ballistic_profile.muzzle_velocity doubleValue];
    double mass = [self.ballistic_profile.bullet_weight doubleValue] / 7000;
    double sectionalArea = (M_PI / 4) * pow([self.ballistic_profile.bullet_diameter_inches doubleValue] / 12, 2);
    double speedOfSound = METERS_to_FEET(self.calculateSpeedOfSoundInMPS);
    
    double xAtZero = [self.ballistic_profile.zero doubleValue];
    double airDensity = 0.076474;
    double c = [self.ballistic_profile getBCWithSpeedOfSound:speedOfSound andVelocity:vInitial];
//    double c = 0.584;
    double vAtZero = pow((sqrt(vInitial) - (0.5 * (airDensity * sectionalArea * c * sqrt(speedOfSound) / (2*mass)) * (YARDS_to_FEET((xAtZero))))), 2);
    double tAtZero = (YARDS_to_FEET(xAtZero) / vInitial) * sqrt(vInitial / vAtZero);
    double thetaIntial = atan((yAtScope + (0.5 * -GRAVITY_FPS * pow(tAtZero, 2) * ((1.0/3)*(1+(2*sqrt(vAtZero/vInitial)))))) / YARDS_to_FEET(xAtZero));
    NSLog(@"atan((%f + (0.5 * %f * %f * ((1.0/3)*(1+(2*sqrt(%f)))))) / %f)",  yAtScope, -GRAVITY_FPS, pow(tAtZero, 2), vAtZero/ vInitial, YARDS_to_FEET(xAtZero));
    vAtX = vInitial;
    
    NSLog(@"K %f", (airDensity * sectionalArea * c * sqrt(speedOfSound) / (2*mass)));
    NSLog(@"initial v %f", vInitial);
    NSLog(@"speed of sound %f m/s %f ft/s", speedOfSound, METERS_to_FEET(speedOfSound));
    NSLog(@"S  %f", sectionalArea);
    NSLog(@"mass %f", mass);
    NSLog(@"initial xAtZero %f", xAtZero);
    NSLog(@"initial vAtZero %f", vAtZero);
    NSLog(@"initial tAtZero %f", tAtZero);
    NSLog(@"initial angle %f", thetaIntial * (180 / M_PI));
    
    NSLog(@"X\tDrop \"\tMOA\t\tMILs\tVelocity\tMach\tE\tTime");
    
    for (int x = [self.range_min intValue]; x <= [self.range_max intValue]; x += [self.range_increment intValue]) {
        TrajectoryRange *range = [TrajectoryRange createEntity];
        [self addRangesObject:range];
        double c = [self.ballistic_profile getBCWithSpeedOfSound:speedOfSound andVelocity:vInitial];
//        double c = 0.584;
        
        vAtX = pow((sqrt(vInitial) - (0.5 * (airDensity * sectionalArea * c * sqrt(speedOfSound) / (2*mass)) * (YARDS_to_FEET(x)))), 2);
        tAtX = (YARDS_to_FEET(x) / vInitial) * sqrt(vInitial / vAtX);
        thetaAtX = atan(tan(thetaIntial) - (((-GRAVITY_FPS * tAtX)/vInitial)*((1.0/3)*(1+sqrt(vInitial/vAtX) + (vInitial/vAtX))))) * (180/M_PI);
        yAtX = -yAtScope + (YARDS_to_FEET(x) * tan(thetaIntial)) - (0.5 * -GRAVITY_FPS * pow(tAtX, 2)*((1.0/3)*(1+(2*sqrt(vAtX/vInitial)))));

        range.range_m = [[NSDecimalNumber alloc] initWithDouble:FEET_to_METERS(x)];
        range.velocity_mps = [[NSDecimalNumber alloc] initWithDouble:FEET_to_METERS(vAtX)];
        range.drop = [[NSDecimalNumber alloc] initWithDouble:FEET_to_INCHES(yAtX)];
        range.energy_ftlbs = [[NSDecimalNumber alloc] initWithDouble:0.5 * ((mass) / (-GRAVITY_FPS)) * pow(vAtX, 2)];
//        range.windage = [NSNumber numberWithDouble:XXX];
//        range.lead = [NSNumber numberWithDouble:(sin(t)*self.lead_angle*self.lead_speed)];
        range.time = [[NSDecimalNumber alloc] initWithDouble:tAtX];

        double dropMOA = (atan2(yAtX, YARDS_to_FEET(x)) * (180 / M_PI)) * 60.0;
//        NSLog(@"%@", [NSString stringWithFormat:@"%d\t\t%0.1f\t%0.5f\t%0.5f\t%0.2f", x, vAtX, tAtX, thetaAtX * 60, FEET_to_INCHES(yAtX)]);
        double dropMILs = MOA_to_MIL(dropMOA);
        
        NSLog(@"%@", [NSString stringWithFormat:@"%d\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t\t%0.3f\t%0.1f\t%0.3f", x, FEET_to_INCHES(yAtX), dropMOA, dropMILs, vAtX, (vAtX/speedOfSound), [range.energy_ftlbs doubleValue], tAtX]);        
    }
    
}


-(double)calculateSpeedOfSoundInMPS {
    
    // Code from: Dr Richard Lord - http://www.npl.co.uk/acoustics/techguides/speedair
    // Based on the approximate formula found in
    // Owen Cramer, "The variation of the specific heat ratio and the speed of sound in air with temperature, pressure, humidity, and CO2 concentration",
    // The Journal of the Acoustical Society of America (JASA), J. Acoust. Soc. Am. 93(5) p. 2510-2516; formula at p. 2514.
    // Saturation vapour pressure found in 
    // Richard S. Davis, "Equation for the Determination of the Density of Moist Air (1981/91)", Metrologia, 29, p. 67-70, 1992,
    // and a mole fraction of carbon dioxide of 0.0004.
    // The mole fraction is simply an expression of the number of moles of a compound divided by the total number of moles of all the compounds present in the gas.
    
    double Xc, Xw;// Mole fraction of carbon dioxide and water vapour
    double temp_k = TEMP_C_to_TEMP_K([self.temp_c doubleValue]);
    
    // Molecular concentration of water vapour calculated from Rh using Giacomos method by Davis (1991) as implemented in DTU report 11b-1997
    double psv = exp(pow(temp_k, 2) *1.2378847 * pow(10,-5) -1.9121316 *pow(10,-2) * temp_k)*exp(33.93711047-6.3431645*pow(10,3)/temp_k);
    Xw = ([self.relative_humidity doubleValue] * 3.14 *pow(10,-8) * ([self.pressure_inhg doubleValue]*3386.389) + 1.00062 + pow([self.temp_c doubleValue], 2) * 5.6 * pow(10,-7) * psv/([self.pressure_inhg doubleValue] * 3386.389) )/100.0;
    Xc = 400.0 * pow(10,-6); 
    // Speed calculated using the method of Cramer from JASA vol 93 p. 2510
    return (0.603055*[self.temp_c doubleValue] + 331.5024 - pow([self.temp_c doubleValue],2) * 5.28 * pow(10,-4) + (0.1495874 * [self.temp_c doubleValue]+ 51.471935 - pow([self.temp_c doubleValue],2)*7.82 * pow(10,-4))*Xw) + ((-1.82 * pow(10,-7) + 3.73 * pow(10,-8) * [self.temp_c doubleValue] - pow([self.temp_c doubleValue],2) * 2.93 * pow(10,-10)) * ([self.pressure_inhg doubleValue] * 3386.389) + (-85.20931-0.228525 * [self.temp_c doubleValue] + pow([self.temp_c doubleValue],2)*5.91*pow(10,-5))*Xc) - (pow(Xw,2) * 2.835149 - pow([self.pressure_inhg doubleValue] * 3386.389,2) * 2.15 * pow(10,-13) + pow(Xc,2) * 29.179762 + 4.86 * pow(10,-4) * Xw * ([self.pressure_inhg doubleValue] * 3386.389) * Xc);
}

@end

@implementation BallisticProfile (helper)

-(double)ballisticCoefficientWithVelocity:(double)velocity {
    NSArray *bc = self.bullet_bc;
    double value = [(NSDecimalNumber *)[bc objectAtIndex:0] doubleValue];

    for (int i = 1; i < bc.count; i += 2) {
        if ([(NSDecimalNumber *)[bc objectAtIndex:i + 1] doubleValue] < velocity) break;
        value = [(NSDecimalNumber *)[bc objectAtIndex:i] doubleValue];
    }
    return value;
}

-(double)getBCWithSpeedOfSound:(double)speedOfSound andVelocity:(double)velocity{
    double multiplier;
    double mach = velocity / speedOfSound;
    
    if ([self.drag_model isEqualToString:@"G1"]) {
        if (mach > 2.0)
            multiplier = 0.9482590 + mach*(-0.248367 + mach*0.0344343);
        else if (mach > 1.40)
            multiplier = 0.6796810 + mach*(0.0705311 - mach*0.0570628);
        else if (mach > 1.10)
            multiplier = -1.471970 + mach*(3.1652900 - mach*1.1728200);
        else if (mach > 0.85)
            multiplier = -0.647392 + mach*(0.9421060 + mach*0.1806040);
        else if (mach >= 0.55)
            multiplier = 0.6224890 + mach*(-1.426820 + mach*1.2094500);
        else
            multiplier = 0.2637320 + mach*(-0.165665 + mach*0.0852214);
    } else if ([self.drag_model isEqualToString:@"G2"]) {
        if (mach > 2.5)
            multiplier = 0.4465610 + mach*(-0.0958548 + mach*0.00799645);
        else if (mach > 1.2)
            multiplier = 0.7016110 + mach*(-0.3075100 + mach*0.05192560);
        else if (mach > 1.0)
            multiplier = -1.105010 + mach*(2.77195000 - mach*1.26667000);
        else if (mach > 0.9)
            multiplier = -2.240370 + mach*2.63867000;
        else if (mach >= 0.7)
            multiplier = 0.9099690 + mach*(-1.9017100 + mach*1.21524000);
        else
            multiplier = 0.2302760 + mach*(0.000210564 - mach*0.1275050);
    } else if ([self.drag_model isEqualToString:@"G5"]) {
        if (mach > 2.0)
            multiplier = 0.671388 + mach*(-0.185208 + mach*0.0204508);
        else if (mach > 1.1)
            multiplier = 0.134374 + mach*(0.4378330 - mach*0.1570190);
        else if (mach > 0.9)
            multiplier = -0.924258 + mach*1.24904;
        else if (mach >= 0.6)
            multiplier = 0.654405 + mach*(-1.4275000 + mach*0.998463);
        else
            multiplier = 0.186386 + mach*(-0.0342136 - mach*0.035691);
    } else if ([self.drag_model isEqualToString:@"G6"]) {
        if (mach > 2.0)
            multiplier = 0.746228 + mach*(-0.255926 + mach*0.0291726);
        else if (mach > 1.1)
            multiplier = 0.513638 + mach*(-0.015269 - mach*0.0331221);
        else if (mach > 0.9)
            multiplier = -0.908802 + mach*1.25814;
        else if (mach >= 0.6)
            multiplier = 0.366723 + mach*(-0.458435 + mach*0.337906);
        else
            multiplier = 0.264481 + mach*(-0.157237 + mach*0.117441);
    } else if ([self.drag_model isEqualToString:@"G7"]) {
        if (mach > 1.9)
            multiplier = 0.439493 + mach*(-0.0793543 + mach*0.00448477);
        else if (mach > 1.05)
            multiplier = 0.642743 + mach*(-0.2725450 + mach*0.049247500);
        else if (mach > 0.90)
            multiplier = -1.69655 + mach*2.03557;
        else if (mach >= 0.60)
            multiplier = 0.353384 + mach*(-0.69240600 + mach*0.50946900);
        else
            multiplier = 0.119775 + mach*(-0.00231118 + mach*0.00286712);
    } else if ([self.drag_model isEqualToString:@"G8"]) {
        if (mach > 1.1)
            multiplier = 0.639096 + mach*(-0.197471 + mach*0.0216221);
        else if (mach >= 0.925)
            multiplier = -12.9053 + mach*(24.9181 - mach*11.6191);
        else
            multiplier = 0.210589 + mach*(-0.00184895 + mach*0.00211107);
    } else if ([self.drag_model isEqualToString:@"Gl"]) {
        if (mach > 1.0)
            multiplier = 0.286629 + mach*(0.3588930 - mach*0.0610598);
        else if (mach >= 0.8)
            multiplier = 1.59969 + mach*(-3.9465500 + mach*2.831370);
        else
            multiplier = 0.333118 + mach*(-0.498448 + mach*0.474774);
    } else if ([self.drag_model isEqualToString:@"Gi"]) {
        if (mach > 1.65)
            multiplier = 0.845362 + mach*(-0.143989 + mach*0.0113272);
        else if (mach > 1.2)
            multiplier = 0.630556 + mach*0.00701308;
        else if (mach >= 0.7)
            multiplier = 0.531976 + mach*(-1.28079 + mach*1.17628);
        else
            multiplier = 0.2282;
    }
    
    return (multiplier * 0.267978) / [self ballisticCoefficientWithVelocity:velocity];
}

@end