//
//  MillerStabilityViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MillerStabilityViewController.h"

@implementation MillerStabilityViewController
@synthesize bulletCaliberTextField = _bulletCaliberTextField, bulletLengthTextField = _bulletLengthTextField;
@synthesize bulletWeightTextField = _bulletWeightTextField, mvTextField = _mvTextField, twistRateTextField = _twistRateTextField;
@synthesize resultLabel = _resultLabel;
@synthesize currentTextField = _currentTextField;
@synthesize passedCaliber = _passedCaliber, passedWeight = _passedWeight, passedMV = _passedMV;
@synthesize resultView = _resultView;

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
    
    formFields = [NSArray arrayWithObjects:_bulletCaliberTextField,
                                           _bulletLengthTextField, 
                                           _bulletWeightTextField, 
										   _mvTextField, 
										   _twistRateTextField, 
										  nil];
     
    for (UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
    _bulletWeightTextField.keyboardType = _mvTextField.keyboardType = _twistRateTextField.keyboardType = UIKeyboardTypeNumberPad;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_passedCaliber && _passedWeight && _passedMV) {
		_bulletCaliberTextField.text = _passedCaliber;
		_bulletWeightTextField.text = _passedWeight;
		_mvTextField.text = _passedMV;
        [_bulletLengthTextField becomeFirstResponder];
	} else {
        [[formFields objectAtIndex:0] becomeFirstResponder];
    }
}

- (void)viewDidUnload {
    [self setBulletCaliberTextField:nil];
    [self setBulletLengthTextField:nil];
    [self setBulletWeightTextField:nil];
    [self setMvTextField:nil];
    [self setTwistRateTextField:nil];
    [self setResultLabel:nil];
    [self setCurrentTextField:nil];
    [self setPassedCaliber:nil];
    [self setPassedWeight:nil];
    [self setPassedMV:nil];
    
    [self setResultView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark result
- (IBAction)showResult:(id)sender {
    float caliber = [_bulletCaliberTextField.text floatValue];
    float length  = [_bulletLengthTextField.text floatValue];
    float twist   = [_twistRateTextField.text floatValue];
    float weight  = [_bulletWeightTextField.text floatValue];
    float tempFahrenheit = 59.0;
    float pressureHg = 29.92;
    int   mv      = [_mvTextField.text intValue];
    
    if((caliber>0) && (length>0) && (twist>0) && (weight>0) && (mv>0)) {
        float lengthInCalibers = length / caliber;
        float correctiveFactor = sqrt(pow(mv/2800.0, 1/3.0) * ((tempFahrenheit+460) / (59+460) * pressureHg/29.92));
        
        float s = (30*weight)/(pow(twist/caliber, 2)*pow(caliber, 3) * lengthInCalibers * (1+pow(lengthInCalibers,2))) * correctiveFactor;
        
        _resultLabel.text = [NSString stringWithFormat:@"%.2f", s];        
        _resultLabel.textColor = ((s >= 1.3) && (s <= 2.0)) ? [UIColor greenColor] : [UIColor redColor];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didCalculateSG" object:_resultLabel.text];
    } else {
        _resultLabel.text = @"n/a";
        _resultLabel.textColor = [UIColor whiteColor];
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
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 300.f, 88.f)];
    UIToolbar* textFieldToolBarView1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    UIToolbar* textFieldToolBarView2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 44.f, 320.f, 44.f)];
    textFieldToolBarView1.barStyle = UIBarStyleBlackOpaque;
    textFieldToolBarView2.barStyle = UIBarStyleBlackTranslucent;
    [textFieldToolBarView1 addSubview:_resultView];
    [textFieldToolBarView2 setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    [tempView addSubview:textFieldToolBarView1];    
    [tempView addSubview:textFieldToolBarView2];
    textField.inputAccessoryView = tempView;
    
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

@end
