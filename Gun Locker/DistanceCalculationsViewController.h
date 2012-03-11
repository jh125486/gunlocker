//
//  DistanceCalculationsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticsViewController.h"

@interface DistanceCalculationsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *targetSizeTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetSizeUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *targetReadingTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetReadingUnitControl;
@property (weak, nonatomic) IBOutlet UILabel *resultRangeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resultRangeUnitControl;

@property (weak, nonatomic) IBOutlet UITextField *targetDistanceTextField;
@property (weak, nonatomic) IBOutlet UILabel *targetDistanceUnitLabel;
@property (weak, nonatomic) IBOutlet UITextField *shootingAngleTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultHorizontalRangeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *liveAngleUpdateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *resultHorizontalRangeUnitLabel;

@property (weak, nonatomic) NSString *passedResult;
@property (weak, nonatomic) NSString *passedResultUnits;

- (IBAction)showRangeEstimate:(id)sender;
- (IBAction)showHorizontalSolution:(id)sender;
- (IBAction)liveAngleUpdating:(id)sender;
@end
