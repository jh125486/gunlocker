//
//  BallisticProfileAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "BallisticProfile.h"

@interface BallisticProfileViewController : QuickDialogController <QuickDialogStyleProvider, UIActionSheetDelegate>

@property (nonatomic, weak) BallisticProfile *selectedProfile;
@property (nonatomic, strong) QRootElement *editRoot;

- (IBAction)editButtonTapped:(id)sender;

@end
