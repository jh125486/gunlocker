//
//  SettingsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize nightModeControl;
@synthesize rangeUnitsControl;
@synthesize reticleUnitsControl;
@synthesize rangeIncrementLabel;
@synthesize rangeIncrementStepper;

@synthesize prevIncrementValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    nightModeControl.selectedSegmentIndex = [[defaults objectForKey:@"nightModeControl"] intValue];
    rangeUnitsControl.selectedSegmentIndex = [[defaults objectForKey:@"rangeUnitsControl"] intValue];
    reticleUnitsControl.selectedSegmentIndex = [[defaults objectForKey:@"reticleUnitsControl"] intValue];
    rangeIncrementStepper.value = [[defaults objectForKey:@"rangeIncrement"] intValue];
    prevIncrementValue = rangeIncrementStepper.value;
    [self setStepValue:nil];
}

- (void)viewDidUnload
{
    [self setNightModeControl:nil];
    [self setRangeUnitsControl:nil];
    [self setReticleUnitsControl:nil];
    [self setRangeIncrementLabel:nil];
    [self setRangeIncrementStepper:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)settingsChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
    [defaults setObject:[NSNumber numberWithInt:[nightModeControl selectedSegmentIndex]] forKey:@"nightModeControl"];
    [defaults setObject:[NSNumber numberWithInt:[rangeUnitsControl selectedSegmentIndex]] forKey:@"rangeUnitsControl"];
    [defaults setObject:[NSNumber numberWithInt:[reticleUnitsControl selectedSegmentIndex]] forKey:@"reticleUnitsControl"];
    [defaults setObject:[NSNumber numberWithInt:[rangeIncrementLabel.text intValue]] forKey:@"rangeIncrement"];
    
    [defaults synchronize];
}

- (IBAction)setStepValue:(id)sender {
    double newIncrementValue = rangeIncrementStepper.value;
    NSLog(@"%.0f %.0f", prevIncrementValue, newIncrementValue);
    
    // hacks for uistepper acting weird
    if (newIncrementValue == 249) {
        newIncrementValue = 200;
    } else if (newIncrementValue == 49) {
        newIncrementValue = 45;
    } else if (newIncrementValue == 55) {
        newIncrementValue = 100;
    } else if (newIncrementValue == 105){
        newIncrementValue = 150;
    }
        
    if(newIncrementValue > prevIncrementValue) {
        if (newIncrementValue >= 50) {
            rangeIncrementStepper.stepValue = 50;
        } else if (newIncrementValue >= 10) {
            rangeIncrementStepper.stepValue = 5;    
        } else  {
            rangeIncrementStepper.stepValue = 1;
        } 
        NSLog(@"going up from %.0f to %.0f step %.0f", prevIncrementValue, newIncrementValue, rangeIncrementStepper.stepValue);
    } else {
        if (newIncrementValue <= 10) {
            rangeIncrementStepper.stepValue = 1;
        } else if (newIncrementValue <= 50) {
            rangeIncrementStepper.stepValue = 5;    
        } else {
            rangeIncrementStepper.stepValue = 50;
        }
        NSLog(@"going down from %.0f to %.0f step %.0f", prevIncrementValue, newIncrementValue, rangeIncrementStepper.stepValue);
    }
    
    rangeIncrementLabel.text = [NSString stringWithFormat:@"%0.f", newIncrementValue];
    prevIncrementValue = newIncrementValue;
}



@end
