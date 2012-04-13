//
//  BallisticProfile.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface BallisticProfile : NSManagedObject

@property (nonatomic, retain) NSString * bullet_diameter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * bc;
@property (nonatomic, retain) NSString * zero;
@property (nonatomic, retain) NSString * bullet_mass;
@property (nonatomic, retain) NSString * muzzle_velocity;
@property (nonatomic, retain) NSString * sight_height;
@property (nonatomic, retain) NSString * drag_model;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * bc_model;
@property (nonatomic, retain) NSNumber * rh;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * density_altitude;
@property (nonatomic, retain) Weapon *weapon;

@end
