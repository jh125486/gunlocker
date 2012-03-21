//
//  SettingsQuickDialogViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeSettingsViewController.h"
#import "KKPasscodeLock.h"

@interface SettingsQuickDialogViewController : QuickDialogController <KKPasscodeSettingsViewControllerDelegate>

@property (strong,nonatomic) QLabelElement *passCodeElement;
@end
