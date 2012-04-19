//
//  WeaponAddViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManufacturerChooserViewController.h"
#import "CaliberChooserViewController.h"
#import "Weapon.h"
#import "Manufacturer.h"

@class WeaponAddEditViewController;

@protocol WeaponAddViewControllerDelegate <NSObject>
- (void)WeaponAddViewControllerDidCancel:(WeaponAddEditViewController *)controller;
- (void)WeaponAddViewControllerDidSave:(WeaponAddEditViewController *)controller;
@end

@interface WeaponAddEditViewController : UITableViewController <UITextFieldDelegate, CaliberChooserViewControllerDelegate, ManufacturerChooserViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    NSArray *formFields;
    NSNumberFormatter* currencyFormatter;
    Manufacturer *selectedManufacturer;
}
@property (weak, nonatomic) NSString *weaponType;
@property (nonatomic, weak) id <WeaponAddViewControllerDelegate> delegate;

@property (weak, nonatomic) Weapon *selectedWeapon;

@property (weak, nonatomic) IBOutlet UITextField *manufacturerTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *caliberTextField;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UITextField *finishTextField;
@property (weak, nonatomic) IBOutlet UITextField *barrelLengthTextField;
@property (weak, nonatomic) IBOutlet UILabel *barrelLengthUnitLabel;
@property (weak, nonatomic) IBOutlet UITextField *barrelThreadingTextField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *purchaseDateTextField;
@property (retain, nonatomic) UIDatePicker *purchaseDatePickerView;
@property (weak, nonatomic) IBOutlet UITextField *purchasePriceTextfield;
@property (weak, nonatomic) IBOutlet UILabel *currencySymbolLabel;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)barrelLengthValueChanged:(id)sender;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)checkData:(id)sender;
- (IBAction)photoButtonTapped;

- (void)loadTextfieldsFromWeapon:(Weapon*)weapon;

@end