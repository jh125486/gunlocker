//
//  WeaponAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponAddViewController.h"

@implementation WeaponAddViewController

@synthesize delegate;
@synthesize managedObjectContext;
@synthesize actionSheetPicker;
@synthesize manufacturerTextField;
@synthesize modelTextField;
@synthesize caliberTextField;
@synthesize finishTextField;
@synthesize barrelLengthTextField;
@synthesize serialNumberTextField;
@synthesize purchaseDateTextField;
@synthesize purchasePriceTextfield;
@synthesize photoButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.barrelLengthTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.1)) {
        self.barrelLengthTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setManufacturerTextField:nil];
    [self setModelTextField:nil];
    [self setCaliberTextField:nil];
    [self setFinishTextField:nil];
    [self setBarrelLengthTextField:nil];
    [self setPhotoButton:nil];
    [self setSerialNumberTextField:nil];
    [self setPurchaseDateTextField:nil];
    [self setPurchasePriceTextfield:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self verifyEnteredData];
    
    // resign all firstresponders
    [self.view endEditing:TRUE];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self verifyEnteredData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self verifyEnteredData];
}

- (IBAction)checkData:(id)sender
{
    [self verifyEnteredData];    
}

- (IBAction)cancel:(id)sender
{
	[self.delegate WeaponAddViewControllerDidCancel:self];
}

- (IBAction)save:(id)sender
{
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    
    Weapon *weapon = [NSEntityDescription insertNewObjectForEntityForName:@"Weapon" inManagedObjectContext:managedObjectContext];

    weapon.manufacturer = self.manufacturerTextField.text;
    weapon.model = self.modelTextField.text;
    weapon.caliber = self.caliberTextField.text;
    weapon.finish = self.finishTextField.text;
    
    if(self.barrelLengthTextField.text.length > 0)
        weapon.barrel_length = [NSNumber numberWithFloat:[self.barrelLengthTextField.text floatValue]];    
    
    UIImage *photo = [self.photoButton imageForState:UIControlStateNormal];
    if(photo) {
        weapon.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the recipe object.
        CGSize size = photo.size;
        CGFloat ratio = 0;
        ratio = (size.width > size.height) ? 140.0 / size.width : 105.0 / size.height;
        
        CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        weapon.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();   
        
        UIImage *thumbnail = [UIImage imageWithData:weapon.photo_thumbnail];
        NSLog(@"New: %f x %f", photo.size.width, photo.size.height);
        NSLog(@"New: %f x %f", thumbnail.size.width, thumbnail.size.height);
    }
        
    
    weapon.serial_number = self.serialNumberTextField.text;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    weapon.purchased_date = [dateFormat dateFromString:self.purchaseDateTextField.text];
    NSLog([weapon.purchased_date description]);
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
	[self.delegate WeaponAddViewControllerDidSave:self];
}

- (void)verifyEnteredData
{
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
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;  
        
    }
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    [self.photoButton setImage:[info objectForKey:UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];

    [self dismissModalViewControllerAnimated:YES];
}

#pragma ActionSheetPicker for PurchaseDateTextField

- (IBAction)purchaseDateTextFieldTapped:(UIControl *)sender {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    NSDate *selectedDate = [dateFormat dateFromString:self.purchaseDateTextField.text];

    self.actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:selectedDate target:self action:@selector(dateWasSelected:element:) origin:sender];
    [self.actionSheetPicker addCustomButtonWithTitle:@"Today" value:[NSDate date]];
//    [self.actionSheetPicker addCustomButtonWithTitle:@"Yesterday" value:[[NSDate date] TC_dateByAddingCalendarUnits:NSDayCalendarUnit amount:-1]];
    self.actionSheetPicker.hideCancel = YES;
    [self.actionSheetPicker showActionSheetPicker];
}

- (void)purchaseDateWasSelected:(NSDate *)selectedDate element:(id)element {    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    self.purchaseDateTextField.text = [dateFormat stringFromDate:selectedDate];    
}

@end
