//
//  AppDelegate.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CBIntrospect.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize showPasscode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


    #ifdef DEBUG
//    [TestFlight takeOff:@"c9a944113920e415692190a4b0e2e8cc_OTIzOTUyMDEyLTA1LTIyIDAyOjA4OjEyLjk0NzA1OA"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
        DebugLog(@"Setting UDID to %@", [[UIDevice currentDevice] uniqueIdentifier]);
    #pragma clang diagnostic pop
    #endif


    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"GunLocker.sqlite"];
    DebugLog(@"MR setup completed");
    recordsDirty = NO;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

    if (![preferences boolForKey:@"defaultPreferencesSet"]) [self loadDefaultPreferencesOnFirstLoad:preferences];
    if([Manufacturer countOfEntities] == 0) [self loadManufacturers];
    if([Bullet countOfEntities] == 0) [self loadBullets];
    if([Caliber countOfEntities] == 0) [self loadCalibers];
    
    // wait for main queue to empty
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (recordsDirty) [[DataManager sharedManager] saveAppDatabase];
//    });
    
    [[CBIntrospect sharedIntrospector] start];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[DataManager sharedManager].locationManager stopUpdatingLocation];
    [[DataManager sharedManager].locationManager stopMonitoringSignificantLocationChanges];    
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
//            DebugLog(@"tried to show modal");
//        });        
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"tempWeaponDirty"];
    [defaults removeObjectForKey:@"tempWeapon"];
    [defaults synchronize];
}

- (CMMotionManager *)motionManager {
    if (!motionManager) 
        motionManager = [[CMMotionManager alloc] init];
    return motionManager;
}

- (void)loadDefaultPreferencesOnFirstLoad:(NSUserDefaults*)preferences {
    DebugLog(@"\tLoaded default preferences on first load");
    DataManager *dataManager = [DataManager sharedManager];
    NSArray *windageLeading = [dataManager.windageLeading objectForKey:[dataManager.speedTypes objectAtIndex:0]];
    
    [preferences setBool:NO forKey:kGLShowNFADetailsKey];
    [preferences setInteger:0 forKey:kGLCardSortByTypeKey];
    [preferences setInteger:0 forKey:kGLNightModeControlKey];
    [preferences setInteger:0 forKey:kGLRangeUnitsControlKey];
    [preferences setInteger:0 forKey:kGLReticleUnitsControlKey];
    [preferences setInteger:0 forKey:kGLDirectionControlKey];
    [preferences setInteger:100 forKey:kGLRangeStartKey];
    [preferences setInteger:600 forKey:kGLRangeEndKey];
    [preferences setInteger:50 forKey:kGLRangeStepKey];
    [preferences setObject:[dataManager.speedTypes objectAtIndex:0] forKey:@"speedType"];
    [preferences setObject:[windageLeading objectAtIndex:0] forKey:@"speedUnit"];
    [preferences setInteger:0 forKey:@"speedIndexPathRow"];
    [preferences setInteger:0 forKey:@"speedIndexPathSection"];
    
    [preferences setBool:YES forKey:@"defaultPreferencesSet"];
    [preferences synchronize];
}

- (void)loadManufacturers {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* path = [[NSBundle mainBundle] pathForResource:@"manufacturers" ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSArray *splitParts;
        for (NSString *manufacturer in [content componentsSeparatedByString:@"\n"]) {
            splitParts = [manufacturer componentsSeparatedByString:@":"];
            
            Manufacturer *newManufacturer = [Manufacturer createEntity];
            newManufacturer.name       = [splitParts objectAtIndex:0];
            newManufacturer.country    = [splitParts objectAtIndex:1];
            if (splitParts.count > 2) newManufacturer.short_name = [splitParts objectAtIndex:2];

//            [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext){
//                Manufacturer *localManufacturer = [newManufacturer inContext:localContext];
//                
//                localManufacturer.name       = [splitParts objectAtIndex:0];
//                localManufacturer.country    = [splitParts objectAtIndex:1];
//                if (splitParts.count > 2) localManufacturer.short_name = [splitParts objectAtIndex:2];
//            }];
        }   
        [[DataManager sharedManager] saveAppDatabase];
//        recordsDirty = YES;
        DebugLog(@"\tLoaded Manufacturers");
    });
}

