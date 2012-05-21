//
//  exponentodel+Helpers.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/12/12.
//  Copyright (c) 2012 __exponentyCompanyName__. multiplierll rights reserved.
//

#import <Model+Helpers.h>

@implementation Weapon (helper)
-(NSString *)description {
    NSMutableString *description = [[NSString stringWithFormat:@"%@ %@", self.manufacturer.displayName, self.model] mutableCopy];
    if (self.barrel_length) [description appendFormat:@" (%@\")", self.barrel_length];
    
    return [NSString stringWithString:description];
}

-(NSString *)indexLetter {
    return [self.manufacturer.displayName substringToIndex:1];
}

- (NSComparisonResult)compare:(Weapon *)otherObject {
    return [self.description compare:otherObject.description];
}
@end

@implementation Manufacturer (helper)
-(NSString *)displayName {
    return self.short_name ? self.short_name : self.name;
}
@end


@implementation BallisticProfile (helper)

-(void)calculateTheta{
    int vInitial = [self.muzzle_velocity integerValue];
    double yInitial = -INCHES_to_FEET([self.sight_height_inches doubleValue]);
    double gravity = -32.174;

    // Numerical Integration variables
    double t = 0.0;
    double dt = 0.0; // The solution accuracy generally doesn't suffer if its within a foot for each second of time.
    double y=0.0, x=0.0;
    
    // State variables for each integration loop.
    double v=0.0, vx=0.0, vy=0.0; // velocity
    
    double vx1=0, vy1=0;// Last frame's velocity, used for computing average velocity.
    
    double dv=0.0, dvx=0.0, dvy=0.0; // acceleration
    double gx=0.0, gy=0.0; // Gravitational acceleration
    double theta = 0.0; // The actual angle of the bore.
    double zero = YARDS_to_FEET([self.zero doubleValue]);
    
    BOOL thetaFound = FALSE; // We know it's time to quit our successive approximation loop when this is true.
    
    /* The change in the bore angle used to iterate in on the correct zero angle.
     Start with a very coarse angular change, to quickly solve even large launch angle problems. */
    double dtheta = DEGREES_to_RAD(5);
    
    /* The general idea here is to start at 0 degrees elevation, and increase the elevation by 14 degrees until we are above the correct elevation. Then reduce the angular change by half, and begin reducing the angle.  Once we are again below the correct angle, reduce the angular change by half again, and go back up.  This allows for a fast successive approximation of the correct elevation, usually within less than 20 iterations.    */
    while(!thetaFound) {
        vy = vInitial * sin(theta);
        vx = vInitial * cos(theta);
        gx = gravity * sin(theta);
        gy = gravity * cos(theta);
        
        t = 0.0;
        x = 0.0;
        y = yInitial;
        while (x <= zero) {
            vy1 = vy;
            vx1 = vx;
            v = VECTOR_LENGTH(vx, vy);
            dt=1.0/v;
            
            dv =  [self getBCWithSpeedOfSound:1116.45 andVelocity:v];
            dv += [self extraDragRetardationWithVelocity:v];
            dvy = -dv*vy/v*dt;
            dvx = -dv*vx/v*dt;
            
            vx += dvx;
            vy += dvy;
            vy += dt*gy;
            vx += dt*gx;
            
            x += dt * (vx + vx1)/2.0;
            y += dt * (vy + vy1)/2.0;
            
            // Break early to save CPU time if there is no solution
            if ((vy < 0 && y < 0) || (vy > (3 * vx))) break;
            
            t += dt;
        }
        
        if ((y > 0 && dtheta > 0) || (y < 0 && dtheta < 0))
            dtheta = -dtheta/2;
        
        // stop approximating or exceed the 45 degree launch angle
        if ((fabs(dtheta) < MOA_to_RAD(0.001))  || (theta > DEGREES_to_RAD(45))) thetaFound = TRUE;
        
        theta += dtheta;
    }
    self.zero_theta = [NSNumber numberWithDouble:theta]; // angle in radians
    NSLog(@"zero theta angle: %f Rads\t%fº\t%f MOA", theta, RAD_to_DEGREES(theta), RAD_to_MOA(theta));
}

