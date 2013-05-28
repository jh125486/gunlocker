//
//  JHRotaryWheel.h
//  DirectionWheel
//
//  Created by Jacob Hochstetler on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "JHRotaryProtocol.h"
#import "JHSector.h"

@class JHRotaryWheel;

@protocol JHRotaryProtocol <NSObject>
-(void)wheelDidChangeValue:(int)index;
@end

@interface JHRotaryWheel : UIControl {
    float oldAlphaValue;
    BOOL skipLabels;
    int skipCount;
}

@property (weak) id <JHRotaryProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *sectors;
@property int currentSector;
@property NSMutableArray *sectorLabels;
@property NSArray *labels;

-(id)initWithFrame:(CGRect)frame andDelegate:(id)delegate withLabels:(NSArray *)labels;
-(void)rotateCW:(int)amount;
-(void)rotateCCW:(int)amount;
-(float)calculateDistanceFromCenter:(CGPoint)point;
@end
