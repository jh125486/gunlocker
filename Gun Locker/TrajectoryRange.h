//
//  TrajectoryRange.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trajectory;

@interface TrajectoryRange : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * range_m;
@property (nonatomic, retain) NSDecimalNumber * velocity_mps;
@property (nonatomic, retain) NSDecimalNumber * energy_ftlbs;
@property (nonatomic, retain) NSDecimalNumber * drop;
@property (nonatomic, retain) NSDecimalNumber * windage;
@property (nonatomic, retain) NSDecimalNumber * time;
@property (nonatomic, retain) NSDecimalNumber * lead;
@property (nonatomic, retain) Trajectory *trajectory;

@end
