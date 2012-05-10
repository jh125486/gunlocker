//
//  ProfileAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileAddEditViewController.h"

@implementation ProfileAddEditViewController
@synthesize nameTextField;
@synthesize weaponTextField, weaponPicker;
@synthesize muzzleVelocityTextField, muzzleVelocityUnitControl;
@synthesize siteHeightTextField, siteHeightUnitControl;
@synthesize zeroDistanceTextField, zeroDistanceUnitControl;
@synthesize selectedProfile, selectedBullet;
@synthesize diameterTextField;
@synthesize weightTextField;
@synthesize weaponButton;
@synthesize bulletButton;
@synthesize dragModelControl;
@synthesize bcButton;
@synthesize bcButtonTopEdgeView;
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

    dragModels = [NSArray arrayWithObjects:@"G7", @"G1", nil];
    formFields = [[NSMutableArray alloc] initWithObjects:self.nameTextField,
                                                         self.weaponTextField,
                                                         self.muzzleVelocityTextField, 
                                                         self.siteHeightTextField, 
                                                         self.zeroDistanceTextField,
                                                         self.diameterTextField,
                                                         self.weightTextField,
                                                         nil];

    for(UITextField *field in formFields)
        field.delegate = self;
    
    self.siteHeightTextField.keyboardType = self.diameterTextField.keyboardType = self.weightTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.weaponPicker = [[UIPickerView alloc] init];
    self.weaponPicker.delegate = self;
    self.weaponPicker.showsSelectionIndicator = YES;
    self.weaponTextField.inputView = self.weaponPicker;
    
    weapons = [Weapon findAll];
    [self setUpPickerData];
    
    if (selectedProfile) [self loadTextFieldsFromProfile];

    //Register self to recieve notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBullet:) name:@"selectedBullet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didManuallyEnterBC:) name:@"manuallyEnteredBC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDragModel:) name:@"selectedDragModel" object:nil];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSelectedBullet:nil];
    [self setMuzzleVelocityTextField:nil];
    [self setSiteHeightTextField:nil];
    [self setZeroDistanceTextField:nil];
    [self setMuzzleVelocityUnitControl:nil];
    [self setSiteHeightUnitControl:nil];
    [self setZeroDistanceUnitControl:nil];
    [self setNameTextField:nil];
    [self setWeaponTextField:nil];
    [self setBcButtonTopEdgeView:nil];
    [self setBcButton:nil];
    [self setDragModelControl:nil];
    [self setDiameterTextField:nil];
    [self setWeightTextField:nil];
    [self setBulletButton:nil];
    [self setWeaponButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadTextFieldsFromProfile {
    selectedBullet = self.selectedProfile.bullet;
    self.nameTextField.text           = self.selectedProfile.name;
    [self.weaponButton setTitle:self.selectedProfile.weapon.description forState:UIControlStateNormal];
    [self.weaponPicker selectRow:[weapons indexOfObject:self.selectedProfile.weapon] inComponent:0 animated:NO];
    self.muzzleVelocityTextField.text = [self.selectedProfile.muzzle_velocity stringValue];
    self.siteHeightTextField.text     = [self.selectedProfile.sight_height_inches stringValue];
    self.zeroDistanceTextField.text   = [self.selectedProfile.zero stringValue];
    self.diameterTextField.text       = [self.selectedProfile.bullet_diameter_inches stringValue];
    self.weightTextField.text         = [self.selectedProfile.bullet_weight stringValue];
    self.dragModelControl.selectedSegmentIndex = [dragModels indexOfObject:self.selectedProfile.drag_model];
    
    
    NSArray *bc = [self.selectedProfile.bullet_bc objectForKey:drag_model];
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"%@", [bc objectAtIndex:0]];
    if (bc.count > 1) [bcText appendString:@" and ..."];
    [self.bcButton setTitle:bcText forState:UIControlStateNormal];
    
    if (selectedBullet) {
        [self.bulletButton setTitle:selectedBullet.description forState:UIControlStateNormal];
    } else {
        manually_entered_bc = self.selectedProfile.bullet_bc;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"BulletChooser"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		BulletChooserViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.selectedBullet = selectedBullet;
    } else if ([segueID isEqualToString:@"ManualBCEntry"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		BulletBCEntryViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.passedBulletBC =  manually_entered_bc ? manually_entered_bc : [selectedBullet.ballistic_coefficient objectForKey:drag_model];
        dst.selectedDragModel = drag_model;
    }   
}

# pragma mark NS notifiers
- (void)didSelectBullet:(NSNotification*) notification  {
    selectedBullet = [notification object];
    NSArray *bc = [selectedBullet.ballistic_coefficient objectForKey:drag_model];
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"BC: %@", [bc objectAtIndex:0]];
    for (int i = 1; i < bc.count; i += 2)
        [bcText appendFormat:@"/%@", [bc objectAtIndex:i]];
    
    [self.bulletButton setTitle:selectedBullet.description forState:UIControlStateNormal];
    self.diameterTextField.text = [selectedBullet.diameter_inches stringValue];
    self.weightTextField.text   = [selectedBullet.weight_grains stringValue];
    [self.bcButton setTitle:bcText forState:UIControlStateNormal];
    
    manually_entered_bc = nil;
}   

