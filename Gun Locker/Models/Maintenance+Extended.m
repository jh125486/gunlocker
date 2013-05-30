//
//  Maintenance+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Maintenance+Extended.h"

@implementation Maintenance (Extended)
-(NSString *)dateAgoInWords {
    [self willAccessValueForKey:@"date"];
    NSString *distance = [[self date] distanceOfTimeInWordsOnlyDate];
    [self didAccessValueForKey:@"date"];
    return distance;
}

-(NSString*)indexForCollation {
    return self.weapon.indexLetter;
}
@end
