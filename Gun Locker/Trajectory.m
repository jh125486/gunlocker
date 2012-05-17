//
//  Trajectory.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Trajectory.h"

@implementation Trajectory

@synthesize pressureInhg = _pressureInhg, relativeHumidity = _relativeHumidity, tempC = _tempC, altitudeM = _altitudeM;
@synthesize rangeEnd = _rangeEnd, rangeStart = _rangeStart, rangeStep = _rangeStep;
@synthesize leadSpeed = _leadSpeed, leadAngle = _leadAngle, windSpeed = _windSpeed, windAngle = _windAngle, shootingAngle = _shootingAngle;
@synthesize ranges = _ranges, ballisticProfile = _ballisticProfile, setupCompleted = _setupCompleted;

-(id)init {
    if (self = [super init]) {
        _setupCompleted = FALSE;
    }
    return self;
}

-(void)setup {
    gravity = METERS_to_FEET([self gravityFromAltitudeInMeters:_altitudeM]);
    sectionalArea = [self calculateSectionalArea];
    airDensity = [self airDensity];
    xAtZero = [_ballisticProfile.zero doubleValue];
    bulletMass = [self bulletMass];
    yInitial = -INCHES_to_FEET([_ballisticProfile.sight_height_inches doubleValue]);
    vInitial = [_ballisticProfile.muzzle_velocity doubleValue];
    speedOfSound = [self calculateSpeedOfSoundInFeet];
    windXSpeed = MPH_to_FPS(cos(DEGREES_to_RAD(_windAngle)) * _windSpeed);
    
    // wind from rear doesn't affect bullet as much
    // probably should be developed from sectional area
    if (windXSpeed > 0) windXSpeed *= 0.25;
    
    windZSpeed = MPH_to_FPS(sin(DEGREES_to_RAD(_windAngle)) * _windSpeed);
    if (!_ballisticProfile.zero_theta) {[_ballisticProfile calculateTheta]; NSLog(@"Trajectory: had to calculate theta angle");}
    
    _setupCompleted = YES;
}

-(void)calculateTrajectory {
    if(!_setupCompleted) [self setup];

    double t = 0;
    double dt = 0.5 / vInitial;

    double v  = vInitial;
    double vx = vInitial * cos([_ballisticProfile.zero_theta doubleValue]);
    double vy = vInitial * sin([_ballisticProfile.zero_theta doubleValue]);
    double vx1 = 0, vy1 = 0;

    double dv  = 0, dvx = 0, dvy = 0;

    double x   = 0;
    double y   = yInitial;
	double z   = 0;
	double dropMOA = 0, driftMOA = 0;
	
    double gx = gravity * sin(DEGREES_to_RAD(_shootingAngle) + [_ballisticProfile.zero_theta doubleValue]);
    double gy = gravity * cos(DEGREES_to_RAD(_shootingAngle) + [_ballisticProfile.zero_theta doubleValue]);

    self.ranges = [[NSMutableArray alloc] initWithCapacity:_rangeEnd];

    int n = self.rangeStart;
    while (n <= self.rangeEnd) { // stop at max range yards
        vx1 = vx;
        vy1 = vy;
        v = VECTOR_LENGTH(vx, vy);
        dt = 0.5 / v;
        
        // Compute acceleration using the drag function retardation	
        dv =  [_ballisticProfile getBCWithSpeedOfSound:speedOfSound andVelocity: v - 1.5*windXSpeed];
        dv += [self extraDragRetardationWithVelocity: v];
        dvx = -(vx/v)*dv;
        dvy = -(vy/v)*dv;
    
        // Compute velocity, including the resolved gravity vectors 
        vx += dt*dvx + dt*gx + dt*0.5*windXSpeed;
        vy += dt*dvy + dt*gy;
    
        t += dt;
        
        if (FEET_to_YARDS(x) >= n) {            
            if ((lround(x) % _rangeStep) == 0) {
                TrajectoryRange *range = [[TrajectoryRange alloc] init];
                
                // equation 5.2 Litz
                z = windZSpeed * (t - (x/vInitial));
                //        drift = windage +-  lead  which is [NSNumber numberWithDouble:(sin(t)*self.lead_angle*self.lead_speed)];
                // leadXSpeed should be factored into distance travelled: x = dt * (vx + vx1 + leadXSpeed)/2.0  --> same for y = on line 117
                // add in SpinDrift 1.25*(SG + 1.2)* pow(t, 1.83)
                dropMOA  = RAD_to_MOA(atan2(y, x));
                driftMOA = RAD_to_MOA(atan2(z, x)); 
                range.range_yards   = [NSString stringWithFormat:@"%.0f", FEET_to_YARDS(x)];
                range.range_m       = [NSString stringWithFormat:@"%.0f", FEET_to_METERS(x)];
                range.drop_inches   = [NSString stringWithFormat:@"%.1f", FEET_to_INCHES(y)];
                range.drop_moa      = [NSString stringWithFormat:@"%.1f", dropMOA];
                range.drop_mils     = [NSString stringWithFormat:@"%.1f", MOA_to_MIL(dropMOA)];
                range.drift_inches  = [NSString stringWithFormat:@"%.1f", FEET_to_INCHES(z)];
                range.drift_moa     = [NSString stringWithFormat:@"%.1f", driftMOA];
                range.drift_mils    = [NSString stringWithFormat:@"%.1f", MOA_to_MIL(driftMOA)];
                range.velocity_fps  = [NSString stringWithFormat:@"%.1f", v];
                range.energy_ftlbs  = [NSString stringWithFormat:@"%.0f", [self energyAtVelocity:v]];
                range.time          = [NSString stringWithFormat:@"%.3f", t];

                [_ranges addObject:range];
             }
			n++;
		}
            
		// Compute position based on average velocity.
		x += dt * (vx + vx1)/2.0;
		y += dt * (vy + vy1)/2.0;
    
		// break if vertical velocity 3 times greater than horizontal velocity 
		if (fabs(vy) > fabs(3 * vx)) break; 
	}
}

// adjusted extra drag retardation to match jbm as close as possible
-(double)extraDragRetardationWithVelocity:(double)v {
    return (airDensity * sectionalArea / (4*bulletMass)) * v * pow(vInitial/v, 4) * pow(v/speedOfSound, 2.5);
}

-(double)airDensity {
    return [Weather airDensityFromTempC:_tempC andRH:_relativeHumidity andPressurePa:INHG_to_PA(_pressureInhg)];
}

-(double)bulletMass {
   return [self.ballisticProfile.bullet_weight doubleValue] / 7000.0;
}

-(double)calculateSectionalArea {
    return (M_PI_4) * pow(INCHES_to_FEET([_ballisticProfile.bullet_diameter_inches doubleValue]), 2);
}

-(double)gravityFromAltitudeInMeters:(double)altitude {
    return -3.99165757811945e+14 / pow(6.38e+6 + altitude, 2);
}

-(double)energyAtVelocity:(float)v {
    return 0.5 * (bulletMass /-gravity) * pow(v, 2);
}

-(double)calculateSpeedOfSoundInFeet {
    return METERS_to_FEET([Weather calculateSpeedOfSoundFromTempC:_tempC andRH:_relativeHumidity andPressurePa:INHG_to_PA(_pressureInhg)]);
}

-(double)gravityY {
    return gravity * cos(DEGREES_to_RAD((_shootingAngle + [_ballisticProfile.zero_theta doubleValue])));
}

-(double)gravityX {
    return gravity * sin(DEGREES_to_RAD((_shootingAngle + [_ballisticProfile.zero_theta doubleValue])));
}


@end
