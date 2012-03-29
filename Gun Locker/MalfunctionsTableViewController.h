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

@interface MalfunctionsTableViewController : UITableViewController {
    NSMutableDictionary *data;
    NSMutableArray *sections;
}

@property (nonatomic, weak) Weapon *selectedWeapon;

@end
