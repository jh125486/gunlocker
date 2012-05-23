//
//  DirectionSpeedViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHRotaryWheel.h"
#import "JHSlider.h"

@protocol DirectionSpeedProtocol <NSObject>
-(void)windSetWithDirectionType:(int)directionType andDirection:(int)direction andSpeedType:(int)speedType andSpeed:(int)speed;
-(void)targetSetWithDirectionType:(int)directionType andDirection:(int)direction andSpeedType:(int)speedType andSpeed:(int)speed;
@end

@interface DirectionSpeedViewController : UIViewController <JHRotaryProtocol> {
    int directionIndex;
    NSArray *labels;
}

@property (nonatomic, weak) id <DirectionSpeedProtocol> delegate;

@property (nonatomic, strong) JHRotaryWheel *wheel;
@property (nonatomic, strong) JHSlider *speedSlider;
@property (nonatomic) UIImageView *speedImage;
@property (nonatomic, strong) UISegmentedControl *speedUnitControl;
@property (nonatomic, strong) UISegmentedControl *directionTypeControl;
@property (nonatomic, strong) NSString *resultType;

@property (nonatomic) int directionType;
@property (nonatomic) int directionValue;
@property (nonatomic) int speedUnit;
@property (nonatomic) float speedValue;

@property (weak, nonatomic) IBOutlet UILabel *title1Label;
@property (weak, nonatomic) IBOutlet UILabel *title2Label;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)setTapped:(id)sender;

@end
