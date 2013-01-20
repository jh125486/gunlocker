//
//  DopeCardsAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardsAddEditViewController.h"

@implementation DopeCardsAddEditViewController
@synthesize sectionHeader = _sectionHeader;
@synthesize cardNameTextField = _cardNameTextField;
@synthesize zeroTextField = _zeroTextField, zeroUnitField = _zeroUnitField, zeroUnitPickerView = _zeroUnitPickerView;
@synthesize muzzleVelocityTextField = _muzzleVelocityTextField;
@synthesize weatherInfoField = _weatherInfoField;
@synthesize windInfoField = _windInfoField, leadInfoField = _leadInfoField;
@synthesize notesTextField = _notesTextField;
@synthesize rangeUnitField = _rangeUnitField, dropUnitField = _dropUnitField, driftUnitField = _driftUnitField;
@synthesize windInfoPickerView = _windInfoPickerView, leadInfoPickerView = _leadInfoPickerView, dopeUnitPickerView = _dopeUnitPickerView;
@synthesize currentTextField = _currentTextField;
@synthesize selectedDopeCard = _selectedDopeCard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    dataManager = [DataManager sharedManager];
    range_units = dataManager.rangeUnits;
    dope_units  = dataManager.dopeUnits;
    wind_units  = dataManager.windUnits;
    wind_directions = [[NSMutableArray alloc] initWithObjects:@"12 o'clock", nil];
    for (int i = 1; i < 12; i++)
        [wind_directions addObject:[NSString stringWithFormat:@"%d o'clock", i]];
    
    dopeCardCellData = [[NSMutableArray alloc] init];
    
    // inputView pickers
    _zeroUnitPickerView = [[UIPickerView alloc] init];
    _dopeUnitPickerView = [[UIPickerView alloc] init];    
    _windInfoPickerView = [[UIPickerView alloc] init];
    _leadInfoPickerView = [[UIPickerView alloc] init];
    
    _zeroUnitPickerView.delegate = _dopeUnitPickerView.delegate   = _windInfoPickerView.delegate   = _leadInfoPickerView.delegate   = self;
    _zeroUnitPickerView.dataSource = _dopeUnitPickerView.dataSource = _windInfoPickerView.dataSource = _leadInfoPickerView.dataSource = self;
    _zeroUnitPickerView.showsSelectionIndicator = _dopeUnitPickerView.showsSelectionIndicator = _windInfoPickerView.showsSelectionIndicator = _leadInfoPickerView.showsSelectionIndicator = YES;
    
    _zeroUnitField.inputView = _zeroUnitPickerView;
    _rangeUnitField.inputView = _dropUnitField.inputView = _driftUnitField.inputView = _dopeUnitPickerView;
    _windInfoField.inputView  = _windInfoPickerView;
    _leadInfoField.inputView  = _leadInfoPickerView;
    
    formFields = [[NSArray alloc] initWithObjects:_cardNameTextField, 
                                                  _zeroTextField,
                                                  _zeroUnitField,
                                                  _muzzleVelocityTextField,
                                                  _weatherInfoField,
                                                  _windInfoField, 
                                                  _leadInfoField,
                                                  _notesTextField, 
                                                  _rangeUnitField, 
                                                  _dropUnitField, 
                                                  _driftUnitField, 
                                                  nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;
    
    if (_selectedDopeCard) [self loadDopeCard];

    // add extra empty row
    [dopeCardCellData addObjectsFromArray:[NSArray arrayWithObjects:@"", @"", @"", nil]];
}

