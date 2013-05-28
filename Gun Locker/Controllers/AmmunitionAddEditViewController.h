//
//  AmmunitionoAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ammunition.h"
#import "CaliberChooserViewController.h"

@interface AmmunitionAddEditViewController : UITableViewController <UITextFieldDelegate, CaliberChooserViewControllerDelegate, UIActionSheetDelegate> {
    NSArray *formFields;
    NSNumberFormatter* currencyFormatter;
}

@property (weak, nonatomic) Ammunition *selectedAmmunition;
@property (weak, nonatomic) NSString *selectedCaliber;

@property (weak, nonatomic) IBOutlet UITextField *brandTextField;
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;
@property (weak, nonatomic) IBOutlet UITextField *caliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;
@property (weak, nonatomic) IBOutlet UITextField *purchasePriceTextField;
@property (weak, nonatomic) IBOutlet UILabel *currencySymbolLabel;
@property (weak, nonatomic) IBOutlet UITextField *purchasedFromTextField;
@property (weak, nonatomic) IBOutlet UITextField *purchaseDateTextField;
@property (retain, nonatomic) UIDatePicker *purchaseDatePickerView;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)savedTapped:(id)sender;

- (IBAction)purchasePriceValueChanged:(id)sender;

@end
