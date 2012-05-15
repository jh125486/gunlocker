//
//  AmmunitionAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmmunitionAddEditViewController.h"

@implementation AmmunitionAddEditViewController
@synthesize brandTextField = _brandTextField;
@synthesize typeTextField = _typeTextField;
@synthesize caliberTextField = _caliberTextField;
@synthesize countTextField = _countTextField;
@synthesize selectedAmmunition = _selectedAmmunition;
@synthesize selectedCaliber = _selectedCaliber;
@synthesize currentTextField = _currentTextField;

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

    formFields = [[NSArray alloc] initWithObjects:_brandTextField, _typeTextField, _caliberTextField, _countTextField, nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;
    
    if (_selectedAmmunition) [self loadAmmunition];
    if (_selectedCaliber) _caliberTextField.text = _selectedCaliber;
}

-(void)loadAmmunition {
    self.title = @"Edit Ammo";
    _brandTextField.text   = _selectedAmmunition.brand;
    _typeTextField.text    = _selectedAmmunition.type;
    _caliberTextField.text = _selectedAmmunition.caliber;
    _countTextField.text   = [_selectedAmmunition.count stringValue];
}

- (void)viewDidUnload {
    [self setBrandTextField:nil];
    [self setTypeTextField:nil];
    [self setCaliberTextField:nil];
    [self setCountTextField:nil];
    [self setCurrentTextField:nil];
    [self setSelectedAmmunition:nil];
    [self setSelectedCaliber:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"ChooseCaliberAmmunition"]) {
		CaliberChooserViewController *caliberChooserViewController = segue.destinationViewController;
		caliberChooserViewController.delegate = self;
		caliberChooserViewController.selectedCaliber = _caliberTextField.text;
	}
}

#pragma mark - CaliberChooserViewControllerDelegate

- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber {
	_caliberTextField.text = selectedCaliber;
    _currentTextField = _caliberTextField;
    [_currentTextField becomeFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextfield Delegates

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
    } else if (formFields.lastObject == textField) {
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
    
    [_currentTextField resignFirstResponder];
    _currentTextField = [formFields objectAtIndex:index];
    [_currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
    [self.currentTextField resignFirstResponder];
}


# pragma mark Actions
- (IBAction)cancelTapped:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)savedTapped:(id)sender {
    Ammunition *ammunition = (_selectedAmmunition) ? _selectedAmmunition : [Ammunition createEntity];
    
    ammunition.brand   = _brandTextField.text;
    ammunition.type    = _typeTextField.text;
    ammunition.caliber = _caliberTextField.text;
    
    int count = [_countTextField.text integerValue];
    if (count < 0) count = 0;
    ammunition.count   = [NSNumber numberWithInt:count];
    
    [[NSManagedObjectContext defaultContext] save];
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
