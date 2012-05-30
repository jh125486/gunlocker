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
@synthesize nameTextField = _nameTextField;
@synthesize weaponButton = _weaponButton;
@synthesize weaponTextField = _weaponTextField;
@synthesize weaponPicker = _weaponPicker;
@synthesize muzzleVelocityTextField = _muzzleVelocityTextField;
@synthesize siteHeightTextField= _siteHeightTextField;
@synthesize zeroDistanceTextField = _zeroDistanceTextField;
@synthesize zeroDistanceUnitControl = _zeroDistanceUnitControl;
@synthesize selectedBullet = _selectedBullet;
@synthesize selectedProfile = _selectedProfile;
@synthesize diameterTextField = _diameterTextField;
@synthesize weightTextField = _weightTextField;
@synthesize bulletButton = _bulletButton;
@synthesize dragModelControl = _dragModelControl;
@synthesize bcButton = _bcButton;
@synthesize bcButtonTopEdgeView = _bcButtonTopEdgeView;
@synthesize sgTextField = _sgTextField;
@synthesize sgDirectionControl = _sgDirectionControl;
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

    sgDirections = [NSArray arrayWithObjects:@"LH", @"RH", nil];
    dragModels = [NSArray arrayWithObjects:@"G7", @"G1", nil];
    formFields = [[NSMutableArray alloc] initWithObjects:_nameTextField,
                                                         _weaponTextField,
                                                         _muzzleVelocityTextField, 
                                                         _siteHeightTextField, 
                                                         _zeroDistanceTextField,
                                                         _diameterTextField,
                                                         _weightTextField,
                                                         _sgTextField,
                                                         nil];

    for(UITextField *field in formFields)
        field.delegate = self;
    
    _siteHeightTextField.keyboardType = _diameterTextField.keyboardType = _sgTextField.keyboardType = UIKeyboardTypeDecimalPad;
	
    _weaponPicker = [[UIPickerView alloc] init];
    _weaponPicker.delegate = self;
    _weaponPicker.showsSelectionIndicator = YES;
    _weaponTextField.inputView = _weaponPicker;
    
    weapons = [Weapon findAll];
    [self setUpPickerData];
    
    if (_selectedProfile) [self loadProfile];

    //Register self to recieve notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBullet:) name:@"selectedBullet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didManuallyEnterBC:) name:@"manuallyEnteredBC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDragModel:) name:@"selectedDragModel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCalculateSG:) name:@"didCalculateSG" object:nil];
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
    [self setSgTextField:nil];
    [self setSgDirectionControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadProfile {
    self.title = @"Edit Profile";
    
    _selectedBullet = _selectedProfile.bullet;
    drag_model = _selectedProfile.drag_model;
    selectedWeapon = _selectedProfile.weapon;
    _nameTextField.text = _selectedProfile.name;
    [_weaponButton setTitle:selectedWeapon.description forState:UIControlStateNormal];
    [_weaponPicker selectRow:[weapons indexOfObject:selectedWeapon] inComponent:0 animated:NO];
    _muzzleVelocityTextField.text = [_selectedProfile.muzzle_velocity stringValue];
    _siteHeightTextField.text     = [_selectedProfile.sight_height_inches stringValue];
    _zeroDistanceTextField.text   = [_selectedProfile.zero stringValue];
    [_zeroDistanceUnitControl setSelectedSegmentIndex:_selectedProfile.zero_unit.intValue];
    
    if (_selectedBullet) {
        [_bulletButton setTitle:_selectedBullet.description forState:UIControlStateNormal];
    } else {
        manually_entered_bc = _selectedProfile.bullet_bc;
    }
    _diameterTextField.text = [_selectedProfile.bullet_diameter_inches stringValue];
    _weightTextField.text   = [_selectedProfile.bullet_weight stringValue];
    _dragModelControl.selectedSegmentIndex = [dragModels indexOfObject:drag_model];
    [self setBCButtonTitle:[Bullet bcToString:_selectedProfile.bullet_bc]];
    _sgTextField.text = [_selectedProfile.sg stringValue];
    _sgDirectionControl.selectedSegmentIndex = [sgDirections indexOfObject:_selectedProfile.sg_twist_direction];
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
    } else if ([segueID isEqualToString:@"SG"]) {
        MillerStabilityViewController *dst = segue.destinationViewController;
        dst.passedCaliber = _diameterTextField.text;
        dst.passedWeight  =  _weightTextField.text;
        dst.passedMV      = _muzzleVelocityTextField.text;
    }
}

