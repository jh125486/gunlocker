//
//  NSString+Extended.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/27/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Extended)
-(int)lengthAfterDecimal;
+(NSString *)randomStringWithLength:(int)length;
-(NSDecimalNumber*)decimalFromFraction;
@end
