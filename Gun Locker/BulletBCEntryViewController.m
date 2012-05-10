//
//  BulletEntryManualViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BulletBCEntryViewController.h"

@implementation BulletBCEntryViewController
@synthesize g1BC4TextField;
@synthesize g1FPS4TextField;
@synthesize scrollView;
@synthesize dragModelLabel;
@synthesize passedBulletBC, selectedDragModel;
@synthesize g1EntryView, g7EntryView;
@synthesize g7BCTextField;
@synthesize g1BCTextField, g1BC1TextField, g1BC2TextField, g1BC3TextField;
@synthesize g1FPS1TextField, g1FPS2TextField, g1FPS3TextField;
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
    self.scrollView.alwaysBounceVertical = YES;
    
    if ([self.selectedDragModel isEqualToString:@"G7"]) {
        formFields = [[NSArray alloc] initWithObjects:self.g7BCTextField, nil];
    } else {
        formFields = [[NSArray alloc] initWithObjects:self.g1BCTextField, 
                                                      self.g1BC1TextField, self.g1FPS1TextField, 
                                                      self.g1BC2TextField, self.g1FPS2TextField,
                                                      self.g1BC3TextField, self.g1FPS3TextField, 
                                                      self.g1BC4TextField, self.g1FPS4TextField, nil]; 
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
    if (self.passedBulletBC) [self loadBulletInfo];
    
    if ([self.selectedDragModel isEqualToString:@"G7"]) {
        self.dragModelLabel.text = @"Drag Model G7";
        self.g1EntryView.hidden = YES;
        self.g7EntryView.hidden = NO;
    } else if ([self.selectedDragModel isEqualToString:@"G1"]) {
        self.dragModelLabel.text = @"Drag Model G1";
        self.g7EntryView.hidden = YES;
        self.g1EntryView.hidden = NO;
    }
}

- (void)loadBulletInfo {
    ((UITextField*)[formFields objectAtIndex:0]).text = [NSString stringWithFormat:@"%@", [self.passedBulletBC objectAtIndex:0]];
    for (int i = 1; i < self.passedBulletBC.count; i += 2) {
        [(UITextField*)[formFields objectAtIndex:i]   setText:[NSString stringWithFormat:@"%@", [self.passedBulletBC objectAtIndex:i]]];
        [(UITextField*)[formFields objectAtIndex:i+1] setText:[NSString stringWithFormat:@"%@", [self.passedBulletBC objectAtIndex:i+1]]];
    }
}

- (void)viewDidUnload {
    [self setG7EntryView:nil];
    [self setG1EntryView:nil];
    [self setG7BCTextField:nil];
    [self setG1BCTextField:nil];
    [self setG1BC1TextField:nil];
    [self setG1BC2TextField:nil];
    [self setG1BC3TextField:nil];
    [self setG1FPS1TextField:nil];
    [self setG1FPS2TextField:nil];
    [self setG1FPS3TextField:nil];
    [self setScrollView:nil];
    [self setDragModelLabel:nil];
    [self setG1BC4TextField:nil];
    [self setG1FPS4TextField:nil];
    [super viewDidUnload];
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
    self.currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:currentTextField];
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


- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    double originY = self.currentTextField.frame.origin.y + 48.0f;    

    CGRect aRect = CGRectMake(0, self.scrollView.frame.size.height - kbSize.height, kbSize.width, kbSize.height);
        
    if (CGRectContainsPoint(aRect, CGPointMake(currentTextField.frame.origin.x, originY))) {
        [self.scrollView setContentOffset:CGPointMake(0.0, originY - currentTextField.frame.size.height - 85) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    }
    
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
