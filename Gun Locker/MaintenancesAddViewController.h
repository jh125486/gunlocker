//
//  MaintenancesAddViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintenancesAddViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *actionPerformedTextView;
@property (weak, nonatomic) IBOutlet UIPickerView *linkedMalfunctionPicker;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (retain, nonatomic) UIDatePicker *datePickerView;


- (IBAction)savePressed:(id)sender;
- (IBAction)closeModalPopup:(id)sender;

@end
