//
//  DefaultButton.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DefaultButton.h"

@implementation DefaultButton

- (id)initWithFrame:(CGRect)frame {
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
- (id) initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 21, 21)] 
                        forState:UIControlStateNormal];

        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 21, 21)] 
                        forState:UIControlStateHighlighted];
        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 21, 21)] 
                        forState:UIControlStateSelected];

        [self setBackgroundImage:[[UIImage imageNamed:@"DefaultButton_Disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 22, 21, 21)] 
                        forState:UIControlStateDisabled];

        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self setTitleColor:[UIColor colorWithWhite:0.5f alpha:0.5f] forState:UIControlStateDisabled];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateSelected];
        self.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:24];
    
        self.titleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    }
    return self;
}

@end
