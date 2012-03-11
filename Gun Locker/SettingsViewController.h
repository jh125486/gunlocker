//
//  SettingsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *nightModeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rangeUnitsControl;
@property (weak, nonatomic) IBOutlet UILabel *rangeIncrementLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *reticleUnitsControl;
@property (weak, nonatomic) IBOutlet UIStepper *rangeIncrementStepper;
@property double prevIncrementValue;

- (IBAction)settingsChanged:(id)sender;
- (IBAction)setStepValue:(id)sender;
@end
