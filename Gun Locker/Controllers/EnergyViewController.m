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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Calculate Result

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

#pragma mark Tableview
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _resultView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_header_background"]];
    return _resultView;
}
@end
