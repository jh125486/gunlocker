//
//  JHSector.h
//  DirectionWheel
//
//  Created by Jacob Hochstetler on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHSector : NSObject

@property float minValue;
@property float maxValue;
@property float midValue;
@property int sectorNumber;

-(BOOL)contains:(float)radians;
@end
