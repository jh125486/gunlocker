//
//  WeaponAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponAddEditViewController.h"

@implementation WeaponAddEditViewController

@synthesize delegate;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize weaponType = _weaponType;
@synthesize manufacturerTextField = _manufacturerTextField;
@synthesize modelTextField = _modelTextField;
@synthesize caliberTextField = _caliberTextField;
@synthesize finishTextField = _finishTextField;
@synthesize addPhotoButton = _addPhotoButton;
@synthesize barrelLengthTextField = _barrelLengthTextField;
@synthesize barrelLengthUnitLabel = _barrelLengthUnitLabel;
@synthesize barrelThreadingTextField = _barrelThreadingTextField;
@synthesize serialNumberTextField = _serialNumberTextField;
@synthesize purchaseDateTextField = _purchaseDateTextField;
@synthesize purchaseDatePickerView = _purchaseDatePickerView;
@synthesize purchasePriceTextfield = _purchasePriceTextfield;
@synthesize currencySymbolLabel = _currencySymbolLabel;
@synthesize currentTextField = _currentTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
            
    self.addPhotoButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    // set up barrelLength keyboard
    self.barrelLengthTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
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
    
    formFields = [[NSArray alloc] initWithObjects:_manufacturerTextField,
                                                  _modelTextField,
                                                  _caliberTextField,
                                                  _finishTextField,
                                                  _serialNumberTextField,
                                                  _barrelLengthTextField,
                                                  _barrelThreadingTextField,
                                                  _purchaseDateTextField, 
                                                  _purchasePriceTextfield, 
                                                  nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    
    // shenanighans to get around memory problem on iphone Camera Photo capture
    if(_selectedWeapon) {
        [self loadTextfieldsFromWeapon:_selectedWeapon];
    } else if (([defaults boolForKey:@"tempWeaponDirty"]) && ([defaults objectForKey:@"tempWeapon"])) {
        NSDictionary *tempWeapon = [defaults objectForKey:@"tempWeapon"];
        
        _weaponType                     = [tempWeapon objectForKey:@"weaponType"];       
        _manufacturerTextField.text     = [tempWeapon objectForKey:@"manufacturer"];
        _modelTextField.text            = [tempWeapon objectForKey:@"model"];
        _caliberTextField.text          = [tempWeapon objectForKey:@"caliber"];
        _finishTextField.text           = [tempWeapon objectForKey:@"finish"];
        _barrelLengthTextField.text     = [tempWeapon objectForKey:@"barrelLength"];
        _barrelThreadingTextField.text  = [tempWeapon objectForKey:@"barrelThreading"];
        _serialNumberTextField.text     = [tempWeapon objectForKey:@"serialNumber"];
        if (![[tempWeapon objectForKey:@"purchaseDate"] isEqualToString:@""]) {
            _purchaseDatePickerView.date    = dateFromString([tempWeapon objectForKey:@"purchaseDate"], @"MMMM d, YYYY");
            _purchaseDateTextField.text     = [tempWeapon objectForKey:@"purchaseDate"];
        }
        _purchasePriceTextfield.text    = [tempWeapon objectForKey:@"purchasePrice"];
        [self barrelLengthValueChanged:nil];
        [self purchasePriceValueChanged:nil];
        [self checkData:nil];
    }
    [self setTitle];
    
    // set up gestures
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhotoTapped:)];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhotoDoubleTapped:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [doubleTap setDelaysTouchesBegan:YES];
    [singleTap setDelaysTouchesBegan:YES];

    [doubleTap setNumberOfTapsRequired:2];
    [singleTap setNumberOfTapsRequired:1];

    [_addPhotoButton addGestureRecognizer:doubleTap];
    [_addPhotoButton addGestureRecognizer:singleTap];
}

-(void)setTitle {
    if([_weaponType isEqualToString:@"Misc."])
        self.title = @"Add Miscellaneous";
    else
        self.title = [NSString stringWithFormat:@"Add %@", [_weaponType substringToIndex:[self.weaponType length] -1]];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // set tempWeaponFlag to true in nsdefaults
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tempWeaponDirty"];
}

