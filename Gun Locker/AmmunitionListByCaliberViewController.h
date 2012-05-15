//
//  AmmunitionListViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ammunition.h"
#import "AmmunitionListByBrandViewController.h"

@interface AmmunitionListByCaliberViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSMutableDictionary *ammunitionByCaliberDict;
    NSArray *calibers;
}

@property (weak, nonatomic) IBOutlet UIImageView *noAmmunitionImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
