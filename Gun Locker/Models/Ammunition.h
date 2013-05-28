//
//  Ammunition.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ammunition : NSManagedObject

@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSDecimalNumber * purchase_price;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSNumber * count_original;
@property (nonatomic, retain) NSDate * purchase_date;
@property (nonatomic, retain) NSString * retailer;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDecimalNumber *cpr;
@end
