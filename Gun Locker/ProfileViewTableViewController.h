//
//  ProfileViewTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bullet.h"
#import "Weapon.h"
#import "BallisticProfile.h"
#import "ProfileAddEditViewController.h"

@interface ProfileViewTableViewController : UITableViewController <UIActionSheetDelegate>

@property (weak, nonatomic) BallisticProfile *profile;
@property (weak, nonatomic) IBOutlet UILabel *mvLabel;
@property (weak, nonatomic) IBOutlet UILabel *sightHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *zeroLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletDiameterLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *dragModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *bcLabel;

- (IBAction)deleteTapped:(id)sender;

@end