- (void)didSelectDragModel:(NSNotification*) notification  {
    self.dragModelControl.selectedSegmentIndex = [dragModels indexOfObject:[notification object]];
    [self dragModelChanged:self.dragModelControl];
}

- (void)didManuallyEnterBC:(NSNotification*) notification {
    if ([[notification object] count] == 0 ) return;
    
    manually_entered_bc = [notification object];
    
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"BC: %@", [manually_entered_bc objectAtIndex:0]];
    for (int i = 1; i < manually_entered_bc.count; i += 2)
        [bcText appendFormat:@"/%@", [manually_entered_bc objectAtIndex:i]];

    [self.bcButton setTitle:bcText forState:UIControlStateNormal];
    
    selectedBullet = nil;
}

# pragma mark Button Actions
- (IBAction)selectWeaponTapped:(id)sender {
    [self.weaponTextField becomeFirstResponder];
}

- (IBAction)dragModelChanged:(UISegmentedControl *)sender {
    [self resetSelectedBullet];
    manually_entered_bc = nil;
    drag_model = [self.dragModelControl titleForSegmentAtIndex:self.dragModelControl.selectedSegmentIndex];
    self.bcButton.enabled = YES;
    self.bcButtonTopEdgeView.backgroundColor = [UIColor blackColor];
    [self.bcButton setTitle:@"Enter Ballistic Coefficient" forState:UIControlStateNormal];
}

- (void)resetSelectedBullet {
    if (selectedBullet) {
        manually_entered_bc = [selectedBullet.ballistic_coefficient objectForKey:drag_model];
        selectedBullet = nil;
        [self.bulletButton setTitle:@"Select a Bullet" forState:UIControlStateNormal];
    }
}

- (IBAction)bulletFieldChanged:(UITextField *)sender {
    [self resetSelectedBullet];    
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    NSLog(@"Name: %@", self.nameTextField.text);
    NSLog(@"Weapon: %@", selectedWeapon.description);
    NSLog(@"%@ / %@ / %@", self.muzzleVelocityTextField.text, self.siteHeightTextField.text, self.zeroDistanceTextField.text);
    NSLog(@"Bullet: %@", selectedBullet.description);
    NSLog(@"%@ / %@", self.diameterTextField.text, self.weightTextField.text);
    NSLog(@"Drag Model: %@", drag_model);
    NSLog(@"BC: %@", manually_entered_bc ? manually_entered_bc : [selectedBullet.ballistic_coefficient objectForKey:drag_model]);
    
// either save the manually entered bullet data, or link selectedBullet to the profile
//    [self.selectedProfile calculateTheta];
    [[NSManagedObjectContext defaultContext] save];
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
    } else if ([formFields lastObject] == textField) {
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

    if (self.currentTextField == self.weaponTextField) {
        selectedWeapon = [weapons objectAtIndex:[weaponPicker selectedRowInComponent:0]];
        [self.weaponButton setTitle:selectedWeapon.description forState:UIControlStateNormal];
    }

    self.currentTextField = [formFields objectAtIndex:index];
    [self.currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
    if (self.currentTextField == self.weaponTextField) {
        selectedWeapon = [weapons objectAtIndex:[weaponPicker selectedRowInComponent:0]];
        [self.weaponButton setTitle:selectedWeapon.description forState:UIControlStateNormal];
    }
    
    [self.currentTextField resignFirstResponder];
}

# pragma mark pickerview delegates

-(void)setUpPickerData {
    weaponViews = [[NSMutableArray alloc] initWithCapacity:[weapons count]];
    
    for (Weapon *weapon in weapons) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *thumbNail = [[UIImageView alloc] initWithFrame:CGRectMake(16, 1, 56, 42)];
        thumbNail.image = [UIImage imageWithData:weapon.photo_thumbnail];
        UILabel *firstLine  = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 230, 22)];
        UILabel *secondLine = [[UILabel alloc] initWithFrame:CGRectMake(75, 22, 230, 22)];
        firstLine.backgroundColor = [UIColor clearColor];
        secondLine.backgroundColor = [UIColor clearColor];
        firstLine.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
        secondLine.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18];
        firstLine.textColor = [UIColor blackColor];
        secondLine.textColor = [UIColor darkGrayColor];
        firstLine.adjustsFontSizeToFitWidth = YES;
        firstLine.text  = [NSString stringWithFormat:@"%@", weapon];
        secondLine.text = [NSString stringWithFormat:@"%@ - %@", weapon.caliber, weapon.finish];
        [view addSubview:thumbNail];
        [view addSubview:firstLine];
        [view addSubview:secondLine];
        [weaponViews addObject:view];
    }
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    return [weaponViews objectAtIndex:row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [weaponViews count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
