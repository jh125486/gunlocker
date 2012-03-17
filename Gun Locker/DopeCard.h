//
//  DopeCard.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface DopeCard : NSManagedObject

@property (nonatomic, retain) NSNumber * range_start;
@property (nonatomic, retain) NSNumber * range_end;
@property (nonatomic, retain) NSNumber * range_increment;
@property (nonatomic, retain) id drop_dope;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id wind_dope;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * dope_unit;
@property (nonatomic, retain) Weapon *weapon;

@end
