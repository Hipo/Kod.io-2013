//
//  KODImageLoadingCell.h
//  kod.io-2013
//
//  Created by Cemal Eker on 1.10.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KODImageLoadingCell : UITableViewCell {
@private
    BOOL _loading;
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, readwrite, assign, getter = isLoading) BOOL loading;

@end
