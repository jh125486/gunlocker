//
//  Manufacturer.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface Manufacturer : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * short_name;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSSet *weapons;
@end

@interface Manufacturer (CoreDataGeneratedAccessors)

- (void)addWeaponsObject:(Weapon *)value;
- (void)removeWeaponsObject:(Weapon *)value;
- (void)addWeapons:(NSSet *)values;
- (void)removeWeapons:(NSSet *)values;

@end
