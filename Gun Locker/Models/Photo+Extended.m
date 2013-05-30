//
//  Photo+Extended.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Photo+Extended.h"

@implementation Photo (Extended)
-(void)setPhotoAndCreateThumbnailFromImage:(UIImage*)photo {
    self.normal_size = UIImagePNGRepresentation(photo);
    
    CGSize size = photo.size;
    CGFloat ratio = 0;
    ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    UIGraphicsBeginImageContext(rect.size);
    [photo drawInRect:rect];
    self.thumbnail_size = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
    UIGraphicsEndImageContext();
    
    self.date_taken = [NSDate date];
}

-(float)sizeOnDisk {
    return (self.normal_size.length + self.thumbnail_size.length) / 1048576.f;
}

@end
