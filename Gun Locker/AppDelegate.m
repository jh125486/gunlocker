//
//  AppDelegate.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CardsViewController.h"
#import "Manufacturer.h"
#import "Bullet.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize showPasscode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecordHelpers setupCoreDataStackWithStoreNamed:@"GunLocker.sqlite"];
    
    [self loadDefaultsOnFirstLoad];
    
//    [Bullet truncateAll];
//    [Manufacturer truncateAll];
//    [[NSManagedObjectContext defaultContext] save];

    // if no manufacturers, load them from a txt file
    if([Manufacturer countOfEntities] == 0) {
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
            }   
            [[NSManagedObjectContext defaultContext] save];
            NSLog(@"Loaded Manufacturers");
        });
       }
    
        // if no bullets, load them from a txt file
    if([Bullet countOfEntities] == 0) {
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
                        [bc setObject:[NSDecimalNumber decimalNumberWithString:[splitParts objectAtIndex:15]] forKey:@"G7"];

                    newBullet.ballistic_coefficient = bc;
                }   
            }
            [[NSManagedObjectContext defaultContext] save];
            NSLog(@"Loaded Bullets");
        });
    }
    
    // load preference defaults here
    
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

- (void)loadDefaultsOnFirstLoad {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if (![preferences boolForKey:@"defaultPreferencesSet"]) {
        DataManager *dataManager = [DataManager sharedManager];
        NSArray *windageLeading = [dataManager.windageLeading objectForKey:[dataManager.speedTypes objectAtIndex:0]];
        
        [preferences setBool:NO forKey:@"showNFADetails"];
        [preferences setInteger:0 forKey:@"nightModeControl"];
        [preferences setInteger:0 forKey:@"rangeUnitsControl"];
        [preferences setInteger:0 forKey:@"reticleUnitsControl"];
        [preferences setInteger:0 forKey:@"directionControl"];
        [preferences setInteger:100 forKey:@"rangeStart"];
        [preferences setInteger:600 forKey:@"rangeEnd"];
        [preferences setInteger:50 forKey:@"rangeStep"];
        [preferences setObject:[dataManager.speedTypes objectAtIndex:0] forKey:@"speedType"];
        [preferences setObject:[windageLeading objectAtIndex:0] forKey:@"speedUnit"];
        [preferences setInteger:0 forKey:@"speedIndexPathRow"];
        [preferences setInteger:0 forKey:@"speedIndexPathSection"];
        
        [preferences setBool:YES forKey:@"defaultPreferencesSet"];
        [preferences synchronize];
    }
}

@end