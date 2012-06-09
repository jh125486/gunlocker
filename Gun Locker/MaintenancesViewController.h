//
//  MaintenancesTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "Malfunction.h"
#import "Maintenance.h"
#import "MaintenanceCell.h"
#import "MaintenancesAddViewController.h"
#import "MalfunctionsViewController.h"
#import "Photo.h"

@interface MaintenancesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *noMaintenancesImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) Weapon *selectedWeapon;

@end
