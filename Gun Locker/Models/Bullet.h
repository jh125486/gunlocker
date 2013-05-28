//
//  Bullet.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BallisticProfile;

@interface Bullet : NSManagedObject

@property (nonatomic, retain) id ballistic_coefficient;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDecimalNumber * diameter_inches;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * sectional_density_inches;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * weight_grains;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSSet *ballistic_profile;
@end

@interface Bullet (CoreDataGeneratedAccessors)

- (void)addBallistic_profileObject:(BallisticProfile *)value;
- (void)removeBallistic_profileObject:(BallisticProfile *)value;
- (void)addBallistic_profile:(NSSet *)values;
- (void)removeBallistic_profile:(NSSet *)values;

@end
