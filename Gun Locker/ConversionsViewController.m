//
//  ConversionsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversionsViewController.h"

@implementation ConversionsViewController

@synthesize length1UnitTextField = _length1UnitTextField, length2UnitTextField = _length2UnitTextField;
@synthesize length1UnitButton = _length1UnitButton, length1TextField = _length1TextField;
@synthesize length2UnitButton = _length2UnitButton, length2TextField = _length2TextField;
@synthesize lengthUnitPicker = _lengthUnitPicker;

@synthesize weight1UnitTextField = _weight1UnitTextField, weight2UnitTextField = _weight2UnitTextField;
@synthesize weight1UnitButton = _weight1UnitButton, weight1TextField = _weight1TextField;
@synthesize weight2UnitButton = _weight2UnitButton, weight2TextField = _weight2TextField;
@synthesize weightUnitPicker = _weightUnitPicker;

@synthesize currentTextField = _currentTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];

    _lengthUnitPicker = [[UIPickerView alloc] init];
    _weightUnitPicker = [[UIPickerView alloc] init];
    _lengthUnitPicker.showsSelectionIndicator = _weightUnitPicker.showsSelectionIndicator = YES;
    _lengthUnitPicker.delegate = _weightUnitPicker.delegate = self;
    
    
    formFields = [NSArray arrayWithObjects:_length1UnitTextField,
                                           _length2UnitTextField,
                                           _length1TextField, 
                                           _length2TextField,
                                           _weight1UnitTextField,
                                           _weight2UnitTextField,
                                           _weight1TextField, 
                                           _weight2TextField, nil];

    for(UITextField *field in formFields)
        field.delegate = self;
    lastLengthSelected = lastWeightSelected = -1;
    
    _length1UnitTextField.enabled = _length2UnitTextField.enabled = _weight1UnitTextField.enabled = _weight2UnitTextField.enabled = YES;
    _length1UnitTextField.inputView = _length2UnitTextField.inputView = _lengthUnitPicker;
    _weight1UnitTextField.inputView = _weight2UnitTextField.inputView = _weightUnitPicker;

    _length1TextField.enabled = _length2TextField.enabled = _weight1TextField.enabled = _weight2TextField.enabled = NO;
    _length1TextField.keyboardType = _length2TextField.keyboardType = _weight1TextField.keyboardType = _weight2TextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    lengthUnits = [NSArray arrayWithObjects:@"Meters", @"Yards", @"Feet", nil];
    weightUnits = [NSArray arrayWithObjects:@"Pounds", @"Grains", @"Kilograms", @"Grams", nil];
    
    lengthConversionsToMeters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDecimalNumber decimalNumberWithString:@"1"], @"Meters",
                                                                             [NSDecimalNumber decimalNumberWithString:@"1.0936133"], @"Yards",
                                                                             [NSDecimalNumber decimalNumberWithString:@"3.2808399"], @"Feet",nil];

    weightConversionsToGrams = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDecimalNumber decimalNumberWithString:@"0.0022046226"], @"Pounds",
                                                                            [NSDecimalNumber decimalNumberWithString:@"15.43235869"], @"Grains",
                                                                            [NSDecimalNumber decimalNumberWithString:@"0.001"], @"Kilograms",
                                                                            [NSDecimalNumber decimalNumberWithString:@"1"], @"Grams",nil];

    [_lengthUnitPicker selectRow:0 inComponent:0 animated:NO];
    [_lengthUnitPicker selectRow:0 inComponent:1 animated:NO];
    [_weightUnitPicker selectRow:0 inComponent:0 animated:NO];
    [_weightUnitPicker selectRow:0 inComponent:1 animated:NO];
}

