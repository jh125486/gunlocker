//
//  BallisticProfile.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bullet, Trajectory, Weapon;

@interface BallisticProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * bullet_weight;
@property (nonatomic, retain) NSString * drag_model;
@property (nonatomic, retain) id bullet_bc;
@property (nonatomic, retain) NSNumber * muzzle_velocity;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sight_height_inches;
@property (nonatomic, retain) NSNumber * zero;
@property (nonatomic, retain) NSDecimalNumber * bullet_diameter_inches;
@property (nonatomic, retain) Bullet *bullet;
@property (nonatomic, retain) Weapon *weapon;
@property (nonatomic, retain) NSSet *trajectories;
@end

@interface BallisticProfile (CoreDataGeneratedAccessors)

- (void)addTrajectoriesObject:(Trajectory *)value;
- (void)removeTrajectoriesObject:(Trajectory *)value;
- (void)addTrajectories:(NSSet *)values;
- (void)removeTrajectories:(NSSet *)values;

@end
