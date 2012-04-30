//
//  ConversionsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversionsViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    NSArray *lengthUnits;
    NSArray *weightUnits;
    int lastLengthSelected;
    int lastWeightSelected;
    NSArray *formFields;
}

@property (weak, nonatomic) IBOutlet UITextField *length1UnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *length2UnitTextField;
@property (weak, nonatomic) IBOutlet UIButton *length1UnitButton;
@property (weak, nonatomic) IBOutlet UITextField *length1TextField;
@property (weak, nonatomic) IBOutlet UIButton *length2UnitButton;
@property (weak, nonatomic) IBOutlet UITextField *length2TextField;
@property (weak, nonatomic) IBOutlet UITextField *weight1UnitTextField;
@property (weak, nonatomic) IBOutlet UITextField *weight2UnitTextField;
@property (weak, nonatomic) IBOutlet UIButton *weight1UnitButton;
@property (weak, nonatomic) IBOutlet UITextField *weight1TextField;
@property (weak, nonatomic) IBOutlet UIButton *weight2UnitButton;
@property (weak, nonatomic) IBOutlet UITextField *weight2TextField;
@property (weak, nonatomic) UITextField *currentTextField;

@property (strong, nonatomic) UIPickerView *lengthUnitPicker;
@property (strong, nonatomic) UIPickerView *weightUnitPicker;

- (IBAction)convertLength:(id)sender;
- (IBAction)convertWeight:(id)sender;

- (IBAction)chooseUnit:(UIButton *)sender;

@end
