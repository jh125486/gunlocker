//
//  BallisticProfile.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bullet, Weapon;

@interface BallisticProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSString * bc_model;
@property (nonatomic, retain) NSNumber * density_altitude;
@property (nonatomic, retain) NSString * drag_model;
@property (nonatomic, retain) NSString * muzzle_velocity;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * rh;
@property (nonatomic, retain) NSString * sight_height;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * zero;
@property (nonatomic, retain) NSDecimalNumber * bullet_bc;
@property (nonatomic, retain) NSNumber * bullet_weight;
@property (nonatomic, retain) Bullet *bullet;
@property (nonatomic, retain) Weapon *weapon;

@end
