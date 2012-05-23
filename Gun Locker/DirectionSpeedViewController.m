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
    
    labels = [[NSArray alloc] initWithObjects:degreeLabels, clockLabels, nil];
    
    _directionTypeControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(20.f, 44.f, 280.f, 44.f)];
    [_directionTypeControl addTarget:self action:@selector(directionTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [_directionTypeControl insertSegmentWithTitle:@"Degrees" atIndex:0 animated:YES];
    [_directionTypeControl insertSegmentWithTitle:@"Clock Positions" atIndex:1 animated:YES];    
    [_directionTypeControl setSelectedSegmentIndex:_directionType];
    [_directionTypeControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_directionTypeControl setTintColor:[UIColor darkGrayColor]];
    [self.view addSubview:_directionTypeControl];
    
    _speedSlider = [[JHSlider alloc] initWithFrame:CGRectMake(10.f, 390.f, 170.f, 60.f) andIncrement:1 andLabelStep:5];
    [_speedSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    [_speedSlider setBackgroundColor: [UIColor clearColor]];
    [_speedSlider setMinimumValue: 0.0f];
    [_speedSlider setMaximumValue: 25.0f];
    [_speedSlider setContinuous: YES];
    [_speedSlider setValue: _speedValue];
    [_speedSlider setMaximumTrackTintColor: [UIColor whiteColor]];
    [_speedSlider setThumbTintColor: [UIColor darkGrayColor]];
    [_speedSlider setMinimumTrackTintColor: [UIColor blackColor]];    
    [self.view addSubview:_speedSlider];

    _speedImage = [[UIImageView alloc] initWithFrame:CGRectMake(5.f, 350.f, 120.f, 60.f)];
    _speedImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%g",
                                           _resultType,
                                           round(_speedValue/_speedSlider.labelStep) * _speedSlider.labelStep]];    
    [self.view addSubview:_speedImage];
    
    _speedUnitControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(190.f, 410.f, 120.f, 44.f)];
    [_speedUnitControl addTarget:self action:@selector(speedUnitChanged:) forControlEvents:UIControlEventValueChanged];
    [_speedUnitControl insertSegmentWithTitle:[_resultType isEqualToString:@"Wind"] ? @"Knots" : @"KPH" atIndex:0 animated:NO];
    [_speedUnitControl insertSegmentWithTitle:@"MPH" atIndex:1 animated:NO];
    [_speedUnitControl setSelectedSegmentIndex:_speedUnit];
    [_speedUnitControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [_speedUnitControl setTintColor:[UIColor darkGrayColor]];
    [self.view addSubview:_speedUnitControl];
    
    _directionTypeControl.selectedSegmentIndex = _directionType;
    directionIndex = round(_directionValue * ([[labels objectAtIndex:_directionTypeControl.selectedSegmentIndex] count]/360.f));
    
    [self directionTypeChanged:nil];
    [self setTitleLabel];
}

- (void)viewDidUnload {
    [self setDelegate:nil];
    [self setTitle1Label:nil];
    [self setTitle2Label:nil];
    [self setWheel:nil];
    [self setDirectionTypeControl:nil];
    [self setSpeedSlider:nil];
    [self setSpeedUnitControl:nil];
    [self setSpeedImage:nil];
    [self setResultType:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setTitleLabel {
    _title1Label.text = [NSString stringWithFormat:@"%@ from %@", 
                                _resultType, 
                                [[labels objectAtIndex:_directionTypeControl.selectedSegmentIndex] objectAtIndex:directionIndex]];
    
    _title2Label.text = [NSString stringWithFormat:@"%g %@",
                        roundf(_speedValue),
                        [_speedUnitControl titleForSegmentAtIndex:_speedUnitControl.selectedSegmentIndex]];
}

# pragma mark Actions

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)setTapped:(id)sender {
    int speed = [[[labels objectAtIndex:_directionTypeControl.selectedSegmentIndex] objectAtIndex:directionIndex] intValue];
    
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
    int prevLabelCount = [[labels objectAtIndex:!_directionTypeControl.selectedSegmentIndex] count];
    int currentLabelCount = [[labels objectAtIndex:_directionTypeControl.selectedSegmentIndex] count]; 
    int newIndex = (control) ? roundf(directionIndex / (float)prevLabelCount * currentLabelCount) : directionIndex;

    if (_wheel) [_wheel removeFromSuperview];    
    _wheel = [[JHRotaryWheel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 200.f)  
                                      andDelegate:self 
                                       withLabels:[labels objectAtIndex:_directionTypeControl.selectedSegmentIndex]];
    _wheel.center = CGPointMake(160.f, 240.f);
    [self.view addSubview:_wheel];    
    
    directionIndex = newIndex;
    (directionIndex > currentLabelCount/2.f) ? [_wheel rotateCCW:currentLabelCount - directionIndex] : [_wheel rotateCW:directionIndex];
}

- (void) wheelDidChangeValue:(int)index {
    directionIndex = index;
    [self setTitleLabel];
}

-(void)sliderMoved:(UISlider *)slider {    
    _speedValue = slider.value;
    _speedImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%g",
                                           _resultType,
                                           round(_speedValue/_speedSlider.labelStep) * _speedSlider.labelStep]];
    [self setTitleLabel];
}

-(void)speedUnitChanged:(UISegmentedControl *)control {
    _speedUnit = control.selectedSegmentIndex;
    [self setTitleLabel];
}

@end
