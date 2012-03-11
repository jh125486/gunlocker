//
//  MillerStabilityViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MillerStabilityViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *bulletCaliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *bulletLengthTextField;
@property (weak, nonatomic) IBOutlet UITextField *bulletWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *twistRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *muzzleVelocityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stabilityFactorTextField;

@property (weak, nonatomic) IBOutlet UILabel *twistRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stabilityFactorLabel;

-(IBAction)showTwistRate:(id)sender;
-(IBAction)showStabilityFactor:(id)sender;

@end