- (void)loadBullets {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *bulletDirectory = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Bullets"];
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bulletDirectory error:nil];
        NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.csv'"];
        
        for (NSString *bulletCSVFile in [dirContents filteredArrayUsingPredicate:fltr]) {
            NSString *csvFullPath = [bulletDirectory stringByAppendingPathComponent:bulletCSVFile];
            NSString* content = [NSString stringWithContentsOfFile:csvFullPath encoding:NSUTF8StringEncoding error:NULL];
            
            for (NSString *bulletRow in [content componentsSeparatedByString:@"\n"]) {
                if ([bulletRow isEqualToString:@""]) {
                    continue;   
                }
                
                NSArray *splitParts = [bulletRow componentsSeparatedByString:@","];
                
                Bullet *newBullet  = [Bullet createEntity];
                
                newBullet.category = [bulletCSVFile stringByDeletingPathExtension];
                newBullet.diameter_inches = [NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:0]];
                newBullet.brand = [splitParts objectAtIndex:1];
                newBullet.name = [splitParts objectAtIndex:2];
                newBullet.weight_grains = [NSNumber numberWithInt:[[splitParts objectAtIndex:3] intValue]];
                // index 4 is Overall Length (OAL)
                newBullet.sectional_density_inches = [NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:5]];
                NSMutableDictionary *bc = [[NSMutableDictionary alloc] init];
                
                // G1 is array of fps and bc's
                NSMutableArray *g1 = [[NSMutableArray alloc] init];
                if ([[splitParts objectAtIndex:6] floatValue] > 0 ) {
                    [g1 addObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:6]]];
                    for(int index = 7; index <= 10; index++)
                        if ([[splitParts objectAtIndex:index] floatValue] > 0) {
                            [g1 addObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:index]]];
                            [g1 addObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:index + 4]]];
                        }
                    [bc setObject:g1 forKey:@"G1"];
                }
                
                if ([[splitParts objectAtIndex:15] floatValue] > 0 )
                    [bc setObject:[NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:15]]] forKey:@"G7"];
                
                newBullet.ballistic_coefficient = bc;
            }   
        }
        [[DataManager sharedManager] saveAppDatabase];

                

//                [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext){
//                    Bullet *localBullet = [newBullet inContext:localContext];
//
//                    localBullet.category = [bulletCSVFile stringByDeletingPathExtension];
//                    localBullet.diameter_inches = [NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:0]];
//                    localBullet.brand = [splitParts objectAtIndex:1];
//                    localBullet.name = [splitParts objectAtIndex:2];
//                    localBullet.weight_grains = [NSNumber numberWithInt:[[splitParts objectAtIndex:3] intValue]];
//                    // index 4 is Overall Length (OAL)
//                    localBullet.sectional_density_inches = [NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:5]];
//                    NSMutableDictionary *bc = [[NSMutableDictionary alloc] init];
//                    
//                    // G1 is array of fps and bc's
//                    NSMutableArray *g1 = [[NSMutableArray alloc] init];
//                    if ([[splitParts objectAtIndex:6] floatValue] > 0 ) {
//                        [g1 addObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:6]]];
//                        for(int index = 7; index <= 10; index++)
//                            if ([[splitParts objectAtIndex:index] floatValue] > 0) {
//                                [g1 addObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:index]]];
//                                [g1 addObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:index + 4]]];
//                            }
//                        [bc setObject:g1 forKey:@"G1"];
//                    }
//                    
//                    if ([[splitParts objectAtIndex:15] floatValue] > 0 )
//                        [bc setObject:[NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:15]]] forKey:@"G7"];
//                    
//                    localBullet.ballistic_coefficient = bc;
//                }];
//            }   
//        }
//        recordsDirty = YES;
//        DebugLog(@"\tLoaded Bullets");
    });
}

- (void)loadCalibers {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* path = [[NSBundle mainBundle] pathForResource:@"calibers" ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSArray *splitParts;
        for (NSString *caliber in [content componentsSeparatedByString:@"\n"]) {
            splitParts = [caliber componentsSeparatedByString:@":"];
            
            Caliber *newCaliber = [Caliber createEntity];
            newCaliber.type = [splitParts objectAtIndex:0];
            newCaliber.name = [splitParts objectAtIndex:1];
            newCaliber.diameter_inches = [NSNumber numberWithFloat:[[splitParts objectAtIndex:2] floatValue]];
            
            
//            [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext){
//                Caliber *localCaliber = [newCaliber inContext:localContext];
//                localCaliber.type = [splitParts objectAtIndex:0];
//                localCaliber.name = [splitParts objectAtIndex:1];
//                localCaliber.diameter_inches = [NSNumber numberWithFloat:[[splitParts objectAtIndex:2] floatValue]];
//            }];
        }   
        [[DataManager sharedManager] saveAppDatabase];
//        recordsDirty = YES;
//        DebugLog(@"\tLoaded Calibers");
    });
}

@end