- (void)loadDopeCard {
    // TODO set pickers to correct values
    
    self.title = @"Edit Dope Card";
    _cardNameTextField.text       = _selectedDopeCard.name;
    _zeroTextField.text           = _selectedDopeCard.zero;
    _muzzleVelocityTextField.text = _selectedDopeCard.muzzle_velocity;
    _weatherInfoField.text        = _selectedDopeCard.weather_info;
    _notesTextField.text          = _selectedDopeCard.notes;
    
    [_zeroUnitPickerView selectRow:_selectedDopeCard.zero_unit.intValue inComponent:0 animated:NO];
    [self setZeroUnit];
    
    if (_selectedDopeCard.wind_info) {
        NSArray *windInfoArray = [_selectedDopeCard.wind_info componentsSeparatedByString:@" "];
        int speed      = [[windInfoArray objectAtIndex:0] intValue];
        NSString *unit = [windInfoArray objectAtIndex:1];
        int direction  = [[windInfoArray objectAtIndex:3] intValue];    

        if ([windInfoArray count] == 4) direction = DEGREES_TO_CLOCK(direction);
            
        [_windInfoPickerView selectRow:speed inComponent:0 animated:NO];
        [_windInfoPickerView selectRow:[wind_units indexOfObject:unit] inComponent:1 animated:NO];
        [_windInfoPickerView selectRow:(direction == 12) ? 0 : direction inComponent:2 animated:NO];
        [self setWindInfo];
    }
        
    if (_selectedDopeCard.lead_info) {
        NSArray *leadInfoArray = [_selectedDopeCard.lead_info componentsSeparatedByString:@" "];
        int speed      = [[leadInfoArray objectAtIndex:0] intValue];
        NSString *unit = [leadInfoArray objectAtIndex:1];
        int direction  = [[leadInfoArray objectAtIndex:3] intValue];    
        
        if ([leadInfoArray count] == 4) direction = DEGREES_TO_CLOCK(direction);

        [_leadInfoPickerView selectRow:speed inComponent:0 animated:NO];
        [_leadInfoPickerView selectRow:[wind_units indexOfObject:unit] inComponent:1 animated:NO];
        [_leadInfoPickerView selectRow:(direction == 12) ? 0 : direction inComponent:2 animated:NO];
        [self setLeadInfo];
    }
    
    [_dopeUnitPickerView selectRow:[range_units indexOfObject:_selectedDopeCard.range_unit] inComponent:0 animated:NO];
    [_dopeUnitPickerView selectRow:[dope_units indexOfObject:_selectedDopeCard.drop_unit] inComponent:1 animated:NO];
    [_dopeUnitPickerView selectRow:[dope_units indexOfObject:_selectedDopeCard.drift_unit] inComponent:2 animated:NO];
    [self setDopeUnits];
    
    dopeCardCellData = [_selectedDopeCard.dope_data mutableCopy];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TestFlight passCheckpoint:@"DopeCardsAddEdit unloaded"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([dopeCardCellData count] / 3 );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DopeCardRowEditCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DopeCardEditRowCell"];
        
    if (_selectedDopeCard && (([dopeCardCellData count] / 3) > (indexPath.row))) {
        cell.rangeField.text = [dopeCardCellData objectAtIndex:(indexPath.row * 3 + 0)];
        cell.dropField.text  = [dopeCardCellData objectAtIndex:(indexPath.row * 3 + 1)];
        cell.driftField.text = [dopeCardCellData objectAtIndex:(indexPath.row * 3 + 2)];
    } else {
        cell.rangeField.text = @"";
        cell.dropField.text  = @"";
        cell.driftField.text = @"";
    }

    cell.tag = indexPath.row;
    
    cell.rangeField.tag = 1;
    cell.dropField.tag  = 2;
    cell.driftField.tag = 3;

    cell.rangeField.delegate = cell.dropField.delegate = cell.driftField.delegate = self;
    
    cell.rangeField.keyboardType = UIKeyboardTypeNumberPad;
    cell.dropField.keyboardType = cell.driftField.keyboardType = UIKeyboardTypeDecimalPad;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor colorWithRed:0.855 green:0.812 blue:0.682 alpha:1.000];
}  

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _sectionHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(_sectionHeader.frame);
}

