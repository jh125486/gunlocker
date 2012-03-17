//
//  Manufacturer.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Manufacturer : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * name;

@end
