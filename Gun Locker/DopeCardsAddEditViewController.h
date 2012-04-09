//
//  DopeCardsAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DopeCard.h"
#import "DopeCardRowEditCell.h"

@interface DopeCardsAddEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    NSArray *range_units;
    NSArray *dope_units;
    NSArray *wind_units;
    NSMutableArray *wind_directions;
    NSMutableArray *dopeFields;
    NSMutableArray *formFields;
    NSMutableArray *dopeCardCellData;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *cardNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *zeroTextField;
@property (weak, nonatomic) IBOutlet UITextField *rangeUnitField;
@property (weak, nonatomic) IBOutlet UITextField *dropUnitField;
@property (weak, nonatomic) IBOutlet UITextField *driftUnitField;
@property (retain, nonatomic) UIPickerView *dopeUnitPickerView;
@property (weak, nonatomic) IBOutlet UITextField *windInfoField;
@property (retain, nonatomic) UIPickerView *windInfoPickerView;
@property (weak, nonatomic) IBOutlet UITextField *notesTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UITextField *currentTextField;

@property (weak, nonatomic) DopeCard *selectedDopeCard;

- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
