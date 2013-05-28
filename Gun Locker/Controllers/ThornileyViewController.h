//
//  ThornileyViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThornileyViewController : UITableViewController <UITextFieldDelegate> {
    NSArray *formFields;
    NSDecimalNumberHandler *behavior;
}

@property (strong, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UITextField *bulletCaliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *bulletWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *mvTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)showResult:(id)sender;

@end
