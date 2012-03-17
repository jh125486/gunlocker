//
//  LockerViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeaponAddEditViewController.h"
#import "WeaponShowViewController.h"
#import "Weapon.h"
#import "WeaponCell.h"
#import "NSDate+Formatting.h"
#import "KKPasscodeLock.h"

@interface LockerViewController : UITableViewController <WeaponAddViewControllerDelegate, 
                                                         NSFetchedResultsControllerDelegate, 
                                                         KKPasscodeViewControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
    BOOL _firstInsert;
}
@property (nonatomic, retain) NSFetchedResultsController  *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedTypeControl;
@property (nonatomic, retain) NSArray *weapons;
@property (nonatomic, retain) NSString *selectedType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editModeButton;
@property BOOL editModeOn;
@property BOOL showPasscodeFlag;

- (IBAction)editMode:(id)sender;
- (IBAction)segmentedTypeControlClicked;
- (void)showPasscodeModal;
@end
