//
//  JHSector.m
//  DirectionWheel
//
//  Created by Jacob Hochstetler on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHSector.h"

@implementation JHSector : NSObject

@synthesize minValue = _minValue, maxValue = _maxValue, midValue = _midValue, sectorNumber = _sectorNumber;

-(NSString *)description {
    return [NSString stringWithFormat:@"%i | %f, %f, %f", _sectorNumber, _minValue, _midValue, _maxValue];
}

-(BOOL)contains:(float)radians {
    return (radians > self.minValue && radians < self.maxValue);   
}
@end
