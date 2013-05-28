//
//  NFAInformationViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Weapon.h"
#import "../Models/StampInfo.h"

@interface NFAInformationViewController : QuickDialogController <QuickDialogStyleProvider, UIActionSheetDelegate> {
    NSArray *nfa_types;
    NSArray *transfer_types;
}

@property (nonatomic, weak) Weapon *selectedWeapon;

@property (weak, nonatomic) IBOutlet UILabel *line1Label;
@property (weak, nonatomic) IBOutlet UILabel *line2Label;
@property (strong, nonatomic) UILabel *timeLineFooterLabel;

- (IBAction)saveButtonTapped:(id)sender;

@end
