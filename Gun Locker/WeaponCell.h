//
//  WeaponCell.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"

@interface WeaponCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *modelLabel;
@property (nonatomic, strong) IBOutlet UILabel *manufacturerLabel;
@property (nonatomic, strong) IBOutlet UILabel *barrelInfoLabel;
@property (nonatomic, strong) IBOutlet UILabel *finishLabel;
@property (nonatomic, strong) IBOutlet UILabel *roundCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *serialNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *malfunctionNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *caliberLabel;
@property (nonatomic, strong) IBOutlet UILabel *purchaseDateLabel;
@property (nonatomic, strong) IBOutlet UIView *photoImageContainer;
@property (nonatomic, strong) IBOutlet UIView *stampViewContainer;
@property (nonatomic, strong) IBOutlet UIImageView *photoImageView;
@property (nonatomic, strong) IBOutlet UIButton *stampViewButton;
@property (nonatomic, strong) IBOutlet UILabel *stampDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *stampSerialNumberLabel;
@property (nonatomic, strong) Weapon *weapon;

@end
