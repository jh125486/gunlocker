//
//  BallisticProfile.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bullet, Weapon;

@interface BallisticProfile : NSManagedObject

@property (nonatomic, retain) id bullet_bc;
@property (nonatomic, retain) NSDecimalNumber * bullet_diameter_inches;
@property (nonatomic, retain) NSNumber * bullet_weight;
@property (nonatomic, retain) NSString * drag_model;
@property (nonatomic, retain) NSNumber * muzzle_velocity;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * sg;
@property (nonatomic, retain) NSString * sg_twist_direction;
@property (nonatomic, retain) NSNumber * sight_height_inches;
@property (nonatomic, retain) NSNumber * zero;
@property (nonatomic, retain) NSNumber * zero_theta;
@property (nonatomic, retain) NSNumber * zero_unit;
@property (nonatomic, retain) NSString * elevation_click;
@property (nonatomic, retain) NSString * windage_click;
@property (nonatomic, retain) NSString * scope_click_unit;
@property (nonatomic, retain) Bullet *bullet;
@property (nonatomic, retain) Weapon *weapon;

@end
