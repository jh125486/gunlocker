//
//  Note.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * entry;
@property (nonatomic, retain) Weapon *weapon;

@end
