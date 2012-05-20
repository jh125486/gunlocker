//
//  AppDelegate.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "CardsViewController.h"
#import "Manufacturer.h"
#import "Bullet.h"
#import "Caliber.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    CMMotionManager *motionManager;
    BOOL recordsDirty;
}

@property (strong, nonatomic) UIWindow *window;
@property (readonly) CMMotionManager *motionManager;
@property BOOL showPasscode;

@end
