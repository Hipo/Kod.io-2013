//
//  KODBaseViewController.h
//  kod.io-2013
//
//  Created by Cemal Eker on 24.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KODModalViewControllerDelegate <NSObject>

- (void)modalViewControllerDidDismiss:(UIViewController *)controller;

@end

@interface KODBaseViewController : UIViewController

@property (nonatomic, readonly) UIView *contentView;

- (NSString *)uniqueIdentifier;

@end
