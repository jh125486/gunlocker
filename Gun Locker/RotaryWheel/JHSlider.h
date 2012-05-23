//
//  JHSlider.h
//  DirectionWheel
//
//  Created by Jacob Hochstetler on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JHSlider : UISlider

@property (nonatomic, assign, readwrite) int increment;
@property (nonatomic, assign, readwrite) int labelStep;

-(id)initWithFrame:(CGRect)frame andIncrement:(int)increment andLabelStep:(int)labelStep;
@end
