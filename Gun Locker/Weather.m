//
//  Weather.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Weather.h"

@implementation Weather

@synthesize timestamp, temp_c, dewpoint_c, wind_speed_kt, wind_dir_degrees, altim_in_hg, relativeHumidity, kmFromStation, densityAltitude;
@synthesize altitude_m, air_density;
@synthesize stationID, goodData;

- (id)initWithLocation:(CLLocation *)location {
    goodData = NO;
    
    if (self = [super init]) {
        float longitude = location.coordinate.longitude;
        float latitude  = location.coordinate.latitude;
        self.altitude_m = location.altitude;
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
        int closestStationIndex = -1;
        self.kmFromStation = MAXFLOAT;
        float distanceKM;
        
        // rolls through returned stations and find closest station
        for (int index = 6; index < numberOfResults + 6; index++) {
            stationWeather = [[weatherArray objectAtIndex:index] componentsSeparatedByString:@","];
            CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:[[stationWeather objectAtIndex:3] floatValue] 
                                                                     longitude:[[stationWeather objectAtIndex:4] floatValue]];
            distanceKM = [location distanceFromLocation:stationLocation] / 1000.0f;
            
            if(distanceKM < self.kmFromStation) {
                closestStationIndex = index;
                self.kmFromStation = distanceKM;
            }
        }
        
        // set up ivars with weather
        if(closestStationIndex >= 0) {
            stationWeather = [[weatherArray objectAtIndex:closestStationIndex] componentsSeparatedByString:@","];
            self.timestamp = [formatter dateFromString:[stationWeather objectAtIndex:2]];        
            self.stationID = [stationWeather objectAtIndex:1];
            self.temp_c           = [[stationWeather objectAtIndex:5] floatValue];
            self.dewpoint_c       = [[stationWeather objectAtIndex:6] floatValue];
            self.wind_dir_degrees = [[stationWeather objectAtIndex:7] floatValue];
            self.wind_speed_kt    = [[stationWeather objectAtIndex:8] floatValue];
            self.altim_in_hg      = [[stationWeather objectAtIndex:11] floatValue];
            self.relativeHumidity = exp((17.271*self.dewpoint_c)/(237.7+self.dewpoint_c)) / exp((17.271*self.temp_c)/(237.7+self.temp_c)) * 100;
            //self.densityAltitude  = 145442.16 * (1 - pow((17.326*self.altim_in_hg)/(459.67+((self.temp_c/5)*9 + 32)), 0.235)) ;
            [self calculateDensityAltitude];
            
            goodData = YES;
            
        } else {
            NSLog(@"Failed to get weather. %d results.", numberOfResults);
        }
    }
    return self;
}


