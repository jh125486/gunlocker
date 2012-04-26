//
//  RangingViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface RangingViewController : UITableViewController <UITextFieldDelegate> {
    NSArray *formFields;
    NSArray *sizeUnits;
    NSArray *spansUnits;
}

@property (weak, nonatomic) IBOutlet UITextField *targetSizeTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetSizeUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *targetSpansTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetSpansUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *angleTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *angleLiveUpdateControl;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resultUnitControl;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)showRangeEstimate:(id)sender;
- (IBAction)liveAngleUpdating:(id)sender;

@end
