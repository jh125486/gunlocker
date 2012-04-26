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
        [self setTintColor:[UIColor greenColor]];
//        [self setFrame: CGRectMake(self.frame.origin.x,
//                                   self.frame.origin.y,
//                                   self.frame.size.width, 
//                                   44)];
        
        UIImage *buttonImage = [[UIImage imageNamed:@"button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 12, 20)];
        [self setBackgroundImage:buttonImage forState:UIControlStateNormal];

        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.titleLabel.shadowColor = [UIColor whiteColor];
        self.titleLabel.shadowOffset = CGSizeMake(0, 1);
//        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];        
    }
    return self;
}

@end
