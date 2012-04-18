//
//  DataManager.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject {
    NSArray *directionTypes;
    NSArray *rangeUnits;
    NSArray *dopeUnits;
    NSArray *windUnits;
    NSArray *leadUnits;
    NSArray *nfaTypes;
    NSArray *transferTypes;
    NSDictionary *windageLeading;
    NSArray *speedTypes;
}

@property (nonatomic, retain) NSArray *directionTypes;
@property (nonatomic, retain) NSArray *rangeUnits;
@property (nonatomic, retain) NSArray *dopeUnits;
@property (nonatomic, retain) NSArray *windUnits;
@property (nonatomic, retain) NSArray *leadUnits;
@property (nonatomic, retain) NSArray *nfaTypes;
@property (nonatomic, retain) NSArray *transferTypes;
@property (nonatomic, retain) NSDictionary *windageLeading;
@property (nonatomic, retain) NSArray *speedTypes;

+ (id)sharedManager;
@end