- (void)viewDidUnload {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults setObject:[[NSDictionary alloc] initWithObjectsAndKeys:_manufacturerTextField.text, @"manufacturer", 
                                                                     _modelTextField.text, @"model",
                                                                     _caliberTextField.text, @"caliber",
                                                                     _finishTextField.text, @"finish",
                                                                     _barrelLengthTextField.text, @"barrelLength",
                                                                     _barrelThreadingTextField.text, @"barrelThreading",
                                                                     _serialNumberTextField.text, @"serialNumber",
                                                                     _purchaseDateTextField.text, @"purchaseDate",
                                                                     _purchasePriceTextfield.text, @"purchasePrice",
                                                                     _weaponType, @"weaponType",
                                                                     nil] 
                forKey:@"tempWeapon"];
    
    [self setManufacturerTextField:nil];
    [self setModelTextField:nil];
    [self setCaliberTextField:nil];
    [self setFinishTextField:nil];
    [self setBarrelLengthTextField:nil];
    [self setBarrelLengthUnitLabel:nil];
    [self setBarrelThreadingTextField:nil];
    [self setAddPhotoButton:nil];
    [self setSerialNumberTextField:nil];
    [self setPurchaseDateTextField:nil];
    [self setPurchasePriceTextfield:nil];
    [self setCurrencySymbolLabel:nil];
    [self setSelectedWeapon:nil];
    [self setCurrentTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)loadTextfieldsFromWeapon:(Weapon*)weapon {
    self.title = [NSString stringWithFormat:@"Edit %@", [self.weaponType substringToIndex:[self.weaponType length] - 1]];

    _manufacturerTextField.text = weapon.manufacturer.name;
    _modelTextField.text        = weapon.model;
    _caliberTextField.text      = weapon.caliber;
    _finishTextField.text       = weapon.finish;
    _barrelLengthTextField.text = [weapon.barrel_length stringValue];
    _barrelThreadingTextField.text = weapon.threaded_barrel_pitch;
    [self.addPhotoButton setImage:[UIImage imageWithData:weapon.photo_thumbnail] forState:UIControlStateNormal];
    _serialNumberTextField.text = weapon.serial_number;
    if (weapon.purchased_date) {
        _purchaseDatePickerView.date = weapon.purchased_date;
        _purchaseDateTextField.text = [_purchaseDatePickerView.date onlyDate];
    }
    _purchasePriceTextfield.text = [weapon.purchased_price compare:[NSDecimalNumber zero]] ? [currencyFormatter stringFromNumber:weapon.purchased_price] : @"";
    
    [self barrelLengthValueChanged:nil];
    [self purchasePriceValueChanged:nil];
    [self checkData:nil];
}

