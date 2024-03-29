//
//  DopeCardsAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/DopeCard.h"
#import "../Views/DopeCardRowEditCell.h"

@interface DopeCardsAddEditViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    NSArray *range_units;
    NSArray *dope_units;
    NSArray *wind_units;
    NSMutableArray *wind_directions;
    NSArray *formFields;
    
    NSMutableArray *dopeCardCellData;
    DataManager *dataManager;
}

@property (strong, nonatomic) IBOutlet UIView *sectionHeader;
@property (weak, nonatomic) IBOutlet UITextField *cardNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *zeroTextField;
@property (weak, nonatomic) IBOutlet UITextField *zeroUnitField;
@property (strong, nonatomic) UIPickerView *zeroUnitPickerView;

@property (weak, nonatomic) IBOutlet UITextField *muzzleVelocityTextField;
@property (weak, nonatomic) IBOutlet UITextField *weatherInfoField;
@property (weak, nonatomic) IBOutlet UITextField *rangeUnitField;

@property (weak, nonatomic) IBOutlet UITextField *dropUnitField;
@property (weak, nonatomic) IBOutlet UITextField *driftUnitField;
@property (strong, nonatomic) UIPickerView *dopeUnitPickerView;

@property (weak, nonatomic) IBOutlet UITextField *windInfoField;
@property (strong, nonatomic) UIPickerView *windInfoPickerView;

@property (weak, nonatomic) IBOutlet UITextField *leadInfoField;
@property (strong, nonatomic) UIPickerView *leadInfoPickerView;

@property (weak, nonatomic) IBOutlet UITextField *notesTextField;

@property (weak, nonatomic) UITextField *currentTextField;

@property (weak, nonatomic) DopeCard *selectedDopeCard;

- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

-(UITextField*)textFieldForIndex:(int)index;
-(int)indexForTextField:(UITextField*)textField;
@end
