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
@synthesize purchaseDatePickerView;
@synthesize photoButton;
@synthesize barrelLengthUnitLabel;

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
        
    if(selectedWeapon)
        [self loadTextfieldsFromWeapon];
    
    self.photoButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    // set up barrel length field with decimal pad and a Done button on accessoryview toolbar
    self.barrelLengthTextField.keyboardType = UIKeyboardTypeDecimalPad;
    UIToolbar* toolBarView = [[UIToolbar alloc] init];
    toolBarView.barStyle = UIBarStyleBlack;
    toolBarView.translucent = YES;
    toolBarView.tintColor = nil;
    [toolBarView sizeToFit];

    [toolBarView setItems:[NSArray arrayWithObjects: 
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self 
                                                                         action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self 
                                                                         action:@selector(barrelLengthDoneClicked:)],
                           nil]];
    self.barrelLengthTextField.inputAccessoryView = toolBarView;
    
    // purchase price local currency symbol
    UILabel *currencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    currencyLabel.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    currencyLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    currencyLabel.textColor = [UIColor lightGrayColor];
    self.purchasePriceTextfield.keyboardType = UIKeyboardTypeDecimalPad;
    self.purchasePriceTextfield.leftViewMode = UITextFieldViewModeWhileEditing;
    self.purchasePriceTextfield.leftView = currencyLabel;

    // purchase date picker set up
    purchaseDatePickerView = [[UIDatePicker alloc] init];
    UIToolbar* pickerToolBarView = [[UIToolbar alloc] init];
    pickerToolBarView.barStyle = UIBarStyleBlack;
    pickerToolBarView.translucent = YES;
    pickerToolBarView.tintColor = nil;
    [pickerToolBarView sizeToFit];
    
    [pickerToolBarView setItems:[NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                    target:self
                                                                    action:@selector(purchaseDatePickerCancelClicked:)],
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],

                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                  target:self
                                                                  action:@selector(purchaseDatePickerDoneClicked:)],
                                 nil]];
    
    purchaseDatePickerView.datePickerMode = UIDatePickerModeDate; 
    self.purchaseDateTextField.inputView = purchaseDatePickerView;
    self.purchaseDateTextField.inputAccessoryView = pickerToolBarView;
}

- (void)barrelLengthDoneClicked:(id)sender {
    [self.barrelLengthTextField resignFirstResponder];
}

- (void)purchaseDatePickerDoneClicked:(id)sender {
    self.purchaseDateTextField.text = [purchaseDatePickerView.date onlyDate];
    
    [self.purchaseDateTextField resignFirstResponder];
}

- (void)purchaseDatePickerCancelClicked:(id)sender {
    [self.purchaseDateTextField resignFirstResponder];
}


