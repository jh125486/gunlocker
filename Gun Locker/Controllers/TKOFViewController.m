//
//  TKOFViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TKOFViewController.h"

@implementation TKOFViewController
@synthesize resultView = _resultView;
@synthesize bulletCaliberTextField = _bulletCaliberTextField;
@synthesize bulletWeightTextField = _bulletWeightTextField;
@synthesize mvTextField = _mvTextField;
@synthesize resultLabel = _resultLabel;
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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];

    behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:1 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    formFields = [NSArray arrayWithObjects:_bulletCaliberTextField, 
                                           _bulletWeightTextField, 
                                           _mvTextField, 
                                           nil];
    for (UITextField *field in formFields)
        field.delegate = self;
    _bulletCaliberTextField.keyboardType = UIKeyboardTypeDecimalPad;
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
    if(([_bulletCaliberTextField.text length]>0) && ([_bulletWeightTextField.text length]>0) && ([_mvTextField.text length] >0)) {
        NSDecimalNumber *caliber = [NSDecimalNumber decimalNumberWithString:_bulletCaliberTextField.text];
        NSDecimalNumber *weight  = [NSDecimalNumber decimalNumberWithString:_bulletWeightTextField.text];
        NSDecimalNumber *mv      = [NSDecimalNumber decimalNumberWithString:_mvTextField.text];
        NSDecimalNumber *divisor = [NSDecimalNumber decimalNumberWithString:@"7000"];
        
        _resultLabel.text = [[[[[caliber decimalNumberByMultiplyingBy:weight] 
								decimalNumberByMultiplyingBy:mv] 
									decimalNumberByDividingBy:divisor] 
										decimalNumberByRoundingAccordingToBehavior:behavior] stringValue];
    } else {
        _resultLabel.text = @"n/a";
    }
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
    } else if ([formFields lastObject] == textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    }
    
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBarView;
    
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
