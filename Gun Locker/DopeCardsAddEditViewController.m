//
//  DopeCardsAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardsAddEditViewController.h"

@implementation DopeCardsAddEditViewController
@synthesize sectionHeader;
@synthesize cardNameTextField;
@synthesize zeroTextField, muzzleVelocityTextField;
@synthesize weatherInfoField;
@synthesize windInfoField, windInfoPickerView, leadInfoField, leadInfoPickerView;
@synthesize notesTextField;
@synthesize rangeUnitField, dropUnitField, driftUnitField, dopeUnitPickerView;
@synthesize currentTextField;
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
    dataManager = [DataManager sharedManager];
    range_units = dataManager.rangeUnits;
    dope_units  = dataManager.dopeUnits;
    wind_units  = dataManager.windUnits;
    wind_directions = [[NSMutableArray alloc] initWithObjects:@"12 o'clock", nil];
    for (int i = 1; i < 12; i++)
        [wind_directions addObject:[NSString stringWithFormat:@"%d o'clock", i]];
    
    dopeCardCellData = [[NSMutableArray alloc] init];
    
    // inputView pickers
    dopeUnitPickerView = [[UIPickerView alloc] init];    
    windInfoPickerView = [[UIPickerView alloc] init];
    leadInfoPickerView = [[UIPickerView alloc] init];
    
    dopeUnitPickerView.delegate   = windInfoPickerView.delegate   = leadInfoPickerView.delegate   = self;
    dopeUnitPickerView.dataSource = windInfoPickerView.dataSource = leadInfoPickerView.dataSource = self;
    dopeUnitPickerView.showsSelectionIndicator = windInfoPickerView.showsSelectionIndicator = leadInfoPickerView.showsSelectionIndicator = YES;
    
    rangeUnitField.inputView = dropUnitField.inputView = driftUnitField.inputView = dopeUnitPickerView;
    windInfoField.inputView  = windInfoPickerView;
    leadInfoField.inputView = leadInfoPickerView;
    
    formFields = [[NSArray alloc] initWithObjects:self.cardNameTextField, 
                                                  self.zeroTextField, 
                                                  self.muzzleVelocityTextField,
                                                  self.weatherInfoField,
                                                  self.windInfoField, 
                                                  self.leadInfoField,
                                                  self.notesTextField, 
                                                  self.rangeUnitField, 
                                                  self.dropUnitField, 
                                                  self.driftUnitField, 
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
    self.cardNameTextField.text       = _selectedDopeCard.name;
    self.zeroTextField.text           = _selectedDopeCard.zero;
    self.muzzleVelocityTextField.text = _selectedDopeCard.muzzle_velocity;
    self.weatherInfoField.text        = _selectedDopeCard.weather_info;
    self.windInfoField.text           = _selectedDopeCard.wind_info;
    self.leadInfoField.text           = _selectedDopeCard.lead_info;
    self.notesTextField.text          = _selectedDopeCard.notes;
    self.rangeUnitField.text          = _selectedDopeCard.range_unit;
    self.dropUnitField.text           = _selectedDopeCard.drop_unit;
    self.driftUnitField.text          = _selectedDopeCard.drift_unit;
    
    dopeCardCellData = [_selectedDopeCard.dope_data mutableCopy];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setCardNameTextField:nil];
    [self setZeroTextField:nil];
    [self setMuzzleVelocityTextField:nil];
    [self setWeatherInfoField:nil];
    [self setWindInfoField:nil];
    [self setLeadInfoField:nil];
    [self setNotesTextField:nil];
    [self setRangeUnitField:nil];
    [self setDropUnitField:nil];
    [self setDriftUnitField:nil];
    [self setSectionHeader:nil];
    [self setTableView:nil];
    [super viewDidUnload];
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
    return self.sectionHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(self.sectionHeader.frame);
}

