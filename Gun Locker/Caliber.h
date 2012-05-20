//
//  Caliber.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Caliber : NSManagedObject

@property (nonatomic, retain) NSNumber * diameter_inches;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;

@end