- (void)viewDidUnload {
    [self setManufacturerTextField:nil];
    [self setModelTextField:nil];
    [self setCaliberTextField:nil];
    [self setFinishTextField:nil];
    [self setBarrelLengthTextField:nil];
    [self setPhotoButton:nil];
    [self setSerialNumberTextField:nil];
    [self setPurchaseDateTextField:nil];
    [self setPurchasePriceTextfield:nil];
    [self setSelectedWeapon:nil];
    [self setBarrelLengthUnitLabel:nil];
    [self setBarrelThreadingTextField:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self verifyEnteredData];
    
    // resign all firstresponders
    [self.view endEditing:TRUE];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
    [self verifyEnteredData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
    [self verifyEnteredData];
}

- (IBAction)checkData:(id)sender {
    [self verifyEnteredData];    
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up {
    const int movementDistance = 40; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)loadTextfieldsFromWeapon {
    self.title = [NSString stringWithFormat:@"Edit %@", [self.weaponType substringToIndex:[self.weaponType length] - 1]];

    self.manufacturerTextField.text = selectedWeapon.manufacturer;
    self.modelTextField.text        = selectedWeapon.model;
    self.caliberTextField.text      = selectedWeapon.caliber;
    self.finishTextField.text       = selectedWeapon.finish;
    self.barrelLengthTextField.text = [selectedWeapon.barrel_length stringValue];
    self.barrelThreadingTextField.text = selectedWeapon.threaded_barrel_pitch;
    [self barrelLengthValueChanged:nil];
    [self.photoButton setImage:[UIImage imageWithData:selectedWeapon.photo_thumbnail] forState:UIControlStateNormal];
    self.serialNumberTextField.text = selectedWeapon.serial_number;
    self.purchasePriceTextfield.text = [selectedWeapon.purchased_price stringValue];
    self.purchaseDateTextField.text = [selectedWeapon.purchased_date onlyDate];
    [self verifyEnteredData];
}

- (IBAction)barrelLengthValueChanged:(id)sender {
    if([self.barrelLengthTextField.text length]) {
        self.barrelLengthUnitLabel.frame = CGRectMake(142,70,[self.barrelLengthTextField.text sizeWithFont:self.barrelLengthTextField.font].width,34); 
        self.barrelLengthUnitLabel.hidden = NO;
    } else {
        self.barrelLengthUnitLabel.hidden = YES;
    }
}

- (IBAction)cancelTapped:(id)sender {
	[self.delegate WeaponAddViewControllerDidCancel:self];
}

- (IBAction)saveTapped:(id)sender {
    Weapon *weapon = selectedWeapon ? selectedWeapon : [Weapon createEntity];
    weapon.type = self.weaponType;
    weapon.manufacturer = self.manufacturerTextField.text;
    weapon.model = self.modelTextField.text;
    weapon.caliber = self.caliberTextField.text;
    weapon.finish = self.finishTextField.text;
    
    if(self.barrelLengthTextField.text.length > 0)
        weapon.barrel_length = [NSNumber numberWithFloat:[self.barrelLengthTextField.text floatValue]];    
    weapon.threaded_barrel_pitch = self.barrelThreadingTextField.text;
    
    UIImage *photo = [self.photoButton imageForState:UIControlStateNormal];
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
    weapon.purchased_date = purchaseDatePickerView.date;
    
    [[NSManagedObjectContext defaultContext] save];
    
	[self.delegate WeaponAddViewControllerDidSave:self];
}

// TODO possible a better way to do this... 
// alert saying not enough fields completed?
- (void)verifyEnteredData {
    [self.navigationItem.rightBarButtonItem setEnabled:(([self.manufacturerTextField.text length] > 0) && ([self.modelTextField.text length] > 0))];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ChooseCaliber"]) {
		CaliberChooserViewController *caliberChooserViewController = segue.destinationViewController;
		caliberChooserViewController.delegate = self;
		caliberChooserViewController.selectedCaliber = self.caliberTextField.text;
	} else if ([segue.identifier isEqualToString:@"ChooseManufacturer"]) {
		ManufacturerChooserViewController *manufacturerChooserViewController = segue.destinationViewController;
		manufacturerChooserViewController.delegate = self;
		manufacturerChooserViewController.selectedManufacturer = self.manufacturerTextField.text;        
    }
}

#pragma mark - CaliberChooserViewControllerDelegate

- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber
{
	self.caliberTextField.text = selectedCaliber;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ManufacturerChooserViewControllerDelegate

- (void)manufacturerChooserViewController:(ManufacturerChooserViewController *)controller didSelectManufacturer:(NSString *)selectedManufacturer
{
	self.manufacturerTextField.text = selectedManufacturer;
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
    [self.photoButton setImage:image forState:UIControlStateNormal];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == self.purchasePriceTextfield) {
        static NSString *numbers = @"0123456789";
        static NSString *numbersPeriod = @"01234567890.";
        static NSString *numbersComma = @"0123456789,";
        
        //NSLog(@"%d %d %@", range.location, range.length, string);
        if (range.length > 0 && [string length] == 0) {
            // enable delete
            return YES;
        }
        
        // decimalseparator should not be first
        NSString *symbol = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
        if (range.location == 0 && [string isEqualToString:symbol]) {
            return NO;
        } else {

        }
        
        NSCharacterSet *characterSet;
        NSRange separatorRange = [textField.text rangeOfString:symbol];
        if (separatorRange.location == NSNotFound) {
            if ([symbol isEqualToString:@"."]) {
                characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersPeriod] invertedSet];
            }
            else {
                characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersComma] invertedSet];              
            }
        }
        else {
            // allow 2 characters after the decimal separator
            if (range.location > (separatorRange.location + 2)) {
                return NO;
            }
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];               
        }
        return ([[string stringByTrimmingCharactersInSet:characterSet] length] > 0);
    }
    
    return YES;
}

@end
