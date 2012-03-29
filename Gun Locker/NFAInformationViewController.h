//
//  NFAInformationViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "StampInfo.h"

@interface NFAInformationViewController : QuickDialogController <QuickDialogStyleProvider, UIActionSheetDelegate> {
    NSArray *nfa_types;
    NSArray *transfer_types;
}

@property (nonatomic, weak) Weapon *selectedWeapon;
@property (nonatomic, strong) QRootElement *editRoot;
           
- (IBAction)editButtonTapped:(id)sender;

@end
