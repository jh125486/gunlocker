//
//  PhotoViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"

@implementation PhotoViewController
@synthesize containerView = _containerView;
@synthesize navigationBar = _navigationBar;
@synthesize modelLabel = _modelLabel;
@synthesize manufacturerLabel = _manufacturerLabel;
@synthesize photoView = _photoView;
@synthesize selectedWeapon = _selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _selectedWeapon.model;
    [self setTitleView];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundFabricTexture"]];
    photo = [UIImage imageWithData:self.selectedWeapon.photo];
    _photoView.image = photo;
    [_photoView sizeToFit];
    _containerView.contentSize = _photoView.frame.size;
    _containerView.alwaysBounceVertical = _containerView.alwaysBounceHorizontal = YES;
	_containerView.minimumZoomScale = _containerView.frame.size.width / photo.size.width;
	_containerView.maximumZoomScale = 1.f;
	[_containerView setZoomScale:_containerView.minimumZoomScale];
    
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [doubleTap setDelaysTouchesBegan:YES];
    [singleTap setDelaysTouchesBegan:YES];
    
    [doubleTap setNumberOfTapsRequired:2];
    [singleTap setNumberOfTapsRequired:1];
    
    [_photoView addGestureRecognizer:doubleTap];
    [_photoView addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:singleTap];
}

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)aView {
	CGSize boundsSize = _containerView.bounds.size;
    CGRect frameToCenter = aView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
	
	return frameToCenter;
}

- (void)setTitleView {
    self.modelLabel.text = self.title;
    self.manufacturerLabel.text = self.selectedWeapon.manufacturer.displayName;    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_photoView sizeToFit];
    _containerView.contentSize = _photoView.frame.size;

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _containerView.minimumZoomScale = _containerView.frame.size.width / photo.size.width;
    } else {
        _containerView.minimumZoomScale = _containerView.frame.size.height / photo.size.height;        
    }
    [_containerView setZoomScale:_containerView.minimumZoomScale];
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

-(IBAction)handleTap:(UIGestureRecognizer *)recognizer {
    if (self.navigationBar.alpha == 0.0f) {
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.navigationBar.alpha = 1.0f;
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"fadeOut" context:nil];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.navigationBar.alpha = 0.0f;
        [UIView commitAnimations];
    }
}

-(IBAction)handleDoubleTap:(UIGestureRecognizer *)recognizer {
    if (_containerView.zoomScale < _containerView.maximumZoomScale) {
//        CGPoint center = [recognizer locationInView:_photoView];
        [_containerView setZoomScale:_containerView.maximumZoomScale];
//        CGPoint newCenter = CGPointMake(center.x, center.y - CGRectGetHeight(self.view.frame)/2);
//        NSLog(@"%g %g", newCenter.x, newCenter.y);
//        if (newCenter.x < 0.f) newCenter.x = 0.f;
//        if (newCenter.y < 0.f) newCenter.y = 0.f;
//        if (newCenter.x > CGRectGetMaxX(_containerView.bounds)) newCenter.x = CGRectGetMaxX(_containerView.bounds);
//        if (newCenter.y > CGRectGetMaxY(_containerView.bounds)) newCenter.y = CGRectGetMaxY(_containerView.bounds);
//        NSLog(@"%g %g", newCenter.x, newCenter.y);
//        NSLog(@"width %g height %g width %g height %g\nwidth %g height %g width %g height %g", CGRectGetMaxX(_containerView.frame), CGRectGetMaxY(_containerView.frame), CGRectGetMaxX(_containerView.bounds), CGRectGetMaxY(_containerView.bounds),
//               CGRectGetWidth(_containerView.frame), CGRectGetHeight(_containerView.frame), CGRectGetWidth(_containerView.bounds), CGRectGetHeight(_containerView.bounds));
//        [_containerView setContentOffset:newCenter animated:YES];
    } else {
        [_containerView setZoomScale:_containerView.minimumZoomScale];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _photoView.frame = [self centeredFrameForScrollView:scrollView andUIView:_photoView];;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoView;
}

@end
