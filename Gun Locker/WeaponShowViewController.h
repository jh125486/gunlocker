//
//  WeaponShowViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "WeaponAddEditViewController.h"

@interface WeaponShowViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *maintenanceButton;
@property (weak, nonatomic) IBOutlet UIButton *malfunctionsButton;
@property (weak, nonatomic) IBOutlet UIButton *dopeCardsButton;
@property (weak, nonatomic) IBOutlet UIButton *quickCleanButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) Weapon *selectedWeapon;
@end
