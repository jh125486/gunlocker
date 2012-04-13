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
@synthesize rangeStart;
@synthesize rangeEnd;
@synthesize rangeStep;
@synthesize reticleUnitsControl;
@synthesize windLeadingLabel;
@synthesize directionControl;
@synthesize showNFADetailsSwitch;
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

    showNFADetailsSwitch.on = [defaults boolForKey:@"showNFADetails"];
    self.passcodeCell.detailTextLabel.text   = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
    rangeUnitsControl.selectedSegmentIndex   = [defaults integerForKey:@"rangeUnitsControl"];
    reticleUnitsControl.selectedSegmentIndex = [defaults integerForKey:@"reticleUnitsControl"];

    rangeStart.Current = [defaults integerForKey:@"rangeStart"] ? [defaults integerForKey:@"rangeStart"] : 50;
    rangeEnd.Current   = [defaults integerForKey:@"rangeEnd"]   ? [defaults integerForKey:@"rangeEnd"]   : 1200;
    rangeStep.Current  = [defaults integerForKey:@"rangeStep"]  ? [defaults integerForKey:@"rangeStep"]  : 25;
    rangeStart.Minimum = 5;
    rangeStart.Maximum = 500;
    rangeEnd.Minimum   = 100;
    rangeEnd.Maximum   = 2000;
    rangeStep.Minimum  = 1;
    rangeStep.Maximum  = 250;
    rangeStart.VariableSteps = rangeEnd.VariableSteps = rangeStep.VariableSteps = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:5],  [NSNumber numberWithInt:50], nil];
    rangeStart.VariableRanges = rangeEnd.VariableRanges = rangeStep.VariableRanges = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:10], [NSNumber numberWithInt:50], nil];
    rangeStart.NumDecimals = rangeEnd.NumDecimals = rangeStep.NumDecimals = 0;
    rangeStart.IsEditableTextField = rangeEnd.IsEditableTextField = rangeStep.IsEditableTextField = NO;
    
    windLeadingLabel.text = [NSString stringWithFormat:@"%@ %@", [defaults stringForKey:@"speedType"], [defaults stringForKey:@"speedUnit"]];
    directionControl.selectedSegmentIndex = [defaults integerForKey:@"directionControl"];
    nightModeControl.selectedSegmentIndex = [defaults integerForKey:@"nightModeControl"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setNightModeControl:nil];
    [self setRangeUnitsControl:nil];
    [self setReticleUnitsControl:nil];
    [self setPasscodeCell:nil];
    [self setRangeStart:nil];
    [self setRangeEnd:nil];
    [self setRangeStep:nil];
    [self setWindLeadingLabel:nil];
    [self setDirectionControl:nil];
    [self setShowNFADetailsSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController {
    self.passcodeCell.detailTextLabel.text = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == self.passcodeCell) {
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];        
    }
}

- (IBAction)saveSettings:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setBool:showNFADetailsSwitch.on forKey:@"showNFADetails"];
    [defaults setInteger:[nightModeControl selectedSegmentIndex] forKey:@"nightModeControl"];
    [defaults setInteger:[rangeUnitsControl selectedSegmentIndex] forKey:@"rangeUnitsControl"];
    [defaults setInteger:[reticleUnitsControl selectedSegmentIndex] forKey:@"reticleUnitsControl"];
    [defaults setInteger:[directionControl selectedSegmentIndex] forKey:@"directionControl"];
    [defaults setInteger:(int)rangeStart.Current forKey:@"rangeStart"];
    [defaults setInteger:(int)rangeEnd.Current forKey:@"rangeEnd"];
    [defaults setInteger:(int)rangeStep.Current forKey:@"rangeStep"];
}

- (void)windLeadingTableViewController:(WindLeadingTableViewController *)controller didSelectWindLeading:(NSString *)selectedWindLeading {
	self.windLeadingLabel.text = selectedWindLeading;
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"WindLeadingTable"])
        [[segue destinationViewController] setDelegate:self];
}

@end
