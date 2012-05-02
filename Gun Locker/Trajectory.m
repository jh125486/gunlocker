//
//  Trajectory.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Trajectory.h"

@implementation Trajectory

@synthesize pressureInhg;
@synthesize relativeHumidity;
@synthesize tempC;
@synthesize altitudeM;
@synthesize rangeIncrement;
@synthesize rangeMax;
@synthesize rangeMin;
@synthesize leadSpeed;
@synthesize leadAngle;
@synthesize windSpeed;
@synthesize windAngle;
@synthesize ranges;
@synthesize thetaInitial;
@synthesize ballisticProfile;

-(id)init {
    if (self = [super init]) {
        // Initialization code here
    }
    return self;
}

-(NSNumber*)energyAtVelocity:(float)v {
    return [NSNumber numberWithDouble:0.5 * (([self.ballisticProfile.bullet_weight intValue]/7000) /(-gravity)) * pow(v, 2)]; 
}

-(void)calculateTrajectory {
    yAtScope = INCHES_to_FEET([self.ballisticProfile.sight_height_inches doubleValue]);
    vInitial = [self.ballisticProfile.muzzle_velocity doubleValue];
    windXspeed = cos(self.windAngle * (M_PI/180)) * self.windSpeed * 5280/3600.0;
    windZSpeed = sin(self.windAngle * (M_PI/180)) * self.windSpeed * 5280 / 3600.0;
    leadZSpeed = sin(self.leadAngle * (M_PI/180)) * self.leadSpeed * 5280 / 3600.0;
    gravity = METERS_to_FEET([self.class gravityFromAltitudeM:altitudeM]);
    mass = [self.ballisticProfile.bullet_weight doubleValue] / 7000;
    sectionalArea = (M_PI / 4) * pow([self.ballisticProfile.bullet_diameter_inches doubleValue] / 12, 2);

    speedOfSound = METERS_to_FEET([Weather calculateSpeedOfSoundFromTempC:self.tempC 
                                                                    andRH:self.relativeHumidity 
                                                            andPressurePa:INHG_to_PA(self.pressureInhg)]);
    airDensity = [Weather airDensityFromTempC:self.tempC 
                                        andRH:self.relativeHumidity 
                                andPressurePa:INHG_to_PA(self.pressureInhg)];

    xAtZero = [self.ballisticProfile.zero doubleValue];
    
    k = [self.ballisticProfile getBCWithSpeedOfSound:speedOfSound andVelocity:vInitial];
    vInitial = vInitial + (k * windXspeed);
    NSLog(@"k %f\tS %f", k, sectionalArea);
    vAtZero = pow((sqrt(vInitial) - (0.5 * (airDensity * sectionalArea * k * sqrt(speedOfSound) / (2*mass)) * (YARDS_to_FEET((xAtZero))))), 2);
    NSLog(@"Mass: %f\tSectionArea: %f\tairDensity:%f\tspeedOfSound:%f\tvAtZero: %.1f", mass, sectionalArea, airDensity, speedOfSound, vAtZero);
    tAtZero = (YARDS_to_FEET(xAtZero) / vInitial) * sqrt(vInitial / vAtZero);
    self.thetaInitial = atan((yAtScope + (0.5 * -gravity * pow(tAtZero, 2) * ((1.0/3)*(1+(2*sqrt(vAtZero/vInitial)))))) / YARDS_to_FEET(xAtZero));
    NSLog(@"Theta initial %f", self.thetaInitial);
    
    vAtX = vInitial;
    self.ranges = [[NSMutableArray alloc] init];
    for (int x = self.rangeMin; x <= self.rangeMax; x += self.rangeIncrement) {
//        c = [self.ballisticProfile getBCWithSpeedOfSound:speedOfSound andVelocity:vInitial];
        k = [self.ballisticProfile getBCWithSpeedOfSound:speedOfSound andVelocity:vAtX];
        TrajectoryRange *range = [[TrajectoryRange alloc] init];
        
        vAtX = pow((sqrt(vInitial) - (0.5 * (airDensity * sectionalArea * k * sqrt(speedOfSound) / (2*mass)) * (YARDS_to_FEET(x)))), 2);
        tAtX = (YARDS_to_FEET(x) / vInitial) * sqrt(vInitial / vAtX);
        yAtX = -yAtScope + (YARDS_to_FEET(x) * tan(thetaInitial)) - (0.5 * -gravity * pow(tAtX, 2)*((1.0/3)*(1+(2*sqrt(vAtX/vInitial)))));
        
        // equation 5.2 Litz
        double zAtX = windZSpeed * (tAtX - (YARDS_to_FEET(x)/vInitial));
//        NSLog(@"speed: %f\tlead inches: %.1f", leadZSpeed, leadZSpeed * tAtX * 12);
        //        drift = windage +-  lead  which is [NSNumber numberWithDouble:(sin(t)*self.lead_angle*self.lead_speed)];
        double dropMOA = (atan2(yAtX, YARDS_to_FEET(x)) * (180 / M_PI)) * 60.0;
        double driftMOA = (atan2(zAtX, YARDS_to_FEET(x)) * (180 / M_PI)) * 60.0; 
        range.range_yards   = [NSString stringWithFormat:@"%d", x];
        range.range_m       = [NSString stringWithFormat:@"%.0f", x/YARDS_PER_METER];
        range.drop_inches   = [NSString stringWithFormat:@"%.1f", FEET_to_INCHES(yAtX)];
        range.drop_moa      = [NSString stringWithFormat:@"%.1f", dropMOA];
        range.drop_mils     = [NSString stringWithFormat:@"%.1f", MOA_to_MIL(dropMOA)];
        range.drift_inches  = [NSString stringWithFormat:@"%.1f", FEET_to_INCHES(zAtX)];
        range.drift_moa     = [NSString stringWithFormat:@"%.1f", driftMOA];
        range.drift_mils    = [NSString stringWithFormat:@"%.1f", MOA_to_MIL(driftMOA)];
        range.velocity_fps  = [NSString stringWithFormat:@"%.0f", vAtX];
        range.energy_ftlbs  = [NSString stringWithFormat:@"%.0f", 0.5 * ((mass) / (-gravity)) * pow(vAtX, 2)];
        range.time          = [NSString stringWithFormat:@"%.3f", tAtX];

        [self.ranges addObject:range];
        
//        NSLog(@"%@", [NSString stringWithFormat:@"%d\t%0.1f\t%0.1f\t%0.1f\t%0.1f\t\t%0.3f\t%0.1f\t%0.3f", x, FEET_to_INCHES(yAtX), dropMOA, dropMILs, vAtX, (vAtX/speedOfSound), [range.energy_ftlbs doubleValue], tAtX]);        
    }    
}

-(void)calculateThetaAngle {
    
    
    
    //set all static variables to retain, so that drop/drift can be calculated on the fly for a range (ie during whizwheel)
    
    
//    self.thetaAngle = atan((yAtScope + (0.5 * -gravity * pow(tAtZero, 2) * ((1.0/3)*(1+(2*sqrt(vAtZero/vInitial)))))) / YARDS_to_FEET(xAtZero));

}

+(double)gravityFromAltitudeM:(double)altitudeM {
    return -3.99165757811945e+14 / pow(6.38e+6 + altitudeM, 2);
}

@end
