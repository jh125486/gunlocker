//
//  NoteAddTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteAddEditTableViewController.h"

@implementation NoteAddEditTableViewController
@synthesize titleTextField = _titleTextField;
@synthesize bodyTextView = _bodyTextView;
@synthesize fakePlaceholderLabel = _fakePlaceholderLabel;
@synthesize passedNote = _passedNote;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [_titleTextField becomeFirstResponder];
    _bodyTextView.delegate = self;
    
    _bodyTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Notes_TextView"]];
    _bodyTextView.contentInset = UIEdgeInsetsMake(-10, 10, 30, 10);
    
    if (_passedNote) [self loadNote];

    [super viewDidLoad];
}

-(void)loadNote {
    _titleTextField.text = _passedNote.title;
    _bodyTextView.text   = _passedNote.body;
    [self textViewDidChange:_bodyTextView];
    self.title = @"Note";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneTapped:(id)sender {
    if (_passedNote) {
        _passedNote.date  = [NSDate date];
        _passedNote.title = _titleTextField.text;
        _passedNote.body  = _bodyTextView.text;
        [[DataManager sharedManager] saveAppDatabase];
//        [TestFlight passCheckpoint:@"Note edited"];
    } else if (![_titleTextField.text isEqualToString:@""] && ![_bodyTextView.text isEqualToString:@""]) {
        Note *newNote = [Note createEntity];
        newNote.date  = [NSDate date];
        newNote.title = _titleTextField.text;
        newNote.body  = _bodyTextView.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newNote" object:newNote];
    }
         
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TextView delegate
- (void)textViewDidChange:(UITextView *)textView {
    _fakePlaceholderLabel.hidden = ([textView.text isEqualToString:@""]) ? NO : YES;
}

@end
