//
//  KODSplashViewController.m
//  kod.io-2013
//
//  Created by Cemal Eker on 24.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODSplashViewController.h"

@interface KODSplashViewController () {
@private
    UIImageView *_imageView;

    UIImageView *_animatingView;
    UIImageView *_splashOverlay;
}

@end

@implementation KODSplashViewController

- (void)dealloc {
    [_imageView release], _imageView = nil;
    [_animatingView release], _animatingView = nil;
    [_splashOverlay release], _splashOverlay = nil;

    [super dealloc];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *splashPath = [mainBundle pathForResource:@"Default-568h@2x" ofType:@"png"];

    UIImage *image = [UIImage imageWithContentsOfFile:splashPath];

    _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [_imageView setImage:image];
    [_imageView setContentMode:UIViewContentModeCenter];
    [self.contentView addSubview:_imageView];

    _splashOverlay = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [_splashOverlay setImage:[UIImage imageNamed:@"splash-overlay.png"]];
    [_splashOverlay setContentMode:UIViewContentModeCenter];

    _animatingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash-blur.png"]];
    [_animatingView sizeToFit];

    CGRect viewFrame = _animatingView.frame;
    viewFrame.origin.x = -20.0;
    [_animatingView setFrame:viewFrame];

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self.contentView insertSubview:_animatingView
                           belowSubview:_imageView];
        [self.contentView insertSubview:_splashOverlay
                           belowSubview:_imageView];

        [UIView
         animateWithDuration:0.5
         animations:^{
             [_imageView setAlpha:0.0];
         }];

        [UIView
         animateWithDuration:30.0
         animations:^{
             CGRect viewFrame = _animatingView.frame;
             viewFrame.origin.x = self.contentView.frame.size.width - viewFrame.size.width;
             [_animatingView setFrame:viewFrame];
         }];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

@end
