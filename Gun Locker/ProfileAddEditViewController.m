//
//  ProfileAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileAddEditViewController.h"

@implementation ProfileAddEditViewController
@synthesize bulletWeightLabel;
@synthesize dragModelLabel;
@synthesize bcLabel;
@synthesize bulletTypePromptLabel;
@synthesize bulletDiameterLabel;
@synthesize bulletTypeLabel;
@synthesize bulletWeightPromptLabel;
@synthesize nameTextField;
@synthesize weaponTextField, weaponPicker;
@synthesize muzzleVelocityTextField, muzzleVelocityUnitControl;
@synthesize siteHeightTextField, siteHeightUnitControl;
@synthesize zeroDistanceTextField, zeroDistanceUnitControl;
@synthesize selectedProfile, selectedBullet;
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

    //Register self to recieve notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBullet:) name:@"selectedBullet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manuallyEnteredBulletInfo:) name:@"manuallyEnteredBullet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectDragModel:) name:@"selectedDragModel" object:nil];

    formFields = [[NSMutableArray alloc] initWithObjects:self.muzzleVelocityTextField, self.siteHeightTextField, self.zeroDistanceTextField, nil];
    
    self.weaponPicker = [[UIPickerView alloc] init];
    self.weaponPicker.delegate = self;
    self.weaponPicker.showsSelectionIndicator = YES;
    self.weaponTextField.inputView = self.weaponPicker;
    
    for(UITextField *field in formFields)
        field.delegate = self;    
    
    if (selectedProfile) [self loadTextFieldsFromProfile];
    
    weapons = [Weapon findAll];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setBulletWeightLabel:nil];
    [self setSelectedBullet:nil];
    [self setMuzzleVelocityTextField:nil];
    [self setSiteHeightTextField:nil];
    [self setZeroDistanceTextField:nil];
    [self setMuzzleVelocityUnitControl:nil];
    [self setSiteHeightUnitControl:nil];
    [self setZeroDistanceUnitControl:nil];
    [self setDragModelLabel:nil];
    [self setBcLabel:nil];
    [self setNameTextField:nil];
    [self setBulletTypePromptLabel:nil];
    [self setBulletTypeLabel:nil];
    [self setBulletWeightPromptLabel:nil];
    [self setBulletDiameterLabel:nil];
    [self setWeaponTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadTextFieldsFromProfile {

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"BulletChooser"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		BulletChooserViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.selectedBullet = self.selectedBullet;
    } else if ([segueID isEqualToString:@"ManualBulletEntry"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		BulletEntryManualViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.passedBulletBC = manually_entered_bc;
        dst.passedBulletWeight = bullet_weight;
        dst.selectedDragModel = drag_model;
    }   
}

# pragma mark NS notifiers
- (void)didSelectBullet:(NSNotification*) notification  {
    self.selectedBullet = [notification object];
    NSArray *bc = [self.selectedBullet.ballistic_coefficient objectForKey:self.dragModelLabel.text];
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"%@", [bc objectAtIndex:0]];
    for (int i = 1; i < bc.count; i += 2)
        [bcText appendFormat:@" \n %@ below %@ fps", [bc objectAtIndex:i], [bc objectAtIndex:i+1]];
    
    self.bulletTypePromptLabel.text = @"Name";
    NSMutableString *type = [[NSMutableString alloc] initWithFormat:@"%@ %@", self.selectedBullet.brand, self.selectedBullet.name];
    if (![self.selectedBullet.brand isEqualToString:self.selectedBullet.category]) [type appendFormat:@" (%@)", self.selectedBullet.category];
    
    self.bulletTypeLabel.text = type;
    self.bulletTypeLabel.adjustsFontSizeToFitWidth = YES;
    self.bulletTypeLabel.minimumFontSize = 12.0f;
    self.bulletDiameterLabel.text = [NSString stringWithFormat:@"%@\"", self.selectedBullet.diameter_inches];
    self.bulletWeightPromptLabel.text = @"Caliber\nWeight";
    self.bulletWeightPromptLabel.numberOfLines = 2;
    self.bulletWeightLabel.text = [NSString stringWithFormat:@"%.3f caliber\n%@ grains", [self.selectedBullet.diameter_inches doubleValue], self.selectedBullet.weight_grains];
    self.bulletWeightLabel.numberOfLines = 2;
    self.bcLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.bcLabel.numberOfLines = 2;
    self.bcLabel.text = bcText;
    manually_entered_bc = nil;
}   

- (void)didSelectDragModel:(NSNotification*) notification  {
    self.dragModelLabel.text = [notification object];
    drag_model = self.dragModelLabel.text;
}

- (void)manuallyEnteredBulletInfo:(NSNotification*) notification {
    NSArray *manuallyEnteredBulletInfo = [notification object];

    manually_entered_bc = [manuallyEnteredBulletInfo objectAtIndex:2];
    NSMutableString *bcText = [[NSMutableString alloc] initWithFormat:@"%@", [manually_entered_bc objectAtIndex:0]];
    for (int i = 2; i < manually_entered_bc.count; i += 2)
        [bcText appendFormat:@" \n %@ below %@ fps", [manually_entered_bc objectAtIndex:i], [manually_entered_bc objectAtIndex:i+1]];
    
    self.bulletDiameterLabel.text = [NSString stringWithFormat:@"%@\"", [manuallyEnteredBulletInfo objectAtIndex:1]];
    self.bulletTypePromptLabel.text = @"Type";
    self.bulletTypeLabel.text = @"manually entered";
    bullet_weight = [manuallyEnteredBulletInfo objectAtIndex:0];
    self.bulletWeightPromptLabel.text = @"Weight";
    self.bulletWeightLabel.text = [NSString stringWithFormat:@"%@ grains", bullet_weight]; 
    self.bcLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.bcLabel.numberOfLines = 2;
    self.bcLabel.text = bcText;
    self.selectedBullet = nil;
}

# pragma mark Button Actions
- (IBAction)selectWeaponTapped:(id)sender {
    [self.weaponTextField becomeFirstResponder];
}

- (IBAction)bulletControlTapped:(UISegmentedControl *)sender {
    [self performSegueWithIdentifier:(sender.selectedSegmentIndex == 0) ? @"BulletChooser" : @"ManualBulletEntry" sender:nil];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    
// either save the manually entered bullet data, or link selectedBullet to the profile
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
    if (self.currentTextField = self.weaponTextField) {
        selectedWeapon = [weapons objectAtIndex:[weaponPicker selectedRowInComponent:0]];
        self.weaponTextField.text = [NSString stringWithFormat:@"%@", selectedWeapon];
    }
    
    [self.currentTextField resignFirstResponder];
}

# pragma mark pickerview delegates

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (view == nil) {
        Weapon *weapon = [weapons objectAtIndex:row];
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
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
    }
    
    return view;    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [weapons count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

@end
