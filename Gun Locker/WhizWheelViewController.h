//
//  WhizWheelViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhizWheelViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSMutableArray *arrayColors;
}

@property (weak, nonatomic) IBOutlet UIPickerView *whizWheelPicker;

@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (strong, nonatomic) NSObject *selectedProfile;
@end
