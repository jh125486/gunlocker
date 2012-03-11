//
//  EnergyFormulasViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnergyFormulasViewController.h"

//@interface EnergyFormulasViewController ()
//
//@end

@implementation EnergyFormulasViewController

@synthesize bulletCaliberTextField;
@synthesize bulletWeightTextField;
@synthesize muzzleVeloctiyTextField;
@synthesize resultTKOFLabel;
@synthesize resultThornileyLabel;
@synthesize resultEnergyLabel;
@synthesize energyUnitsControl;

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

    [self.bulletCaliberTextField becomeFirstResponder];
    [self.bulletWeightTextField becomeFirstResponder];
    
    // set up proper keyboards for fields
    self.bulletCaliberTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.bulletWeightTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.muzzleVeloctiyTextField.keyboardType = UIKeyboardTypeDecimalPad;

}

- (void)viewDidUnload
{
    [self setBulletCaliberTextField:nil];
    [self setBulletWeightTextField:nil];
    [self setMuzzleVeloctiyTextField:nil];
    [self setResultTKOFLabel:nil];
    [self setResultThornileyLabel:nil];
    [self setResultEnergyLabel:nil];
    [self setEnergyUnitsControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)showTKOF:(id)sender 
{
    if(([self.bulletCaliberTextField.text length]>0) && ([self.bulletWeightTextField.text length]>0) && ([self.muzzleVeloctiyTextField.text length] >0)) {
        float caliber = [self.bulletCaliberTextField.text floatValue];
        float weight  = [self.bulletWeightTextField.text floatValue];
        float mv      = [self.muzzleVeloctiyTextField.text floatValue];
        
        self.resultTKOFLabel.text = [NSString stringWithFormat:@"%.0f", (caliber * weight * mv)/7000.0];
        self.resultThornileyLabel.text = [NSString stringWithFormat:@"%.0f", 2.866*mv*(weight/7000)*sqrt(caliber)];
    } else {
        self.resultTKOFLabel.text = @"?";
        self.resultThornileyLabel.text = @"?";
    }
}

- (IBAction)showEnergy:(id)sender {
    if(([self.bulletWeightTextField.text length]>0) && ([self.muzzleVeloctiyTextField.text length] >0)) {;
        float bulletWeight  = [self.bulletWeightTextField.text floatValue];
        float mv            = [self.muzzleVeloctiyTextField.text floatValue];

        
        float energyFootPounds = bulletWeight*pow(mv,2)/450395;

        if(energyUnitsControl.selectedSegmentIndex == 0) {
            self.resultEnergyLabel.text = [NSString stringWithFormat:@"%.0f", energyFootPounds];
        } else {
            self.resultEnergyLabel.text = [NSString stringWithFormat:@"%.0f", energyFootPounds * 1.3558179483314];            
        }
    } else {
        self.resultEnergyLabel.text = @"?";
    }
}



@end
