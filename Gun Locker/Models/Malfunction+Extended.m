//
//  Malfunction+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Malfunction+Extended.h"

@implementation Malfunction (Extended)
-(NSString *)dateAgoInWords {
    [self willAccessValueForKey:@"date"];
    NSString *distance = [[self date] distanceOfTimeInWordsOnlyDate];
    [self didAccessValueForKey:@"date"];
    return distance;
}
@end
