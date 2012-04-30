//
//  Weather.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (assign, nonatomic) NSDate *timestamp;
@property float temp_c;
@property float dewpoint_c;
@property float wind_speed_kt;
@property float wind_dir_degrees;
@property float altim_in_hg;
@property float relativeHumidity;
@property float altitude_m;
@property float air_density;
@property float kmFromStation;
@property float densityAltitude;
@property (assign, nonatomic)  NSString *stationID;
@property BOOL  goodData;

-(id)initWithLocation: (CLLocation*)location;

-(NSString*)description;

-(float)absoluteAirPressureFromBarometricPressureInMB:(float)pressure altitudeInMeters:(float)altitude;
-(float)pressureAltitudeinFeetFromBarometricPressureinMB:(float)pressure;
-(void)calculateDensityAltitude;
-(double)calculateSpeedOfSound;
-(float)temp_f;
-(NSString *)cardinalDirectionFromDegrees:(float)degrees;

+(float)saturationVaporPressureFromTemperatureInCelsius:(float)temp_c;
+(double)calculateSpeedOfSoundFromTempC:(double)tempC andRH:(int)rh andPressurePa:(double)pressurePa;
+(double)airDensityFromTempC:(double)tempC andRH:(double)rh andPressurePa:(double)pressurePa;
@end
