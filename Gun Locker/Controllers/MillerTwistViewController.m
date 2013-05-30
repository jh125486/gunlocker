//
//  MillerTwistViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MillerTwistViewController.h"

@implementation MillerTwistViewController
@synthesize bulletCaliberTextField = _bulletCaliberTextField;
@synthesize bulletLengthTextField = _bulletLengthTextField;
@synthesize bulletWeightTextField = _bulletWeightTextField;
@synthesize mvTextField = _mvTextField;
@synthesize stabilityFactorTextField = _stabilityFactorTextField;
@synthesize resultLabel = _resultLabel;
@synthesize currentTextField = _currentTextField;
@synthesize resultView = _resultView;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];
    
    behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers 
                                                                      scale:0 
                                                           raiseOnExactness:NO 
                                                            raiseOnOverflow:NO 
                                                           raiseOnUnderflow:NO 
                                                        raiseOnDivideByZero:NO];
    
    formFields = [NSArray arrayWithObjects:_bulletCaliberTextField, 
		                                   _bulletLengthTextField, 
										   _bulletWeightTextField, 
										   _mvTextField, 
										   _stabilityFactorTextField, 
										   nil];
	
    for (UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
    _bulletWeightTextField.keyboardType = _mvTextField.keyboardType = UIKeyboardTypeNumberPad;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[formFields objectAtIndex:0] becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark result
- (IBAction)showResult:(id)sender {
    float caliber = [_bulletCaliberTextField.text floatValue];
    float length  = [_bulletLengthTextField.text floatValue];
    float weight  = [_bulletWeightTextField.text floatValue];
    float s       = [_stabilityFactorTextField.text floatValue];
    float tempFahrenheit = 59.0;
    float pressureInHg = 29.92;
    int   mv      = [_mvTextField.text intValue];
    
    if((caliber>0) && (length>0) && (weight>0) && (s>0) && (mv>0)) {
        float lengthInCalibers = length / caliber;
        float correctiveFactor = pow(mv/2800.0, 1/3.0) * ((tempFahrenheit+460.0) / (59+460.0) * pressureInHg/29.92);
        float twist = sqrt((30*weight)/(s * caliber * lengthInCalibers * (1+pow(lengthInCalibers,2)))) * correctiveFactor;
        
        _resultLabel.text = [NSString stringWithFormat:@"%.0f\"", twist];
    } else {
        _resultLabel.text = @"n/a";
    }

}

#pragma mark TextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                             NSLocalizedString(@"Previous",@"Previous form field"),
                                                                             NSLocalizedString(@"Next",@"Next form field"),                                         
                                                                             nil]];
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.tintColor = [UIColor darkGrayColor];
    control.momentary = YES;
    [control addTarget:self action:@selector(nextPreviousTapped:) forControlEvents:UIControlEventValueChanged];     
    
    UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                           target:nil 
                                                                           action:nil];
    UIBarButtonItem *done  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                           target:self 
                                                                           action:@selector(doneTyping:)];
    
    if ([formFields indexOfObject:textField] == 0) {
        [control setEnabled:NO forSegmentAtIndex:0];
    } else if ([formFields lastObject] == textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    }
    
    UIToolbar* textFieldToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    textFieldToolBar.barStyle = UIBarStyleBlackTranslucent;
    [textFieldToolBar setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBar;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
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
    [_currentTextField resignFirstResponder];
}

#pragma mark Tableview
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _resultView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_header_background"]];
    return _resultView;
}

@end
