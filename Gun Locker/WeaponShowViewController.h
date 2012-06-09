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
#import "MaintenancesViewController.h"
#import "MalfunctionsViewController.h"
#import "NFAInformationViewController.h"
#import "NotesListViewController.h"
#import "TextStepperField.h"
#import "DopeCardsViewController.h"
#import "CardsViewController.h"
#import "PhotosTableViewController.h"

@class CardsViewController;

@interface WeaponShowViewController : UITableViewController <WeaponAddViewControllerDelegate, UIActionSheetDelegate> {
    UIActionSheet *changeCategorySheet;
}

@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteCountLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *nfaCell;
@property (weak, nonatomic) IBOutlet UILabel *dopeCardCount;
@property (weak, nonatomic) IBOutlet UILabel *maintenanceCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *malfunctionCountLabel;
@property (weak, nonatomic) IBOutlet TextStepperField *adjustRoundCountStepper;
@property (weak, nonatomic) IBOutlet UIButton *quickCleanButton;
@property (weak, nonatomic) IBOutlet UILabel *weaponTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastCleanedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastCleanedCountLabel;

@property (assign, nonatomic) CardsViewController *cardsViewController;
@property (strong, nonatomic) Weapon *selectedWeapon;

- (IBAction)roundCountAdjust:(id)sender;
- (IBAction)changeWeaponTypeTapped:(id)sender;
- (IBAction)cleanNowTapped:(id)sender;
- (IBAction)deleteTapped:(id)sender;

@end
