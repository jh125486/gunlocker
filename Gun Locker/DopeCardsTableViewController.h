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

@interface DopeCardsTableViewController : UITableViewController {
    NSMutableDictionary *dopeCards;
    NSMutableArray *sections;
}

@property (nonatomic, weak) Weapon *selectedWeapon;

@end
