//
//  EnergyFormulasViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnergyViewController.h"

@implementation EnergyViewController
@synthesize bulletWeightTextField, mvTextField;
@synthesize resultFtLbsLabel;
@synthesize resultJoulesLabel;
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
    
    formFields = [NSArray arrayWithObjects:self.bulletWeightTextField, self.mvTextField, nil];
    for (UITextField *field in formFields)
        field.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[formFields objectAtIndex:0] becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setBulletWeightTextField:nil];
    [self setMvTextField:nil];
    [self setResultFtLbsLabel:nil];
    [self setResultJoulesLabel:nil];
    [self setCurrentTextField:nil];
    [self setResultJoulesLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark result

- (IBAction)showResult:(id)sender {
    if(([self.bulletWeightTextField.text length] > 0) && ([self.mvTextField.text length] >0)) {
        NSDecimalNumber *weight     = [NSDecimalNumber decimalNumberWithString:self.bulletWeightTextField.text];
        NSDecimalNumber *mv         = [NSDecimalNumber decimalNumberWithString:self.mvTextField.text];
        NSDecimalNumber *divisor    =  [NSDecimalNumber decimalNumberWithString:@"450395"];
        NSDecimalNumber *multiplier =  [NSDecimalNumber decimalNumberWithString:@"1.3558179483314"];
        
        NSDecimalNumber *resultFtLbs = [[weight decimalNumberByMultiplyingBy:[mv decimalNumberByRaisingToPower:2]] decimalNumberByDividingBy:divisor]; 
        
        self.resultFtLbsLabel.text = [[resultFtLbs decimalNumberByRoundingAccordingToBehavior:behavior] stringValue];

        self.resultJoulesLabel.text = [[[resultFtLbs decimalNumberByMultiplyingBy:multiplier] decimalNumberByRoundingAccordingToBehavior:behavior] stringValue];
    } else {
        self.resultFtLbsLabel.text = @"n/a";
        self.resultJoulesLabel.text = @"n/a";
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
