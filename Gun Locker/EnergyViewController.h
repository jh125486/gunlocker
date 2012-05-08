//
//  EnergyFormulasViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnergyViewController : UITableViewController <UITextFieldDelegate> {
    NSArray *formFields;
    NSDecimalNumberHandler *behavior;
}

@property (weak, nonatomic) IBOutlet UITextField *bulletWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *mvTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultFtLbsLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultJoulesLabel;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)showResult:(id)sender;

@end
