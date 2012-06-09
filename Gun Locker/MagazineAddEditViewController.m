//
//  MagazineAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazineAddEditViewController.h"

@implementation MagazineAddEditViewController
@synthesize brandTextField = _brandTextField;
@synthesize typeTextField = _typeTextField;
@synthesize caliberTextField = _caliberTextField;
@synthesize capacityTextField = _capacityTextField;
@synthesize capacityRoundsLabel = _capacityRoundsLabel;
@synthesize colorTextField = _colorTextField;
@synthesize quantitiyTextField = _quantityTextField;
@synthesize selectedMagazine = _selectedMagazine;
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

    formFields = [[NSArray alloc] initWithObjects:_brandTextField, 
                                                  _typeTextField, 
                                                  _caliberTextField, 
                                                  _capacityTextField,
                                                  _colorTextField, 
                                                  _quantityTextField, 
                                                  nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;
    
    if (_selectedMagazine) [self loadMagazine];
    if (_selectedCaliber) _caliberTextField.text = _selectedCaliber;
}

-(void)loadMagazine {
    self.title = @"Edit Magazine";
    _brandTextField.text    = _selectedMagazine.brand;
    _typeTextField.text     = _selectedMagazine.type;
    _caliberTextField.text  = _selectedMagazine.caliber;
	_colorTextField.text    = _selectedMagazine.color;
    _capacityTextField.text = [_selectedMagazine.capacity stringValue];
    _quantityTextField.text    = [_selectedMagazine.count stringValue];
}

-(void)viewDidDisappear:(BOOL)animated {
    [TestFlight passCheckpoint:@"Magazines disappeared"];
}

- (void)viewDidUnload {
    [self setBrandTextField:nil];
    [self setTypeTextField:nil];
    [self setCaliberTextField:nil];
	[self setColorTextField:nil];
    [self setQuantitiyTextField:nil];
    [self setCurrentTextField:nil];
    [self setSelectedMagazine:nil];
    [self setSelectedCaliber:nil];
    [self setCapacityTextField:nil];
    [self setCapacityRoundsLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"ChooseCaliberMagazine"]) {
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
    Magazine *magazine = (_selectedMagazine) ? _selectedMagazine : [Magazine createEntity];
    
    magazine.brand    = _brandTextField.text;
    magazine.type     = _typeTextField.text;
    magazine.caliber  = _caliberTextField.text;
    magazine.capacity = [NSNumber numberWithInt:[_capacityTextField.text intValue]];
    magazine.color    = _colorTextField.text;
    
    int count = [_quantityTextField.text integerValue];
    if (count < 0) count = 0;
    magazine.count   = [NSNumber numberWithInt:count];
    
    [[NSManagedObjectContext defaultContext] save];
    
    [TestFlight passCheckpoint:@"New Magazine Saved"];

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)capacityTextFieldChanged:(id)sender {
    if([_capacityTextField.text length]) {
        CGSize textSize = [_capacityTextField.text sizeWithFont:_capacityTextField.font];
        NSLog(@"width %g", textSize.width);
        // move rounds label to the right of capacity textfield
        _capacityRoundsLabel.frame = CGRectMake(textSize.width + CGRectGetMinX(_capacityTextField.frame), 
                                                CGRectGetMinY(_capacityRoundsLabel.frame), 
                                                CGRectGetWidth(_capacityRoundsLabel.frame), 
                                                CGRectGetHeight(_capacityRoundsLabel.frame));        
        _capacityRoundsLabel.hidden = NO;
    } else { // hide rounds labbl
        _capacityRoundsLabel.hidden = YES;
    }
}

@end
