//
//  LogsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Maintenance.h"
#import "Malfunction.h"
#import "DopeCard.h"
#import "MaintenancesTableViewController.h"
#import "MalfunctionsTableViewController.h"
#import "DopeCardsTableViewController.h"

@interface LogsViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *maintenanceCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *malfunctionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dopeCardsCountLabel;

@end
