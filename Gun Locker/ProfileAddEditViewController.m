//
//  ProfileAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileAddEditViewController.h"

@implementation ProfileAddEditViewController
@synthesize delegate = _delegate;
@synthesize nameTextField;
@synthesize weaponButton, weaponTextField, weaponPicker;
@synthesize muzzleVelocityTextField, siteHeightTextField, zeroDistanceTextField, zeroDistanceUnitControl;
@synthesize selectedBullet = _selectedBullet;
@synthesize selectedProfile, diameterTextField, weightTextField, bulletButton, dragModelControl, bcButton, bcButtonTopEdgeView;
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
    
    self.siteHeightTextField.keyboardType = self.diameterTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.weaponPicker = [[UIPickerView alloc] init];
    self.weaponPicker.delegate = self;
    self.weaponPicker.showsSelectionIndicator = YES;
    self.weaponTextField.inputView = self.weaponPicker;
    
    weapons = [Weapon findAll];
    [self setUpPickerData];
    
    if (self.selectedProfile) [self loadProfile];

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
    [self setDelegate:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadProfile {
    self.title = @"Edit Profile";
    
    _selectedBullet = self.selectedProfile.bullet;
    drag_model = self.selectedProfile.drag_model;
    selectedWeapon = self.selectedProfile.weapon;
    self.nameTextField.text           = self.selectedProfile.name;
    [self.weaponButton setTitle:selectedWeapon.description forState:UIControlStateNormal];
    [self.weaponPicker selectRow:[weapons indexOfObject:selectedWeapon] inComponent:0 animated:NO];
    self.muzzleVelocityTextField.text = [self.selectedProfile.muzzle_velocity stringValue];
    self.siteHeightTextField.text     = [self.selectedProfile.sight_height_inches stringValue];
    self.zeroDistanceTextField.text   = [self.selectedProfile.zero stringValue];
            
    if (_selectedBullet) {
        [self.bulletButton setTitle:_selectedBullet.description forState:UIControlStateNormal];
    } else {
        manually_entered_bc = self.selectedProfile.bullet_bc;
    }
    self.diameterTextField.text       = [self.selectedProfile.bullet_diameter_inches stringValue];
    self.weightTextField.text         = [self.selectedProfile.bullet_weight stringValue];
    self.dragModelControl.selectedSegmentIndex = [dragModels indexOfObject:drag_model];
    [self setBCButtonTitle:[Bullet bcToString:self.selectedProfile.bullet_bc]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"BulletChooser"]) {
        [self.currentTextField resignFirstResponder];
        UINavigationController *destinationController = segue.destinationViewController;
		BulletChooserViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.selectedBullet = _selectedBullet;
    } else if ([segueID isEqualToString:@"ManualBCEntry"]) {
        BulletBCEntryViewController *dst = [[segue.destinationViewController  viewControllers] objectAtIndex:0];
        dst.passedBulletBC =  manually_entered_bc ? manually_entered_bc : [_selectedBullet.ballistic_coefficient objectForKey:drag_model];
        dst.selectedDragModel = drag_model;
    }   
}

# pragma mark NS notifiers
- (void)didSelectBullet:(NSNotification*) notification  {
    self.selectedBullet = [notification object];
    
    [self.bulletButton setTitle:self.selectedBullet.description forState:UIControlStateNormal];
    self.diameterTextField.text = [_selectedBullet.diameter_inches stringValue];
    self.weightTextField.text   = [_selectedBullet.weight_grains stringValue];
    [self setBCButtonTitle:[Bullet bcToString:[self.selectedBullet.ballistic_coefficient objectForKey:drag_model]]];
    manually_entered_bc = nil;
}   

- (void)didSelectDragModel:(NSNotification*) notification  {
    self.dragModelControl.selectedSegmentIndex = [dragModels indexOfObject:[notification object]];
    [self dragModelChanged:self.dragModelControl];
}

- (void)didManuallyEnterBC:(NSNotification*) notification {
    if ([[notification object] count] == 0 ) return;
    manually_entered_bc = [notification object];

    self.selectedBullet = nil;    
    [self setBCButtonTitle:[Bullet bcToString:manually_entered_bc]];
}

# pragma mark Button Actions
- (IBAction)selectWeaponTapped:(id)sender {
    [self.weaponTextField becomeFirstResponder];
}

- (IBAction)dragModelChanged:(UISegmentedControl *)sender {
    [self resetSelectedBullet];
    manually_entered_bc = nil;
    drag_model = [self.dragModelControl titleForSegmentAtIndex:self.dragModelControl.selectedSegmentIndex];
    [self setBCButtonTitle:@"Enter Ballistic Coefficient"];
}

-(void)setBCButtonTitle:(NSString *)title {
    [self.bcButton setTitle:title forState:UIControlStateNormal];
    self.bcButton.enabled = YES;
    self.bcButtonTopEdgeView.backgroundColor = [UIColor blackColor];
}

- (void)resetSelectedBullet {
    if (_selectedBullet) {
        manually_entered_bc = [self.selectedBullet.ballistic_coefficient objectForKey:drag_model];
        self.selectedBullet = nil;
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
    // TODO if some fields are blank, throw up uialertview
    
    BallisticProfile *profile = (self.selectedProfile == nil) ? [BallisticProfile createEntity] : self.selectedProfile;
    
    profile.name = self.nameTextField.text;
    profile.weapon = selectedWeapon;
    profile.muzzle_velocity = [NSNumber numberWithInteger:[self.muzzleVelocityTextField.text intValue]];
    profile.sight_height_inches = [NSNumber numberWithDouble:[self.siteHeightTextField.text doubleValue]];
    profile.zero = [NSNumber numberWithInteger:[self.zeroDistanceTextField.text integerValue]];

    if (_selectedBullet != nil) { // either link selectedBullet to the profile or set the manually entered bullet data
        profile.bullet = _selectedBullet;
        profile.bullet_bc = [_selectedBullet.ballistic_coefficient objectForKey:drag_model];
    } else {
        profile.bullet_bc = manually_entered_bc;
    }
    
    profile.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:self.diameterTextField.text];
    profile.bullet_weight = [NSNumber numberWithInteger:[self.weightTextField.text intValue]];
    profile.drag_model = drag_model;

    [profile calculateTheta];
    
    [[NSManagedObjectContext defaultContext] save];
    
    [_delegate profileAddEditViewController:self didAddEditProfile:profile];
    [self dismissModalViewControllerAnimated:YES];
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

#pragma mark Table delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
	label.shadowColor = [UIColor clearColor];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

@end