- (void)addPhotoTapped:(UITapGestureRecognizer *)recognizer {
    [[[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Take Photo", @"Choose Existing", nil]
     showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)addPhotoDoubleTapped:(UITapGestureRecognizer *)recognizer {
    // should perform seque to with ViewPhoto if photo is present
    DebugLog(@"taps: %d", [recognizer numberOfTouches]);
}

- (IBAction)cancelTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"tempWeaponDirty"];
    [defaults removeObjectForKey:@"tempWeapon"];
    [defaults synchronize];
    
	[self.delegate WeaponAddViewControllerDidCancel:self];
}

- (IBAction)saveTapped:(id)sender {
    Weapon *weapon = _selectedWeapon ? _selectedWeapon : [Weapon createEntity];
    weapon.type = _weaponType;
    weapon.model = _modelTextField.text;
    weapon.caliber = _caliberTextField.text;
    weapon.finish = _finishTextField.text;
    weapon.barrel_length = (_barrelLengthTextField.text.length > 0) ? [NSNumber numberWithFloat:[_barrelLengthTextField.text floatValue]] : nil;    
    weapon.threaded_barrel_pitch = _barrelThreadingTextField.text;
    
    UIImage *photo = [_addPhotoButton imageForState:UIControlStateNormal];
    if(photo) {
        weapon.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        CGSize size = photo.size;
        CGFloat ratio = 0;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        
        CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        weapon.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();   
        
        #ifdef DEBUG
        UIImage *thumbnail = [UIImage imageWithData:weapon.photo_thumbnail];
        DebugLog(@"New photo: %f x %f", photo.size.width, photo.size.height);
        DebugLog(@"New thumbnail: %f x %f", thumbnail.size.width, thumbnail.size.height);
        #endif
    }
        
    weapon.serial_number = _serialNumberTextField.text;
    weapon.purchased_date = (_purchaseDateTextField.text.length > 0) ? _purchaseDatePickerView.date : nil;
    weapon.purchased_price = [NSDecimalNumber decimalNumberWithDecimal:[[currencyFormatter numberFromString:_purchasePriceTextfield.text] decimalValue]];
    
    // if no selectedManufacturer, find one, else create one with the textfield text
    if(!selectedManufacturer) {
        if ((selectedManufacturer = [Manufacturer findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(name like[cd] %@) OR (short_name like[cd] %@)", self.manufacturerTextField.text, self.manufacturerTextField.text]])) {
        } else {
            selectedManufacturer = [Manufacturer createEntity];
            selectedManufacturer.name = _manufacturerTextField.text;
        }
    }
    weapon.manufacturer = selectedManufacturer;
    
    [[NSManagedObjectContext defaultContext] save];

    [TestFlight passCheckpoint:@"Weapon Saved/Edited"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"tempWeaponDirty"];
    [defaults removeObjectForKey:@"tempWeapon"];
    [defaults synchronize];
    
	[self.delegate WeaponAddViewControllerDidSave:self];
}

// TODO possible a better way to do this... 
// alert saying not enough fields completed?

// validation of Model and Manufacturer
- (IBAction)checkData:(id)sender {
    BOOL validated = ((self.manufacturerTextField.text.length > 0) && (self.modelTextField.text.length > 0));
    [self.navigationItem.rightBarButtonItem setEnabled:validated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"ChooseCaliber"]) {
		CaliberChooserViewController *caliberChooserViewController = segue.destinationViewController;
		caliberChooserViewController.delegate = self;
		caliberChooserViewController.selectedCaliber = _caliberTextField.text;
	} else if ([segueID isEqualToString:@"ChooseManufacturer"]) {
		ManufacturerChooserViewController *manufacturerChooserViewController = segue.destinationViewController;
		manufacturerChooserViewController.delegate = self;
		manufacturerChooserViewController.selectedManufacturer = selectedManufacturer;
    }
}

#pragma mark - CaliberChooserViewControllerDelegate

- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber {
	_caliberTextField.text = selectedCaliber;
    _currentTextField = _caliberTextField;
    [_currentTextField becomeFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ManufacturerChooserViewControllerDelegate

- (void)manufacturerChooserViewController:(ManufacturerChooserViewController *)controller didSelectManufacturer:(Manufacturer *)passedManufacturer {
    selectedManufacturer = passedManufacturer;
	_manufacturerTextField.text = selectedManufacturer.name;
    _currentTextField = self.manufacturerTextField;
    [_currentTextField becomeFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Image methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DebugLog(@"set photoButton image");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    [_addPhotoButton setImage:image forState:UIControlStateNormal];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) return; // sheet cancelled
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = (buttonIndex == 0) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [self presentModalViewController:imagePicker animated:YES];
}

// disable camera if no camera present
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    NSString *type = @"Take Photo";
    
    for (UIView* view in [actionSheet subviews]) {
        if ([[[view class] description] isEqualToString:@"UIAlertButton"]) {
            if ([view respondsToSelector:@selector(title)]) {
                if ([[view performSelector:@selector(title)] isEqualToString:type] && [view respondsToSelector:@selector(setEnabled:)]) {
                    [view performSelector:@selector(setEnabled:) withObject:nil];
                }		
            }        
        }   
    }
}

#pragma mark Textfield Delegates

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == self.purchasePriceTextfield) {
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
    if (_currentTextField == self.purchaseDateTextField)
        _purchaseDateTextField.text = [_purchaseDatePickerView.date onlyDate];

    [_currentTextField resignFirstResponder];
}

- (IBAction)barrelLengthValueChanged:(id)sender {
    if([_barrelLengthTextField.text length]) {
        CGPoint origin = _barrelLengthTextField.frame.origin;
        CGFloat width = [@"\"" sizeWithFont:_barrelLengthTextField.font].width;
        _barrelLengthUnitLabel.frame = CGRectMake(origin.x + width, origin.y, [_barrelLengthTextField.text sizeWithFont:_barrelLengthTextField.font].width, CGRectGetHeight(self.barrelLengthTextField.frame)); 
        _barrelLengthUnitLabel.hidden = NO;
    } else {
        _barrelLengthUnitLabel.hidden = YES;
    }
}

- (IBAction)purchasePriceValueChanged:(id)sender {
    if([self.purchasePriceTextfield.text length]) {
        // move field to the right
        _purchasePriceTextfield.frame = CGRectMake(22.0f, 
                                                   0.0f, 
                                                   CGRectGetWidth(_purchasePriceTextfield.frame), 
                                                   CGRectGetHeight( _purchasePriceTextfield.frame));
        _currencySymbolLabel.hidden = NO;
    } else {
        // reset field to the left
        _purchasePriceTextfield.frame = CGRectMake(10.0f, 
                                                   0.0f, 
                                                   CGRectGetWidth(_purchasePriceTextfield.frame), 
                                                   CGRectGetHeight(_purchasePriceTextfield.frame));
        _currencySymbolLabel.hidden = YES;
    }
}

#pragma mark Tableview delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                            owner:self 
                                                                          options:nil] 
                                              objectAtIndex:0];
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

@end
