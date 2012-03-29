//
//  WeaponShowViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "WeaponAddEditViewController.h"
#import "MaintenancesTableViewController.h"
#import "MalfunctionsTableViewController.h"
#import "NFAInformationViewController.h"
#import "TextStepperField.h"

@interface WeaponShowViewController : UITableViewController <WeaponAddViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *nfaCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *notesCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dopeCardsCell;
@property (weak, nonatomic) IBOutlet UILabel *maintenanceCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *malfunctionCountLabel;
@property (weak, nonatomic) IBOutlet TextStepperField *adjustRoundCountStepper;
@property (weak, nonatomic) IBOutlet UIButton *quickCleanButton;
@property (nonatomic, strong) Weapon *selectedWeapon;

- (IBAction)roundCountAdjust:(id)sender;
@end
