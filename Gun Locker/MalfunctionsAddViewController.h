//
//  MalfunctionsAddViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "Malfunction.h"

@interface MalfunctionsAddViewController : QuickDialogController

@property (nonatomic, weak) Weapon *selectedWeapon;

- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
