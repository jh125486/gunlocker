//
//  CardsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "WeaponCell.h"
#import "KKPasscodeLock.h"
#import "WeaponAddEditViewController.h"
#import "WeaponShowViewController.h"
#import "NFAInformationViewController.h"

@interface CardsViewController : UIViewController <WeaponAddViewControllerDelegate, 
                                                   NSFetchedResultsControllerDelegate, 
                                                   KKPasscodeViewControllerDelegate, 
                                                   UITableViewDataSource, UITableViewDelegate> {
	NSFetchedResultsController *fetchedResultsController;
    BOOL _firstInsert;
}

@property (nonatomic, retain) NSFetchedResultsController  *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedTypeControl;
@property (weak, nonatomic) IBOutlet UIImageView *noFilesImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *selectedType;
@property BOOL showPasscodeFlag;

- (IBAction)segmentedTypeControlClicked;
- (void)showPasscodeModal;

@end
