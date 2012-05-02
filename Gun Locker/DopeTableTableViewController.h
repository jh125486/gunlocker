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
#import "Weather.h"

@interface DopeTableTableViewController : UITableViewController <UITextFieldDelegate> {
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
@property (weak, nonatomic) IBOutlet UISegmentedControl *windDirectionUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *leadingSpeedTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *leadingSpeedUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *leadingDirectionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *leadingDirectionUnitControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeUnitControl;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeStartStepper;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeEndStepper;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeStepStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dropDriftUnitcontrol;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)calculate:(id)sender;
- (IBAction)setToDefaultEnvironmentTapped:(id)sender;

@end
