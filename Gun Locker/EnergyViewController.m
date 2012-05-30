//
//  EnergyFormulasViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnergyViewController.h"

@implementation EnergyViewController
@synthesize resultView = _resultView;
@synthesize bulletWeightTextField = _bulletWeightTextField, mvTextField = _mvTextField;
@synthesize resultFtLbsLabel = _resultFtLbsLabel;
@synthesize resultJoulesLabel = _resultJoulesLabel;
@synthesize currentTextField = _currentTextField;

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
    
    behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers 
                                                                      scale:0 
                                                           raiseOnExactness:NO 
                                                            raiseOnOverflow:NO 
                                                           raiseOnUnderflow:NO 
                                                        raiseOnDivideByZero:NO];
    
    formFields = [NSArray arrayWithObjects:_bulletWeightTextField, _mvTextField, nil];
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
    [self setResultView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark result

- (IBAction)showResult:(id)sender {
    if(([_bulletWeightTextField.text length] > 0) && ([_mvTextField.text length] >0)) {
        NSDecimalNumber *weight     = [NSDecimalNumber decimalNumberWithString:_bulletWeightTextField.text];
        NSDecimalNumber *mv         = [NSDecimalNumber decimalNumberWithString:_mvTextField.text];
        NSDecimalNumber *divisor    = [NSDecimalNumber decimalNumberWithString:@"450395"];
        NSDecimalNumber *multiplier = [NSDecimalNumber decimalNumberWithString:@"1.3558179483314"];
        
        NSDecimalNumber *resultFtLbs = [[weight decimalNumberByMultiplyingBy:[mv decimalNumberByRaisingToPower:2]] decimalNumberByDividingBy:divisor]; 
        
        _resultFtLbsLabel.text = [[resultFtLbs decimalNumberByRoundingAccordingToBehavior:behavior] stringValue];

        _resultJoulesLabel.text = [[[resultFtLbs decimalNumberByMultiplyingBy:multiplier] 
                                    decimalNumberByRoundingAccordingToBehavior:behavior] stringValue];
    } else {
        _resultFtLbsLabel.text = @"n/a";
        _resultJoulesLabel.text = @"n/a";
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
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 300.f, 95.f)];
    UIToolbar* textFieldToolBarView1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 95.f)];
    UIToolbar* textFieldToolBarView2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 51.f, 320.f, 44.f)];
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
    int index = [formFields indexOfObject:self.currentTextField];
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
