//
//  BulletEntryManualViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BulletBCEntryViewController.h"

@implementation BulletBCEntryViewController
@synthesize g1BC4TextField = _g1BC4TextField;
@synthesize g1FPS4TextField = _g1FPS4TextField;
@synthesize scrollView = _scrollView;
@synthesize dragModelLabel = _dragModelLabel;
@synthesize passedBulletBC = _passedBulletBC;
@synthesize selectedDragModel = _selectedDragModel;
@synthesize g7EntryView = _g7EntryView;
@synthesize g1EntryView = _g1EntryView;
@synthesize g7BCTextField = _g7BCTextField;
@synthesize g1BCTextField = _g1BCTextField;
@synthesize g1BC1TextField = _g1BC1TextField;
@synthesize g1BC2TextField = _g1BC2TextField;
@synthesize g1BC3TextField = _g1BC3TextField;
@synthesize g1FPS1TextField = _g1FPS1TextField;
@synthesize g1FPS2TextField = _g1FPS2TextField;
@synthesize g1FPS3TextField = _g1FPS3TextField;
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
    _scrollView.alwaysBounceVertical = YES;
    
    if ([_selectedDragModel isEqualToString:@"G7"]) {
        formFields = [[NSArray alloc] initWithObjects:_g7BCTextField, nil];
    } else {
        formFields = [[NSArray alloc] initWithObjects:_g1BCTextField, 
                                                      _g1BC1TextField, _g1FPS1TextField, 
                                                      _g1BC2TextField, _g1FPS2TextField,
                                                      _g1BC3TextField, _g1FPS3TextField, 
                                                      _g1BC4TextField, _g1FPS4TextField, 
													  nil]; 
    }
    
    for(UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    if (_passedBulletBC) [self loadBulletInfo];
    
    if ([_selectedDragModel isEqualToString:@"G7"]) {
        _dragModelLabel.text = @"Drag Model G7";
        _g1EntryView.hidden = YES;
        _g7EntryView.hidden = NO;
    } else if ([_selectedDragModel isEqualToString:@"G1"]) {
        _dragModelLabel.text = @"Drag Model G1";
        _g7EntryView.hidden = YES;
        _g1EntryView.hidden = NO;
    }
}

- (void)loadBulletInfo {
    ((UITextField*)[formFields objectAtIndex:0]).text = [NSString stringWithFormat:@"%@", [_passedBulletBC objectAtIndex:0]];
    for (int i = 1; i < _passedBulletBC.count; i += 2) {
        [(UITextField*)[formFields objectAtIndex:i]     setText:[NSString stringWithFormat:@"%@", [_passedBulletBC objectAtIndex:i]]];
        [(UITextField*)[formFields objectAtIndex:i + 1] setText:[NSString stringWithFormat:@"%@", [_passedBulletBC objectAtIndex:i + 1]]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveTapped:(id)sender {
    NSMutableArray *bc = [[NSMutableArray alloc] init];
    for (UITextField *field in formFields) {
        if(![field.text isEqualToString:@""]) [bc addObject:field.text];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"manuallyEnteredBC" object:bc];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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


- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    double originY = _currentTextField.frame.origin.y + 48.0f;    

    CGRect aRect = CGRectMake(0, _scrollView.frame.size.height - kbSize.height, kbSize.width, kbSize.height);
        
    if (CGRectContainsPoint(aRect, CGPointMake(_currentTextField.frame.origin.x, originY))) {
        [_scrollView setContentOffset:CGPointMake(0.0, originY - _currentTextField.frame.size.height - 85) animated:YES];
    } else {
        [_scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
    
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [_scrollView setContentOffset:CGPointZero animated:YES];
    _scrollView.scrollIndicatorInsets = contentInsets;
}

@end
