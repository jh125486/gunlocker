//
//  DefaultButton.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DefaultButton.h"

@implementation DefaultButton

- (id)initWithFrame:(CGRect)frame
{
    if (self) {
    }
    
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (id) initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Normal"] 
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Highlighted"] 
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Disabled"] 
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(21, 21, 21, 21)] forState:UIControlStateDisabled];

        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self setTitleColor:[UIColor colorWithWhite:0.5f alpha:0.5f] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];
        
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return self;
}

@end
