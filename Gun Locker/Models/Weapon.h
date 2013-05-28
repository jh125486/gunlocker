//
//  Weapon.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BallisticProfile, DopeCard, Maintenance, Malfunction, Manufacturer, Note, Photo, StampInfo;

@interface Weapon : NSManagedObject

@property (nonatomic, retain) NSNumber * barrel_length;
@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSString * finish;
@property (nonatomic, retain) NSString * indexLetter;
@property (nonatomic, retain) NSDate * last_cleaned_date;
@property (nonatomic, retain) NSNumber * last_cleaned_round_count;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * purchased_date;
@property (nonatomic, retain) NSDecimalNumber * purchased_price;
@property (nonatomic, retain) NSNumber * round_count;
@property (nonatomic, retain) NSString * serial_number;
@property (nonatomic, retain) NSNumber * threaded_barrel;
@property (nonatomic, retain) NSString * threaded_barrel_pitch;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *ballistic_profile;
@property (nonatomic, retain) NSSet *dope_cards;
@property (nonatomic, retain) NSSet *maintenances;
@property (nonatomic, retain) NSSet *malfunctions;
@property (nonatomic, retain) Manufacturer *manufacturer;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *preferred_load;
@property (nonatomic, retain) StampInfo *stamp;
@property (nonatomic, retain) Photo *primary_photo;
@end

@interface Weapon (CoreDataGeneratedAccessors)

- (void)addBallistic_profileObject:(BallisticProfile *)value;
- (void)removeBallistic_profileObject:(BallisticProfile *)value;
- (void)addBallistic_profile:(NSSet *)values;
- (void)removeBallistic_profile:(NSSet *)values;

- (void)addDope_cardsObject:(DopeCard *)value;
- (void)removeDope_cardsObject:(DopeCard *)value;
- (void)addDope_cards:(NSSet *)values;
- (void)removeDope_cards:(NSSet *)values;

- (void)addMaintenancesObject:(Maintenance *)value;
- (void)removeMaintenancesObject:(Maintenance *)value;
- (void)addMaintenances:(NSSet *)values;
- (void)removeMaintenances:(NSSet *)values;

- (void)addMalfunctionsObject:(Malfunction *)value;
- (void)removeMalfunctionsObject:(Malfunction *)value;
- (void)addMalfunctions:(NSSet *)values;
- (void)removeMalfunctions:(NSSet *)values;

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addPreferred_loadObject:(NSManagedObject *)value;
- (void)removePreferred_loadObject:(NSManagedObject *)value;
- (void)addPreferred_load:(NSSet *)values;
- (void)removePreferred_load:(NSSet *)values;

@end
