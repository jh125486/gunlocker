//
//  DopeCardViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DopeCard.h"
#import "DopeCardRowCell.h"
#import "DopeCardsAddEditViewController.h"
#import "Weapon.h"

@interface DopeCardTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIView *dopeCardSectionHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *weaponLabel;
@property (weak, nonatomic) IBOutlet UILabel *zeroLabel;
@property (weak, nonatomic) IBOutlet UILabel *mvLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *windInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *leadInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropLabel;
@property (weak, nonatomic) IBOutlet UILabel *driftLabel;
@property (weak, nonatomic) DopeCard *selectedDopeCard;
@end
