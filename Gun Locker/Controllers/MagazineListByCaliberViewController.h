//
//  MagazineByCaliberListViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Magazine.h"
#import "MagazineListByBrandViewController.h"

@interface MagazineListByCaliberViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    NSMutableDictionary *magazineByCaliberDict;
    NSArray *calibers;
}

@property (weak, nonatomic) IBOutlet UIImageView *noMagazineImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
