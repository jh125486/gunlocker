//
//  SettingsQuickDialogViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsQuickDialogViewController.h"

@interface SettingsQuickDialogViewController ()

@end

@implementation SettingsQuickDialogViewController
@synthesize passCodeElement;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.root =  [[QRootElement alloc] init];
    self.root.grouped = YES;
    self.root.title = @"Settings";

    [self.root addSection:[self createAppSection]];
    [self.root addSection:[self createBallisticSection]];
    
    [self.root fetchValueIntoObject:[NSUserDefaults standardUserDefaults]];
    
    
//    self.passcodeCellStatusLabel.text = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";


    
    
}

-(void)viewWillDisappear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

//    [defaults setObject:<#(id)#> forKey:<#(NSString *)#>];
    
    [defaults synchronize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (QSection *)createAppSection {
    QSection *section = [[QSection alloc] initWithTitle:@"Application"];
    
    // about element
    
    self.passCodeElement = [[QLabelElement alloc] initWithTitle:@"Passcode" Value:([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off"];
    self.passCodeElement.controllerAction = @"pushPasscodeController:";
    self.passCodeElement.onSelected = ^{
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    };
        
    [section addElement:self.passCodeElement];

    return section;
}


- (QSection *)createBallisticSection {
    QSection *section = [[QSection alloc] initWithTitle:@"Ballistics"];

    QRadioElement *rangeUnits = [[QRadioElement alloc] initWithItems:[[NSArray alloc] initWithObjects:@"Yards", @"Meters", nil] selected:0 title:@"Range units"];
	rangeUnits.key = @"rangeUnitsControl";
    
    QDecimalElement *rangeStart = [[QDecimalElement alloc] initWithTitle:@"Range start" value:100];
    rangeStart.key = @"rangeStart";
    rangeStart.keyboardType = UIKeyboardTypeNumberPad;
    rangeStart.fractionDigits = 0;

    QDecimalElement *rangeEnd = [[QDecimalElement alloc] initWithTitle:@"Range start" value:1000];
    rangeEnd.key = @"rangeEnd";
    rangeEnd.keyboardType = UIKeyboardTypeNumberPad;
    rangeEnd.fractionDigits = 0;
    
    QRadioElement *reticleUnits = [[QRadioElement alloc] initWithItems:[[NSArray alloc] initWithObjects:@"MOA", @"MILs", nil] selected:0 title:@"Reticle units"];
	reticleUnits.key = @"reticleUnitsControl";
    
    QRadioElement *nightModeControl = [[QRadioElement alloc] initWithItems:[[NSArray alloc] initWithObjects:@"Off", @"On", @"Auto", nil] selected:0 title:@"Night mode"];
	nightModeControl.key = @"nightModeControl";
    
    [section addElement:rangeUnits];
    [section addElement:rangeStart];
    [section addElement:rangeEnd];
    [section addElement:reticleUnits];
    [section addElement:nightModeControl];
    
    
    return section;
}

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController {
    self.passCodeElement.value = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
}


@end
