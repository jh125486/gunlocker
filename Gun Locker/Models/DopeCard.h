//
//  DopeCard.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface DopeCard : NSManagedObject

@property (nonatomic, retain) id dope_data;
@property (nonatomic, retain) NSString * drift_unit;
@property (nonatomic, retain) NSString * drop_unit;
@property (nonatomic, retain) NSString * lead_info;
@property (nonatomic, retain) NSString * muzzle_velocity;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * range_unit;
@property (nonatomic, retain) NSString * weather_info;
@property (nonatomic, retain) NSString * wind_info;
@property (nonatomic, retain) NSString * zero;
@property (nonatomic, retain) NSNumber * zero_unit;
@property (nonatomic, retain) Weapon *weapon;

@end
