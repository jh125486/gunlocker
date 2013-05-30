//
//  NSString+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/27/13.
//
//

#import "NSString+Extended.h"

@implementation NSString (Extended)
-(int)lengthAfterDecimal {
    NSArray *components = [self componentsSeparatedByString:@"."];
    if ([components count] == 1) {
        return 0;
    } else {
        return [[components objectAtIndex:1] length];
    }
}

+(NSString *)randomStringWithLength:(int)length {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) [randomString appendFormat: @"%C", [letters characterAtIndex: rand()%[letters length]]];
    
    return [NSString stringWithString:randomString];
}

-(NSDecimalNumber*)decimalFromFraction {
    NSArray *components = [self componentsSeparatedByString:@"/"];
    
    if (components.count == 1) {
        return [NSDecimalNumber decimalNumberWithString:self];
    } else if (components.count > 2) {
        return nil;
    }
    
    return [[NSDecimalNumber decimalNumberWithString:[components objectAtIndex:0]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:[components objectAtIndex:1]]];
}
@end
