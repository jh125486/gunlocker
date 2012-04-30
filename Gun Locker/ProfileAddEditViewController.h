//
//  ProfileAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticProfile.h"
#import "Bullet.h"
#import "BulletChooserViewController.h"
#import "BulletEntryManualViewController.h"
#import "Weapon.h"

@interface ProfileAddEditViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    Weapon *selectedWeapon;
    NSArray *weapons;
    NSArray *manually_entered_bc;
    NSNumber *bullet_weight;
    NSString *drag_model;
    NSMutableArray *formFields;
}

@property (weak, nonatomic) BallisticProfile *selectedProfile;
@property (strong, nonatomic) Bullet *selectedBullet;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *weaponTextField;
@property (retain, nonatomic) UIPickerView *weaponPicker;
@property (weak, nonatomic) IBOutlet UILabel *bulletTypePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletDiameterLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletWeightPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *dragModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *bcLabel;
@property (weak, nonatomic) IBOutlet UITextField *muzzleVelocityTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *muzzleVelocityUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *siteHeightTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *siteHeightUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *zeroDistanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *zeroDistanceUnitControl;

@property (weak, nonatomic) UITextField *currentTextField;


- (IBAction)selectWeaponTapped:(id)sender;
- (IBAction)bulletControlTapped:(UISegmentedControl *)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@end
