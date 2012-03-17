//
//  AppDelegate.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "LockerViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize showPasscode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecordHelpers setupCoreDataStackWithStoreNamed:@"GunLocker.sqlite"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = nil;
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager stopUpdatingLocation];
    [MagicalRecordHelpers cleanUp];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    showPasscode = YES;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    showPasscode = YES;

// DOES NOT SHOW MODAL for some reason !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
//    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
//        KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil] ;
//        vc.mode = KKPasscodeModeEnter;
//        vc.delegate = self;
//        dispatch_async(dispatch_get_main_queue(),^ {
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            
//            nav.modalPresentationStyle = UIModalPresentationFullScreen;
//            nav.navigationBar.barStyle = UIBarStyleBlack;
//            nav.navigationBar.opaque = NO;
//
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//            UIViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
//            [tabBarController presentModalViewController:nav animated:YES];
//            NSLog(@"tried to show modal");
//        });        
//    }
}




- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecordHelpers cleanUp];
}

- (CMMotionManager *)motionManager
{
    if (!motionManager) 
        motionManager = [[CMMotionManager alloc] init];
    return motionManager;
}

@end