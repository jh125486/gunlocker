//
//  MillerStabilityViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MillerStabilityViewController.h"

@implementation MillerStabilityViewController
@synthesize bulletCaliberTextField, bulletLengthTextField, bulletWeightTextField, mvTextField, twistRateTextField;
@synthesize resultLabel;
@synthesize currentTextField;

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
    
    behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    formFields = [NSArray arrayWithObjects:self.bulletCaliberTextField, self.bulletLengthTextField, self.bulletWeightTextField, self.mvTextField, self.twistRateTextField, nil];
     
    for (UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
    self.bulletWeightTextField.keyboardType = self.mvTextField.keyboardType = self.twistRateTextField.keyboardType = UIKeyboardTypeNumberPad;

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
    [self setTwistRateTextField:nil];
    [self setResultLabel:nil];
    [self setCurrentTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark result
- (IBAction)showResult:(id)sender {
    float caliber = [bulletCaliberTextField.text floatValue];
    float length  = [bulletLengthTextField.text floatValue];
    float twist   = [twistRateTextField.text floatValue];
    float weight  = [bulletWeightTextField.text floatValue];
    float tempFahrenheit = 59.0;
    float pressureHg = 29.92;
    int   mv      = [mvTextField.text intValue];
    
    if((caliber>0) && (length>0) && (twist>0) && (weight>0) && (mv>0)) {
        float lengthInCalibers = length / caliber;
        float correctiveFactor = sqrt(pow(mv/2800.0, 1/3.0) * ((tempFahrenheit+460) / (59+460) * pressureHg/29.92));
        
        float s = (30*weight)/(pow(twist/caliber, 2)*pow(caliber, 3) * lengthInCalibers * (1+pow(lengthInCalibers,2))) * correctiveFactor;
        
        self.resultLabel.text = [NSString stringWithFormat:@"%.2f", s];        
        self.resultLabel.textColor = ((s >= 1.3) && (s <= 2.0)) ? [UIColor greenColor] : [UIColor redColor];
    } else {
        self.resultLabel.text = @"n/a";
        self.resultLabel.textColor = [UIColor whiteColor];
        
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
