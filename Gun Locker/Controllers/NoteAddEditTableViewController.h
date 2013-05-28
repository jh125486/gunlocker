//
//  NoteAddTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Note.h"
#import "../Models/Weapon.h"

@interface NoteAddEditTableViewController : UITableViewController <UITextViewDelegate>

- (IBAction)doneTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UILabel *fakePlaceholderLabel;
@property (weak, nonatomic) Note *passedNote;
@end
