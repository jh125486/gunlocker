//
//  ConversionsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversionsViewController.h"

@implementation ConversionsViewController

@synthesize lengthUnit1Button;
@synthesize length1TextField;
@synthesize lengthUnit2Button;
@synthesize length2TextField;
@synthesize weightUnit1Button;
@synthesize weight1TextField;
@synthesize weightUnit2Button;
@synthesize weight2TextField;
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

    formFields = [NSArray arrayWithObjects:self.length1TextField, self.length2TextField, self.weight2TextField, self.weight2TextField, nil];

    for(UITextField *field in formFields)
        field.delegate = self;
}

- (void)viewDidUnload {
    [self setLength1TextField:nil];
    [self setLength2TextField:nil];
    [self setWeight1TextField:nil];
    [self setWeight2TextField:nil];
    [self setLengthUnit1Button:nil];
    [self setLengthUnit2Button:nil];
    [self setWeightUnit1Button:nil];
    [self setWeightUnit2Button:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TableView

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, headerView.frame.size.width - 20, tableView.sectionHeaderHeight)];
	label.text = sectionTitle;
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:20.0];
	label.shadowColor = [UIColor lightTextColor];
    label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor clearColor];    
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
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

#pragma mark Conversions

- (IBAction)convertLength:(id)sender {
}

- (IBAction)convertWeight:(id)sender {
}

- (IBAction)chooseLengthUnit:(UIButton *)sender {
}

- (IBAction)chooseWeightUnit:(UIButton *)sender {
}

@end
