//
//  AmmunitionByBrandViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ammunition.h"
#import "AmmunitionShowViewController.h"
#import "AmmunitionAddEditViewController.h"

@interface AmmunitionListByBrandViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) NSString *selectedCaliber;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UILabel *caliberLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandCountLabel;

@end
