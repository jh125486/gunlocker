//
//  AppDelegate.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIWindow *window;

@end
