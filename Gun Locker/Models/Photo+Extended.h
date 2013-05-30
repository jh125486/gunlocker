//
//  Photo+Extended.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/28/13.
//
//

#import "Photo.h"

@interface Photo (Extended)
-(void)setPhotoAndCreateThumbnailFromImage:(UIImage *)photo;
-(float)sizeOnDisk;
@end
