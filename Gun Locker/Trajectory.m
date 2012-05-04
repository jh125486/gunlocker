//
//  Trajectory.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Trajectory.h"

@implementation Trajectory

@synthesize pressureInhg, relativeHumidity, tempC, altitudeM;
@synthesize rangeMax, rangeMin, rangeIncrement;
@synthesize leadSpeed, leadAngle, windSpeed, windAngle, shootingAngle;
@synthesize ranges, ballisticProfile, setupCompleted;

-(id)init {
    if (self = [super init]) {
        self.setupCompleted = FALSE;
    }
    return self;
}

-(void)setup {
    gravity = METERS_to_FEET([self gravityFromAltitudeInMeters:altitudeM]);
    sectionalArea = [self calculateSectionalArea];
    airDensity = [self airDensity];
    xAtZero = [self.ballisticProfile.zero doubleValue];
    bulletMass = [self bulletMass];
    yInitial = -INCHES_to_FEET([self.ballisticProfile.sight_height_inches doubleValue]);
    vInitial = [self.ballisticProfile.muzzle_velocity doubleValue];
    speedOfSound = [self calculateSpeedOfSoundInFeet];
    windXSpeed = MPH_to_FPS(cos(DEGREES_to_RAD(self.windAngle)) * self.windSpeed);
    windZSpeed = MPH_to_FPS(sin(DEGREES_to_RAD(self.windAngle)) * self.windSpeed);
    thetaInitial = [self calculateThetaAngleWithYIntercept:0];
    
    self.setupCompleted = YES;
}

-(double)calculateThetaAngleWithYIntercept:(double)yIntercept {
    // Numerical Integration variables
    double t = 0;
    double dt = 1 / vInitial; // The solution accuracy generally doesn't suffer if its within a foot for each second of time.
    double y=0, x=0;
        
    // State variables for each integration loop.
    double v=0, vx=0, vy=0; // velocity

    double vx1=0, vy1=0;// Last frame's velocity, used for computing average velocity.

    double dv=0, dvx=0, dvy=0; // acceleration
    double gx=0, gy=0; // Gravitational acceleration
    double theta = 0; // The actual angle of the bore.
    double zero = YARDS_to_FEET([self.ballisticProfile.zero doubleValue]);
    
    BOOL thetaFound = FALSE; // We know it's time to quit our successive approximation loop when this is true.
    
    // The change in the bore angle used to iterate in on the correct zero angle.
    // Start with a very coarse angular change, to quickly solve even large launch angle problems.
    double dtheta = DEGREES_to_RAD(5);
    
    /* The general idea here is to start at 0 degrees elevation, and increase the elevation by 14 degrees until we are above the correct elevation. Then reduce the angular change by half, and begin reducing the angle.  Once we are again below the correct angle, reduce the angular change by half again, and go back up.  This allows for a fast successive approximation of the correct elevation, usually within less than 20 iterations.    */
//    int count = 0;
    while(!thetaFound) {
        vy = vInitial * sin(theta);
        vx = vInitial * cos(theta);
        gx = gravity * sin(theta);
        gy = gravity * cos(theta);
        
        t = 0;
        x = 0;
        y = yInitial;
        while (x <= zero) {
            vy1 = vy;
            vx1 = vx;
            v = VECTOR_LENGTH(vx, vy);
            dt=1/v;
            
            dv =  [self.ballisticProfile getBCWithSpeedOfSound:speedOfSound andVelocity:v + windXSpeed];
            dv += [self extraDragRetardationWithVelocity:v + windXSpeed];
            dvy = -dv*vy/v*dt;
            dvx = -dv*vx/v*dt;
    
            vx += dvx;
            vy += dvy;
            vy += dt*gy;
            vx += dt*gx;
            
            x += dt * (vx + vx1)/2.0;
            y += dt * (vy + vy1)/2.0;
    
            // Break early to save CPU time if there is no solution
            if ((vy < 0 && y < yIntercept) || (vy > (3 * vx))) break;
            
            t += dt;
//            count++;
        }
            
        if ((y > yIntercept && dtheta > 0) || (y < yIntercept && dtheta < 0))
            dtheta = -dtheta/2;

        // stop approximating or exceed the 45 degree launch angle
        if ((fabs(dtheta) < MOA_to_RAD(0.001))  || (theta > DEGREES_to_RAD(45))) thetaFound = TRUE;
        
        theta += dtheta;
    }
//    NSLog(@"angle %f rads\t%f degrees\tMOA %f\tcount %d", theta, RAD_to_DEGREES(theta), RAD_to_MOA(theta), count);
    return theta; // angle in radians
}

