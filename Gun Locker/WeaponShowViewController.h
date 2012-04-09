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
#import "NotesTableViewController.h"
#import "TextStepperField.h"
#import "DopeCardsTableViewController.h"
#import "CardsViewController.h"

@class CardsViewController;

@interface WeaponShowViewController : UITableViewController <WeaponAddViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *nfaCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *notesCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *dopeCardsCell;
@property (weak, nonatomic) IBOutlet UILabel *maintenanceCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *malfunctionCountLabel;
@property (weak, nonatomic) IBOutlet TextStepperField *adjustRoundCountStepper;
@property (weak, nonatomic) IBOutlet UIButton *quickCleanButton;
@property (weak, nonatomic) IBOutlet UILabel *weaponTypeLabel;

@property (assign, nonatomic) CardsViewController *cardsViewController;
@property (strong, nonatomic) Weapon *selectedWeapon;

- (IBAction)roundCountAdjust:(id)sender;
- (IBAction)changeWeaponTypeTapped:(id)sender;
@end
