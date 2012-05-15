//
//  Maintenance.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Malfunction, Weapon;

@interface Maintenance : NSManagedObject

@property (nonatomic, retain) NSString * action_performed;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * dateAgoInWords;
@property (nonatomic, retain) NSNumber * round_count;
@property (nonatomic, retain) NSString * indexForCollation;
@property (nonatomic, retain) NSSet *malfunctions;
@property (nonatomic, retain) Weapon *weapon;
@end

@interface Maintenance (CoreDataGeneratedAccessors)

- (void)addMalfunctionsObject:(Malfunction *)value;
- (void)removeMalfunctionsObject:(Malfunction *)value;
- (void)addMalfunctions:(NSSet *)values;
- (void)removeMalfunctions:(NSSet *)values;

@end