-(void)calculateTrajectory {
    if(!self.setupCompleted) [self setup];

    double t = 0;
    double dt = 0.5 / vInitial;

    double v  = vInitial;
    double vx = vInitial * cos(thetaInitial);
    double vy = vInitial * sin(thetaInitial);
    double vx1 = 0, vy1 = 0;

    double dv  = 0, dvx = 0, dvy = 0;

    double x   = 0;
    double y   = yInitial;
	double z   = 0;
	double dropMOA = 0, driftMOA = 0;
	
    double gx = gravity * sin(DEGREES_to_RAD(self.shootingAngle) + thetaInitial);
    double gy = gravity * cos(DEGREES_to_RAD(self.shootingAngle) + thetaInitial);

    self.ranges = [[NSMutableArray alloc] initWithCapacity:self.rangeMax];

    int n = self.rangeMin;
    while (n <= self.rangeMax) { // stop at max range yards
        vx1 = vx;
        vy1 = vy;
        v = VECTOR_LENGTH(vx, vy);
        dt = 0.5 / v;
        
        // Compute acceleration using the drag function retardation	
        dv =  [self.ballisticProfile getBCWithSpeedOfSound:speedOfSound andVelocity: v + windXSpeed];
        dv += [self extraDragRetardationWithVelocity: v + windXSpeed];
        dvx = -(vx/v)*dv;
        dvy = -(vy/v)*dv;
    
        // Compute velocity, including the resolved gravity vectors 
        vx += dt*dvx + dt*gx;
        vy += dt*dvy + dt*gy;
    
        t += dt;
        
        if (FEET_to_YARDS(x) >= n) {            
            if ((lround(x) % self.rangeIncrement) == 0) {
                TrajectoryRange *range = [[TrajectoryRange alloc] init];
                
                // equation 5.2 Litz
                z = windZSpeed * (t - (x/vInitial));
                //        drift = windage +-  lead  which is [NSNumber numberWithDouble:(sin(t)*self.lead_angle*self.lead_speed)];
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
                range.energy_ftlbs  = [NSString stringWithFormat:@"%.1f", [self energyAtVelocity:v]];
                range.time          = [NSString stringWithFormat:@"%.3f", t];

                [self.ranges addObject:range];
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
    return [Weather airDensityFromTempC:self.tempC andRH:self.relativeHumidity andPressurePa:INHG_to_PA(self.pressureInhg)];
}

-(double)bulletMass {
   return [self.ballisticProfile.bullet_weight doubleValue] / 7000.0;
}

-(double)calculateSectionalArea {
    return (M_PI / 4) * pow(INCHES_to_FEET([self.ballisticProfile.bullet_diameter_inches doubleValue]), 2);
}

-(double)gravityFromAltitudeInMeters:(double)altitude {
    return -3.99165757811945e+14 / pow(6.38e+6 + altitude, 2);
}

-(double)energyAtVelocity:(float)v {
    return 0.5 * (bulletMass /-gravity) * pow(v, 2);
}

-(double)calculateSpeedOfSoundInFeet {
    return METERS_to_FEET([Weather calculateSpeedOfSoundFromTempC:self.tempC andRH:self.relativeHumidity andPressurePa:INHG_to_PA(self.pressureInhg)]);
}

-(double)gravityY {
    return gravity * cos(DEGREES_to_RAD((self.shootingAngle + thetaInitial)));
}

-(double)gravityX {
    return gravity * sin(DEGREES_to_RAD((self.shootingAngle + thetaInitial)));
}


@end
