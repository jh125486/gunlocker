//
//  Weapon.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DopeCard, Maintenance, Malfunction;

@interface Weapon : NSManagedObject

@property (nonatomic, retain) NSNumber * barrel_length;
@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSString * finish;
@property (nonatomic, retain) NSString * manufacturer;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSData * nfa_stamp;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSData * photo_thumbnail;
@property (nonatomic, retain) NSDate * purchased_date;
@property (nonatomic, retain) NSDecimalNumber * purchased_price;
@property (nonatomic, retain) NSNumber * round_count;
@property (nonatomic, retain) NSString * serial_number;
@property (nonatomic, retain) NSNumber * threaded_barrel;
@property (nonatomic, retain) NSString * threaded_barrel_pitch;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSOrderedSet *maintenances;
@property (nonatomic, retain) NSOrderedSet *malfunctions;
@property (nonatomic, retain) NSSet *preferred_load;
@property (nonatomic, retain) NSOrderedSet *dope_cards;
@end

@interface Weapon (CoreDataGeneratedAccessors)

- (void)insertObject:(Maintenance *)value inMaintenancesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMaintenancesAtIndex:(NSUInteger)idx;
- (void)insertMaintenances:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMaintenancesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMaintenancesAtIndex:(NSUInteger)idx withObject:(Maintenance *)value;
- (void)replaceMaintenancesAtIndexes:(NSIndexSet *)indexes withMaintenances:(NSArray *)values;
- (void)addMaintenancesObject:(Maintenance *)value;
- (void)removeMaintenancesObject:(Maintenance *)value;
- (void)addMaintenances:(NSOrderedSet *)values;
- (void)removeMaintenances:(NSOrderedSet *)values;
- (void)insertObject:(Malfunction *)value inMalfunctionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMalfunctionsAtIndex:(NSUInteger)idx;
- (void)insertMalfunctions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMalfunctionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMalfunctionsAtIndex:(NSUInteger)idx withObject:(Malfunction *)value;
- (void)replaceMalfunctionsAtIndexes:(NSIndexSet *)indexes withMalfunctions:(NSArray *)values;
- (void)addMalfunctionsObject:(Malfunction *)value;
- (void)removeMalfunctionsObject:(Malfunction *)value;
- (void)addMalfunctions:(NSOrderedSet *)values;
- (void)removeMalfunctions:(NSOrderedSet *)values;
- (void)addPreferred_loadObject:(NSManagedObject *)value;
- (void)removePreferred_loadObject:(NSManagedObject *)value;
- (void)addPreferred_load:(NSSet *)values;
- (void)removePreferred_load:(NSSet *)values;

- (void)insertObject:(DopeCard *)value inDope_cardsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDope_cardsAtIndex:(NSUInteger)idx;
- (void)insertDope_cards:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDope_cardsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDope_cardsAtIndex:(NSUInteger)idx withObject:(DopeCard *)value;
- (void)replaceDope_cardsAtIndexes:(NSIndexSet *)indexes withDope_cards:(NSArray *)values;
- (void)addDope_cardsObject:(DopeCard *)value;
- (void)removeDope_cardsObject:(DopeCard *)value;
- (void)addDope_cards:(NSOrderedSet *)values;
- (void)removeDope_cards:(NSOrderedSet *)values;
@end