- (void)viewDidUnload {
    [self setLengthUnitPicker:nil];
    [self setWeightUnitPicker:nil];
    [self setLength1UnitTextField:nil];
    [self setLength2UnitTextField:nil];
    [self setWeight1UnitTextField:nil];
    [self setWeight2UnitTextField:nil];
    [self setLength1UnitButton:nil];
    [self setLength2UnitButton:nil];
    [self setWeight1UnitButton:nil];
    [self setWeight2UnitButton:nil];
    [self setLength1TextField:nil];
    [self setLength2TextField:nil];
    [self setWeight1TextField:nil];
    [self setWeight2TextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), 30.0f)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 6.0f, CGRectGetWidth(headerView.frame) - 20.0f, 24.0f)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0f];
	label.shadowColor = [UIColor clearColor];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

#pragma mark TextField delegates
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
    
    if ([formFields indexOfObject:textField] == 0) {
        [control setEnabled:NO forSegmentAtIndex:0];
    } else if ([formFields  lastObject] == textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    } else if (![formFields containsObject:textField]){
        controlItem = space;
    }
    
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBarView;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == _length1TextField) {
        lastLengthSelected = 0;
    } else if (textField == _length2TextField) {
        lastLengthSelected = 1;
    } else if (textField == _weight1TextField) {
        lastWeightSelected = 0;
    } else if (textField == _weight2TextField) {
        lastWeightSelected = 1;
    }
    
    [self setButtonSelectedForTextField:textField andState:YES];
    
    _currentTextField = textField;   
}

-(void)setButtonSelectedForTextField:(UITextField *)textField andState:(BOOL)state {
    if (textField == _length1UnitTextField) {
        [_length1UnitButton setSelected:state];
    } else if (textField == _length2UnitTextField) {
        [_length2UnitButton setSelected:state];
    } else if (textField == _weight1UnitTextField) {
        [_weight1UnitButton setSelected:state];
    } else if (textField == _weight2UnitTextField) {
        [_weight2UnitButton setSelected:state];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setButtonSelectedForTextField:textField andState:NO];
    
    _currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
    [self setUnits];

    int index = [formFields indexOfObject:_currentTextField];
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            if (index > 0) index--;
            break;
        case 1: //next
            if (index < ([formFields count] - 1)) index++;
            break;
    }
    
    _currentTextField = [formFields objectAtIndex:index];
    [_currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
    [self setUnits];
    [_currentTextField resignFirstResponder];
}

-(void)setUnits {
    if ((_currentTextField == _length1UnitTextField) || (_currentTextField == _length2UnitTextField)) {
        [self setLengthUnits];
    } else if ((_currentTextField == _weight1UnitTextField) || (_currentTextField == _weight2UnitTextField)) {
        [self setWeightUnits];
    }
}

#pragma mark Conversions

- (IBAction)convertLength:(id)sender { 
    if (lastLengthSelected == 0) { // left unit last edited
        if ((_length1TextField.text.length == 0)) {
            _length2TextField.text = @"0";
        } else {
            NSDecimalNumber *length1InMeters = [[NSDecimalNumber decimalNumberWithString:_length1TextField.text] decimalNumberByDividingBy:[lengthConversionsToMeters objectForKey:length1Unit]];
            _length2TextField.text = [NSString stringWithFormat:@"%g", [[length1InMeters decimalNumberByMultiplyingBy:[lengthConversionsToMeters objectForKey:length2Unit]] doubleValue]];
        }
    } else { // right unit last edited        
        if (_length2TextField.text.length == 0) {
            _length1TextField.text = @"0";
        } else {
            NSDecimalNumber *length2InMeters = [[NSDecimalNumber decimalNumberWithString:_length2TextField.text] decimalNumberByDividingBy:[lengthConversionsToMeters objectForKey:length2Unit]];            
            _length1TextField.text = [NSString stringWithFormat:@"%g", [[length2InMeters decimalNumberByMultiplyingBy:[lengthConversionsToMeters objectForKey:length1Unit]] doubleValue]];
        }
    }
}

