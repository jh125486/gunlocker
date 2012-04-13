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
@synthesize selectedWeapon;
@synthesize weaponType;
@synthesize manufacturerTextField;
@synthesize modelTextField;
@synthesize caliberTextField;
@synthesize finishTextField;
@synthesize barrelLengthTextField;
@synthesize barrelThreadingTextField;
@synthesize serialNumberTextField;
@synthesize purchaseDateTextField;
@synthesize purchasePriceTextfield;
@synthesize currencySymbolLabel;
@synthesize purchaseDatePickerView;
@synthesize addPhotoButton;
@synthesize barrelLengthUnitLabel;
@synthesize currentTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([self.weaponType isEqualToString:@"Misc."])
        self.title = @"Add Miscellaneous";
    else
        self.title = [NSString stringWithFormat:@"Add %@", [self.weaponType substringToIndex:[self.weaponType length] -1]];
        
    self.addPhotoButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    // set up barrelLength keyboard
    self.barrelLengthTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    // set up purchase price field with local currency symbol and keyboard
    currencySymbolLabel.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:[NSLocale currentLocale]];
    [currencyFormatter setCurrencySymbol:@""];
    
    // set up purchase date picker
    purchaseDatePickerView = [[UIDatePicker alloc] init];
    purchaseDatePickerView.datePickerMode = UIDatePickerModeDate;
    purchaseDatePickerView.maximumDate = [NSDate date];
    self.purchaseDateTextField.inputView = purchaseDatePickerView;
    
    formFields = [[NSMutableArray alloc] initWithObjects:manufacturerTextField,
                                                         modelTextField,
                                                         caliberTextField,
                                                         finishTextField,
                                                         barrelLengthTextField,
                                                         barrelThreadingTextField,
                                                         serialNumberTextField, 
                                                         purchaseDateTextField, 
                                                         purchasePriceTextfield, 
                                                         nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;    
    
    if(selectedWeapon) [self loadTextfieldsFromWeapon];    
}

- (void)viewDidUnload {
    [self setManufacturerTextField:nil];
    [self setModelTextField:nil];
    [self setCaliberTextField:nil];
    [self setFinishTextField:nil];
    [self setBarrelLengthTextField:nil];
    [self setAddPhotoButton:nil];
    [self setSerialNumberTextField:nil];
    [self setPurchaseDateTextField:nil];
    [self setPurchasePriceTextfield:nil];
    [self setSelectedWeapon:nil];
    [self setBarrelLengthUnitLabel:nil];
    [self setBarrelThreadingTextField:nil];
    [self setCurrentTextField:nil];
    [self setCurrencySymbolLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)loadTextfieldsFromWeapon {
    self.title = [NSString stringWithFormat:@"Edit %@", [self.weaponType substringToIndex:[self.weaponType length] - 1]];

    manufacturerTextField.text = selectedWeapon.manufacturer.name;
    modelTextField.text        = selectedWeapon.model;
    caliberTextField.text      = selectedWeapon.caliber;
    finishTextField.text       = selectedWeapon.finish;
    barrelLengthTextField.text = [selectedWeapon.barrel_length stringValue];
    barrelThreadingTextField.text = selectedWeapon.threaded_barrel_pitch;
    [self barrelLengthValueChanged:nil];
    [addPhotoButton setImage:[UIImage imageWithData:selectedWeapon.photo_thumbnail] forState:UIControlStateNormal];
    serialNumberTextField.text = selectedWeapon.serial_number;
    if (selectedWeapon.purchased_date) {
        purchaseDateTextField.text = [selectedWeapon.purchased_date onlyDate];
        purchaseDatePickerView.date = selectedWeapon.purchased_date;
    }
    purchasePriceTextfield.text = [selectedWeapon.purchased_price compare:[NSDecimalNumber zero]] ? [currencyFormatter stringFromNumber:selectedWeapon.purchased_price] : @"";
    [self purchasePriceValueChanged:nil];
    
    [self checkData:nil];
}

# pragma mark View delegates

- (IBAction)cancelTapped:(id)sender {
	[self.delegate WeaponAddViewControllerDidCancel:self];
}

- (IBAction)saveTapped:(id)sender {
    Weapon *weapon = selectedWeapon ? selectedWeapon : [Weapon createEntity];
    weapon.type = self.weaponType;
    weapon.model = self.modelTextField.text;
    weapon.caliber = self.caliberTextField.text;
    weapon.finish = self.finishTextField.text;
    
    if(self.barrelLengthTextField.text.length > 0)
        weapon.barrel_length = [NSNumber numberWithFloat:[self.barrelLengthTextField.text floatValue]];    
    weapon.threaded_barrel_pitch = self.barrelThreadingTextField.text;
    
    UIImage *photo = [self.addPhotoButton imageForState:UIControlStateNormal];
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
        
        UIImage *thumbnail = [UIImage imageWithData:weapon.photo_thumbnail];
        NSLog(@"New photo: %f x %f", photo.size.width, photo.size.height);
        NSLog(@"New thumbnail: %f x %f", thumbnail.size.width, thumbnail.size.height);
    }
        
    weapon.serial_number = self.serialNumberTextField.text;
    weapon.purchased_date = (purchaseDateTextField.text.length > 0) ? purchaseDatePickerView.date : nil;
    weapon.purchased_price = [NSDecimalNumber decimalNumberWithDecimal:[[currencyFormatter numberFromString:self.purchasePriceTextfield.text] decimalValue]];
    
    // if no selectedManufacturer, find one, else create one with the textfield text
    if(!selectedManufacturer) {
        if ((selectedManufacturer = [Manufacturer findFirstWithPredicate:[NSPredicate predicateWithFormat:@"(name like[cd] %@) OR (short_name like[cd] %@)", self.manufacturerTextField.text, self.manufacturerTextField.text]])) {
        } else {
            selectedManufacturer = [Manufacturer createEntity];
            selectedManufacturer.name = self.manufacturerTextField.text;
        }
    }
    weapon.manufacturer = selectedManufacturer;
    
    [[NSManagedObjectContext defaultContext] save];
    
	[self.delegate WeaponAddViewControllerDidSave:self];
}

