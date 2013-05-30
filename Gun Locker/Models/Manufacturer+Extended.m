//
//  Manufacturer+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Manufacturer+Extended.h"

@implementation Manufacturer (Extended)
-(NSString *)displayName {
    return self.short_name ? self.short_name : self.name;
}
@end
