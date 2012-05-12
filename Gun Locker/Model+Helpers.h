//
//  Model+Helpers.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Accelerate/Accelerate.h>
#import "Weapon.h"
#import "Manufacturer.h"
#import "Trajectory.h"
#import "BallisticProfile.h"
#import "Weather.h"
#import "Bullet.h"

#define INCHES_PER_METER    39.3700787401575
#define FEET_PER_METER      3.28083989501312
#define YARDS_PER_METER     1.0936132983377078
#define MOA_PER_MIL         ((360*60)/(2000*M_PI))

#define DEGREES_to_RAD(x)   (x*M_PI/180.0)
#define RAD_to_DEGREES(x)   (x*180/M_PI)
#define RAD_to_MOA(x)       (x*60*180/M_PI)

#define MOA_to_RAD(x)       (x/60*M_PI/180.0)
#define MOA_to_MIL(x)       (x / ((360*60)/(2000*M_PI)))
#define CLOCK_to_DEGREES(x) (x * 30)

#define METERS_to_FEET(x)   (x*3.28083989501312)
#define FEET_to_METERS(x)   (x/3.28083989501312)
#define FEET_to_YARDS(x)    (x/3.0)
#define YARDS_to_FEET(x)    (x*3)
#define INCHES_to_FEET(x)   (x/12.0)
#define FEET_to_INCHES(x)   (x*12.0)
#define MPH_to_FPS(x)       (x*5280.0/(60*60))
#define INHG_to_PA(x)       (x*3386.389)

#define TEMP_C_to_TEMP_F(x) (x * (9/5.0) + 32.0)
#define TEMP_C_to_TEMP_K(x) (x + 273.15)
#define TEMP_F_to_TEMP_C(x) ((x - 32.0) * (5/9.0))
#define TEMP_F_to_TEMP_R(x) (x + 459.67)

#define KNOTS_to_MPH(x)     (x * (1.852/1.609344))

#define VECTOR_LENGTH(x, y) (sqrt(pow(x, 2) + pow(y, 2)))

#define GRAVITY_FPS (-32.1740486)

@interface Weapon (helper)
- (NSString *)description;
@end

@interface BallisticProfile (helper)

-(double)ballisticCoefficientWithVelocity:(double)velocity;
-(double)getBCWithSpeedOfSound:(double)speed andVelocity:(double)velocity;
-(void)calculateTheta;
@end

@interface Bullet (helper)
- (NSString *)description;
+(NSString *)bcToString:(NSArray*)bc;
@end