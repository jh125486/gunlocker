//
//  Ammunition.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Ammunition : NSManagedObject

@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * count;

@end
