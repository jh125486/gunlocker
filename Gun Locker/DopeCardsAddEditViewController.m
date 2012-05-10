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
@synthesize scrollView;
@synthesize cardNameTextField;
@synthesize zeroTextField, muzzleVelocityTextField;
@synthesize weatherInfoField;
@synthesize windInfoField, windInfoPickerView, leadInfoField, leadInfoPickerView;
@synthesize notesTextField;
@synthesize rangeUnitField, dropUnitField, driftUnitField, dopeUnitPickerView;
@synthesize tableView;
@synthesize currentTextField;
@synthesize selectedDopeCard;

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
    
    dopeFields = [[NSMutableArray alloc] init];
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
    
    formFields = [[NSMutableArray alloc] initWithObjects:self.cardNameTextField, 
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    if (selectedDopeCard) [self loadDopeCard];
}

- (void)loadDopeCard {
    // TODO set pickers to correct values
    
    self.title = @"Edit Dope Card";
    self.cardNameTextField.text       = selectedDopeCard.name;
    self.zeroTextField.text           = selectedDopeCard.zero;
    self.muzzleVelocityTextField.text = selectedDopeCard.muzzle_velocity;
    self.weatherInfoField.text        = selectedDopeCard.weather_info;
    self.windInfoField.text           = selectedDopeCard.wind_info;
    self.leadInfoField.text           = selectedDopeCard.lead_info;
    self.notesTextField.text          = selectedDopeCard.notes;
    self.rangeUnitField.text          = selectedDopeCard.range_unit;
    self.dropUnitField.text           = selectedDopeCard.drop_unit;
    self.driftUnitField.text          = selectedDopeCard.drift_unit;
    
    dopeCardCellData = selectedDopeCard.dope_data;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setScrollView:nil];
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
    return ([dopeCardCellData count] / 3 ) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DopeCardRowEditCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DopeCardEditRowCell"];
    
    [dopeFields addObjectsFromArray:[NSArray arrayWithObjects:cell.rangeField, cell.dropField, cell.driftField, nil]];
    [formFields addObjectsFromArray:[NSArray arrayWithObjects:cell.rangeField, cell.dropField, cell.driftField, nil]];
    
    if (selectedDopeCard && (([dopeCardCellData count] / 3) > (indexPath.row))) {
        cell.rangeField.text = [dopeCardCellData objectAtIndex:(indexPath.row * 3 + 0)];
        cell.dropField.text  = [dopeCardCellData objectAtIndex:(indexPath.row * 3 + 1)];
        cell.driftField.text = [dopeCardCellData objectAtIndex:(indexPath.row * 3 + 2)];
    } else {
        cell.rangeField.text = @"";
        cell.dropField.text  = @"";
        cell.driftField.text = @"";
    }
    
    cell.rangeField.delegate = cell.dropField.delegate = cell.driftField.delegate = self;
    
    cell.rangeField.keyboardType = UIKeyboardTypeNumberPad;
    cell.dropField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.driftField.keyboardType = UIKeyboardTypeDecimalPad;    

    cell.tag = indexPath.row;
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

    if ([dopeFields containsObject:self.currentTextField] && [dopeFields indexOfObject:self.currentTextField] % 3 != 0) {
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
    self.currentTextField = nil;
}

- (void)nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:self.currentTextField];
    
    if (currentTextField == rangeUnitField) {
        [self setDopeUnits];
    } else if (currentTextField == windInfoField) {
        [self setWindInfo];
    } else if (currentTextField == leadInfoField) {
        [self setLeadInfo];
    }
    
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            index--;
            break;
        case 1: //next            
            if ([dopeFields containsObject:self.currentTextField] && [self.currentTextField isEqual:[dopeFields lastObject]]) {
                int row = [dopeFields indexOfObject:self.currentTextField] / 3;
                // if last textfield in dope card row, and last row in table, add new row
                DopeCardRowEditCell *cell = (DopeCardRowEditCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
                if (![cell.rangeField.text isEqualToString:@""]) {
                    [dopeCardCellData addObject:cell.rangeField.text];
                    [dopeCardCellData addObject:cell.dropField.text];
                    [dopeCardCellData addObject:cell.driftField.text];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row + 1 inSection:0 ]] 
                                          withRowAnimation:UITableViewRowAnimationBottom];
                    index++;
                }
            } else {
                index++;
            }
            break;
    }
    
    self.currentTextField = [formFields objectAtIndex:index];
    [self.currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
    if (currentTextField == self.rangeUnitField) {
        [self setDopeUnits];
    } else if (currentTextField == self.windInfoField) {
        [self setWindInfo];
    } else if (currentTextField == self.leadInfoField) {
        [self setLeadInfo];
    }
    
    [self.currentTextField resignFirstResponder];
}

