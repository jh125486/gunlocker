//
//  DopeTableTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticProfile.h"
#import "DopeTableGeneratedTableViewController.h"
#import "TextStepperField.h"
#import "DirectionSpeedViewController.h"
#import "Weather.h"

@class DopeTableTableViewController;

@protocol DopeTableTableViewControllerProtocol <NSObject>
-(void)windSetWithDirectionType:(int)directionType andDirection:(int)direction andSpeedType:(int)speedType andSpeed:(int)speed;
-(void)targetSetWithDirectionType:(int)directionType andDirection:(int)direction andSpeedType:(int)speedType andSpeed:(int)speed;
@end

@interface DopeTableTableViewController : UITableViewController <UITextFieldDelegate, DirectionSpeedProtocol> {
    NSMutableArray *formFields;
}

@property (weak, nonatomic) BallisticProfile *selectedProfile;
@property (weak, nonatomic) Weather *currentWeather;

@property (weak, nonatomic) IBOutlet UITextField *tempTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tempUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *pressureTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pressureUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *rhTextField;
@property (weak, nonatomic) IBOutlet UITextField *altitudeTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *altitudeUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *windSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *windSpeedUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *windDirectionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *windDirectionTypeControl;
@property (weak, nonatomic) IBOutlet UITextField *targetSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetSpeedUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *targetDirectionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetDirectionTypeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeUnitControl;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeStartStepper;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeEndStepper;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeStepStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dropDriftUnitcontrol;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)calculate:(id)sender;
- (IBAction)setToDefaultEnvironmentTapped:(id)sender;
- (IBAction)setStepperRanges:(id)sender;

@end
