//
//  PhotoViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"

@implementation PhotoViewController
@synthesize containerView;
@synthesize navigationBar;
@synthesize modelLabel;
@synthesize manufacturerLabel;
@synthesize photoView;
@synthesize selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.selectedWeapon.model;
    [self setTitleView];
    self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFabricTexture"]];
    photo = [UIImage imageWithData:self.selectedWeapon.photo];
    self.photoView.image = photo;
    
    [self setPhotoFrame];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)setPhotoFrame {
    CGRect imageFrame = CGRectMake(0, 0, 0, 0);
    if (photo.size.width > photo.size.height) {
        imageFrame.size.width  = CGRectGetWidth(self.containerView.frame);
        imageFrame.size.height = photo.size.height * (CGRectGetWidth(imageFrame)/photo.size.width);
        imageFrame.origin.y = (CGRectGetHeight(self.containerView.frame) - CGRectGetHeight(imageFrame))/2;
    } else {
        imageFrame.size.height  = CGRectGetHeight(self.containerView.frame);
        imageFrame.size.width = photo.size.width * (CGRectGetHeight(imageFrame)/photo.size.height);
        imageFrame.origin.x = (CGRectGetWidth(self.containerView.frame) - CGRectGetWidth(imageFrame))/2;
    }
    
    self.photoView.frame = imageFrame;
}

- (void)setTitleView {
    self.modelLabel.text = self.title;
    self.manufacturerLabel.text = self.selectedWeapon.manufacturer.short_name ? self.selectedWeapon.manufacturer.short_name : self.selectedWeapon.manufacturer.name;    
}

- (void)viewDidUnload {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setManufacturerLabel:nil];
    [self setModelLabel:nil];
    [self setPhotoView:nil];
    [self setNavigationBar:nil];
    [self setContainerView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)orientationChanged:(id)sender {
    [self setPhotoFrame];

//    NSLog(@"image frame (%.0f, %.0f, %.0f, %.0f)", self.photoView.frame.origin.x, self.photoView.frame.origin.y, CGRectGetWidth(self.photoView.frame), CGRectGetHeight(self.photoView.frame));
//    NSLog(@"contain frame (%.0f, %.0f, %.0f, %.0f)", self.containerView.frame.origin.x, self.containerView.frame.origin.y, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));

}

- (IBAction)doneTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark gestures
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {    
    CGPoint translation = [recognizer translationInView:self.view];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
//    NSLog(@"x %.0f y %.0f", translation.x, translation.y);
        
    if ((recognizer.state == UIGestureRecognizerStateEnded)) {
//        CGPoint midpoint = CGPointMake(CGRectGetWidth(self.photoView.frame)/2, CGRectGetHeight(self.photoView.frame)/2);
        CGRect bounds = CGRectMake(CGRectGetMinX(self.containerView.frame) + CGRectGetWidth(self.photoView.frame)/2, 
                                   CGRectGetMinY(self.containerView.frame) + CGRectGetHeight(self.photoView.frame)/2,
                                   CGRectGetWidth(self.containerView.frame) - CGRectGetWidth(self.photoView.frame), 
                                   CGRectGetHeight(self.containerView.frame) - CGRectGetHeight(self.photoView.frame));
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide

        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor), 
                                         recognizer.view.center.y + (velocity.y * slideFactor));

        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        if (!CGRectContainsPoint(bounds, finalPoint)){
            NSLog(@"point (%.0f, %.0f) outside bounds (%.0f, %.0f, %.0f, %.0f)", 
                  finalPoint.x, finalPoint.y, 
                  bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);

            if (finalPoint.x < CGRectGetMinX(bounds)){
                NSLog(@"left edge");
                finalPoint.x = CGRectGetMinX(bounds);
            } else if (finalPoint.x > CGRectGetMaxX(bounds)) {
                NSLog(@"right edge");
                finalPoint.x = CGRectGetMaxX(bounds);
            }
            
            if (finalPoint.y < CGRectGetMinY(bounds)) {
                NSLog(@"top edge");
                finalPoint.y = CGRectGetMinY(bounds);
            } else if (finalPoint.y > CGRectGetMaxY(bounds)) {
                NSLog(@"bottom edge");
                finalPoint.y = CGRectGetMaxY(bounds);
            }
        }  else {
            NSLog(@"point (%.0f, %.0f) INSIDE bounds (%.0f, %.0f, %.0f, %.0f) (%.0f, %.0f)", 
                  finalPoint.x, finalPoint.y, 
                  bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height,
                  translation.x, translation.y);

        }      
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
    }
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    if ([recognizer numberOfTouches] < 2)
        return;
        
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
        lastPoint = [recognizer locationInView:self.photoView];
    }
    
    // Scale
    CGFloat scale = 1.0 - (lastScale - recognizer.scale);
    [self.photoView.layer setAffineTransform:CGAffineTransformScale([self.photoView.layer affineTransform], scale, scale)];
    lastScale = recognizer.scale;
    
    // Translate
    CGPoint point = [recognizer locationInView:self.photoView];
    [self.photoView.layer setAffineTransform:CGAffineTransformTranslate([self.photoView.layer affineTransform], point.x - lastPoint.x, point.y - lastPoint.y)];
    lastPoint = [recognizer locationInView:self.photoView];
    
//  figure out scale to bounds edge;    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"container frame: (%.0f, %.0f, %.0f, %.0f)", self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height);
        NSLog(@"photoView frame: (%.0f, %.0f, %.0f, %.0f)", self.photoView.frame.origin.x, self.photoView.frame.origin.y, self.photoView.frame.size.width, self.photoView.frame.size.height);
    
        if(!CGRectContainsRect(self.containerView.frame, self.photoView.frame)) {
            NSLog(@"outside frame");
        } else {
            NSLog(@"inside frame");
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setPhotoFrame];
            } completion:nil];
        }
        
        
    }
    
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint point = [recognizer locationInView:self.containerView];
//        NSLog(@"scale %f point(%.0f, %.0f)", recognizer.scale, point.x, point.y);
//        self.photoView.layer.anchorPoint = point;
//    }
//
//    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    recognizer.scale = 1;
}


-(IBAction)handleTap:(UIGestureRecognizer *)recoginizer {
    if (self.navigationBar.alpha == 0.0f) {
//        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.navigationBar.alpha = 1.0f;
        [UIView commitAnimations];
    } else {
//        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [UIView beginAnimations:@"fadeOut" context:nil];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.navigationBar.alpha = 0.0f;
        [UIView commitAnimations];
    }
}
@end