- (IBAction)convertWeight:(id)sender {
    if (lastWeightSelected == 0) { // left unit last edited
        if (_weight1TextField.text.length == 0) {
            _weight2TextField.text = @"0";
        } else {
            NSDecimalNumber *length1InMeters = [[NSDecimalNumber decimalNumberWithString:_weight1TextField.text] decimalNumberByDividingBy:[weightConversionsToGrams objectForKey:weight1Unit]];
            _weight2TextField.text = [NSString stringWithFormat:@"%g", [[length1InMeters decimalNumberByMultiplyingBy:[weightConversionsToGrams objectForKey:weight2Unit]] doubleValue]];            
        }
    } else { // right unit last edited
        if (_weight2TextField.text.length == 0) {
            _weight1TextField.text = @"0";
        } else {
            NSDecimalNumber *weight2InMeters = [[NSDecimalNumber decimalNumberWithString:_weight2TextField.text] decimalNumberByDividingBy:[weightConversionsToGrams objectForKey:weight2Unit]];
            _weight1TextField.text = [NSString stringWithFormat:@"%g", [[weight2InMeters decimalNumberByMultiplyingBy:[weightConversionsToGrams objectForKey:weight1Unit]] doubleValue]];            
        }
    }
}

- (IBAction)chooseUnitTapped:(UIButton *)sender {
    if (sender == _length1UnitButton) {
        [_length1UnitTextField becomeFirstResponder];
    } else if (sender == _length2UnitButton) {
        [_length2UnitTextField becomeFirstResponder];
    } else if (sender == _weight1UnitButton) {
        [_weight1UnitTextField becomeFirstResponder];
    } else if (sender == _weight2UnitButton) {
        [_weight2UnitTextField becomeFirstResponder];
    }
}

#pragma mark Pickerviews

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _lengthUnitPicker) {
        return [lengthUnits objectAtIndex:row];
    } else if (pickerView == _weightUnitPicker) {
        return [weightUnits objectAtIndex:row];
    } else {
        return @"";
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _lengthUnitPicker) {
        return [lengthUnits count];
    } else if (pickerView == _weightUnitPicker) {
        return [weightUnits count];
    } else {
        return 0;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == _lengthUnitPicker) {
        lastLengthSelected = component;
        [self setLengthUnits];
    } else if (pickerView == _weightUnitPicker) {
        lastWeightSelected = component;
        [self setWeightUnits];
    }
}

-(void)setLengthUnits {
    _length1TextField.enabled = _length2TextField.enabled = YES;
    length1Unit = [lengthUnits objectAtIndex:[_lengthUnitPicker selectedRowInComponent:0]];
    length2Unit = [lengthUnits objectAtIndex:[_lengthUnitPicker selectedRowInComponent:1]];
    
    [_length1UnitButton setTitle:length1Unit forState:UIControlStateNormal];
    [_length1UnitButton setTitle:length1Unit forState:UIControlStateSelected];

    [_length2UnitButton setTitle:length2Unit forState:UIControlStateNormal];
    [_length2UnitButton setTitle:length2Unit forState:UIControlStateSelected];
    
    _length1UnitButton.titleLabel.textAlignment = _length2UnitButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [self convertLength:nil];
}

-(void)setWeightUnits {
    _weight1TextField.enabled = _weight2TextField.enabled = YES;
    weight1Unit = [weightUnits objectAtIndex:[_weightUnitPicker selectedRowInComponent:0]];
    weight2Unit = [weightUnits objectAtIndex:[_weightUnitPicker selectedRowInComponent:1]];

    [_weight1UnitButton setTitle:weight1Unit forState:UIControlStateNormal];
    [_weight1UnitButton setTitle:weight1Unit forState:UIControlStateSelected];
    
    [_weight2UnitButton setTitle:weight2Unit forState:UIControlStateNormal];
    [_weight2UnitButton setTitle:weight2Unit forState:UIControlStateSelected];

    _weight1UnitButton.titleLabel.textAlignment = _weight2UnitButton.titleLabel.textAlignment = UITextAlignmentCenter;

    [self convertWeight:nil];
}

@end
