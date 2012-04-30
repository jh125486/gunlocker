//
//  Model+Helpers.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Model+Helpers.h>

@implementation Weapon (helper)

- (NSString *)description {
    NSString *manufacturer = self.manufacturer.short_name ? self.manufacturer.short_name : self.manufacturer.name;
    NSMutableString *description = [[NSString stringWithFormat:@"%@ %@", manufacturer, self.model] mutableCopy];
    if (self.barrel_length) [description appendFormat:@" (%@\")", self.barrel_length];
    
    return [NSString stringWithString:description];
}

@end

@implementation BallisticProfile (helper)

-(double)ballisticCoefficientWithVelocity:(double)velocity {
    NSArray *bc = self.bullet_bc;
    double value = [(NSDecimalNumber *)[bc objectAtIndex:0] doubleValue];

    for (int i = 1; i < bc.count; i += 2) {
        if ([(NSDecimalNumber *)[bc objectAtIndex:i + 1] doubleValue] < velocity) break;
        value = [(NSDecimalNumber *)[bc objectAtIndex:i] doubleValue];
    }
    return value;
}

-(double)getBCWithSpeedOfSound:(double)speedOfSound andVelocity:(double)velocity{
    double multiplier = 0;
    double mach = velocity / speedOfSound;
    
    if ([self.drag_model isEqualToString:@"G1"]) {
        if (mach > 2.0)
            multiplier = 0.9482590 + mach*(-0.248367 + mach*0.0344343);
        else if (mach > 1.40)
            multiplier = 0.6796810 + mach*(0.0705311 - mach*0.0570628);
        else if (mach > 1.10)
            multiplier = -1.471970 + mach*(3.1652900 - mach*1.1728200);
        else if (mach > 0.85)
            multiplier = -0.647392 + mach*(0.9421060 + mach*0.1806040);
        else if (mach >= 0.55)
            multiplier = 0.6224890 + mach*(-1.426820 + mach*1.2094500);
        else
            multiplier = 0.2637320 + mach*(-0.165665 + mach*0.0852214);
    } else if ([self.drag_model isEqualToString:@"G2"]) {
        if (mach > 2.5)
            multiplier = 0.4465610 + mach*(-0.0958548 + mach*0.00799645);
        else if (mach > 1.2)
            multiplier = 0.7016110 + mach*(-0.3075100 + mach*0.05192560);
        else if (mach > 1.0)
            multiplier = -1.105010 + mach*(2.77195000 - mach*1.26667000);
        else if (mach > 0.9)
            multiplier = -2.240370 + mach*2.63867000;
        else if (mach >= 0.7)
            multiplier = 0.9099690 + mach*(-1.9017100 + mach*1.21524000);
        else
            multiplier = 0.2302760 + mach*(0.000210564 - mach*0.1275050);
    } else if ([self.drag_model isEqualToString:@"G5"]) {
        if (mach > 2.0)
            multiplier = 0.671388 + mach*(-0.185208 + mach*0.0204508);
        else if (mach > 1.1)
            multiplier = 0.134374 + mach*(0.4378330 - mach*0.1570190);
        else if (mach > 0.9)
            multiplier = -0.924258 + mach*1.24904;
        else if (mach >= 0.6)
            multiplier = 0.654405 + mach*(-1.4275000 + mach*0.998463);
        else
            multiplier = 0.186386 + mach*(-0.0342136 - mach*0.035691);
    } else if ([self.drag_model isEqualToString:@"G6"]) {
        if (mach > 2.0)
            multiplier = 0.746228 + mach*(-0.255926 + mach*0.0291726);
        else if (mach > 1.1)
            multiplier = 0.513638 + mach*(-0.015269 - mach*0.0331221);
        else if (mach > 0.9)
            multiplier = -0.908802 + mach*1.25814;
        else if (mach >= 0.6)
            multiplier = 0.366723 + mach*(-0.458435 + mach*0.337906);
        else
            multiplier = 0.264481 + mach*(-0.157237 + mach*0.117441);
    } else if ([self.drag_model isEqualToString:@"G7"]) {
        if (mach > 1.9)
            multiplier = 0.439493 + mach*(-0.0793543 + mach*0.00448477);
        else if (mach > 1.05)
            multiplier = 0.642743 + mach*(-0.2725450 + mach*0.049247500);
        else if (mach > 0.90)
            multiplier = -1.69655 + mach*2.03557;
        else if (mach >= 0.60)
            multiplier = 0.353384 + mach*(-0.69240600 + mach*0.50946900);
        else
            multiplier = 0.119775 + mach*(-0.00231118 + mach*0.00286712);
    } else if ([self.drag_model isEqualToString:@"G8"]) {
        if (mach > 1.1)
            multiplier = 0.639096 + mach*(-0.197471 + mach*0.0216221);
        else if (mach >= 0.925)
            multiplier = -12.9053 + mach*(24.9181 - mach*11.6191);
        else
            multiplier = 0.210589 + mach*(-0.00184895 + mach*0.00211107);
    } else if ([self.drag_model isEqualToString:@"Gl"]) {
        if (mach > 1.0)
            multiplier = 0.286629 + mach*(0.3588930 - mach*0.0610598);
        else if (mach >= 0.8)
            multiplier = 1.59969 + mach*(-3.9465500 + mach*2.831370);
        else
            multiplier = 0.333118 + mach*(-0.498448 + mach*0.474774);
    } else if ([self.drag_model isEqualToString:@"Gi"]) {
        if (mach > 1.65)
            multiplier = 0.845362 + mach*(-0.143989 + mach*0.0113272);
        else if (mach > 1.2)
            multiplier = 0.630556 + mach*0.00701308;
        else if (mach >= 0.7)
            multiplier = 0.531976 + mach*(-1.28079 + mach*1.17628);
        else
            multiplier = 0.2282;
    }
    
    return (multiplier * 0.267978) / [self ballisticCoefficientWithVelocity:velocity];
}

@end