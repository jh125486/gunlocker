//
//  Weapon+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Weapon+Extended.h"

@implementation Weapon (Extended)
-(NSString *)description {
    NSMutableString *description = [[NSString stringWithFormat:@"%@ %@", self.manufacturer.displayName, self.model] mutableCopy];
    if (self.barrel_length) [description appendFormat:@" (%@\")", self.barrel_length];
    
    return [NSString stringWithString:description];
}

-(NSString *)indexLetter {
    return [self.manufacturer.displayName substringToIndex:1];
}

- (NSComparisonResult)compare:(Weapon *)otherObject {
    return [self.description compare:otherObject.description];
}
@end
