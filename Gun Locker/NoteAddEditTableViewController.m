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
    _bodyTextView.scrollEnabled = NO;
    
    if (_passedNote) [self loadNote];

    [super viewDidLoad];
}

-(void)loadNote {
    _titleTextField.text = _passedNote.title;
    _bodyTextView.text   = _passedNote.body;
    _fakePlaceholderLabel.hidden = ([_bodyTextView.text isEqualToString:@""]) ? NO : YES;
    self.title = @"Note";
}

- (void)viewDidUnload {
    [self setFakePlaceholderLabel:nil];
    [self setTitleTextField:nil];
    [self setBodyTextView:nil];
	[self setPassedNote:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneTapped:(id)sender {
    if (_passedNote) {
        _passedNote.date  = [NSDate date];
        _passedNote.title = _titleTextField.text;
        _passedNote.body  = _bodyTextView.text;
        [[NSManagedObjectContext defaultContext] save];
        [TestFlight passCheckpoint:@"Note edited"];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    int newLineCount = [newText length] - [[newText stringByReplacingOccurrencesOfString:@"\n" withString:@""] length];
    if (newLineCount >= 4) return NO;
    
    CGSize tallerSize = CGSizeMake(textView.frame.size.width -19, textView.frame.size.height * 2);
    CGSize newSize = [newText sizeWithFont:textView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeCharacterWrap];
    return (newSize.height > (CGRectGetHeight(textView.frame))) ? NO : YES;
}

@end
