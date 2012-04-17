//
//  ProfileAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileAddEditViewController.h"

@implementation ProfileAddEditViewController
@synthesize bulletInfoLabel;
@synthesize dragModelControl;
@synthesize muzzleVelocityTextField;
@synthesize muzzleVelocityUnitControl;
@synthesize siteHeightTextField;
@synthesize siteHeightUnitControl;
@synthesize zeroDistanceTextField;
@synthesize zeroDistanceUnitControl;
@synthesize temperatureTextField;
@synthesize temperatureUnitControl;
@synthesize pressureTextfield;
@synthesize pressureUnitControl;
@synthesize relativeHumidityTextField;
@synthesize altitudeTextField;
@synthesize altitudeUnitControl;
@synthesize selectedBullet;
@synthesize currentTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    //Register self to recieve "selectedBullet" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBullet:) name:@"selectedBullet" object:nil];
    //Register self to recieve "manuallyEnteredBullet" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manuallyEnteredBulletInfo:) name:@"manuallyEnteredBullet" object:nil];

    
    formFields = [[NSMutableArray alloc] initWithObjects:muzzleVelocityTextField, siteHeightTextField, zeroDistanceTextField, temperatureTextField, pressureTextfield, relativeHumidityTextField, altitudeTextField, nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;    

    
    if (selectedBullet) [self loadTextFieldsFromBullet];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setBulletInfoLabel:nil];
    [self setSelectedBullet:nil];
    [self setMuzzleVelocityTextField:nil];
    [self setSiteHeightTextField:nil];
    [self setZeroDistanceTextField:nil];
    [self setTemperatureTextField:nil];
    [self setPressureTextfield:nil];
    [self setRelativeHumidityTextField:nil];
    [self setAltitudeTextField:nil];
    [self setMuzzleVelocityUnitControl:nil];
    [self setSiteHeightUnitControl:nil];
    [self setZeroDistanceUnitControl:nil];
    [self setTemperatureUnitControl:nil];
    [self setPressureUnitControl:nil];
    [self setAltitudeUnitControl:nil];
    [self setDragModelControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadTextFieldsFromBullet {
    
}

// trying to size up segment controls
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    for (UISegmentedControl *control in cell.subviews){
        if ([control isKindOfClass:[UISegmentedControl class]]) {
            NSLog(@"%@", control);
            [control setFrame: CGRectMake(control.frame.origin.x, control.frame.origin.y, control.frame.size.width, 43.0)];
        }
    }
}

# pragma NS notifiers
- (void)didSelectBullet:(NSNotification*) notification  {
    self.selectedBullet = [notification object];
    // if only have G1 or G7 drag model, disable segment on dragModelControl
    if (![self.selectedBullet.ballistic_coefficient objectForKey:@"G1"]) {
        [self.dragModelControl setEnabled:NO forSegmentAtIndex:0];
        [self.dragModelControl setSelectedSegmentIndex:1];
    } else {
        [self.dragModelControl setEnabled:YES forSegmentAtIndex:0];
    }

    if (![self.selectedBullet.ballistic_coefficient objectForKey:@"G7"]) {
        [self.dragModelControl setEnabled:NO forSegmentAtIndex:1];
        [self.dragModelControl setSelectedSegmentIndex:0];
    } else {
        [self.dragModelControl setEnabled:YES forSegmentAtIndex:1];
    }
    
    self.bulletInfoLabel.text = [NSString stringWithFormat:@"%@ %@", self.selectedBullet.brand, self.selectedBullet.name];
}

- (void)manuallyEnteredBulletInfo:(NSNotification*) notification  {
    NSArray *manuallyEnteredBulletInfo = [notification object];
    bullet_weight = [manuallyEnteredBulletInfo objectAtIndex:0];
    bullet_bc = [manuallyEnteredBulletInfo objectAtIndex:1];
    
    self.bulletInfoLabel.text = [NSString stringWithFormat:@"%@ gr / BC %@\n(manually entered)", bullet_weight, bullet_bc]; 
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
    [self.currentTextField resignFirstResponder];
}

@end
