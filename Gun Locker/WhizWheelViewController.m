//
//  WhizWheelViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WhizWheelViewController.h"

@interface WhizWheelViewController ()

@end

@implementation WhizWheelViewController
@synthesize whizWheelPicker;
@synthesize rangeLabel;
@synthesize directionLabel;
@synthesize speedLabel;
@synthesize selectedProfile;

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
    arrayRanges = [[NSMutableArray alloc] init];
//    for(
    [arrayRanges addObject:@"Red"];
    [arrayRanges addObject:@"Orange"];
    [arrayRanges addObject:@"Yellow"];
    [arrayRanges addObject:@"Green"];
    [arrayRanges addObject:@"Blue"];
    [arrayRanges addObject:@"Indigo"];
    [arrayRanges addObject:@"Violet"];
}

- (void)viewDidUnload
{
    [self setWhizWheelPicker:nil];
    [self setRangeLabel:nil];
    [self setDirectionLabel:nil];
    [self setSpeedLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayRanges count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0) {
        return [arrayRanges objectAtIndex:row];
    } else {
        
        return [[NSNumber numberWithInt:row] stringValue];        
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return (CGFloat)((component == 0) ? 260.0 : 40.0);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedProfile = [arrayRanges objectAtIndex:row];
    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayRanges objectAtIndex:row], row);
}

- (IBAction)closeModalPopup:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
