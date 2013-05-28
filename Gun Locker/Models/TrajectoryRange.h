//
//  TrajectoryRange.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrajectoryRange : NSObject

@property (nonatomic, assign) double range;
@property (nonatomic, assign) double drop_inches;
@property (nonatomic, assign) double drop_moa;
@property (nonatomic, assign) double drop_mils;
@property (nonatomic, assign) double drift_inches;
@property (nonatomic, assign) double drift_moa;
@property (nonatomic, assign) double drift_mils;
@property (nonatomic, assign) double velocity_fps;
@property (nonatomic, assign) double energy_ftlbs;
@property (nonatomic, assign) double time;

@end