-(void)flipSignTapped:(id)sender {
    NSDecimalNumber *flip = [NSDecimalNumber decimalNumberWithString:@"-1"];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:self.currentTextField.text];
    self.currentTextField.text = [[number decimalNumberByMultiplyingBy:flip] stringValue];
}

# pragma mark Moving content under the keyboard

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    double originY = currentTextField.frame.origin.y;
    
    if ((currentTextField == self.rangeUnitField) || (currentTextField == self.dropUnitField) || (currentTextField == self.driftUnitField)) {
        UILabel *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 10, 283, 35)];
        pickerLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_header"]];
        pickerLabel.text = @"   Range       Drop         Drift";
        pickerLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
        pickerLabel.textColor = [UIColor lightGrayColor];
        pickerLabel.shadowColor = [UIColor whiteColor];
        pickerLabel.shadowOffset = CGSizeMake (0,-1);
        [dopeUnitPickerView insertSubview:pickerLabel atIndex:20];
        originY += self.tableView.frame.origin.y;
    } else if ((currentTextField == self.windInfoField) || (currentTextField == self.leadInfoField)) {
        UILabel *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 10, 282, 35)];
        pickerLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableview_header"]];
        pickerLabel.text = @" Speed      Unit        Direction";
        pickerLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:24];
        pickerLabel.textColor = [UIColor lightGrayColor];
        pickerLabel.shadowColor = [UIColor whiteColor];
        pickerLabel.shadowOffset = CGSizeMake (0,-1);
        if (currentTextField == self.windInfoField) {            
            [windInfoPickerView insertSubview:pickerLabel atIndex:20];
        } else if (currentTextField == self.leadInfoField) {
            [leadInfoPickerView insertSubview:pickerLabel atIndex:20];            
        }
    }
    
    if ([dopeFields containsObject:currentTextField]) {
        CGRect frame = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:[dopeFields indexOfObject:currentTextField]/3 inSection:0]];
        originY = frame.origin.y + self.tableView.frame.origin.y;
    }
    
    CGPoint currentOrigin = CGPointMake(currentTextField.frame.origin.x, originY);
    CGRect aRect = CGRectMake(0, self.scrollView.frame.size.height - kbSize.height, kbSize.width, kbSize.height);
    
    if (CGRectContainsPoint(aRect, currentOrigin)) {
        [scrollView setContentOffset:CGPointMake(0.0, currentOrigin.y - currentTextField.frame.size.height - 90) animated:YES];
    } else {
        [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [scrollView setContentOffset:CGPointZero animated:YES];
    scrollView.scrollIndicatorInsets = contentInsets;
}

# pragma mark Save Data
- (IBAction)saveTapped:(id)sender {
    if (![self.cardNameTextField.text isEqualToString:@""]) {
        DopeCard *newDopeCard       = selectedDopeCard ? selectedDopeCard : [DopeCard createEntity];
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
        
        
        NSMutableArray *data = [[NSMutableArray alloc] init];
        UITextField *t1, *t2, *t3;
        for (int index = 0; index < [dopeFields count]; index += 3) {
            t1 = [dopeFields objectAtIndex:index];
            t2 = [dopeFields objectAtIndex:index + 1];
            t3 = [dopeFields objectAtIndex:index + 2];
            if ((![t1.text isEqualToString:@""]) && (![t2.text isEqualToString:@""])) {
                [data addObject:t1.text];
                [data addObject:t2.text];
                [data addObject:t3.text];
            }
        }
        newDopeCard.dope_data = data;
            
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newDopeCard" object:newDopeCard];

        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
