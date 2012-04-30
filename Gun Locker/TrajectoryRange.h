//
//  TrajectoryRange.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrajectoryRange : NSObject

@property (nonatomic, strong) NSString *range_yards;
@property (nonatomic, strong) NSString *range_m;
@property (nonatomic, strong) NSString *drop_inches;
@property (nonatomic, strong) NSString *drop_moa;
@property (nonatomic, strong) NSString *drop_mils;
@property (nonatomic, strong) NSString *drift_inches;
@property (nonatomic, strong) NSString *drift_moa;
@property (nonatomic, strong) NSString *drift_mils;
@property (nonatomic, strong) NSString *velocity_fps;
@property (nonatomic, strong) NSString *energy_ftlbs;
@property (nonatomic, strong) NSString *time;

@end
