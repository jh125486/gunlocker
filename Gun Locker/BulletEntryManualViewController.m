//
//  BulletEntryManualViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BulletEntryManualViewController.h"

@implementation BulletEntryManualViewController
@synthesize scrollView;
@synthesize passedBulletBC, passedBulletWeight, selectedDragModel;
@synthesize dragModelControl;
@synthesize g1EntryView, g7EntryView;
@synthesize bulletWeightTextField;
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
    
    if (!self.selectedDragModel) self.selectedDragModel = @"G7";
    
    formFields = [[NSMutableArray alloc] initWithObjects:self.bulletWeightTextField, nil];
    g1Fields = [[NSArray alloc] initWithObjects:self.g1BCTextField, 
                                                self.g1BC1TextField, self.g1FPS1TextField, 
                                                self.g1BC2TextField, self.g1FPS2TextField,
                                                self.g1BC3TextField, self.g1FPS3TextField, nil];
    g7Fields = [[NSArray alloc] initWithObjects:self.g7BCTextField, nil];
    
    
    for(UITextField *field in formFields)
        field.delegate = self;    
    for(UITextField *field in g1Fields)
        field.delegate = self;    
    for(UITextField *field in g7Fields)
        field.delegate = self;
    
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
        self.dragModelControl.selectedSegmentIndex = 0;
        self.g1EntryView.hidden = YES;
        self.g7EntryView.hidden = NO;
    } else if ([self.selectedDragModel isEqualToString:@"G1"]) {
        self.dragModelControl.selectedSegmentIndex = 1;
        self.g7EntryView.hidden = YES;
        self.g1EntryView.hidden = NO;
    }
    [self calculateFormFields];
}

- (void)loadBulletInfo {
    self.bulletWeightTextField.text = [NSString stringWithFormat:@"%@", self.passedBulletWeight];
    if ([self.selectedDragModel isEqualToString:@"G7"]) {
        self.g7BCTextField.text = [NSString stringWithFormat:@"%@", [self.passedBulletBC objectAtIndex:0]];
    } else {
        for (int i = 0; i < self.passedBulletBC.count; i +=2) {
            [(UITextField*)[g1Fields objectAtIndex:i] setText:[NSString stringWithFormat:@"%@", [self.passedBulletBC objectAtIndex:i]]];
            [(UITextField*)[g1Fields objectAtIndex:i+1] setText:[NSString stringWithFormat:@"%@", [self.passedBulletBC objectAtIndex:i+1]]];
        }
    }
}

- (void)calculateFormFields {
    if (self.dragModelControl.selectedSegmentIndex == 0) {
        [formFields removeObjectsInArray:g1Fields];
        [formFields addObjectsFromArray:g7Fields];
    } else {
        [formFields removeObjectsInArray:g7Fields];
        [formFields addObjectsFromArray:g1Fields];
    }
}
                  
- (void)viewDidUnload {
    [self setG7EntryView:nil];
    [self setG1EntryView:nil];
    [self setDragModelControl:nil];
    [self setBulletWeightTextField:nil];
    [self setG7BCTextField:nil];
    [self setG1BCTextField:nil];
    [self setG1BC1TextField:nil];
    [self setG1BC2TextField:nil];
    [self setG1BC3TextField:nil];
    [self setG1FPS1TextField:nil];
    [self setG1FPS2TextField:nil];
    [self setG1FPS3TextField:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dragModelTypeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0 ) {
        self.selectedDragModel = @"G7";
        self.g1EntryView.hidden = YES;
        self.g7EntryView.hidden = NO;
        [self.g7BCTextField becomeFirstResponder];
    } else {
        self.selectedDragModel = @"G1";
        self.g7EntryView.hidden = YES;
        self.g1EntryView.hidden = NO;
        [self.g1BCTextField becomeFirstResponder];
    }
    [self calculateFormFields];
}

- (IBAction)saveTapped:(id)sender {
    // notify manually entered
    // notify drag model
    NSMutableArray *bc = [[NSMutableArray alloc] init];
    if ([self.selectedDragModel isEqualToString:@"G7"]) {
        for (UITextField *field in g7Fields)
            if(![field.text isEqualToString:@""]) [bc addObject:field.text];
    } else {
        for (UITextField *field in g1Fields)
            if(![field.text isEqualToString:@""]) [bc addObject:field.text];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedDragModel" object:self.selectedDragModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"manuallyEnteredBullet" object:[NSArray arrayWithObjects:self.bulletWeightTextField.text, bc, nil]];
    
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
    } else if ([formFields indexOfObject:textField] == ([formFields count] -1)) {
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
    
    double originY = self.currentTextField.frame.origin.y;
    if ([g1Fields containsObject:self.currentTextField]) {
        originY += self.g1EntryView.frame.origin.y;
    } else if ([g7Fields containsObject:self.currentTextField]) {
        originY += self.g7EntryView.frame.origin.y;
    }

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