#pragma mark - Picker view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return (pickerView == _zeroUnitPickerView) ? 1 : 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _zeroUnitPickerView) {
        return [range_units count];
    } else if (pickerView == _dopeUnitPickerView) {
        return (component == 0) ? [range_units count] : [dope_units count];
    } else { // wind picker
        switch (component) {
            case 0: // speed
                return 25;
                break;
            case 1: // units
                return [wind_units count];
                break;
            case 2: // clock direction
                return [wind_directions count];
                break;
            default:
                return -1;
                break;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _zeroUnitPickerView) {
        return [range_units objectAtIndex:row];
    } else if (pickerView == _dopeUnitPickerView) {
        return (component == 0) ? [range_units objectAtIndex:row] : [dope_units objectAtIndex:row];
    } else { // wind picker
        switch (component) {
            case 0: //speed
                return [NSString stringWithFormat:@"%d", row];
                break;
            case 1: // units
                return [wind_units objectAtIndex:row];
                break;
            case 2: // clock direction
                return [wind_directions objectAtIndex:row];
                break;
            default:
                return nil;
                break;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == _zeroUnitPickerView) {
        [self setZeroUnit];
    } else if (pickerView == _dopeUnitPickerView) {
        [self setDopeUnits];
    } else if (pickerView == _windInfoPickerView) {
        [self setWindInfo];
    } else if (pickerView == _leadInfoPickerView) {
        [self setLeadInfo];
    } 
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (pickerView == _zeroUnitPickerView) {
        return 284.f;
    } else if (pickerView == _dopeUnitPickerView) {
        return 95.0f;
    } else {
        switch (component) {
            case 0:
                return 80.0f;
                break;
            case 1:
                return 84.0f;
                break;
            case 2:
                return 120.0f;
                break;
            default:
                return 0.0f;
                break;
        }
    }
}

-(void)setZeroUnit {
    _zeroUnitField.text = [range_units objectAtIndex:[_zeroUnitPickerView selectedRowInComponent:0]];
}

-(void)setDopeUnits {
    _rangeUnitField.text = [range_units objectAtIndex:[_dopeUnitPickerView selectedRowInComponent:0]];
    _dropUnitField.text  = [dope_units objectAtIndex:[_dopeUnitPickerView selectedRowInComponent:1]];
    _driftUnitField.text = [dope_units objectAtIndex:[_dopeUnitPickerView selectedRowInComponent:2]];
}

-(void)setWindInfo {
    _windInfoField.text = [NSString stringWithFormat:@"%d %@ at %@", 
                               [_windInfoPickerView selectedRowInComponent:0],
                               [wind_units objectAtIndex:[_windInfoPickerView selectedRowInComponent:1]],
                               [wind_directions objectAtIndex:[_windInfoPickerView selectedRowInComponent:2]]];
}

-(void)setLeadInfo {
    _leadInfoField.text = [NSString stringWithFormat:@"%d %@ at %@", 
                               [_leadInfoPickerView selectedRowInComponent:0],
                               [wind_units objectAtIndex:[_leadInfoPickerView selectedRowInComponent:1]],
                               [wind_directions objectAtIndex:[_leadInfoPickerView selectedRowInComponent:2]]];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    UIToolbar* textFieldToolBarView = [[UIToolbar alloc] init];
    textFieldToolBarView.barStyle = UIBarStyleBlack;
    textFieldToolBarView.translucent = YES;
    textFieldToolBarView.tintColor = nil;
    [textFieldToolBarView sizeToFit];

    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                             NSLocalizedString(@"Previous",@"Previous form field"),
                                                                             NSLocalizedString(@"Next",@"Next form field"),                                         
                                                                             nil]];
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.tintColor = [UIColor darkGrayColor];
    control.momentary = YES;
    [control addTarget:self action:@selector(nextPreviousTapped:) forControlEvents:UIControlEventValueChanged];     
    
    UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                           target:self action:@selector(doneTyping:)];
    
    if ([formFields containsObject:textField]) {
        if ((textField == _rangeUnitField) || (textField == _dropUnitField) || (textField == _driftUnitField)) {
            [self.tableView setContentOffset:CGPointMake(0.f, 130.f) animated:YES];
        } else if (textField.frame.origin.y > 125.f) {
            [self.tableView setContentOffset:CGPointMake(0.f, textField.frame.origin.y - 120.f) animated:YES];            
        }
    }
    

    if (![formFields containsObject:textField] && textField.tag != 1) {
        UIBarButtonItem *flipSign  = [[UIBarButtonItem alloc] initWithTitle:@" ± " 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(flipSignTapped:)];
        
        [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, flipSign, space, done, nil]];
    } else {
        if ([formFields indexOfObject:textField] == 0) [control setEnabled:NO forSegmentAtIndex:0];
        [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    }
    textField.inputAccessoryView = textFieldToolBarView;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // update dopeCardCellData
    if (![formFields containsObject:textField]) {
        if ([textField.text isEqualToString:@""] && textField.tag > 1)
            textField.text = @"0.0";
            
        [dopeCardCellData replaceObjectAtIndex:[self indexForTextField:textField] - formFields.count withObject:textField.text];
    }
    
    if ([formFields containsObject:textField]) {
        [self.tableView setContentOffset:CGPointMake(0.f, 0.f) animated:YES];
    }

    _currentTextField = nil;
}

