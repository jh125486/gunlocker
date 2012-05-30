//
//  SettingsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "KKPasscodeLock.h"

@implementation SettingsViewController
@synthesize nightModeControl;
@synthesize rangeUnitsControl;
@synthesize rangeStartStepper, rangeEndStepper, rangeStepStepper;
@synthesize reticleUnitsControl;
@synthesize windLeadingLabel;
@synthesize directionControl;
@synthesize showNFAInformationSwitch;
@synthesize passcodeCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    showNFAInformationSwitch.on = [defaults boolForKey:@"showNFADetails"];
    self.passcodeCell.detailTextLabel.text   = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
    rangeUnitsControl.selectedSegmentIndex   = [defaults integerForKey:@"rangeUnitsControl"];
    reticleUnitsControl.selectedSegmentIndex = [defaults integerForKey:@"reticleUnitsControl"];

    rangeStartStepper.Current = [defaults integerForKey:@"rangeStart"];
    rangeEndStepper.Current   = [defaults integerForKey:@"rangeEnd"];
    rangeStepStepper.Current  = [defaults integerForKey:@"rangeStep"];
    rangeStartStepper.Minimum = 5;
    rangeStartStepper.Maximum = 500;
    rangeEndStepper.Minimum   = 100;
    rangeEndStepper.Maximum   = 2000;
    rangeStepStepper.Minimum  = 1;
    rangeStepStepper.Maximum  = 250;
    rangeStartStepper.VariableSteps = rangeEndStepper.VariableSteps = rangeStepStepper.VariableSteps = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:5],  [NSNumber numberWithInt:50], nil];
    rangeStartStepper.VariableRanges = rangeEndStepper.VariableRanges = rangeStepStepper.VariableRanges = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:10], [NSNumber numberWithInt:50], nil];
    rangeStartStepper.NumDecimals = rangeEndStepper.NumDecimals = rangeStepStepper.NumDecimals = 0;
    rangeStartStepper.IsEditableTextField = rangeEndStepper.IsEditableTextField = rangeStepStepper.IsEditableTextField = NO;
    
    windLeadingLabel.text = [NSString stringWithFormat:@"%@ %@", [defaults stringForKey:@"speedType"], [defaults stringForKey:@"speedUnit"]];
    directionControl.selectedSegmentIndex = [defaults integerForKey:@"directionControl"];
    nightModeControl.selectedSegmentIndex = [defaults integerForKey:@"nightModeControl"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TestFlight passCheckpoint:@"Settings disappeared"];
}

- (void)viewDidUnload {
    [self setNightModeControl:nil];
    [self setRangeUnitsControl:nil];
    [self setReticleUnitsControl:nil];
    [self setPasscodeCell:nil];
    [self setRangeStartStepper:nil];
    [self setRangeEndStepper:nil];
    [self setRangeStepStepper:nil];
    [self setWindLeadingLabel:nil];
    [self setDirectionControl:nil];
    [self setShowNFAInformationSwitch:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"WindLeadingTable"])
        [[segue destinationViewController] setDelegate:self];
}

#pragma mark Method Delegates

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController {
    self.passcodeCell.detailTextLabel.text = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
}

- (void)windLeadingTableViewController:(WindLeadingTableViewController *)controller didSelectWindLeading:(NSString *)selectedWindLeading {
	self.windLeadingLabel.text = selectedWindLeading;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Actions

- (IBAction)showNFAInformationTapped:(UISwitch *)nfaSwitch {
    if (nfaSwitch.isOn) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Showing 'NFA Information'"
                                                          message:@"Look for NFA information in each weapon's 'Details' section."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }

    [TestFlight passCheckpoint:[NSString stringWithFormat:@"NFAInformation switched %@", nfaSwitch.isOn ? @"on" : @"off" ]];
}

- (IBAction)saveSettings:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:showNFAInformationSwitch.on forKey:@"showNFADetails"];
    [defaults setInteger:[nightModeControl selectedSegmentIndex] forKey:@"nightModeControl"];
    [defaults setInteger:[rangeUnitsControl selectedSegmentIndex] forKey:@"rangeUnitsControl"];
    [defaults setInteger:[reticleUnitsControl selectedSegmentIndex] forKey:@"reticleUnitsControl"];
    [defaults setInteger:[directionControl selectedSegmentIndex] forKey:@"directionControl"];
    [defaults setInteger:(int)rangeStartStepper.Current forKey:@"rangeStart"];
    [defaults setInteger:(int)rangeEndStepper.Current forKey:@"rangeEnd"];
    [defaults setInteger:(int)rangeStepStepper.Current forKey:@"rangeStep"];
}

- (IBAction)setStepperRanges:(id)sender {
    self.rangeStartStepper.Maximum = self.rangeEndStepper.Current - self.rangeStepStepper.Current;
    self.rangeEndStepper.Minimum   = self.rangeStartStepper.Current + self.rangeStepStepper.Current;
    self.rangeStepStepper.Maximum  = self.rangeEndStepper.Current - self.rangeStartStepper.Current;    
}

#pragma mark Table delegates
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" owner:self options:nil] 
                                              objectAtIndex:0];
    
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.passcodeCell) {
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];        
    }
}

@end
