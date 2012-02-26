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
#import "DatabaseHelper.h"
#import "Weapon.h"
#import "ActionSheetPicker.h"

@class WeaponAddViewController;

@protocol WeaponAddViewControllerDelegate <NSObject>
- (void)WeaponAddViewControllerDidCancel:(WeaponAddViewController *)controller;
- (void)WeaponAddViewControllerDidSave:(WeaponAddViewController *)controller;
@end

@interface WeaponAddViewController : UITableViewController <UITextFieldDelegate, 
                                                            CaliberChooserViewControllerDelegate, 
                                                            ManufacturerChooserViewControllerDelegate,
                                                            UIImagePickerControllerDelegate,
                                                            UINavigationControllerDelegate> {
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id <WeaponAddViewControllerDelegate> delegate;

@property (nonatomic, retain) AbstractActionSheetPicker *actionSheetPicker;

@property (weak, nonatomic) IBOutlet UITextField *manufacturerTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *caliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *finishTextField;
@property (weak, nonatomic) IBOutlet UITextField *barrelLengthTextField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *purchaseDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *purchasePriceTextfield;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)checkData:(id)sender;
- (IBAction)photoButtonTapped;
- (IBAction)purchaseDateTextFieldTapped:(id)sender;

- (void)verifyEnteredData;
@end