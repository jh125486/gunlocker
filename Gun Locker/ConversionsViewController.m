//
//  ConversionsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversionsViewController.h"

@implementation ConversionsViewController

@synthesize length1UnitTextField;
@synthesize length2UnitTextField;
@synthesize lengthUnitPicker;
@synthesize length1UnitButton;
@synthesize length1TextField;
@synthesize length2UnitButton;
@synthesize length2TextField;

@synthesize weight1UnitTextField;
@synthesize weight2UnitTextField;
@synthesize weightUnitPicker;
@synthesize weight1UnitButton;
@synthesize weight1TextField;
@synthesize weight2UnitButton;
@synthesize weight2TextField;

@synthesize currentTextField;

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

    self.lengthUnitPicker = [[UIPickerView alloc] init];
    self.weightUnitPicker = [[UIPickerView alloc] init];
    self.lengthUnitPicker.showsSelectionIndicator = self.weightUnitPicker.showsSelectionIndicator = YES;
    self.lengthUnitPicker.delegate = self.weightUnitPicker.delegate = self;
    
    
    formFields = [NSArray arrayWithObjects:self.length1UnitTextField,
                                           self.length2UnitTextField,
                                           self.length1TextField, 
                                           self.length2TextField,
                                           self.weight1UnitTextField,
                                           self.weight2UnitTextField,
                                           self.weight2TextField, 
                                           self.weight2TextField, nil];

    for(UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
        field.enabled = NO;
    }
    lastLengthSelected = lastWeightSelected = -1;
    
    self.length1UnitTextField.enabled = self.length2UnitTextField.enabled = self.weight1UnitTextField.enabled = self.weight2UnitTextField.enabled = YES;
    self.length1UnitTextField.inputView = self.length2UnitTextField.inputView = self.lengthUnitPicker;
    self.weight1UnitTextField.inputView = self.weight2UnitTextField.inputView = self.weightUnitPicker;
    
    lengthUnits = [NSArray arrayWithObjects:@"Meters", @"Yards", @"Feet", nil];
    weightUnits = [NSArray arrayWithObjects:@"Pounds", @"Grains", @"Kilograms", @"Grams", nil];
    
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, headerView.frame.size.width - 20, tableView.sectionHeaderHeight)];
	label.text = sectionTitle;
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:18.0];
	label.shadowColor = [UIColor lightTextColor];
    label.shadowOffset = CGSizeMake(0, 1);
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
    } else if ([formFields indexOfObject:textField] == ([formFields count] -1)) {
        [control setEnabled:NO forSegmentAtIndex:1];
    } else if (![formFields containsObject:formFields]){
        controlItem = space;
    }
    
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBarView;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.length1TextField) {
        lastLengthSelected = 0;
    } else if (textField == self.length2TextField) {
        lastLengthSelected = 1;
    } else if (textField == self.weight1TextField) {
        lastWeightSelected = 0;
    } else if (textField == self.weight2TextField) {
        lastWeightSelected = 1;
    }
    
    self.currentTextField = textField;   
}

- (void)textFieldDidEndEditing:(UITextField *)textField {    
    self.currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:currentTextField];
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            if (index > 0) index--;
            break;
        case 1: //next
            if (index < ([formFields count] - 1)) index++;
            break;
    }
    
    self.currentTextField = [formFields objectAtIndex:index];
    [self.currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {    
    [self.currentTextField resignFirstResponder];
}

#pragma mark Conversions

- (IBAction)convertLength:(id)sender {
    if (lastLengthSelected == 0) {
        self.length2TextField.text = [NSString stringWithFormat:@"%f", [self.length1TextField.text doubleValue] * M_PI];
    } else {
        self.length1TextField.text = [NSString stringWithFormat:@"%f", [self.length2TextField.text doubleValue] * M_PI];
    }
}

- (IBAction)convertWeight:(id)sender {
    if (lastWeightSelected == 0) {
        self.weight2TextField.text = [NSString stringWithFormat:@"%f", [self.weight1TextField.text doubleValue] * M_PI];
    } else {
        self.weight1TextField.text = [NSString stringWithFormat:@"%f", [self.weight2TextField.text doubleValue] * M_PI];
    }
}

- (IBAction)chooseUnit:(UIButton *)sender {
    if (sender == self.length1UnitButton) {
        [self.length1UnitTextField becomeFirstResponder];
    } else if (sender == self.length2UnitButton) {
        [self.length2UnitTextField becomeFirstResponder];
    } else if (sender == self.weight1UnitButton) {
        [self.weight1UnitTextField becomeFirstResponder];
    } else if (sender == self.weight2UnitButton) {
        [self.weight2UnitTextField becomeFirstResponder];
    }
}

#pragma mark Pickerviews

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.lengthUnitPicker) {
        return [lengthUnits objectAtIndex:row];
    } else if (pickerView == self.weightUnitPicker) {
        return [weightUnits objectAtIndex:row];
    } else {
        return @"";
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.lengthUnitPicker) {
        return [lengthUnits count];
    } else if (pickerView == self.weightUnitPicker) {
        return [weightUnits count];
    } else {
        return 0;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.lengthUnitPicker) {
        if (lastLengthSelected == -1) self.length1TextField.enabled = self.length2TextField.enabled = YES;
        self.length1UnitButton.titleLabel.text = [lengthUnits objectAtIndex:[self.lengthUnitPicker selectedRowInComponent:0]];
        self.length2UnitButton.titleLabel.text = [lengthUnits objectAtIndex:[self.lengthUnitPicker selectedRowInComponent:1]];
        self.length1UnitButton.titleLabel.textAlignment = self.length2UnitButton.titleLabel.textAlignment = UITextAlignmentCenter;
        lastLengthSelected = component;
        [self convertLength:nil];
    } else if (pickerView == self.weightUnitPicker) {
        if (lastWeightSelected == -1) self.length1TextField.enabled = self.length2TextField.enabled = YES;
        self.weight1UnitButton.titleLabel.text = [weightUnits objectAtIndex:[self.weightUnitPicker selectedRowInComponent:0]];
        self.weight2UnitButton.titleLabel.text = [weightUnits objectAtIndex:[self.weightUnitPicker selectedRowInComponent:1]];
        self.weight1UnitButton.titleLabel.textAlignment = self.weight2UnitButton.titleLabel.textAlignment = UITextAlignmentCenter;
        lastWeightSelected = component;
        [self convertWeight:nil];
    }
}

@end
