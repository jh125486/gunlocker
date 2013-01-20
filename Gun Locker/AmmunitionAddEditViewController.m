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
@synthesize purchasePriceTextField = _purchasePriceTextField;
@synthesize currencySymbolLabel = _currencySymbolLabel;
@synthesize purchasedFromTextField = _purchasedFromTextField;
@synthesize purchaseDateTextField = _purchaseDateTextField;
@synthesize purchaseDatePickerView = _purchaseDatePickerView;
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

    // set up purchase price field with local currency symbol and keyboard
    _currencySymbolLabel.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:[NSLocale currentLocale]];
    [currencyFormatter setCurrencySymbol:@""];

    // set up purchase date picker
    _purchaseDatePickerView = [[UIDatePicker alloc] init];
    _purchaseDatePickerView.datePickerMode = UIDatePickerModeDate;
    _purchaseDatePickerView.maximumDate = [NSDate date];
    _purchaseDateTextField.inputView = _purchaseDatePickerView;
    
    formFields = [[NSArray alloc] initWithObjects:_brandTextField, 
                                                  _typeTextField, 
                                                  _caliberTextField, 
                                                  _countTextField, 
                                                  _purchasePriceTextField,
                                                  _purchasedFromTextField,
                                                  _purchaseDateTextField,
                                                  nil];
    
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
    
    _purchasePriceTextField.text = [_selectedAmmunition.purchase_price compare:[NSDecimalNumber zero]] ? [currencyFormatter stringFromNumber:_selectedAmmunition.purchase_price] : @"";
    _purchasedFromTextField.text = _selectedAmmunition.retailer;
    if (_selectedAmmunition.purchase_date) {
        _purchaseDatePickerView.date = _selectedAmmunition.purchase_date;
        _purchaseDateTextField.text = [_purchaseDatePickerView.date onlyDate];
    }
    
    [self purchasePriceValueChanged:nil];
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == _purchasePriceTextField) {
        NSString *newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        NSMutableString *result = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i< [newValue length]; i++){
            unichar c = [newValue characterAtIndex:i];
            NSString *charStr = [NSString stringWithCharacters:&c length:1];
            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c]) {
                [result appendString:charStr];
            }
        }
        result = [NSMutableString stringWithFormat:@"%i", [result integerValue]]; // strip leading zeros
        if (result.length < currencyFormatter.minimumFractionDigits) { // move decimal place to correct location
            [result insertString:currencyFormatter.decimalSeparator atIndex:0];
            while(result.length <= currencyFormatter.minimumFractionDigits)
                [result insertString:@"0" atIndex:1];
        } else {
            [result insertString:currencyFormatter.decimalSeparator atIndex:(result.length - currencyFormatter.minimumFractionDigits)];
        }
        
        textField.text = ([result doubleValue] > 0) ? [currencyFormatter stringFromNumber:[NSNumber numberWithDouble:[result doubleValue]]] : nil;
        
        //always return no since we are manually changing the text field
        return NO;
    }
    
    return YES;
}

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
    if (_currentTextField == _purchaseDateTextField)
        _purchaseDateTextField.text = [_purchaseDatePickerView.date onlyDate];

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
    ammunition.count = [NSNumber numberWithInt:count];

    if (!_selectedAmmunition) ammunition.count_original = [NSNumber numberWithInt:count];
    
    ammunition.purchase_price  = [NSDecimalNumber decimalNumberWithDecimal:[[currencyFormatter numberFromString:_purchasePriceTextField.text] decimalValue]];
    ammunition.retailer = _purchasedFromTextField.text;
    ammunition.purchase_date = (_purchaseDateTextField.text.length > 0) ? _purchaseDatePickerView.date : nil;
    
    [[DataManager sharedManager] saveAppDatabase];
    
    [self dismissModalViewControllerAnimated:YES];
    [TestFlight passCheckpoint:@"New Ammunition Saved"];
}

- (IBAction)purchasePriceValueChanged:(id)sender {
    if([_purchasePriceTextField.text length]) { // move field to the right
        _currencySymbolLabel.hidden = NO;
        _purchasePriceTextField.frame = CGRectMake(160.f, 
                                                   CGRectGetMinY(_purchasePriceTextField.frame), 
                                                   CGRectGetWidth(_purchasePriceTextField.frame), 
                                                   CGRectGetHeight( _purchasePriceTextField.frame));
    } else { // reset field to the left
        _purchasePriceTextField.frame = CGRectMake(145.f, 
                                                   CGRectGetMinY(_purchasePriceTextField.frame), 
                                                   CGRectGetWidth(_purchasePriceTextField.frame), 
                                                   CGRectGetHeight(_purchasePriceTextField.frame));
        _currencySymbolLabel.hidden = YES;
    }
}

@end
