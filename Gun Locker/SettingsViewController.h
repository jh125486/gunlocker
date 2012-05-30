//
//  SettingsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeSettingsViewController.h"
#import "TextStepperField.h"
#import "WindLeadingTableViewController.h"

@interface SettingsViewController : UITableViewController <KKPasscodeSettingsViewControllerDelegate, WindLeadingTableViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *showNFAInformationSwitch;
@property (weak, nonatomic) IBOutlet UITableViewCell *passcodeCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeUnitsControl;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeStartStepper;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeEndStepper;
@property (weak, nonatomic) IBOutlet TextStepperField *rangeStepStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *reticleUnitsControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *directionControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *nightModeControl;
@property (weak, nonatomic) IBOutlet UILabel *windLeadingLabel;

- (IBAction)showNFAInformationTapped:(UISwitch *)nfaSwitch;
- (IBAction)setStepperRanges:(id)sender;

@end