// TODO possible a better way to do this... 
// alert saying not enough fields completed?

- (IBAction)checkData:(id)sender {
    [self.navigationItem.rightBarButtonItem setEnabled:(([self.manufacturerTextField.text length] > 0) && ([self.modelTextField.text length] > 0))];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ChooseCaliber"]) {
		CaliberChooserViewController *caliberChooserViewController = segue.destinationViewController;
		caliberChooserViewController.delegate = self;
		caliberChooserViewController.selectedCaliber = self.caliberTextField.text;
	} else if ([segue.identifier isEqualToString:@"ChooseManufacturer"]) {
		ManufacturerChooserViewController *manufacturerChooserViewController = segue.destinationViewController;
		manufacturerChooserViewController.delegate = self;
		manufacturerChooserViewController.selectedManufacturer = selectedManufacturer;        
    }
}

#pragma mark - CaliberChooserViewControllerDelegate

- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber
{
	self.caliberTextField.text = selectedCaliber;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ManufacturerChooserViewControllerDelegate

- (void)manufacturerChooserViewController:(ManufacturerChooserViewController *)controller didSelectManufacturer:(Manufacturer *)manufacturer {
    selectedManufacturer = manufacturer;
	self.manufacturerTextField.text = selectedManufacturer.name;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerController

-(IBAction)photoButtonTapped {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];        
    
    imagePicker.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;  
        
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"set photoButton image");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    [self.addPhotoButton setImage:image forState:UIControlStateNormal];
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
            [result insertString:@"." atIndex:0];
             while(result.length <= currencyFormatter.minimumFractionDigits)
             [result insertString:@"0" atIndex:1];
        } else {
            [result insertString:@"." atIndex:(result.length - currencyFormatter.minimumFractionDigits)];
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
    if (self.currentTextField == self.purchaseDateTextField) {
        self.purchaseDateTextField.text = [purchaseDatePickerView.date onlyDate];
    }    
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
    
    
    [self.currentTextField resignFirstResponder];
    self.currentTextField = [formFields objectAtIndex:index];
    [self.currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
    [self.currentTextField resignFirstResponder];
}

- (IBAction)barrelLengthValueChanged:(id)sender {
    if([self.barrelLengthTextField.text length]) {
        CGPoint origin = self.barrelLengthTextField.frame.origin;
        self.barrelLengthUnitLabel.frame = CGRectMake(origin.x + 8, origin.y, [self.barrelLengthTextField.text sizeWithFont:self.barrelLengthTextField.font].width, self.barrelLengthTextField.frame.size.height); 
        self.barrelLengthUnitLabel.hidden = NO;
    } else {
        self.barrelLengthUnitLabel.hidden = YES;
    }
}

- (IBAction)purchasePriceValueChanged:(id)sender {
    if([self.purchasePriceTextfield.text length]) {
        // move field to the right
        self.purchasePriceTextfield.frame = CGRectMake(22, 0, purchasePriceTextfield.frame.size.width, purchasePriceTextfield.frame.size.height);
        self.currencySymbolLabel.hidden = NO;
    } else {
        // reset field to the left
        self.purchasePriceTextfield.frame = CGRectMake(10, 0, purchasePriceTextfield.frame.size.width, purchasePriceTextfield.frame.size.height);
        self.currencySymbolLabel.hidden = YES;
    }
}

@end
