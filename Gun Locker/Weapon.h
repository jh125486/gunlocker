//
//  Weapon.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DopeCard, Maintenance, Malfunction, Note, StampInfo;

@interface Weapon : NSManagedObject

@property (nonatomic, retain) NSNumber * barrel_length;
@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSString * finish;
@property (nonatomic, retain) NSString * manufacturer;
@property (nonatomic, retain) NSString * model;
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
@property (nonatomic, retain) NSOrderedSet *dope_cards;
@property (nonatomic, retain) NSSet *maintenances;
@property (nonatomic, retain) NSSet *malfunctions;
@property (nonatomic, retain) NSOrderedSet *notes;
@property (nonatomic, retain) NSSet *preferred_load;
@property (nonatomic, retain) StampInfo *stamp;
@end

@interface Weapon (CoreDataGeneratedAccessors)

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
- (void)addMaintenancesObject:(Maintenance *)value;
- (void)removeMaintenancesObject:(Maintenance *)value;
- (void)addMaintenances:(NSSet *)values;
- (void)removeMaintenances:(NSSet *)values;

- (void)addMalfunctionsObject:(Malfunction *)value;
- (void)removeMalfunctionsObject:(Malfunction *)value;
- (void)addMalfunctions:(NSSet *)values;
- (void)removeMalfunctions:(NSSet *)values;

- (void)insertObject:(Note *)value inNotesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNotesAtIndex:(NSUInteger)idx;
- (void)insertNotes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNotesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNotesAtIndex:(NSUInteger)idx withObject:(Note *)value;
- (void)replaceNotesAtIndexes:(NSIndexSet *)indexes withNotes:(NSArray *)values;
- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSOrderedSet *)values;
- (void)removeNotes:(NSOrderedSet *)values;
- (void)addPreferred_loadObject:(NSManagedObject *)value;
- (void)removePreferred_loadObject:(NSManagedObject *)value;
- (void)addPreferred_load:(NSSet *)values;
- (void)removePreferred_load:(NSSet *)values;

@end
