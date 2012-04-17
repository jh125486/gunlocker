//
//  Weapon+Helper.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Weapon+Helper.h>

@implementation Weapon (Helper)

- (NSString *)description {
    NSString *manufacturer = self.manufacturer.short_name ? self.manufacturer.short_name : self.manufacturer.name;
    NSMutableString *description = [[NSString stringWithFormat:@"%@ %@", manufacturer, self.model] mutableCopy];
    if (self.barrel_length) [description appendFormat:@" (%@\")", self.barrel_length];
    
    return [NSString stringWithString:description];
}

@end
