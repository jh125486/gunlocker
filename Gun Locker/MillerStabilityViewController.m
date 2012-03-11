//
//  MillerStabilityViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MillerStabilityViewController.h"

@interface MillerStabilityViewController ()

@end

@implementation MillerStabilityViewController
@synthesize bulletCaliberTextField;
@synthesize bulletLengthTextField;
@synthesize twistRateLabel;
@synthesize stabilityFactorLabel;
@synthesize bulletWeightTextField;
@synthesize twistRateTextField;
@synthesize muzzleVelocityTextField;
@synthesize stabilityFactorTextField;

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
    
    // set up proper keyboards for fields
    self.bulletLengthTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.bulletCaliberTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.bulletWeightTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.twistRateTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.stabilityFactorTextField.keyboardType = UIKeyboardTypeDecimalPad;
}

- (void)viewDidUnload
{
    [self setBulletCaliberTextField:nil];
    [self setBulletLengthTextField:nil];
    [self setTwistRateLabel:nil];
    [self setBulletWeightTextField:nil];
    [self setTwistRateTextField:nil];
    [self setStabilityFactorLabel:nil];
    [self setMuzzleVelocityTextField:nil];
    [self setStabilityFactorTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)showTwistRate:(id)sender
{
    float caliber = [bulletCaliberTextField.text floatValue];
    float length  = [bulletLengthTextField.text floatValue];
    float weight  = [bulletWeightTextField.text floatValue];
    float s       = [stabilityFactorTextField.text floatValue];
    float tempFahrenheit = 59.0;
    float pressureHg = 29.92;
    int   mv      = [muzzleVelocityTextField.text intValue];
    
    if((caliber>0) && (length>0) && (weight>0) && (s>0) && (mv>0)) {
        float lengthInCalibers = length / caliber;
        float correctiveFactor = pow(mv/2800.0, 1/3.0) * ((tempFahrenheit+460.0) / (59+460.0) * pressureHg/29.92);
        
        float twist = sqrt((30*weight)/(s * caliber * lengthInCalibers * (1+pow(lengthInCalibers,2)))) * correctiveFactor;

        twistRateLabel.text = [NSString stringWithFormat:@"%.0f\"", twist];
    } else {
        twistRateLabel.text = @"?";
    }
}

- (IBAction)showStabilityFactor:(id)sender
{
    float caliber = [bulletCaliberTextField.text floatValue];
    float length  = [bulletLengthTextField.text floatValue];
    float twist   = [twistRateTextField.text floatValue];
    float weight  = [bulletWeightTextField.text floatValue];
    float tempFahrenheit = 59.0;
    float pressureHg = 29.92;
    int   mv      = [muzzleVelocityTextField.text intValue];
    
    if((caliber>0) && (length>0) && (twist>0) && (weight>0) && (mv>0)) {
        float lengthInCalibers = length / caliber;
        float correctiveFactor = sqrt(pow(mv/2800.0, 1/3.0) * ((tempFahrenheit+460) / (59+460) * pressureHg/29.92));
        
        float s = (30*weight)/(pow(twist/caliber, 2)*pow(caliber, 3) * lengthInCalibers * (1+pow(lengthInCalibers,2))) * correctiveFactor;
        
        self.stabilityFactorLabel.text = [NSString stringWithFormat:@"%.2f", s];        
        self.stabilityFactorLabel.textColor = ((s >= 1.3) && (s <= 2.0)) ? [UIColor greenColor] : [UIColor redColor];
    } else {
        self.stabilityFactorLabel.text = @"?";
        self.stabilityFactorLabel.textColor = [UIColor whiteColor];
        
    }
    
}

@end
