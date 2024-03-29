//
//  Magazine.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Magazine : NSManagedObject

@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * caliber;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * type;

@end
