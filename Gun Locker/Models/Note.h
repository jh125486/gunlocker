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

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Weapon *weapon;

@end
