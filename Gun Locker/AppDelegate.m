//
//  AppDelegate.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define TESTING 1

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize showPasscode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TestFlight takeOff:@"c9a944113920e415692190a4b0e2e8cc_OTIzOTUyMDEyLTA1LTIyIDAyOjA4OjEyLjk0NzA1OA"];
    
    #ifdef TESTING
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    #pragma clang diagnostic pop
    #endif
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"GunLocker.sqlite"];
    NSLog(@"\tMagicalRecord setup completed");
    recordsDirty = NO;
    
    [self loadDefaultPreferencesOnFirstLoad];
    
    if([Manufacturer countOfEntities] == 0) [self loadManufacturers];
    if([Bullet countOfEntities] == 0) [self loadBullets];
    if([Caliber countOfEntities] == 0) [self loadCalibers];
    
    // wait for main queue to empty
    dispatch_async(dispatch_get_main_queue(), ^{
        if (recordsDirty) [[NSManagedObjectContext defaultContext] save];
    });
    
    
    // TESTING
    if([Weapon countOfEntities] == 0) [self loadTestWeapons];
    // TESTING
    
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
        recordsDirty = YES;
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
        recordsDirty = YES;
        NSLog(@"\tLoaded Bullets");
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
        }   
        recordsDirty = YES;
        NSLog(@"\tLoaded Calibers");
    });
}

// TESTING WEAPONS below

-(void)loadTestWeapons {
    dispatch_async(dispatch_get_main_queue(), ^{
        [Weapon truncateAll];
        [BallisticProfile truncateAll];
        [[NSManagedObjectContext defaultContext] save];
        
        NSArray *calibers = [Caliber findAllSortedBy:@"diameter_inches" ascending:YES];
                
        NSLog(@"Creating Test Weapon 1");
        Weapon *newWeapon1 = [Weapon createEntity];
        newWeapon1.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon1.model = @"M14 EBR";
        newWeapon1.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon1.type = @"Rifles";
        newWeapon1.barrel_length = [NSNumber numberWithDouble:18.0f];
        newWeapon1.finish = @"FDE";
        newWeapon1.threaded_barrel_pitch = @"5/8 x 24 LH";
        newWeapon1.serial_number = [self randomStringWithLength:12];
        newWeapon1.purchased_price = [NSDecimalNumber decimalNumberWithString:@"1800.00"];
        newWeapon1.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        UIImage *photo = [UIImage imageNamed:@"Test/test1.jpg"];
        newWeapon1.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        CGSize size = photo.size;
        CGFloat ratio = 0;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon1.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();   

        NSLog(@"Creating Test Weapon 2");
        Weapon *newWeapon2 = [Weapon createEntity];
        newWeapon2.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon2.model = @"Vector CRB/SO";
        newWeapon2.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon2.type = @"Rifles";
        newWeapon2.barrel_length = [NSNumber numberWithDouble:16.0f];
        newWeapon2.finish = @"Wood Furniture";
        newWeapon2.threaded_barrel_pitch = @"1/2 x 28 LH";
        newWeapon2.serial_number = [self randomStringWithLength:12];
        newWeapon2.purchased_price = [NSDecimalNumber decimalNumberWithString:@"900.00"];
        newWeapon2.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        photo = [UIImage imageNamed:@"Test/test2.jpg"];
        newWeapon2.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        size = photo.size;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon2.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        
        NSLog(@"Creating Test Weapon 3");
        Weapon *newWeapon3 = [Weapon createEntity];
        newWeapon3.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon3.model = @"1911 Series 80";
        newWeapon3.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon3.type = @"Handguns";
        newWeapon3.barrel_length = [NSNumber numberWithDouble:5.2f];
        newWeapon3.finish = @"Stainless/Black";
        newWeapon3.threaded_barrel_pitch = @"3 lug";
        newWeapon3.serial_number = [self randomStringWithLength:12];
        newWeapon3.purchased_price = [NSDecimalNumber decimalNumberWithString:@"13000.00"];
        newWeapon3.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        photo = [UIImage imageNamed:@"Test/test3.jpg"];
        newWeapon3.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        size = photo.size;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon3.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        
        NSLog(@"Creating Test Weapon 4");
        Weapon *newWeapon4 = [Weapon createEntity];
        newWeapon4.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon4.model = @"Super Shorty";
        newWeapon4.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon4.type = @"Shotguns";
        newWeapon4.barrel_length = [NSNumber numberWithDouble:9.5f];
        newWeapon4.finish = @"Stainless/Black";
        newWeapon4.serial_number = [self randomStringWithLength:12];
        newWeapon4.purchased_price = [NSDecimalNumber decimalNumberWithString:@"13000.00"];
        newWeapon4.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        
        photo = [UIImage imageNamed:@"Test/test4.jpg"];
        newWeapon4.photo = UIImagePNGRepresentation(photo);
        // Create a thumbnail version of the image for the object.
        size = photo.size;
        ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
        rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
        UIGraphicsBeginImageContext(rect.size);
        [photo drawInRect:rect];
        newWeapon4.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        
        BallisticProfile *ballisticProfile1 = [BallisticProfile createEntity];
        ballisticProfile1.bullet_weight = [NSNumber numberWithInt:55.0];
        ballisticProfile1.drag_model = @"G7";
        ballisticProfile1.muzzle_velocity = [NSNumber numberWithInt:3240];
        ballisticProfile1.zero = [NSNumber numberWithInt:100];
        ballisticProfile1.zero_unit = [NSNumber numberWithInt:0];
        ballisticProfile1.sight_height_inches = [NSNumber numberWithDouble:1.5];
        ballisticProfile1.name = @"55 grain M193 ";
        ballisticProfile1.bullet_bc = [NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:@"0.272"]];
        ballisticProfile1.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:@"0.224"];                 
        ballisticProfile1.weapon = [[Weapon findAll] objectAtIndex:1];
        ballisticProfile1.sg = [NSDecimalNumber decimalNumberWithString:@"1.5"];
        ballisticProfile1.sg_twist_direction =@"RH";
        [ballisticProfile1 calculateTheta];
        
        BallisticProfile *ballisticProfile2 = [BallisticProfile createEntity];
        
        ballisticProfile2.bullet_weight = [NSNumber numberWithInt:62.0f];
        ballisticProfile2.drag_model = @"G7";
        ballisticProfile2.muzzle_velocity = [NSNumber numberWithInt:2900];
        ballisticProfile2.zero = [NSNumber numberWithInt:100];
        ballisticProfile2.zero_unit = [NSNumber numberWithInt:0];
        ballisticProfile2.sight_height_inches = [NSNumber numberWithDouble:2.6];
        ballisticProfile2.name = @"62 grain SS109";
        ballisticProfile2.bullet_bc = [NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:@"0.151"]];
        ballisticProfile2.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:@"0.224"];                 
        ballisticProfile2.weapon = [[Weapon findAll] objectAtIndex:0];
        ballisticProfile2.sg = [NSDecimalNumber decimalNumberWithString:@"1.2"];
        ballisticProfile2.sg_twist_direction =@"RH";
        [ballisticProfile2 calculateTheta];
        
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