//
//  Ammunition.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ammunition.h"


@implementation Ammunition

@dynamic brand;
@dynamic caliber;
@dynamic purchase_price;
@dynamic count;
@dynamic count_original;
@dynamic purchase_date;
@dynamic retailer;
@dynamic type;

@synthesize cpr;

-(NSDecimalNumber *)cpr {
    return [self.purchase_price decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:[self.count_original stringValue]]];
}
@end
