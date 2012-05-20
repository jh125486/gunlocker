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
#import "Weapon.h"
#import "BulletChooserViewController.h"
#import "BulletBCEntryViewController.h"
#import "MillerStabilityViewController.h"

@class ProfileAddEditViewController;

@protocol ProfileAddEditViewControllerDelegate <NSObject>
- (void)profileAddEditViewController:(ProfileAddEditViewController *)controller didAddEditProfile:(BallisticProfile *)profile;
@end

@interface ProfileAddEditViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    Weapon *selectedWeapon;
    NSArray *weapons;
    NSMutableArray *weaponViews;
    NSArray *manually_entered_bc;
    NSString *drag_model;
    NSMutableArray *formFields;
    NSArray *dragModels;
    NSArray *sgDirections;
}

@property (nonatomic, weak) id <ProfileAddEditViewControllerDelegate> delegate;

@property (weak, nonatomic) BallisticProfile *selectedProfile;
@property (strong, nonatomic) Bullet *selectedBullet;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *weaponTextField;
@property (retain, nonatomic) UIPickerView *weaponPicker;

@property (weak, nonatomic) IBOutlet UITextField *muzzleVelocityTextField;
@property (weak, nonatomic) IBOutlet UITextField *siteHeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *zeroDistanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *zeroDistanceUnitControl;

@property (weak, nonatomic) IBOutlet UITextField *diameterTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;

@property (weak, nonatomic) IBOutlet UIButton *weaponButton;
@property (weak, nonatomic) IBOutlet UIButton *bulletButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dragModelControl;
@property (weak, nonatomic) IBOutlet UIView *bcButtonTopEdgeView;
@property (weak, nonatomic) IBOutlet UIButton *bcButton;

@property (weak, nonatomic) IBOutlet UITextField *sgTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgDirectionControl;


@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)selectWeaponTapped:(id)sender;
- (IBAction)dragModelChanged:(UISegmentedControl *)sender;
- (IBAction)bulletFieldChanged:(UITextField *)sender;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;

@end
