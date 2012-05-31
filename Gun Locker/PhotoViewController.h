//
//  PhotoViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Weapon.h"

@interface PhotoViewController : UIViewController <UIScrollViewDelegate> {
    UIImage *photo;
}

@property (weak, nonatomic) IBOutlet UIScrollView *containerView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) Weapon *selectedWeapon;

- (IBAction)handleTap:(UIGestureRecognizer *)recognizer;

- (IBAction)doneTapped:(id)sender;

@end
