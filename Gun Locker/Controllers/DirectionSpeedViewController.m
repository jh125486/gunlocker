//
//  DirectionSpeedViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DirectionSpeedViewController.h"

@implementation DirectionSpeedViewController
@synthesize delegate = _delegate;
@synthesize directionTypeControl = _directionTypeControl;
@synthesize wheel = _wheel;
@synthesize speedImage = _speedImage;
@synthesize speedSlider = _speedSlider;
@synthesize speedUnitControl = _speedUnitControl;
@synthesize resultType = _resultType;
@synthesize title1Label = _title1Label;
@synthesize title2Label = _title2Label;

@synthesize speedUnit = _speedUnit, speedValue = _speedValue;
@synthesize directionType = _directionType, directionValue = _directionValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // two different styles of labels: Degrees / Clock
    NSMutableArray *degreeLabels = [[NSMutableArray alloc] init];
    for (int i = 0; i < 360; i +=15) [degreeLabels addObject:[NSString stringWithFormat:@"%dº", i]];
    
    NSMutableArray *clockLabels = [[NSMutableArray alloc] initWithObjects:@"12\no'clock", nil];
    for (int i = 1; i < 12; i++) [clockLabels addObject:[NSString stringWithFormat:@"%d\no'clock", i]];
    
    directionLabels = [[NSArray alloc] initWithObjects:degreeLabels, clockLabels, nil];
    
    _speedSlider.increment = 1;
    _speedSlider.labelStep = 5;
    
    int imageStepNumber = round(_speedValue/_speedSlider.labelStep) * _speedSlider.labelStep;
    _speedImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"JH_RotaryWheel_%@_%d", _resultType, imageStepNumber]];
    
    [_speedUnitControl setTitle:[_resultType isEqualToString:@"Wind"] ? @"Knots" : @"KPH" forSegmentAtIndex:0];
    
    [_directionTypeControl setSelectedSegmentIndex:_directionType];    
    [_speedSlider setValue: _speedValue];
    [_speedUnitControl setSelectedSegmentIndex:_speedUnit];
    
    directionIndex = round(_directionValue * ([[directionLabels objectAtIndex:_directionTypeControl.selectedSegmentIndex] count]/360.f));
    
    [self directionTypeChanged:nil];
    [self updateTitleLabel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)updateTitleLabel {
    _title1Label.text = [NSString stringWithFormat:@"%@ from %@", 
                                _resultType, 
                                [[directionLabels objectAtIndex:_directionTypeControl.selectedSegmentIndex] objectAtIndex:directionIndex]];
    
    _title2Label.text = [NSString stringWithFormat:@"%g %@",
                        roundf(_speedValue),
                        [_speedUnitControl titleForSegmentAtIndex:_speedUnitControl.selectedSegmentIndex]];
}

# pragma mark Actions

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneTapped:(id)sender {
    int speed = [[[directionLabels objectAtIndex:_directionTypeControl.selectedSegmentIndex] objectAtIndex:directionIndex] intValue];
    
    if ([_resultType isEqualToString:@"Wind"]) {
        [_delegate windSetWithDirectionType:_directionTypeControl.selectedSegmentIndex 
                               andDirection:speed
                               andSpeedType:_speedUnitControl.selectedSegmentIndex
                                   andSpeed:_speedSlider.value];
    } else { // Target
        [_delegate targetSetWithDirectionType:_directionTypeControl.selectedSegmentIndex 
                                 andDirection:speed
                                 andSpeedType:_speedUnitControl.selectedSegmentIndex
                                     andSpeed:_speedSlider.value];
        
    }
        
    [self dismissModalViewControllerAnimated:YES];
}

-(void)directionTypeChanged:(UISegmentedControl *)control {
    int prevLabelCount = [[directionLabels objectAtIndex:!_directionTypeControl.selectedSegmentIndex] count];
    int currentLabelCount = [[directionLabels objectAtIndex:_directionTypeControl.selectedSegmentIndex] count]; 
    int newIndex = (control) ? roundf(directionIndex / (float)prevLabelCount * currentLabelCount) : directionIndex;

    if (_wheel) [_wheel removeFromSuperview];    
    _wheel = [[JHRotaryWheel alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 320.f)  
                                      andDelegate:self 
                                       withLabels:[directionLabels objectAtIndex:_directionTypeControl.selectedSegmentIndex]];
    _wheel.center = CGPointMake(160.f, 232.f);
    [self.view addSubview:_wheel];    
    
    directionIndex = newIndex;
    (directionIndex > currentLabelCount/2.f) ? [_wheel rotateCCW:currentLabelCount - directionIndex] : [_wheel rotateCW:directionIndex];
}

- (void) wheelDidChangeValue:(int)index {
    directionIndex = index;
    [self updateTitleLabel];
}

-(void)sliderMoved:(UISlider *)slider {    
    _speedValue = slider.value;
    _speedImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"JH_RotaryWheel_%@_%g",
                                           _resultType,
                                           round(_speedValue/_speedSlider.labelStep) * _speedSlider.labelStep]];
    [self updateTitleLabel];
}

-(void)speedUnitChanged:(UISegmentedControl *)control {
    _speedUnit = control.selectedSegmentIndex;
    [self updateTitleLabel];
}

@end
