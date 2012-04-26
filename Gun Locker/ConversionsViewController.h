//
//  ConversionsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversionsViewController : UITableViewController <UITextFieldDelegate> {
    NSArray *formFields;
}

@property (weak, nonatomic) IBOutlet UIButton *lengthUnit1Button;
@property (weak, nonatomic) IBOutlet UITextField *length1TextField;
@property (weak, nonatomic) IBOutlet UIButton *lengthUnit2Button;
@property (weak, nonatomic) IBOutlet UITextField *length2TextField;
@property (weak, nonatomic) IBOutlet UIButton *weightUnit1Button;
@property (weak, nonatomic) IBOutlet UITextField *weight1TextField;
@property (weak, nonatomic) IBOutlet UIButton *weightUnit2Button;
@property (weak, nonatomic) IBOutlet UITextField *weight2TextField;
@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)convertLength:(id)sender;
- (IBAction)convertWeight:(id)sender;

- (IBAction)chooseLengthUnit:(UIButton *)sender;
- (IBAction)chooseWeightUnit:(UIButton *)sender;

@end
