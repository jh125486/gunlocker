//
//  Weapon.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weapon : NSManagedObject

@property (nonatomic, retain) NSNumber * barrel_length;
@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSString * finish;
@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDate * purchased_date;
@property (nonatomic, retain) NSDecimalNumber * purchased_price;
@property (nonatomic, retain) NSString * serial_number;
@property (nonatomic, retain) NSOrderedSet *malfunctions;
@property (nonatomic, retain) NSSet *preferred_load;
@end

@interface Weapon (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inMalfunctionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMalfunctionsAtIndex:(NSUInteger)idx;
- (void)insertMalfunctions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMalfunctionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMalfunctionsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceMalfunctionsAtIndexes:(NSIndexSet *)indexes withMalfunctions:(NSArray *)values;
- (void)addMalfunctionsObject:(NSManagedObject *)value;
- (void)removeMalfunctionsObject:(NSManagedObject *)value;
- (void)addMalfunctions:(NSOrderedSet *)values;
- (void)removeMalfunctions:(NSOrderedSet *)values;
- (void)addPreferred_loadObject:(NSManagedObject *)value;
- (void)removePreferred_loadObject:(NSManagedObject *)value;
- (void)addPreferred_load:(NSSet *)values;
- (void)removePreferred_load:(NSSet *)values;

@end