# pragma mark NS notifiers
- (void)didSelectBullet:(NSNotification*) notification  {
    _selectedBullet = [notification object];
    
    [_bulletButton setTitle:self.selectedBullet.description forState:UIControlStateNormal];
    _diameterTextField.text = [_selectedBullet.diameter_inches stringValue];
    _weightTextField.text   = [_selectedBullet.weight_grains stringValue];
    [self setBCButtonTitle:[Bullet bcToString:[_selectedBullet.ballistic_coefficient objectForKey:drag_model]]];
    manually_entered_bc = nil;
}   

- (void)didSelectDragModel:(NSNotification*) notification  {
    _dragModelControl.selectedSegmentIndex = [dragModels indexOfObject:[notification object]];
    [self dragModelChanged:self.dragModelControl];
}

- (void)didManuallyEnterBC:(NSNotification*) notification {
    if ([[notification object] count] == 0 ) return;
    manually_entered_bc = [notification object];

    _selectedBullet = nil;    
    [self setBCButtonTitle:[Bullet bcToString:manually_entered_bc]];
}

- (void)didCalculateSG:(NSNotification*) notification  {
    _sgTextField.text = [notification object];
}

# pragma mark Button Actions
- (IBAction)selectWeaponTapped:(id)sender {
    [_weaponTextField becomeFirstResponder];
}

- (IBAction)dragModelChanged:(UISegmentedControl *)sender {
    [self resetSelectedBullet];
    manually_entered_bc = nil;
    drag_model = [_dragModelControl titleForSegmentAtIndex:_dragModelControl.selectedSegmentIndex];
    [self setBCButtonTitle:@"Enter Ballistic Coefficient"];
}

-(void)setBCButtonTitle:(NSString *)title {
    [_bcButton setTitle:title forState:UIControlStateNormal];
    _bcButton.enabled = YES;
    _bcButtonTopEdgeView.backgroundColor = [UIColor blackColor];
}

- (void)resetSelectedBullet {
    if (_selectedBullet) {
        manually_entered_bc = [_selectedBullet.ballistic_coefficient objectForKey:drag_model];
        _selectedBullet = nil;
        [_bulletButton setTitle:@"Select a Bullet" forState:UIControlStateNormal];
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
    
    BallisticProfile *profile = (_selectedProfile == nil) ? [BallisticProfile createEntity] : _selectedProfile;
    
    profile.name = self.nameTextField.text;
    profile.weapon = selectedWeapon;
    profile.muzzle_velocity = [NSNumber numberWithInteger:_muzzleVelocityTextField.text.intValue];
    profile.sight_height_inches = [NSNumber numberWithDouble:_siteHeightTextField.text.doubleValue];
    profile.zero = [NSNumber numberWithInteger:_zeroDistanceTextField.text.intValue];
    profile.zero_unit = [NSNumber numberWithInteger:_zeroDistanceUnitControl.selectedSegmentIndex];
    
    if (_selectedBullet != nil) { // either link selectedBullet to the profile or set the manually entered bullet data
        profile.bullet = _selectedBullet;
        profile.bullet_bc = [_selectedBullet.ballistic_coefficient objectForKey:drag_model];
    } else {
        profile.bullet_bc = manually_entered_bc;
    }
    
    profile.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:_diameterTextField.text];
    profile.bullet_weight = [NSNumber numberWithInteger:_weightTextField.text.intValue];
    profile.drag_model = drag_model;
	profile.sg = [NSDecimalNumber decimalNumberWithString:_sgTextField.text];
	profile.sg_twist_direction = [sgDirections objectAtIndex:_sgDirectionControl.selectedSegmentIndex];

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

	[self setWeaponIfCurrentTextField];

    _currentTextField = [formFields objectAtIndex:index];
    [_currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
	[self setWeaponIfCurrentTextField];
    
    [_currentTextField resignFirstResponder];
}

-(void)setWeaponIfCurrentTextField {
    if (_currentTextField == _weaponTextField) {
        selectedWeapon = [weapons objectAtIndex:[_weaponPicker selectedRowInComponent:0]];
        [_weaponButton setTitle:selectedWeapon.description forState:UIControlStateNormal];
    }
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
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                            owner:self 
                                                                          options:nil] 
                                              objectAtIndex:0];
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

@end
