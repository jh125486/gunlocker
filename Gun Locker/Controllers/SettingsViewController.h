//
//  SettingsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "KKPasscodeSettingsViewController.h"
#import "TextStepperField.h"
#import "WindLeadingTableViewController.h"
#import "Weapon.h"
#import "Manufacturer.h"
#import "StampInfo.h"
#import "Magazine.h"
#import "Ammunition.h"

@interface SettingsViewController : UITableViewController <KKPasscodeSettingsViewControllerDelegate, WindLeadingTableViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    DataManager *dataManager;
    UIButton *exportButton;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *cardsSortByControl;
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
@property (weak, nonatomic) IBOutlet UIButton *exportWeaponsButton;
@property (weak, nonatomic) IBOutlet UIButton *exportMagazinesButton;
@property (weak, nonatomic) IBOutlet UIButton *exportAmmunitionButton;

- (IBAction)showNFAInformationTapped:(UISwitch *)nfaSwitch;
- (IBAction)saveSettings:(id)sender;
- (IBAction)cardsSortByChanged:(UISegmentedControl *)sender;
- (IBAction)updateStepperRanges:(id)sender;
- (IBAction)exportTapped:(UIButton *)button;
- (IBAction)savePhotosTapped:(UIButton *)button;

-(NSString *)csvDumpAll;
-(NSString *)csvDumpWeapons;
-(NSString *)csvDumpMagazines;
-(NSString *)csvDumpAmmunition;

@end
