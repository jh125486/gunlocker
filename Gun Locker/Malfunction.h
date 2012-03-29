//
//  Malfunction.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Maintenance, Weapon;

@interface Malfunction : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * failure;
@property (nonatomic, retain) NSString * fix;
@property (nonatomic, retain) NSNumber * round_count;
@property (nonatomic, retain) Maintenance *maintenance;
@property (nonatomic, retain) Weapon *weapon;

@end