-(double)ballisticCoefficientWithVelocity:(double)velocity {
    NSArray *bc = self.bullet_bc;
    double value = [(NSDecimalNumber *)[bc objectAtIndex:0] doubleValue];

    for (int i = 1; i < bc.count; i += 2) {
        if ([(NSDecimalNumber *)[bc objectAtIndex:i + 1] doubleValue] < velocity) break;
        value = [(NSDecimalNumber *)[bc objectAtIndex:i] doubleValue];
    }
    return value;
}

-(double)getBCWithSpeedOfSound:(double)speed andVelocity:(double)velocity{
//    double mach = velocity / speed;
        
    double multiplier = -1;
    double exponent   = -1;
    if ([self.drag_model isEqualToString:@"G1"]) { 
        if      (velocity > 4230) {multiplier = 1.477404177730177e-04; exponent = 1.9565;}
        else if (velocity > 3680) {multiplier = 1.920339268755614e-04; exponent = 1.925 ;}
        else if (velocity > 3450) {multiplier = 2.894751026819746e-04; exponent = 1.875 ;}
        else if (velocity > 3295) {multiplier = 4.349905111115636e-04; exponent = 1.825 ;}
        else if (velocity > 3130) {multiplier = 6.520421871892662e-04; exponent = 1.775 ;}
        else if (velocity > 2960) {multiplier = 9.748073694078696e-04; exponent = 1.725 ;}
        else if (velocity > 2830) {multiplier = 1.453721560187286e-03; exponent = 1.675 ;}
        else if (velocity > 2680) {multiplier = 2.162887202930376e-03; exponent = 1.625 ;}
        else if (velocity > 2460) {multiplier = 3.209559783129881e-03; exponent = 1.575 ;}
        else if (velocity > 2225) {multiplier = 3.904368218691249e-03; exponent = 1.55  ;}
        else if (velocity > 2015) {multiplier = 3.222942271262336e-03; exponent = 1.575 ;}
        else if (velocity > 1890) {multiplier = 2.203329542297809e-03; exponent = 1.625 ;}
        else if (velocity > 1810) {multiplier = 1.511001028891904e-03; exponent = 1.675 ;}
        else if (velocity > 1730) {multiplier = 8.609957592468259e-04; exponent = 1.75  ;}
        else if (velocity > 1595) {multiplier = 4.086146797305117e-04; exponent = 1.85  ;}
        else if (velocity > 1520) {multiplier = 1.954473210037398e-04; exponent = 1.95  ;}
        else if (velocity > 1420) {multiplier = 5.431896266462351e-05; exponent = 2.125 ;}
        else if (velocity > 1360) {multiplier = 8.847742581674416e-06; exponent = 2.375 ;}
        else if (velocity > 1315) {multiplier = 1.456922328720298e-06; exponent = 2.625 ;}
        else if (velocity > 1280) {multiplier = 2.419485191895565e-07; exponent = 2.875 ;}
        else if (velocity > 1220) {multiplier = 1.657956321067612e-08; exponent = 3.25  ;}
        else if (velocity > 1185) {multiplier = 4.745469537157371e-10; exponent = 3.75  ;}
        else if (velocity > 1150) {multiplier = 1.379746590025088e-11; exponent = 4.25  ;}
        else if (velocity > 1100) {multiplier = 4.070157961147882e-13; exponent = 4.75  ;}
        else if (velocity > 1060) {multiplier = 2.938236954847331e-14; exponent = 5.125 ;}
        else if (velocity > 1025) {multiplier = 1.228597370774746e-14; exponent = 5.25  ;}
        else if (velocity >  980) {multiplier = 2.916938264100495e-14; exponent = 5.125 ;}
        else if (velocity >  945) {multiplier = 3.855099424807451e-13; exponent = 4.75  ;}
        else if (velocity >  905) {multiplier = 1.185097045689854e-11; exponent = 4.25  ;}
        else if (velocity >  860) {multiplier = 3.566129470974951e-10; exponent = 3.75  ;}
        else if (velocity >  810) {multiplier = 1.045513263966272e-08; exponent = 3.25  ;}
        else if (velocity >  780) {multiplier = 1.291159200846216e-07; exponent = 2.875 ;}
        else if (velocity >  750) {multiplier = 6.824429329105383e-07; exponent = 2.625 ;}
        else if (velocity >  700) {multiplier = 3.569169672385163e-06; exponent = 2.375 ;}
        else if (velocity >  640) {multiplier = 1.839015095899579e-05; exponent = 2.125 ;}
        else if (velocity >  600) {multiplier = 5.71117468873424e-05 ; exponent = 1.950 ;}
        else if (velocity >  550) {multiplier = 9.226557091973427e-05; exponent = 1.875 ;}
        else if (velocity >  250) {multiplier = 9.337991957131389e-05; exponent = 1.875 ;}
        else if (velocity >  100) {multiplier = 7.225247327590413e-05; exponent = 1.925 ;}
        else if (velocity >   65) {multiplier = 5.792684957074546e-05; exponent = 1.975 ;}
        else if (velocity >    0) {multiplier = 5.206214107320588e-05; exponent = 2.000 ;}
    } else if ([self.drag_model isEqualToString:@"G2"]) {
        if      (velocity > 1674) {multiplier = .0079470052136733   ;  exponent = 1.36999902851493;}
        else if (velocity > 1172) {multiplier = 1.00419763721974e-03;  exponent = 1.65392237010294;}
        else if (velocity > 1060) {multiplier = 7.15571228255369e-23;  exponent = 7.91913562392361;}
        else if (velocity >  949) {multiplier = 1.39589807205091e-10;  exponent = 3.81439537623717;}
        else if (velocity >  670) {multiplier = 2.34364342818625e-04;  exponent = 1.71869536324748;}
        else if (velocity >  335) {multiplier = 1.77962438921838e-04;  exponent = 1.76877550388679;}
        else if (velocity >    0) {multiplier = 5.18033561289704e-05;  exponent = 1.98160270524632;}
    } else if ([self.drag_model isEqualToString:@"G5"]) {
        if      (velocity > 1730) {multiplier = 7.24854775171929e-03; exponent = 1.41538574492812;}
        else if (velocity > 1228) {multiplier = 3.50563361516117e-05; exponent = 2.13077307854948;}
        else if (velocity > 1116) {multiplier = 1.84029481181151e-13; exponent = 4.81927320350395;}
        else if (velocity > 1004) {multiplier = 1.34713064017409e-22; exponent = 7.8100555281422 ;}
        else if (velocity >  837) {multiplier = 1.03965974081168e-07; exponent = 2.84204791809926;}
        else if (velocity >  335) {multiplier = 1.09301593869823e-04; exponent = 1.81096361579504;}
        else if (velocity >    0) {multiplier = 3.51963178524273e-05; exponent = 2.00477856801111;}	
    } else if ([self.drag_model isEqualToString:@"G6"]) {
        if      (velocity > 3236) {multiplier = 0.0455384883480781   ; exponent = 1.15997674041274;}
        else if (velocity > 2065) {multiplier = 7.167261849653769e-02; exponent = 1.10704436538885;}
        else if (velocity > 1311) {multiplier = 1.66676386084348e-03 ; exponent = 1.60085100195952;}
        else if (velocity > 1144) {multiplier = 1.01482730119215e-07 ; exponent = 2.9569674731838 ;}
        else if (velocity > 1004) {multiplier = 4.31542773103552e-18 ; exponent = 6.34106317069757;}
        else if (velocity >  670) {multiplier = 2.04835650496866e-05 ; exponent = 2.11688446325998;}
        else if (velocity >    0) {multiplier = 7.50912466084823e-05 ; exponent = 1.92031057847052;}
    } else if ([self.drag_model isEqualToString:@"G7"]) {
		if      (velocity > 4200) {multiplier = 1.29081656775919e-09; exponent = 3.24121295355962;}
		else if (velocity > 3000) {multiplier = 0.0171422231434847  ; exponent = 1.27907168025204;}
		else if (velocity > 1470) {multiplier = 2.33355948302505e-03; exponent = 1.52693913274526;}
		else if (velocity > 1260) {multiplier = 7.97592111627665e-04; exponent = 1.67688974440324;}
		else if (velocity > 1110) {multiplier = 5.71086414289273e-12; exponent = 4.3212826264889 ;}
		else if (velocity >  960) {multiplier = 3.02865108244904e-17; exponent = 5.99074203776707;}
		else if (velocity >  670) {multiplier = 7.52285155782535e-06; exponent = 2.1738019851075 ;}
		else if (velocity >  540) {multiplier = 1.31766281225189e-05; exponent = 2.08774690257991;}
		else if (velocity >    0) {multiplier = 1.34504843776525e-05; exponent = 2.08702306738884;}
    } else if ([self.drag_model isEqualToString:@"G8"]) {
		if      (velocity > 3571) {multiplier = .0112263766252305   ; exponent = 1.33207346655961;}
		else if (velocity > 1841) {multiplier = .0167252613732636   ; exponent = 1.28662041261785;}
		else if (velocity > 1120) {multiplier = 2.20172456619625e-03; exponent = 1.55636358091189;}
		else if (velocity > 1088) {multiplier = 2.0538037167098e-16 ; exponent = 5.80410776994789;}
		else if (velocity >  976) {multiplier = 5.92182174254121e-12; exponent = 4.29275576134191;}
		else if (velocity >    0) {multiplier = 4.3917343795117e-05 ; exponent = 1.99978116283334;}
	}
        
    if (multiplier!=-1 && exponent!=-1 && velocity>0 && velocity<10000){
        return multiplier * pow(velocity, exponent) / [self ballisticCoefficientWithVelocity:velocity];
    }
    else return -1;
}