#pragma mark - Picker view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.dopeUnitPickerView) {
        return (component == 0) ? [range_units count] : [dope_units count];
    } else { // wind picker
        switch (component) {
            case 0: // speed
                return 15;
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
    if (pickerView == self.dopeUnitPickerView) {
        return (component == 0) ? [range_units objectAtIndex:row] : [dope_units objectAtIndex:row];
    } else { // wind picker
        switch (component) {
            case 0: //speed
                return [NSString stringWithFormat:@"%5d", row];
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
    if (pickerView == dopeUnitPickerView) {
        [self setDopeUnits];
    } else if (pickerView == self.windInfoPickerView) {
        [self setWindInfo];
    } else if (pickerView == self.leadInfoPickerView) {
        [self setLeadInfo];
    } 
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (pickerView == dopeUnitPickerView) {
        return 95.0;
    } else {
        switch (component) {
            case 0:
                return 80.0;
                break;
            case 1:
                return 84.0;
                break;
            case 2:
                return 120.0;
                break;
            default:
                return 0;
                break;
        }
    }
}

- (void)setDopeUnits {
    self.rangeUnitField.text = [range_units objectAtIndex:[self.dopeUnitPickerView selectedRowInComponent:0]];
    self.dropUnitField.text  = [dope_units objectAtIndex:[self.dopeUnitPickerView selectedRowInComponent:1]];
    self.driftUnitField.text = [dope_units objectAtIndex:[self.dopeUnitPickerView selectedRowInComponent:2]];
}

- (void)setWindInfo {
    self.windInfoField.text = [NSString stringWithFormat:@"%d %@ from %@", 
                               [self.windInfoPickerView selectedRowInComponent:0],
                               [wind_units objectAtIndex:[self.windInfoPickerView selectedRowInComponent:1]],
                               [wind_directions objectAtIndex:[self.windInfoPickerView selectedRowInComponent:2]]];
}

- (void)setLeadInfo {
    self.leadInfoField.text = [NSString stringWithFormat:@"%d %@ at %@", 
                               [self.leadInfoPickerView selectedRowInComponent:0],
                               [wind_units objectAtIndex:[self.leadInfoPickerView selectedRowInComponent:1]],
                               [wind_directions objectAtIndex:[self.leadInfoPickerView selectedRowInComponent:2]]];
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
    self.currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // update dopeCardCellData
    if (![formFields containsObject:textField]) {
        if ([textField.text isEqualToString:@""] && textField.tag > 1)
            textField.text = @"0.0";
            
        [dopeCardCellData replaceObjectAtIndex:[self indexForTextField:textField] - formFields.count withObject:textField.text];
    }
    self.currentTextField = nil;
}

- (void)nextPreviousTapped:(id)sender {
    
    if (self.currentTextField == self.rangeUnitField) {
        [self setDopeUnits];
    } else if (self.currentTextField == self.windInfoField) {
        [self setWindInfo];
    } else if (self.currentTextField == self.leadInfoField) {
        [self setLeadInfo];
    } 
        
    int index = [self indexForTextField:self.currentTextField];
    
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            index--;
            break;
        case 1: //next
            if ([formFields containsObject:self.currentTextField]) {
                index++;
            } else if (self.currentTextField.superview.superview.tag < [self.tableView numberOfRowsInSection:0] - 1) {
                index++;
            } else if (self.currentTextField.tag == 3) { // if last textfield in last row in table, add new row if not empty string
                int row = self.currentTextField.superview.superview.tag;
                DopeCardRowEditCell *cell = (DopeCardRowEditCell *)self.currentTextField.superview.superview;
                
                if (![cell.rangeField.text isEqualToString:@""]) {
                    [dopeCardCellData addObject:@""];
                    [dopeCardCellData addObject:@""];
                    [dopeCardCellData addObject:@""];
                    
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row + 1 inSection:0]] 
                                          withRowAnimation:UITableViewRowAnimationBottom];

                    index++;
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Blank Range"
                                                                    message:@"Enter a range to add a new row" 
                                                                   delegate:nil 
                                                          cancelButtonTitle:nil 
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                }
            } else {
                index++;
            }
            break;
    }

    self.currentTextField = [self textFieldForIndex:index];
    [self.currentTextField becomeFirstResponder];
}

- (void)doneTyping:(id)sender {
    if (self.currentTextField == self.rangeUnitField) {
        [self setDopeUnits];
    } else if (self.currentTextField == self.windInfoField) {
        [self setWindInfo];
    } else if (self.currentTextField == self.leadInfoField) {
        [self setLeadInfo];
    }
    
    [self.currentTextField resignFirstResponder];
}

-(void)flipSignTapped:(id)sender {
    NSDecimalNumber *flip = [NSDecimalNumber decimalNumberWithString:@"-1"];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:self.currentTextField.text];
    self.currentTextField.text = [[number decimalNumberByMultiplyingBy:flip] stringValue];
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
    if (![self.cardNameTextField.text isEqualToString:@""]) {
        DopeCard *newDopeCard       = _selectedDopeCard ? _selectedDopeCard : [DopeCard createEntity];
        newDopeCard.name            = self.cardNameTextField.text;
        newDopeCard.zero            = self.zeroTextField.text;
        newDopeCard.muzzle_velocity = self.muzzleVelocityTextField.text;
        newDopeCard.weather_info    = self.weatherInfoField.text;
        newDopeCard.wind_info       = self.windInfoField.text;
        newDopeCard.lead_info       = self.leadInfoField.text;
        newDopeCard.notes           = self.notesTextField.text;
        newDopeCard.range_unit      = self.rangeUnitField.text;
        newDopeCard.drop_unit       = self.dropUnitField.text;
        newDopeCard.drift_unit      = self.driftUnitField.text;    
        
        // check if range is blank, remove row if true
        if ([[dopeCardCellData objectAtIndex:dopeCardCellData.count - 3] isEqualToString:@""])
            [dopeCardCellData removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(dopeCardCellData.count -3, 3)]];
        
        // check for empty data, set to 0.0 if empty
        for (int i = 0; i < dopeCardCellData.count; i++)
            if ([[dopeCardCellData objectAtIndex:i] isEqualToString:@""])
                [dopeCardCellData replaceObjectAtIndex:i withObject:@"0.0"];        
        
        newDopeCard.dope_data = [NSArray arrayWithArray:dopeCardCellData];

        [[NSNotificationCenter defaultCenter] postNotificationName:_selectedDopeCard ? @"editedDopeCard" : @"newDopeCard" object:newDopeCard];

        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
