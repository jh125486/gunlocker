//
//  DataManager.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"

static DataManager *sharedMyManager = nil;

@implementation DataManager

@synthesize directionTypes = _directionTypes;
@synthesize rangeUnits = _rangeUnits;
@synthesize dopeUnits = _dopeUnits;
@synthesize windUnits = _windUnits;
@synthesize leadUnits = _leadUnits;
@synthesize nfaTypes = _nfaTypes; 
@synthesize transferTypes = _transferTypes;
@synthesize windageLeading = _windageLeading;
@synthesize speedTypes = _speedTypes;
@synthesize scopeClicks = _scopeClicks;
@synthesize scopeUnits = _scopeUnits;
@synthesize whizWheelPicker2 = _whizWheelPicker2;
@synthesize whizWheelPicker3 = _whizWheelPicker3;
@synthesize humanMPHSpeeds = _humanMPHSpeeds;
@synthesize locationManager = _locationManager;

#pragma mark Singleton Methods
+ (DataManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _directionTypes = [[NSArray alloc] initWithObjects:@"Degrees", @"Clocking", nil];
        _rangeUnits     = [[NSArray alloc] initWithObjects:@"Yards", @"Meters", @"Feet", nil];
        _dopeUnits      = [[NSArray alloc] initWithObjects:@"MOA", @"MILs", @"Inches", @"cm", nil];
        _windUnits      = [[NSArray alloc] initWithObjects:@"MPH", @"km/h", @"m/s", @"Knots", nil];
        _leadUnits      = [[NSArray alloc] initWithObjects:@"MPH", @"km/h", @"Human",nil];
        _nfaTypes       = [[NSArray alloc] initWithObjects:@"SBR", @"SBS", @"Suppressor", @"Machinegun", @"DD", @"AOW",nil];
        _transferTypes  = [[NSArray alloc] initWithObjects:@"Form 1", @"Form 4", nil];
        _speedTypes     = [[NSArray alloc] initWithObjects:@"Wind", @"Leading", nil];
        _scopeClicks    = [[NSArray alloc] initWithObjects:@"1/20", @"1/10", @"1/8", @"1/5", @"1/4", @"1/2", @"1", @"2", nil];
        _scopeUnits     = [[NSArray alloc] initWithObjects:@"MILs", @"MOA", nil];
        
        _windageLeading = [[NSDictionary alloc] initWithObjectsAndKeys:_windUnits, [_speedTypes objectAtIndex:0], 
                                                                       _leadUnits, [_speedTypes objectAtIndex:1],
                                                                       nil];
                
        NSMutableArray *degreesDirections = [[NSMutableArray alloc] init];        
        for(int degree = 0; degree < 360; degree += 15)
            [degreesDirections addObject:[NSString stringWithFormat:@"%d°", degree]];
        NSMutableArray *clockDirections = [[NSMutableArray alloc] init];
        
        [clockDirections addObject:@"12 o'clock"];
        for(int clock = 1; clock < 12; clock++)
            [clockDirections addObject:[NSString stringWithFormat:@"%d o'clock", clock]];
        
        _whizWheelPicker2 = [[NSDictionary alloc] initWithObjectsAndKeys:degreesDirections, @"Degrees", clockDirections, @"Clocking", nil];
        
        NSArray *humanSpeeds = [NSArray arrayWithObjects:@"At Rest", @"Walking", @"Jogging", @"Running", nil];
        NSMutableArray *otherSpeeds = [[NSMutableArray alloc] init];
        for (int speed = 0; speed <= 30; speed++)
            [otherSpeeds addObject:[NSString stringWithFormat:@"%d ", speed]];
        
        _whizWheelPicker3 = [[NSDictionary alloc] initWithObjectsAndKeys:humanSpeeds, @"Human", 
                                                                         otherSpeeds, @"MPH",   
                                                                         otherSpeeds, @"km/h",  
                                                                         otherSpeeds, @"m/s",   
                                                                         otherSpeeds, @"Knots", nil];
        
        _humanMPHSpeeds = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:0.0], @"At Rest", 
                                                                       [NSNumber numberWithDouble:3.0], @"Walking", 
																	   [NSNumber numberWithDouble:6.0], @"Jogging", 
																	   [NSNumber numberWithDouble:10.0], @"Running", nil];
      
        _locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

@end