- (void)nextPreviousTapped:(id)sender {
    if (_currentTextField == _zeroTextField) {
        [self setZeroUnit];  
    } else if (_currentTextField == _rangeUnitField) {
        [self setDopeUnits];
    } else if (_currentTextField == _windInfoField) {
        [self setWindInfo];
    } else if (_currentTextField == _leadInfoField) {
        [self setLeadInfo];
    } 
        
    int index = [self indexForTextField:_currentTextField];
    
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            index--;
            break;
        case 1: //next
            if ([formFields containsObject:_currentTextField]) {
                index++;
            } else if (_currentTextField.superview.superview.tag < [self.tableView numberOfRowsInSection:0] - 1) {
                index++;
            } else if (_currentTextField.tag == 3) { // if last textfield in last row in table, add new row if not empty string
                int row = _currentTextField.superview.superview.tag;
                DopeCardRowEditCell *cell = (DopeCardRowEditCell *)_currentTextField.superview.superview;
                
                if (![cell.rangeField.text isEqualToString:@""]) {
                    [dopeCardCellData addObject:@""];
                    [dopeCardCellData addObject:@""];
                    [dopeCardCellData addObject:@""];
                    
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row + 1 inSection:0]] 
                                          withRowAnimation:UITableViewRowAnimationBottom];

                    index++;
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Blank Range"
                                                message:@"Enter a range to add a new row" 
                                               delegate:nil 
                                      cancelButtonTitle:nil 
                                      otherButtonTitles:@"OK", nil] show];
                }
            } else {
                index++;
            }
            break;
    }

    _currentTextField = [self textFieldForIndex:index];
    [_currentTextField becomeFirstResponder];
}

- (void)doneTyping:(id)sender {
    if (_currentTextField == _rangeUnitField) {
        [self setDopeUnits];
    } else if (_currentTextField == _windInfoField) {
        [self setWindInfo];
    } else if (_currentTextField == _leadInfoField) {
        [self setLeadInfo];
    }
    
    [_currentTextField resignFirstResponder];
}

-(void)flipSignTapped:(id)sender {
    NSDecimalNumber *flip = [NSDecimalNumber decimalNumberWithString:@"-1"];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:_currentTextField.text];
    _currentTextField.text = [[number decimalNumberByMultiplyingBy:flip] stringValue];
}

-(UITextField*)textFieldForIndex:(int)index {
    if (index < formFields.count) {
        return [formFields objectAtIndex:index];
    } else {
        int row = (index - formFields.count) / 3;
        int tag = ((index - formFields.count) % 3) + 1;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        return (UITextField *)[cell.contentView viewWithTag:tag];
    }
}

-(int)indexForTextField:(UITextField*)textField {
    if ([formFields containsObject:textField]) {
        return [formFields indexOfObject:textField];
    } else {
        int row = (textField.superview.superview.tag * 3);
        int tag = textField.tag - 1;
        
        return formFields.count + row + tag;
    }
}

# pragma mark Save Data

- (IBAction)saveTapped:(id)sender {
    if (![_cardNameTextField.text isEqualToString:@""]) {
        DopeCard *newDopeCard       = _selectedDopeCard ? _selectedDopeCard : [DopeCard createEntity];
        newDopeCard.name            = _cardNameTextField.text;
        newDopeCard.zero            = _zeroTextField.text;
        newDopeCard.zero_unit       = [NSNumber numberWithInt:[_zeroUnitPickerView selectedRowInComponent:0]];
        newDopeCard.muzzle_velocity = _muzzleVelocityTextField.text;
        newDopeCard.weather_info    = _weatherInfoField.text;
        newDopeCard.wind_info       = _windInfoField.text;
        newDopeCard.lead_info       = _leadInfoField.text;
        newDopeCard.notes           = _notesTextField.text;
        newDopeCard.range_unit      = _rangeUnitField.text;
        newDopeCard.drop_unit       = _dropUnitField.text;
        newDopeCard.drift_unit      = _driftUnitField.text;    
        
        // check if range is blank, remove row if true
        if ([[dopeCardCellData objectAtIndex:dopeCardCellData.count - 3] isEqualToString:@""])
            [dopeCardCellData removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(dopeCardCellData.count -3, 3)]];
        
        // check for empty data, set to 0.0 if empty
        for (int i = 0; i < dopeCardCellData.count; i++)
            if ([[dopeCardCellData objectAtIndex:i] isEqualToString:@""])
                [dopeCardCellData replaceObjectAtIndex:i withObject:@"0.0"];        
        
        [newDopeCard setDope_data:[NSArray arrayWithArray:dopeCardCellData]];

        [[NSNotificationCenter defaultCenter] postNotificationName:_selectedDopeCard ? @"editedDopeCard" : @"newDopeCard" object:newDopeCard];

        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
