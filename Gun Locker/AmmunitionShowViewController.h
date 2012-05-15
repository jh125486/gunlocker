//
//  AmmunitionShowViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ammunition.h"
#import "AmmunitionAddEditViewController.h"

@interface AmmunitionShowViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    UIAlertView *roundsFiredAlertView;
    UIAlertView *roundsBoughtAlertView;
}
@property (weak, nonatomic) Ammunition *selectedAmmunition;

@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caliberLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UIButton *roundsFiredButton;
- (IBAction)roundsFiredTapped:(id)sender;
- (IBAction)roundsBoughtTapped:(id)sender;
- (IBAction)deleteTapped:(id)sender;

@end
