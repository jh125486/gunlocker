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
#import "Caliber.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize showPasscode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecordHelpers setupCoreDataStackWithStoreNamed:@"GunLocker.sqlite"];
    NSLog(@"\tMR setup");
    
//    [Bullet truncateAll];
//    [Manufacturer truncateAll];
//    [[NSManagedObjectContext defaultContext] save];

    if([Manufacturer countOfEntities] == 0) [self loadManufacturers];

    if([Bullet countOfEntities] == 0) [self loadBullets];
  
    [self loadDefaultPreferencesOnFirstLoad];
    
    if([Weapon countOfEntities] == 0) [self loadTestWeapons];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
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

- (void)loadDefaultPreferencesOnFirstLoad {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if (![preferences boolForKey:@"defaultPreferencesSet"]) {
        NSLog(@"\tLoaded default preferences on first load");
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
        }   
        [[NSManagedObjectContext defaultContext] save];
        NSLog(@"\tLoaded Manufacturers");
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
        [[NSManagedObjectContext defaultContext] save];
        NSLog(@"\tLoaded Bullets");
    });
}

-(void)loadTestWeapons {
    dispatch_async(dispatch_get_main_queue(), ^{

        [Weapon truncateAll];
        [[NSManagedObjectContext defaultContext] save];
        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"calibers" ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        NSArray *calibers = [content componentsSeparatedByString:@"\n"];
        
        NSLog(@"Creating Test Weapon 1");
        Weapon *newWeapon = [Weapon createEntity];
        newWeapon.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon.model = @"Test Model 1";
        newWeapon.caliber = [calibers objectAtIndex:arc4random() % [calibers count]];
        newWeapon.type = @"Rifles";
        newWeapon.barrel_length = [NSNumber numberWithDouble:16.0f];
        newWeapon.finish = @"FDE";
        newWeapon.threaded_barrel_pitch = @"5/8 x 24 LH";
        newWeapon.serial_number = [self randomStringWithLength:12];
        newWeapon.purchased_price = [NSDecimalNumber decimalNumberWithString:@"1800.00"];
        newWeapon.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        UIImage *photo = [UIImage imageNamed:@"Test/test1.jpg"];
        newWeapon.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        CGSize size = photo.size;
        CGFloat ratio = 0;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();   

        NSLog(@"Creating Test Weapon 2");
        Weapon *newWeapon1 = [Weapon createEntity];
        newWeapon1.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon1.model = @"Test Model 2";
        newWeapon1.caliber = [calibers objectAtIndex:arc4random() % [calibers count]];
        newWeapon1.type = @"Rifles";
        newWeapon1.barrel_length = [NSNumber numberWithDouble:24.0f];
        newWeapon1.finish = @"Wood Furniture";
        newWeapon1.threaded_barrel_pitch = @"1/2 x 28 LH";
        newWeapon1.serial_number = [self randomStringWithLength:12];
        newWeapon1.purchased_price = [NSDecimalNumber decimalNumberWithString:@"900.00"];
        newWeapon1.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        photo = [UIImage imageNamed:@"Test/test2.jpg"];
        newWeapon1.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        size = photo.size;
        ratio = 0;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon1.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        
        NSLog(@"Creating Test Weapon 3");
        Weapon *newWeapon2 = [Weapon createEntity];
        newWeapon2.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon2.model = @"Test Model 3";
        newWeapon2.caliber = [calibers objectAtIndex:arc4random() % [calibers count]];
        newWeapon2.type = @"Rifles";
        newWeapon2.barrel_length = [NSNumber numberWithDouble:10.3f];
        newWeapon2.finish = @"Stainless/Black";
        newWeapon2.threaded_barrel_pitch = @"3 lug";
        newWeapon2.serial_number = [self randomStringWithLength:12];
        newWeapon2.purchased_price = [NSDecimalNumber decimalNumberWithString:@"13000.00"];
        newWeapon2.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        photo = [UIImage imageNamed:@"Test/test3.jpg"];
        newWeapon2.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        size = photo.size;
        ratio = 0;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon2.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        
        [[NSManagedObjectContext defaultContext] save];
    });
}


-(NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: rand()%[letters length]]];
    }
    
    return randomString;
}
@end