//
//  ThornileyViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThornileyViewController.h"

@implementation ThornileyViewController
@synthesize bulletCaliberTextField, bulletWeightTextField, mvTextField;
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

    formFields = [NSArray arrayWithObjects:self.bulletCaliberTextField, self.bulletWeightTextField, self.mvTextField, nil];
    for (UITextField *field in formFields)
        field.delegate = self;
    self.bulletCaliberTextField.keyboardType = UIKeyboardTypeDecimalPad;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[formFields objectAtIndex:0] becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setBulletCaliberTextField:nil];
    [self setBulletWeightTextField:nil];
    [self setMvTextField:nil];
    [self setResultLabel:nil];
    [self setCurrentTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark result
- (IBAction)showResult:(id)sender {
    if(([self.bulletCaliberTextField.text length]>0) && ([self.bulletWeightTextField.text length]>0) && ([self.mvTextField.text length] >0)) {
        
        NSDecimalNumber *caliber = [[NSDecimalNumber alloc] initWithDouble:sqrt([self.bulletCaliberTextField.text doubleValue])];
        NSDecimalNumber *weight  = [NSDecimalNumber decimalNumberWithString:self.bulletWeightTextField.text];
        NSDecimalNumber *mv      = [NSDecimalNumber decimalNumberWithString:self.mvTextField.text];
        NSDecimalNumber *multipier = [NSDecimalNumber decimalNumberWithString:@"2.866"];
        NSDecimalNumber *divisor = [NSDecimalNumber decimalNumberWithString:@"7000"];
        
        weight = [weight decimalNumberByDividingBy:divisor];
        self.resultLabel.text = [[[[[multipier decimalNumberByMultiplyingBy:mv] decimalNumberByMultiplyingBy:weight] decimalNumberByMultiplyingBy:caliber] decimalNumberByRoundingAccordingToBehavior:behavior] stringValue];
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
