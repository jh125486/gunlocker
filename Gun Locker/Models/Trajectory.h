//
//  Trajectory.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BallisticProfile.h"
#import "Weather.h"
#import "TrajectoryRange.h"

@interface Trajectory : NSObject {
    double yAtScope;
    double vInitial;
    double yInitial;
    double gravity;
    double yAtX;
    double vAtX;
    double tAtX; 
    double xAtZero;
    double vAtZero;
    double tAtZero;
    double windXSpeed;
    double windZSpeed;
    double leadXSpeed;
    double leadZSpeed;
    double mass;
    double sectionalArea;
    double speedOfSound;
    double airDensity;
    double bulletMass;
    double thetaInitial;
    double k;
}

@property (nonatomic, assign) double pressureInhg;
@property (nonatomic, assign) double relativeHumidity;
@property (nonatomic, assign) double tempC;
@property (nonatomic, assign) double altitudeM;
@property (nonatomic, assign) int rangeUnit;
@property (nonatomic, assign) int rangeStart;
@property (nonatomic, assign) int rangeEnd;
@property (nonatomic, assign) int rangeStep;
@property (nonatomic, assign) double targetSpeed;
@property (nonatomic, assign) double targetAngle;
@property (nonatomic, assign) double windSpeed;
@property (nonatomic, assign) double windAngle;
@property (nonatomic, assign) double shootingAngle;
@property (nonatomic, retain) NSMutableArray *ranges;
@property (nonatomic, assign) BOOL setupCompleted;
@property (nonatomic, retain) BallisticProfile *ballisticProfile;

-(void)setup;
-(void)setupWindAndLeading;
-(void)calculateTrajectory;
@end

