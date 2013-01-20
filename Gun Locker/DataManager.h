//
//  DataManager.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSArray *directionTypes;
@property (nonatomic, strong) NSArray *rangeUnits;
@property (nonatomic, strong) NSArray *dopeUnits;
@property (nonatomic, strong) NSArray *windUnits;
@property (nonatomic, strong) NSArray *leadUnits;
@property (nonatomic, strong) NSArray *nfaTypes;
@property (nonatomic, strong) NSArray *transferTypes;
@property (nonatomic, strong) NSDictionary *windageLeading;
@property (nonatomic, strong) NSArray *speedTypes;
@property (nonatomic, strong) NSArray *scopeClicks;
@property (nonatomic, strong) NSArray *scopeUnits;
@property (nonatomic, strong) NSDictionary *whizWheelPicker2;
@property (nonatomic, strong) NSDictionary *whizWheelPicker3;
@property (nonatomic, strong) NSDictionary *humanMPHSpeeds;
@property (nonatomic, strong) CLLocationManager *locationManager;

+(DataManager *)sharedManager;

-(void)saveAppDatabase;
@end
