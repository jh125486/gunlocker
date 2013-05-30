//
//  BallisticProfile+Extended.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "BallisticProfile.h"

@interface BallisticProfile (Extended)
-(void)calculateTheta;
-(double)ballisticCoefficientWithVelocity:(double)velocity;
-(double)getBCWithSpeedOfSound:(double)speed andVelocity:(double)velocity;
-(double)extraDragRetardationWithVelocity:(double)v;
@end
