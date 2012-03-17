//
//  MaintenancesTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"

@interface MaintenancesTableViewController : UITableViewController {
    NSMutableArray *tableDataArray;
}

@property (nonatomic, strong) Weapon *selectedWeapon;

@end
