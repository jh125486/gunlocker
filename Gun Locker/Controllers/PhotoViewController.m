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
@synthesize passedPhoto = _passedPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _passedPhoto.weapon.model;
    [self updateTitleView];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/BackgroundFabricTexture"]];
    photo = [UIImage imageWithData:_passedPhoto.normal_size];
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
    [_containerView addGestureRecognizer:singleTap];
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

- (void)updateTitleView {
    self.modelLabel.text = self.title;
    self.manufacturerLabel.text = _passedPhoto.weapon.manufacturer.displayName;    
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
        CGPoint center = [recognizer locationInView:_photoView];
		
        center.x *= _containerView.maximumZoomScale;
        center.y *= _containerView.maximumZoomScale;
        center.x -= CGRectGetMidX(_containerView.bounds);
        center.y -= CGRectGetMidY(_containerView.bounds);
        
        CGFloat maxWidth = CGRectGetWidth(_photoView.bounds) * _containerView.maximumZoomScale - CGRectGetMaxX(_containerView.bounds);
        CGFloat maxHeight = CGRectGetHeight(_photoView.bounds) * _containerView.maximumZoomScale - CGRectGetMaxY(_containerView.bounds);
        
        if (center.x < 0.f) center.x = 0.f;
        if (center.y < 0.f) center.y = 0.f;
        if (center.x > maxWidth)  center.x = maxWidth;
        if (center.y > maxHeight) center.y = maxHeight;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [_containerView setZoomScale:_containerView.maximumZoomScale];
        [_containerView setContentOffset:center];
        [UIView commitAnimations];
    } else {
        [_containerView setZoomScale:_containerView.minimumZoomScale animated:YES];
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
