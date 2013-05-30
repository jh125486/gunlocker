//
//  Bullet+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Bullet+Extended.h"

@implementation Bullet (Extended)

- (NSString *)description {
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:@"%@ %@", self.brand, self.name];
    if (![self.brand isEqualToString:self.category]) [description appendFormat:@" (%@)", self.category];
    
    return [NSString stringWithString:description];
}

+(NSString *)bcToString:(NSArray*)bc {
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"BC: %@", [bc objectAtIndex:0]];
    for (int i = 1; i < bc.count; i += 2)
        [bcText appendFormat:@"/%@", [bc objectAtIndex:i]];
    
    return [NSString stringWithString:bcText];
}

@end
