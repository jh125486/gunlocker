//
//  MalfunctionsTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Weapon.h"
#import "../Models/Malfunction.h"
#import "MalfunctionsAddViewController.h"
#import "../Views/MalfunctionCell.h"
#import "../Models/Maintenance.h"

@interface MalfunctionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *noMalfunctionsImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) Weapon *selectedWeapon;
@property (nonatomic, weak) Maintenance *selectedMaintenance;

@end
