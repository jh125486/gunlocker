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
@synthesize rangeUnit = _rangeUnit, rangeStart = _rangeStart, rangeEnd = _rangeEnd, rangeStep = _rangeStep;
@synthesize targetSpeed = _leadSpeed, targetAngle = _leadAngle, windSpeed = _windSpeed, windAngle = _windAngle, shootingAngle = _shootingAngle;
@synthesize ranges = _ranges, ballisticProfile = _ballisticProfile, setupCompleted = _setupCompleted;

-(id)init {
    if (self = [super init]) {
        _setupCompleted = FALSE;
    }
    return self;
}

#pragma mark Setup

-(void)setup {
    gravity = METERS_to_FEET([self gravityFromAltitudeInMeters:_altitudeM]);
    sectionalArea = [self calculateSectionalArea];
    airDensity = [self airDensity];
    xAtZero = [_ballisticProfile.zero doubleValue];
    bulletMass = [self bulletMass];
    yInitial = -INCHES_to_FEET([_ballisticProfile.sight_height_inches doubleValue]);
    vInitial = [_ballisticProfile.muzzle_velocity doubleValue];
    speedOfSound = [self calculateSpeedOfSoundInFeet];
        
    if (!_ballisticProfile.zero_theta) {[_ballisticProfile calculateTheta]; DebugLog(@"Trajectory: had to calculate theta angle");}
    
    _setupCompleted = YES;
}

- (void)setupWindAndLeading {
    windXSpeed = -MPH_to_FPS(cos(DEGREES_to_RAD(_windAngle)) * _windSpeed);
    // wind from rear doesn't affect bullet as much
    // probably should be developed from sectional area
    if (windXSpeed > 0) windXSpeed *= 0.25;
    
    windZSpeed = -MPH_to_FPS(sin(DEGREES_to_RAD(_windAngle)) * _windSpeed);
    
    leadXSpeed = MPH_to_FPS(cos(DEGREES_to_RAD(_leadAngle)) * _leadSpeed);
    leadZSpeed = MPH_to_FPS(sin(DEGREES_to_RAD(_leadAngle)) * _leadSpeed);
}

#pragma mark Calculate
-(void)calculateTrajectory {
    if(!_setupCompleted) [self setup];

    double testLeadZ =0.0, testLeadX =0.0;
    
    double t = 0.0;
    double dt = 0.0;

    double v  = vInitial;
    double vx = v * cos([_ballisticProfile.zero_theta doubleValue]);
    double vy = v * sin([_ballisticProfile.zero_theta doubleValue]);
    double vx1 = 0.0, vy1 = 0.0;

    double dv  = 0.0, dvx = 0.0, dvy = 0.0;

    double x   = 0.0;
    double y   = yInitial;
	double z   = 0.0;
    double xInRangeUnit;
    double spinDrift = 1.25 * ([_ballisticProfile.sg doubleValue] + 1.2);
    double spinDriftDirection = [_ballisticProfile.sg_twist_direction isEqualToString:@"RH"] ? 1 : -1;
	
    double gx = gravity * sin(DEGREES_to_RAD(_shootingAngle) + [_ballisticProfile.zero_theta doubleValue]);
    double gy = gravity * cos(DEGREES_to_RAD(_shootingAngle) + [_ballisticProfile.zero_theta doubleValue]);

    _ranges = [[NSMutableArray alloc] initWithCapacity:_rangeEnd];

    int n = _rangeStart;
    while (n <= _rangeEnd) { // stop at max range yards
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
        
        xInRangeUnit = (_rangeUnit == 0) ? FEET_to_YARDS(x) : FEET_to_METERS(x);
        
        if (xInRangeUnit >= n) {            
            if ((lround(xInRangeUnit) % _rangeStep) == 0) {
                TrajectoryRange *range = [[TrajectoryRange alloc] init];
                
                range.range = xInRangeUnit;
                
                range.drop_inches   = FEET_to_INCHES(y);        
                range.drop_moa      = RAD_to_MOA(atan2(y, x));
                range.drop_mils     = MOA_to_MIL(range.drop_moa);
                
                range.drift_inches  = FEET_to_INCHES(z);
                range.drift_moa     = RAD_to_MOA(atan2(z, x));
                range.drift_mils    = MOA_to_MIL(range.drift_moa);
                
                range.velocity_fps  = v;
                range.energy_ftlbs  = [self energyAtVelocity:v];
                range.time          = t;

                [_ranges addObject:range];
             }
			n++;
		}

        // equation 5.2 Litz
        z = windZSpeed * (t - (x/vInitial));
        
        // equation 6.1 Litz
        // SpinDrift is inches 1.25*(SG + 1.2)* pow(t, 1.83)    [rh twist is positive z in inches, lh is negative]
        z += INCHES_to_FEET(spinDrift * pow(t, 1.83) * spinDriftDirection);
        
        // leading target
        z -= leadZSpeed * t;
        x -= leadXSpeed * dt; // leadXSpeed factored into distance travelled
        
		// Compute position based on average velocity.
        x += dt * (vx + vx1)/2.0;
		y += dt * (vy + vy1)/2.0;

        
        //TESTING
        testLeadZ += leadZSpeed * dt;
        testLeadX += leadXSpeed * dt;
        
        
		// break if vertical velocity 3 times greater than horizontal velocity 
		if (fabs(vy) > fabs(3.0 * vx)) break; 
	}
    
    DebugLog(@"Total Z travelled: %g\"\tTotal X travelled: %g\"  speedZ: %g", testLeadZ*12, testLeadX*12, leadZSpeed);
}

# pragma mark helpers
// adjusted extra drag retardation to match jbm as close as possible
-(double)extraDragRetardationWithVelocity:(double)v {
    return (airDensity * sectionalArea / (4*bulletMass)) * v * pow(vInitial/v, 4.0) * pow(v/speedOfSound, 2.5);
}

-(double)airDensity {
    return [Weather airDensityFromTempC:_tempC andRH:_relativeHumidity andPressurePa:INHG_to_PA(_pressureInhg)];
}

-(double)bulletMass {
   return [_ballisticProfile.bullet_weight doubleValue] / 7000.0;
}

-(double)calculateSectionalArea {
    return (M_PI_4) * pow(INCHES_to_FEET([_ballisticProfile.bullet_diameter_inches doubleValue]), 2.0);
}

-(double)gravityFromAltitudeInMeters:(double)altitude {
    return -3.99165757811945e+14 / pow(6.38e+6 + altitude, 2.0);
}

-(double)energyAtVelocity:(float)v {
    return 0.5 * (bulletMass /-gravity) * pow(v, 2.0);
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
