//
//  WeaponAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponAddViewController.h"
#import "Weapon.h"

@implementation WeaponAddViewController
{
    NSString *caliber;
}

@synthesize delegate;
@synthesize managedObjectContext;

@synthesize makeTextField;
@synthesize modelTextField;
@synthesize caliberTextField;
@synthesize finishTextField;
@synthesize barrelLengthTextField;
@synthesize serialNumberTextField;
@synthesize purchaseDateTextField;
@synthesize purchasePriceTextfield;


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
    [self setMakeTextField:nil];
    [self setModelTextField:nil];
    [self setCaliberTextField:nil];
    [self setFinishTextField:nil];
    [self setBarrelLengthTextField:nil];
    [self setSerialNumberTextField:nil];
    [self setPurchaseDateTextField:nil];
    [self setPurchasePriceTextfield:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    weapon.make = self.makeTextField.text;
    weapon.model = self.modelTextField.text;
    weapon.caliber = self.caliberTextField.text;
    weapon.finish = self.finishTextField.text;
    weapon.barrel_length = [NSNumber numberWithFloat:[self.barrelLengthTextField.text floatValue]];    
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // handle error
    }
    
	[self.delegate WeaponAddViewControllerDidSave:self];
}

- (void)verifyEnteredData
{
    [self.navigationItem.rightBarButtonItem setEnabled:(([self.makeTextField.text length] > 0) && ([self.modelTextField.text length] > 0))];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ChooseCaliber"])
	{
		CaliberChooserViewController *caliberChooserViewController = segue.destinationViewController;
		caliberChooserViewController.delegate = self;
		caliberChooserViewController.caliber = caliber;
	}
}

#pragma mark - CaliberChooserViewControllerDelegate

- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber
{
	caliber = selectedCaliber;
	self.caliberTextField.text = caliber;
	[self.navigationController popViewControllerAnimated:YES];
}
@end
