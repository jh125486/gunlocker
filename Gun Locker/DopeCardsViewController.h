//
//  DopeCardsTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "DopeCard.h"
#import "DopeCardsAddEditViewController.h"
#import "DopeCardViewController.h"

@interface DopeCardsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    NSMutableDictionary *dopeCards;
    NSMutableArray *sections;
    int count;
}
@property (weak, nonatomic) IBOutlet UIImageView *noDopeCardsImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) Weapon *selectedWeapon;

@end
