//
//  SettingsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeSettingsViewController.h"

@interface SettingsViewController : UITableViewController <KKPasscodeSettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *nightModeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeUnitsControl;
@property (weak, nonatomic) IBOutlet UILabel *rangeIncrementLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *reticleUnitsControl;
@property (weak, nonatomic) IBOutlet UIStepper *rangeIncrementStepper;
@property (weak, nonatomic) IBOutlet UILabel *passcodeCellStatusLabel;
@property double prevIncrementValue;

- (IBAction)settingsChanged:(id)sender;
- (IBAction)setStepValue:(id)sender;
- (IBAction)passcodeCellClicked:(id)sender;

@end
