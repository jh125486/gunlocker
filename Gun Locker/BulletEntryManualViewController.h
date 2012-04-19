//
//  BulletEntryManualViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BulletEntryManualViewController : UIViewController <UITextFieldDelegate> {
    NSMutableArray *formFields;
    NSArray *g1Fields;
    NSArray *g7Fields;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *g1EntryView;
@property (weak, nonatomic) IBOutlet UIView *g7EntryView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *dragModelControl;
@property (weak, nonatomic) IBOutlet UITextField *bulletWeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *g7BCTextField;
@property (weak, nonatomic) IBOutlet UITextField *g1BCTextField;
@property (weak, nonatomic) IBOutlet UITextField *g1BC1TextField;
@property (weak, nonatomic) IBOutlet UITextField *g1BC2TextField;
@property (weak, nonatomic) IBOutlet UITextField *g1BC3TextField;
@property (weak, nonatomic) IBOutlet UITextField *g1FPS1TextField;
@property (weak, nonatomic) IBOutlet UITextField *g1FPS2TextField;
@property (weak, nonatomic) IBOutlet UITextField *g1FPS3TextField;

@property (weak, nonatomic) NSString *selectedDragModel;
@property (weak, nonatomic) NSNumber  *passedBulletWeight;
@property (weak, nonatomic) NSArray  *passedBulletBC;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)dragModelTypeChanged:(UISegmentedControl *)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
