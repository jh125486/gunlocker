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
    arrayColors = [[NSMutableArray alloc] init];
    [arrayColors addObject:@"Red"];
    [arrayColors addObject:@"Orange"];
    [arrayColors addObject:@"Yellow"];
    [arrayColors addObject:@"Green"];
    [arrayColors addObject:@"Blue"];
    [arrayColors addObject:@"Indigo"];
    [arrayColors addObject:@"Violet"];
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
    return [arrayColors count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0) {
        return [arrayColors objectAtIndex:row];
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
    self.selectedProfile = [arrayColors objectAtIndex:row];
    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
}

- (IBAction)closeModalPopup:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
