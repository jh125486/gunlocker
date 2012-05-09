//
//  MalfunctionsTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "Malfunction.h"
#import "MalfunctionsAddViewController.h"
#import "MalfunctionCell.h"
#import "Maintenance.h"

@interface MalfunctionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary *malfunctions;
    NSMutableArray *sections;
    int count;
}
@property (weak, nonatomic) IBOutlet UIImageView *noMalfunctionsImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) Weapon *selectedWeapon;
@property (nonatomic, weak) Maintenance *selectedMaintenance;

@end