-(double)extraDragRetardationWithVelocity:(double)v {
    return (0.07647 * (M_PI_4) * pow(INCHES_to_FEET([self.bullet_diameter_inches doubleValue]), 2) / (4*[self.bullet_weight doubleValue]/7000.0)) * v * pow([self.muzzle_velocity intValue]/v, 4) * pow(v/1116.45, 2.5);
}

@end

@implementation Bullet (helper)

- (NSString *)description {
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:@"%@ %@", self.brand, self.name];
    if (![self.brand isEqualToString:self.category]) [description appendFormat:@" (%@)", self.category];

    return [NSString stringWithString:description];    
}

+(NSString *)bcToString:(NSArray*)bc {
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"BC: %@", [bc objectAtIndex:0]];
    for (int i = 1; i < bc.count; i += 2) 
        [bcText appendFormat:@"/%@", [bc objectAtIndex:i]];
    
    return [NSString stringWithString:bcText];
}

@end

@implementation Maintenance (helper)
-(NSString *)dateAgoInWords {
    [self willAccessValueForKey:@"date"];
    NSString *distance = [[self date] distanceOfTimeInWords];
    [self didAccessValueForKey:@"date"];
    return distance;
}

-(NSString*)indexForCollation {
    return self.weapon.indexLetter;
}
@end

@implementation Malfunction (helper)
-(NSString *)dateAgoInWords {
    [self willAccessValueForKey:@"date"];
    NSString *distance = [[self date] distanceOfTimeInWords];
    [self didAccessValueForKey:@"date"];
    return distance;
}
@end

@implementation NSString (helper)
-(int)lengthAfterDecimal {
    NSArray *components = [self componentsSeparatedByString:@"."];
    if ([components count] == 1) {
        return 0;
    } else {
        return [[components objectAtIndex:1] length];
    }
}
@end
