//
//  MagazineAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Magazine.h"
#import "CaliberChooserViewController.h"

@interface MagazineAddEditViewController : UITableViewController <UITextFieldDelegate, CaliberChooserViewControllerDelegate> {
        NSArray *formFields;
}

@property (weak, nonatomic) Magazine *selectedMagazine;
@property (weak, nonatomic) NSString *selectedCaliber;

@property (weak, nonatomic) IBOutlet UITextField *brandTextField;
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;
@property (weak, nonatomic) IBOutlet UITextField *caliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *capacityTextField;
@property (weak, nonatomic) IBOutlet UILabel *capacityRoundsLabel;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantitiyTextField;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)savedTapped:(id)sender;
- (IBAction)capacityTextFieldChanged:(id)sender;

@end
