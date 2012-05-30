//
//  JHSlider.m
//  DirectionWheel
//
//  Created by Jacob Hochstetler on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHSlider.h"

@implementation JHSlider
@synthesize labelStep = _labelStep;
@synthesize increment = _increment;

-(void)awakeFromNib {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), 
                            CGRectGetMinY(self.frame), 
                            CGRectGetWidth(self.frame), 
                            60.f);
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    [self addGestureRecognizer:gesture];
}

- (void)drawRect:(CGRect)rect {
    [self drawLabels];
}

-(void)drawLabels {
    int step = 0;
    int segments = round((self.maximumValue - self.minimumValue) / _labelStep);
    float labelWidth = 23.f;
    float widthStep = (CGRectGetWidth(self.frame) - labelWidth) / segments;
    for (int i = self.minimumValue; i <= self.maximumValue; i += _labelStep) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(widthStep * step, 0.f, labelWidth, 20.f)];
        label.text = [NSString stringWithFormat:@"%d", i];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f];
        [self addSubview:label];
        step++;
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.tracking) {
        [self setValue:roundf(self.value / _increment) * _increment animated:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)sliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    if (self.highlighted) return; // tap on thumb, let slider deal with it
    CGPoint point = [gestureRecognizer locationInView:self];
    CGFloat percentage = point.x / self.bounds.size.width;
    CGFloat delta = percentage * (self.maximumValue - self.minimumValue);
    CGFloat value = self.minimumValue + delta;
    [self setValue:roundf(value / _increment) * _increment animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
