//
//  NoteAddTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteAddEditTableViewController.h"

@implementation NoteAddEditTableViewController
@synthesize titleTextField;
@synthesize bodyTextView;
@synthesize fakePlaceholderLabel;
@synthesize passedNote;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [self.titleTextField becomeFirstResponder];
    self.bodyTextView.delegate = self;
    self.bodyTextView.scrollEnabled = NO;
    
    if (self.passedNote) {
        self.titleTextField.text = self.passedNote.title;
        self.bodyTextView.text = self.passedNote.body;
        self.fakePlaceholderLabel.hidden = ([self.bodyTextView.text isEqualToString:@""]) ? NO : YES;
        self.title = @"Note";
    }

    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setFakePlaceholderLabel:nil];
    [self setTitleTextField:nil];
    [self setBodyTextView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)doneTapped:(id)sender {
    if (self.passedNote) {
        self.passedNote.date  = [NSDate date];
        self.passedNote.title = self.titleTextField.text;
        self.passedNote.body  = self.bodyTextView.text;
        [[NSManagedObjectContext defaultContext] save];
    } else if (![self.titleTextField.text isEqualToString:@""] && ![self.bodyTextView.text isEqualToString:@""]) {
        Note *newNote = [Note createEntity];
        newNote.date  = [NSDate date];
        newNote.title = self.titleTextField.text;
        newNote.body  = self.bodyTextView.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newNote" object:newNote];
    }
            
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TextView delegate
- (void)textViewDidChange:(UITextView *)textView {
    self.fakePlaceholderLabel.hidden = ([textView.text isEqualToString:@""]) ? NO : YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    CGSize tallerSize = CGSizeMake(textView.frame.size.width - 15, textView.frame.size.height * 2);
    CGSize newSize = [newText sizeWithFont:textView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
    
    return (newSize.height > textView.frame.size.height) ? NO : YES;
}

@end
