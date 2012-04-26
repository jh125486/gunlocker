//
//  Trajectory.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BallisticProfile, TrajectoryRange;

@interface Trajectory : NSManagedObject

@property (nonatomic, retain) NSNumber * density_altitude;
@property (nonatomic, retain) NSNumber * pressure_inhg;
@property (nonatomic, retain) NSNumber * relative_humidity;
@property (nonatomic, retain) NSNumber * temp_c;
@property (nonatomic, retain) NSNumber * range_increment;
@property (nonatomic, retain) NSNumber * range_max;
@property (nonatomic, retain) NSNumber * range_min;
@property (nonatomic, retain) NSNumber * altitude_m;
@property (nonatomic, retain) NSNumber * lead_speed;
@property (nonatomic, retain) NSNumber * lead_angle;
@property (nonatomic, retain) NSSet *ranges;
@property (nonatomic, retain) BallisticProfile *ballistic_profile;
@end

@interface Trajectory (CoreDataGeneratedAccessors)

- (void)addRangesObject:(TrajectoryRange *)value;
- (void)removeRangesObject:(TrajectoryRange *)value;
- (void)addRanges:(NSSet *)values;
- (void)removeRanges:(NSSet *)values;

@end
