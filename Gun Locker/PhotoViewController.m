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
    self.photoView.frame = CGRectMake(0, CGRectGetMidY(self.containerView.frame), CGRectGetWidth(self.containerView.frame), photo.size.height);
    self.photoView.image = photo;
    
}


- (void)setTitleView {
    self.modelLabel.text = self.title;
    self.manufacturerLabel.text = self.selectedWeapon.manufacturer.short_name ? self.selectedWeapon.manufacturer.short_name : self.selectedWeapon.manufacturer.name;    
}

- (void)viewDidUnload {
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

- (IBAction)doneTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark gestures
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {    
    CGPoint translation = [recognizer translationInView:self.view];

    CGRect bounds = CGRectMake(0, 0, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
    
    if ((translation.x < 0) && (recognizer.view.frame.origin.x < 0)) {
        translation.x = 0; // reached left
    } else if ((translation.x > 0) && (recognizer.view.frame.origin.x + CGRectGetWidth(self.photoView.frame) > CGRectGetWidth(self.view.frame))) {
        translation.x = 0; // reached right
    }
    NSLog(@"aspect ratio %.1f", photo.size.width/photo.size.height);
    NSLog(@"height %f", CGRectGetWidth(self.photoView.frame) / (photo.size.width/photo.size.height));
    
    NSLog(@"view frame(%.0f, %.0f)", CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
    NSLog(@"photoview frame (%.0f, %.0f)",CGRectGetWidth(self.photoView.bounds), CGRectGetHeight(self.photoView.bounds));
    
    if ((translation.y < 0) && (recognizer.view.frame.origin.y < 0)) {
        translation.y = 0; // reached top
    } else if ((translation.y > 0) && (recognizer.view.frame.origin.y + CGRectGetHeight(self.photoView.frame) > CGRectGetHeight(self.view.frame))) {
        translation.y = 0; // reached bottom
    }
    
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;
        
        float slideFactor = 0.05 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(recognizer.view.center.x + (velocity.x * slideFactor), 
                                         recognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            recognizer.view.center = finalPoint;
        } completion:nil];
    }

}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    float smaller1 = MIN(photo.size.height, photo.size.width);
    float smaller2 = MIN(self.photoView.frame.size.height, self.photoView.frame.size.width);

    NSLog(@"photo smallest: %f\tview smallest: %f", smaller1, smaller2);
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
    NSLog(@"got tap");
    if ([UIApplication sharedApplication].statusBarHidden == YES) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.navigationBar.alpha = 1.0;
        [UIView commitAnimations];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [UIView beginAnimations:@"fadeOut" context:nil];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.navigationBar.alpha = 0.0;
        [UIView commitAnimations];
    }
}
@end
