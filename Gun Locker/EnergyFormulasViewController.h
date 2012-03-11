//
//  EnergyFormulasViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnergyFormulasViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *bulletCaliberTextField;
@property (weak, nonatomic) IBOutlet UITextField *bulletWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *muzzleVeloctiyTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultTKOFLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultThornileyLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultEnergyLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *energyUnitsControl;

- (IBAction)showTKOF:(id)sender;
- (IBAction)showEnergy:(id)sender;

@end
