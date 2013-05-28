//
//  MillerStabilityViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MillerStabilityViewController : UITableViewController <UITextFieldDelegate> {
    NSArray *formFields;
    NSDecimalNumberHandler *behavior;
}

@property (weak, nonatomic) IBOutlet UITextField *bulletCaliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *bulletLengthTextField;
@property (weak, nonatomic) IBOutlet UITextField *bulletWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *mvTextField;
@property (weak, nonatomic) IBOutlet UITextField *twistRateTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (weak, nonatomic) NSString *passedCaliber;
@property (weak, nonatomic) NSString *passedWeight;
@property (weak, nonatomic) NSString *passedMV;
@property (strong, nonatomic) IBOutlet UIView *resultView;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)showResult:(id)sender;
@end
