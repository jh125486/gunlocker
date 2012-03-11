//
//  Weather.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Weather.h"

@implementation Weather

@synthesize timestamp, temp_c, dewpoint_c, wind_speed_kt, wind_dir_degrees, altim_in_hg, relativeHumidity, kilometersFromStation, densityAltitude;
@synthesize stationID, goodData;

- (id)initWithLocation:(CLLocation *)location {
    goodData = NO;
    
    if (self = [super init]) {
        float longitude = location.coordinate.longitude;
        float latitude  = location.coordinate.latitude;
        NSLog(@"Getting weather for Lat %f Long %f", latitude, longitude);
        
        NSURL* url = [NSURL URLWithString: [NSString stringWithFormat:@"http://weather.aero/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=csv&radialDistance=30;%f,%f&hoursBeforeNow=2&fields=observation_time,station_id,latitude,longitude,temp_c,dewpoint_c,wind_dir_degrees,wind_speed_kt,altim_in_hg", longitude, latitude]];

        NSError *error = nil;
        NSStringEncoding encoding;
        NSString *weatherString = [[NSString alloc] initWithContentsOfURL:url
                                                             usedEncoding:&encoding 
                                                                    error:&error];
        
        NSMutableArray *weatherArray = [NSMutableArray arrayWithArray:[weatherString componentsSeparatedByString:@"\n"]];
        int numberOfResults = [[[[weatherArray objectAtIndex:4] componentsSeparatedByString:@" "] objectAtIndex:0] intValue];
                
        // METAR timestamp format 2012-03-10T19:23:00Z
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setLocale:[NSLocale systemLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        NSArray *stationWeather;
        int closestStationIndex;
        self.kilometersFromStation = MAXFLOAT;
        float distanceKM;
        
        // rolls through returned stations and find closest station
        for (int index = 6; index < numberOfResults + 6; index++) {
            stationWeather = [[weatherArray objectAtIndex:index] componentsSeparatedByString:@","];
            CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:[[stationWeather objectAtIndex:3] floatValue] 
                                                                     longitude:[[stationWeather objectAtIndex:4] floatValue]];
            distanceKM = [location distanceFromLocation:stationLocation] / 1000.0f;
            
            if(distanceKM < self.kilometersFromStation) {
                closestStationIndex = index;
                self.kilometersFromStation = distanceKM;
            }
        }
        
        // set up ivars with weather
        if(closestStationIndex) {
            stationWeather = [[weatherArray objectAtIndex:closestStationIndex] componentsSeparatedByString:@","];
            self.timestamp = [formatter dateFromString:[stationWeather objectAtIndex:2]];        
            self.stationID = [stationWeather objectAtIndex:1];
            self.temp_c           = [[stationWeather objectAtIndex:5] floatValue];
            self.dewpoint_c       = [[stationWeather objectAtIndex:6] floatValue];
            self.wind_dir_degrees = [[stationWeather objectAtIndex:7] floatValue];
            self.wind_speed_kt    = [[stationWeather objectAtIndex:8] floatValue];
            self.altim_in_hg      = [[stationWeather objectAtIndex:11] floatValue];
            // pressure in hg is mb / 33.8637526
            self.relativeHumidity = exp((17.271 * dewpoint_c)/( 237.7 + dewpoint_c)) / exp((17.271 * temp_c)/( 237.7 + temp_c)) * 100;
            //self.densityAltitude  = 145442.16 * (1 - pow((17.326*self.altim_in_hg)/(459.67+((self.temp_c/5)*9 + 32)), 0.235)) ;
            [self calculateDensityAltitude];
                        
            goodData = YES;
            
        } else {
            NSLog(@"Failed to get weather. %d results.", numberOfResults);
        }
    }
    return self;
}


-(float)saturationVaporPressureFromTemperatureInCelsius:(float)t {
    float eso = 6.1078;
    float c0 =  0.99999683;
    float c1 = -0.90826951E-02;
    float c2 = 0.78736169E-04;
    float c3 = -0.61117958E-06;
    float c4 = 0.43884187E-08;
    float c5 = -0.29883885E-10;
    float c6 = 0.21874425E-12;
    float c7 = -0.17892321E-14;
    float c8 = 0.11112018E-16;
    float c9 = -0.30994571E-19;
    
    return eso/pow(c0+t*(c1+t*(c2+t*(c3+t*(c4+t*(c5+t*(c6+t*(c7+t*(c8+t*(c9))))))))), 8);
}

-(float)absoluteAirPressureFromBarometricPressureInMB:(float)pressure altitudeInMeters:(float)altitude {

	return 0.3 + pow((pow(pressure, 0.190284)-(altitude * 8.4288 * pow(10,-5))), (1/0.190284));
}

-(float)pressureAltitudeinFeetFromBarometricPressureinMB:(float)pressure {
    return (1 - pow((pressure/1013.25), 0.190284)) * 145366.45;
}

-(void)calculateDensityAltitude {
    float ISAtemp = 59 - ([self pressureAltitudeinFeetFromBarometricPressureinMB:(self.altim_in_hg*33.8637526)] / 1000) * 3.6;
    float tempCorrection = (self.temp_f - ISAtemp) * 66.67;
    self.densityAltitude = ISAtemp + tempCorrection;
}

-(float)temp_f {
    return (self.temp_c/5*9 + 32);
}

-(NSString*)description {
    return [NSString stringWithFormat:@"\nStation: %@ @%@ (distance of %.f km)\nTemp: %.0f C\nDew point: %.0f C\nWind: %.0f knots from %.0f degrees\nAltimPressure: %.2f inHg\nRel . Hum.: %.0f%%\nDensity Altitude: %.0f\nPressure Altitude:\t%.0f'",
                                      self.stationID, self.timestamp, self.kilometersFromStation,
                                      self.temp_c, 
                                      self.dewpoint_c, 
                                      self.wind_speed_kt, 
                                      self.wind_dir_degrees, 
                                      self.altim_in_hg, 
                                      self.relativeHumidity,
                                      self.densityAltitude,
                                      [self pressureAltitudeinFeetFromBarometricPressureinMB:(self.altim_in_hg*33.8637526)]];

}
@end
