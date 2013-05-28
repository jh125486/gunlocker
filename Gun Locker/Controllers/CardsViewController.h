//
//  CardsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Weapon.h"
#import "../Models/Photo.h"
#import "../Views/WeaponCell.h"
#import "KKPasscodeLock.h"
#import "WeaponAddEditViewController.h"
#import "WeaponShowViewController.h"
#import "NFAInformationViewController.h"
#import "PhotoViewController.h"

@interface CardsViewController : UIViewController <WeaponAddViewControllerDelegate, 
                                                   NSFetchedResultsControllerDelegate, 
                                                   KKPasscodeViewControllerDelegate, 
                                                   UITableViewDataSource, UITableViewDelegate,
                                                   UIScrollViewDelegate> {
//	NSFetchedResultsController *fetchedResultsController;
    NSString *previousType;
    NSArray *types;
    NSDictionary *frcArray;
}

@property (nonatomic, retain) NSFetchedResultsController  *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *selectedTypeControl;
@property (weak, nonatomic) IBOutlet UIImageView *noFilesImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSString *selectedType;
@property BOOL showPasscodeFlag;

- (IBAction)segmentedTypeControlClicked;
- (void)showPasscodeModal;

@end
