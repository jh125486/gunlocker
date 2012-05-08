//
//  MillerTwistViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MillerTwistViewController.h"

@implementation MillerTwistViewController
@synthesize bulletCaliberTextField, bulletLengthTextField, bulletWeightTextField, mvTextField, stabilityFactorTextField;
@synthesize resultLabel;
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
    
    behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    formFields = [NSArray arrayWithObjects:self.bulletCaliberTextField, self.bulletLengthTextField, self.bulletWeightTextField, self.mvTextField, self.stabilityFactorTextField, nil];
    for (UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
    self.bulletWeightTextField.keyboardType = self.mvTextField.keyboardType = UIKeyboardTypeNumberPad;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[formFields objectAtIndex:0] becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setBulletCaliberTextField:nil];
    [self setBulletLengthTextField:nil];
    [self setBulletWeightTextField:nil];
    [self setMvTextField:nil];
    [self setStabilityFactorTextField:nil];
    [self setResultLabel:nil];
    [self setCurrentTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark result
- (IBAction)showResult:(id)sender {
    float caliber = [self.bulletCaliberTextField.text floatValue];
    float length  = [self.bulletLengthTextField.text floatValue];
    float weight  = [self.bulletWeightTextField.text floatValue];
    float s       = [self.stabilityFactorTextField.text floatValue];
    float tempFahrenheit = 59.0;
    float pressureInHg = 29.92;
    int   mv      = [self.mvTextField.text intValue];
    
    if((caliber>0) && (length>0) && (weight>0) && (s>0) && (mv>0)) {
        float lengthInCalibers = length / caliber;
        float correctiveFactor = pow(mv/2800.0, 1/3.0) * ((tempFahrenheit+460.0) / (59+460.0) * pressureInHg/29.92);
        float twist = sqrt((30*weight)/(s * caliber * lengthInCalibers * (1+pow(lengthInCalibers,2)))) * correctiveFactor;
        
        self.resultLabel.text = [NSString stringWithFormat:@"%.0f\"", twist];
    } else {
        self.resultLabel.text = @"n/a";
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
    } else if ([formFields lastObject]== textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    }
    
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBarView;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:self.currentTextField];
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

@end
