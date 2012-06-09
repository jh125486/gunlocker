//
//  Photo.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * date_taken;
@property (nonatomic, retain) NSData * normal_size;
@property (nonatomic, retain) NSData * thumbnail_size;
@property (nonatomic, retain) Weapon *weapon;
@property (nonatomic, retain) Weapon *fromPrimaryToWeapon;

@end
