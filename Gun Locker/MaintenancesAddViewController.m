//
//  MaintenancesAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenancesAddViewController.h"

@interface MaintenancesAddViewController ()
@end

@implementation MaintenancesAddViewController
@synthesize actionPerformedTextView;
@synthesize linkedMalfunctionPicker;
@synthesize dateTextField;
@synthesize datePickerView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIToolbar* toolBarView = [[UIToolbar alloc] init];
    toolBarView.barStyle = UIBarStyleBlack;
    toolBarView.translucent = NO;
    toolBarView.tintColor = nil;
    [toolBarView sizeToFit];
    
    [toolBarView setItems:[NSArray arrayWithObjects: 
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self 
                                                                         action:nil],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self 
                                                                         action:@selector(keyboardDoneClicked:)],
                           nil]];
    self.actionPerformedTextView.inputAccessoryView = toolBarView;
    
    // date picker set up
    datePickerView = [[UIDatePicker alloc] init];
    UIToolbar* pickerToolBarView = [[UIToolbar alloc] init];
    pickerToolBarView.barStyle = UIBarStyleBlack;
    pickerToolBarView.translucent = YES;
    pickerToolBarView.tintColor = nil;
    [pickerToolBarView sizeToFit];
    
    [pickerToolBarView setItems:[NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                               target:self
                                                                               action:@selector(purchaseDatePickerCancelClicked:)],
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
                                 
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                               target:self
                                                                               action:@selector(purchaseDatePickerDoneClicked:)],
                                 nil]];
    
    datePickerView.datePickerMode = UIDatePickerModeDate; 
    self.dateTextField.inputView = datePickerView;
    self.dateTextField.inputAccessoryView = pickerToolBarView;

}

- (void)keyboardDoneClicked:(id)sender {
    [self.actionPerformedTextView resignFirstResponder];
}

- (void)datePickerDoneClicked:(id)sender {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
    self.dateTextField.text = [dateFormat stringFromDate:datePickerView.date];
    
    [self.dateTextField resignFirstResponder];
}

- (void)purchaseDatePickerCancelClicked:(id)sender {
    [self.dateTextField resignFirstResponder];
}


- (void)viewDidUnload
{
    [self setDatePickerView:nil];
    [self setActionPerformedTextView:nil];
    [self setLinkedMalfunctionPicker:nil];
    [self setDateTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)closeModalPopup:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)savePressed:(id)sender {
    // add notification for MaintenanceTableViewController
    [self dismissModalViewControllerAnimated:YES];
}


@end
