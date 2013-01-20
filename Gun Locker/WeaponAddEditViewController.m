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
@synthesize purchasePriceTextField = _purchasePriceTextField;
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
            
    _addPhotoButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    // set up barrelLength keyboard
    _barrelLengthTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
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
                                                  _purchasePriceTextField, 
                                                  nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    
    // shenanighans to get around memory problem on iphone Camera Photo capture
    if(_selectedWeapon) {
        [self loadWeapon];
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
        _purchasePriceTextField.text    = [tempWeapon objectForKey:@"purchasePrice"];
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
        self.title = [NSString stringWithFormat:@"Add %@", [_weaponType substringToIndex:[_weaponType length] -1]];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // set tempWeaponFlag to true in nsdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"tempWeaponDirty"];
    [defaults setObject:[[NSDictionary alloc] initWithObjectsAndKeys:_manufacturerTextField.text, @"manufacturer",
                         _modelTextField.text, @"model",
                         _caliberTextField.text, @"caliber",
                         _finishTextField.text, @"finish",
                         _barrelLengthTextField.text, @"barrelLength",
                         _barrelThreadingTextField.text, @"barrelThreading",
                         _serialNumberTextField.text, @"serialNumber",
                         _purchaseDateTextField.text, @"purchaseDate",
                         _purchasePriceTextField.text, @"purchasePrice",
                         _weaponType, @"weaponType",
                         nil]
                 forKey:@"tempWeapon"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)loadWeapon {
    self.title = [NSString stringWithFormat:@"Edit %@", [_weaponType substringToIndex:[_weaponType length] - 1]];

    _manufacturerTextField.text = _selectedWeapon.manufacturer.name;
    _modelTextField.text        = _selectedWeapon.model;
    _caliberTextField.text      = _selectedWeapon.caliber;
    _finishTextField.text       = _selectedWeapon.finish;
    _barrelLengthTextField.text = [_selectedWeapon.barrel_length stringValue];
    _barrelThreadingTextField.text = _selectedWeapon.threaded_barrel_pitch;
    [_addPhotoButton setImage:[UIImage imageWithData:_selectedWeapon.primary_photo.normal_size] forState:UIControlStateNormal];
    _serialNumberTextField.text = _selectedWeapon.serial_number;
    if (_selectedWeapon.purchased_date) {
        _purchaseDatePickerView.date = _selectedWeapon.purchased_date;
        _purchaseDateTextField.text = [_purchaseDatePickerView.date onlyDate];
    }
    _purchasePriceTextField.text = [_selectedWeapon.purchased_price compare:[NSDecimalNumber zero]] ? [currencyFormatter stringFromNumber:_selectedWeapon.purchased_price] : @"";
    
    [self barrelLengthValueChanged:nil];
    [self purchasePriceValueChanged:nil];
    [self checkData:nil];
}

- (void)addPhotoTapped:(UITapGestureRecognizer *)recognizer {
    [[[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:kGLCancelText
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Take Photo", @"Choose Existing", nil]
     showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)addPhotoDoubleTapped:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"ViewPhoto" sender:nil];
}

- (IBAction)cancelTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"tempWeaponDirty"];
    [defaults removeObjectForKey:@"tempWeapon"];
    [defaults synchronize];
    
	[self.delegate WeaponAddViewControllerDidCancel:self];
}

- (IBAction)saveTapped:(id)sender {
    Weapon *weapon = _selectedWeapon ?: [Weapon createEntity];
    weapon.type = _weaponType;
    weapon.model = _modelTextField.text;
    weapon.caliber = _caliberTextField.text;
    weapon.finish = _finishTextField.text;
    weapon.barrel_length = (_barrelLengthTextField.text.length > 0) ? [NSNumber numberWithFloat:[_barrelLengthTextField.text floatValue]] : nil;    
    weapon.threaded_barrel_pitch = _barrelThreadingTextField.text;
    
    UIImage *photo = [_addPhotoButton imageForState:UIControlStateNormal];
    
    if (photo) {
        Photo *primaryPhoto = weapon.primary_photo ?: [Photo createEntity];
        [primaryPhoto setPhotoAndCreateThumbnailFromImage:photo];
        weapon.primary_photo = primaryPhoto;
        primaryPhoto.weapon = weapon;
    }
        
    weapon.serial_number = _serialNumberTextField.text;
    weapon.purchased_date = (_purchaseDateTextField.text.length > 0) ? _purchaseDatePickerView.date : nil;
    weapon.purchased_price = [NSDecimalNumber decimalNumberWithDecimal:[[currencyFormatter numberFromString:_purchasePriceTextField.text] decimalValue]];
    
    // if no selectedManufacturer, find one, else create one with the textfield text
    if(!selectedManufacturer) {
        if ((selectedManufacturer = [Manufacturer findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(name like[cd] %@) OR (short_name like[cd] %@)", _manufacturerTextField.text, _manufacturerTextField.text]])) {
        } else {
            selectedManufacturer = [Manufacturer createEntity];
            selectedManufacturer.name = _manufacturerTextField.text;
        }
    }
    weapon.manufacturer = selectedManufacturer;
    
    [[DataManager sharedManager] saveAppDatabase];

    
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
    BOOL validated = ((_manufacturerTextField.text.length > 0) && (_modelTextField.text.length > 0));
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
    } else  if ([segueID isEqualToString:@"ViewPhoto"]) {
        PhotoViewController *dst = segue.destinationViewController;
        dst.passedPhoto = _selectedWeapon.primary_photo;
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
    _currentTextField = _manufacturerTextField;
    [_currentTextField becomeFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Image methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    [_addPhotoButton setImage:image forState:UIControlStateNormal];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
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

- (void)nextPreviousTapped:(id)sender {
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

- (void)doneTyping:(id)sender {
    if (_currentTextField == _purchaseDateTextField)
        _purchaseDateTextField.text = [_purchaseDatePickerView.date onlyDate];

    [_currentTextField resignFirstResponder];
}

- (IBAction)barrelLengthValueChanged:(id)sender {
    if([_barrelLengthTextField.text length]) {
        CGPoint origin = _barrelLengthTextField.frame.origin;
        CGFloat width = [@"\"" sizeWithFont:_barrelLengthTextField.font].width;
        _barrelLengthUnitLabel.frame = CGRectMake(origin.x + width, origin.y, [_barrelLengthTextField.text sizeWithFont:_barrelLengthTextField.font].width, CGRectGetHeight(_barrelLengthTextField.frame)); 
        _barrelLengthUnitLabel.hidden = NO;
    } else {
        _barrelLengthUnitLabel.hidden = YES;
    }
}

- (IBAction)purchasePriceValueChanged:(id)sender {
    if([_purchasePriceTextField.text length]) {
        // move field to the right
        _purchasePriceTextField.frame = CGRectMake(22.0f, 
                                                   CGRectGetMinY(_purchaseDateTextField.frame), 
                                                   CGRectGetWidth(_purchasePriceTextField.frame), 
                                                   CGRectGetHeight( _purchasePriceTextField.frame));
        _currencySymbolLabel.hidden = NO;
    } else {
        // reset field to the left
        _purchasePriceTextField.frame = CGRectMake(10.0f, 
                                                   CGRectGetMinY(_purchaseDateTextField.frame), 
                                                   CGRectGetWidth(_purchasePriceTextField.frame), 
                                                   CGRectGetHeight(_purchasePriceTextField.frame));
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
