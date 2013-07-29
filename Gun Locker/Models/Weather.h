//
//  Weather.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFHTTPRequestOperation.h"

@interface Weather : NSObject

@property (assign, nonatomic) NSDate *timestamp;
@property float tempC;
@property float dewpointC;
@property float windSpeedKnots;
@property float windDirectionDegrees;
@property float altimInHg;
@property float relativeHumidity;
@property float altitudeMeters;
@property float airDensity;
@property float kmFromStation;
@property float densityAltitude;
@property (assign, nonatomic)  NSString *stationID;
@property BOOL  goodData;

-(id)initClosetWeatherFromMetarArray:(NSArray*)metars andLocation:(CLLocation*)location;
-(id)initWithMetarString:(NSString*)metarString andLocation:(CLLocation*)location;

-(NSString*)description;

-(float)absoluteAirPressureFromBarometricPressureInMB:(float)pressure altitudeInMeters:(float)altitude;
-(float)pressureAltitudeinFeetFromBarometricPressureinMB:(float)pressure;
-(void)calculateDensityAltitude;
-(double)calculateSpeedOfSound;
-(float)tempF;
-(NSString *)cardinalDirectionFromDegrees:(float)degrees;

+(float)saturationVaporPressureFromTemperatureInCelsius:(float)temp_c;
+(double)calculateSpeedOfSoundFromTempC:(double)tempC andRH:(int)rh andPressurePa:(double)pressurePa;
+(double)airDensityFromTempC:(double)tempC andRH:(double)rh andPressurePa:(double)pressurePa;
@end
