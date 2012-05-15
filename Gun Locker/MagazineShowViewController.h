//
//  MagazineShowViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Magazine.h"
#import "MagazineAddEditViewController.h"

@interface MagazineShowViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    UIAlertView *sellMagazinesAlertView;
    UIAlertView *buyMagazinesAlertView;
}

@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet UILabel *caliberLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UIButton *sellMagazinesButton;
@property (weak, nonatomic) Magazine *selectedMagazine;

- (IBAction)buyMagazinesTapped:(id)sender;
- (IBAction)sellMagazinesTapped:(id)sender;
- (IBAction)deleteTapped:(id)sender;
@end
