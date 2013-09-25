//
//  KODBaseViewController.m
//  kod.io-2013
//
//  Created by Cemal Eker on 24.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODBaseViewController.h"

#import "UIColor+Kodio.h"

@interface KODBaseViewController ()

@end

@implementation KODBaseViewController

- (UIView *)contentView {
    return self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor sessionsCellBackgroundColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIImageView *titleView = [[[UIImageView alloc]
                               initWithImage:[UIImage imageNamed:@"im-logo.png"]]
                              autorelease];
    [titleView setContentMode:UIViewContentModeScaleAspectFit];
    [titleView setFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    [self.navigationItem setTitleView:titleView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
