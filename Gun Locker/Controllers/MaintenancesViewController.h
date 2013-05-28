//
//  MaintenancesTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Weapon.h"
#import "../Models/Malfunction.h"
#import "../Models/Maintenance.h"
#import "../Models/Photo.h"
#import "../Views/MaintenanceCell.h"
#import "MaintenancesAddViewController.h"
#import "MalfunctionsViewController.h"

@interface MaintenancesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *noMaintenancesImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) Weapon *selectedWeapon;

@end
