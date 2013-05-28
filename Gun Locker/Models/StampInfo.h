//
//  StampInfo.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weapon;

@interface StampInfo : NSManagedObject

@property (nonatomic, retain) NSDate * check_cashed;
@property (nonatomic, retain) NSData * form_photo;
@property (nonatomic, retain) NSDate * form_sent;
@property (nonatomic, retain) NSNumber * nfa_type;
@property (nonatomic, retain) NSDate * stamp_received;
@property (nonatomic, retain) NSNumber * transfer_type;
@property (nonatomic, retain) NSDate * went_pending;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) Weapon *weapon;

@end
