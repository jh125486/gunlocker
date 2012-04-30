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

@synthesize directionTypes;
@synthesize rangeUnits;
@synthesize dopeUnits;
@synthesize windUnits;
@synthesize leadUnits;
@synthesize nfaTypes; 
@synthesize transferTypes;
@synthesize windageLeading;
@synthesize speedTypes;
@synthesize currentWeather;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}
- (id)init {
    if (self = [super init]) {
        
        self.directionTypes = [[NSArray alloc] initWithObjects:@"Degrees", @"Clocking", nil];
        self.rangeUnits     = [[NSArray alloc] initWithObjects:@"Yards", @"Meters", @"Feet", nil];
        self.dopeUnits      = [[NSArray alloc] initWithObjects:@"MOA", @"MILs", @"Inches", @"cm", nil];
        self.windUnits      = [[NSArray alloc] initWithObjects:@"MPH", @"km/h", @"MPS", @"Knots", nil];
        self.leadUnits      = [[NSArray alloc] initWithObjects:@"MPH", @"km/h", @"Human",nil];
        self.nfaTypes       = [[NSArray alloc] initWithObjects:@"SBR", @"SBS", @"Suppressor", @"Machinegun", @"DD", @"AOW",nil];
        self.transferTypes  = [[NSArray alloc] initWithObjects:@"Form 1", @"Form 4", nil];
        self.speedTypes     = [[NSArray alloc] initWithObjects:@"Wind", @"Leading", nil];
        self.windageLeading = [[NSDictionary alloc] initWithObjectsAndKeys:self.windUnits, [self.speedTypes objectAtIndex:0], 
                                                                           self.leadUnits, [self.speedTypes objectAtIndex:1],
                                                                           nil];
    }
    return self;
}

@end