+(float)saturationVaporPressureFromTemperatureInCelsius:(float)t {
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

-(NSString*)description {
    return [NSString stringWithFormat:@"\nStation: %@ @%@ (distance of %.f km)\nTemp: %.0f C\nDew point: %.0f C\nWind: %.0f knots from %.0f degrees\nAltimPressure: %.2f inHg\nRel . Hum.: %.0f%%\nDensity Altitude: %.0f\nPressure Altitude:\t%.0f'\nSpeed of Sound:\t%.0fm/s (%.0fft/s)",
                                      self.stationID, self.timestamp, self.kmFromStation,
                                      self.temp_c, 
                                      self.dewpoint_c, 
                                      self.wind_speed_kt, 
                                      self.wind_dir_degrees, 
                                      self.altim_in_hg, 
                                      self.relativeHumidity,
                                      self.densityAltitude,
                                      [self pressureAltitudeinFeetFromBarometricPressureinMB:(self.altim_in_hg*33.8637526)],
                                      self.calculateSpeedOfSound, METERS_to_FEET(self.calculateSpeedOfSound)];

}

-(float)temp_f {
    return TEMP_C_to_TEMP_F(self.temp_c);
}

-(float)temp_r {
    return TEMP_F_to_TEMP_R(self.temp_f);
}

-(float)temp_k {
    return TEMP_C_to_TEMP_K(self.temp_c);
}

-(float)altim_in_pa {
    return self.altim_in_hg * 3386.389;
}

-(double)calculateSpeedOfSound {
    return [Weather calculateSpeedOfSoundFromTempC:self.temp_c andRH:self.relativeHumidity andPressurePa:self.altim_in_pa];
}

+(double)calculateSpeedOfSoundFromTempC:(double)tempC andRH:(int)rh andPressurePa:(double)pressurePa {
    double tempK = TEMP_C_to_TEMP_K(tempC);
    
    // Code from: Dr Richard Lord - http://www.npl.co.uk/acoustics/techguides/speedair
    // Based on the approximate formula found in
    // Owen Cramer, "The variation of the specific heat ratio and the speed of sound in air with temperature, pressure, humidity, and CO2 concentration",
    // The Journal of the Acoustical Society of America (JASA), J. Acoust. Soc. Am. 93(5) p. 2510-2516; formula at p. 2514.
    // Saturation vapour pressure found in 
    // Richard S. Davis, "Equation for the Determination of the Density of Moist Air (1981/91)", Metrologia, 29, p. 67-70, 1992,
    // and a mole fraction of carbon dioxide of 0.0004.
    // The mole fraction is simply an expression of the number of moles of a compound divided by the total number of moles of all the compounds present in the gas.
    
    double Xc, Xw;// Mole fraction of carbon dioxide and water vapour
    
    // Molecular concentration of water vapour calculated from Rh using Giacomos method by Davis (1991) as implemented in DTU report 11b-1997
    double psv = exp(pow(tempK,2) *1.2378847 * pow(10,-5) -1.9121316 *pow(10,-2) * tempK)*exp(33.93711047-6.3431645*pow(10,3)/tempK);
    Xw = (rh * 3.14 *pow(10,-8) * pressurePa + 1.00062 + pow(tempC, 2) * 5.6 * pow(10,-7) * psv/pressurePa)/100.0;
    Xc = 400.0 * pow(10,-6);
    // Speed calculated using the method of Cramer from JASA vol 93 p. 2510
    return (0.603055*tempC + 331.5024 - pow(tempC,2) * 5.28 * pow(10,-4) + (0.1495874 * tempC + 51.471935 - pow(tempC,2)*7.82 * pow(10,-4))*Xw) + ((-1.82 * pow(10,-7) + 3.73 * pow(10,-8) * tempC - pow(tempC,2) * 2.93 * pow(10,-10)) * pressurePa + (-85.20931-0.228525 * tempC + pow(tempC,2)*5.91*pow(10,-5))*Xc) - (pow(Xw,2) * 2.835149 - pow(pressurePa,2) * 2.15 * pow(10,-13) + pow(Xc,2) * 29.179762 + 4.86 * pow(10,-4) * Xw * pressurePa * Xc);
}

-(NSString *)cardinalDirectionFromDegrees:(float)degrees {
    if(degrees <= 11.25) {
        return @"N";
    } else if (degrees <= 33.75) {
        return @"NNE";
    } else if (degrees <= 56.75) {
        return @"NE";
    } else if (degrees <= 78.75) {
        return @"ENE";
    } else if (degrees <= 101.75) {
        return @"E";  
    } else if (degrees <= 123.75) {
        return @"ESE";
    } else if (degrees <= 146.75) {
        return @"SE"; 
    } else if (degrees <= 168.75) {
        return @"SSE";
    } else if (degrees <= 191.75) {
        return @"S";  
    } else if (degrees <= 213.75) {
        return @"SSW";
    } else if  (degrees <= 236.75) {
        return @"SW"; 
    } else if  (degrees <= 258.75) {
        return @"WSW";
    } else if  (degrees <= 281.75) {
        return @"W";  
    } else if  (degrees <= 303.75) {
        return @"WNW";
    } else if  (degrees <= 326.25) {
        return @"NW"; 
    } else if  (degrees <= 348.75) {
        return @"NNW";
    } else {
        return @"N";
    }
}

+(double)airDensityFromTempC:(double)tempC andRH:(double)rh andPressurePa:(double)pressurePa {
    // from http://wahiduddin.net/calc/density_altitude.htm
    double pv = [self saturationVaporPressureFromTemperatureInCelsius:tempC] * (rh /100.0f) * 100;
    double pd = pressurePa - pv;
    double tempK = TEMP_C_to_TEMP_K(tempC);
    
    return ((pd/(tempK * 287.05)) + (pv/(tempK * 461.495))) / 16.018463;
}

@end
