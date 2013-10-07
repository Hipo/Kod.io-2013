//
//  KODImageLoadingCell.m
//  kod.io-2013
//
//  Created by Cemal Eker on 1.10.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODImageLoadingCell.h"

@implementation KODImageLoadingCell

@synthesize loading = _loading;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];

    if (nil != self) {
        _loading = NO;

        [self setBackgroundColor:[UIColor whiteColor]];

        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [_activityIndicatorView setHidesWhenStopped:YES];
        [_activityIndicatorView stopAnimating];
        [self.contentView addSubview:_activityIndicatorView];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (_loading) {
        [_activityIndicatorView startAnimating];
    } else {
        [_activityIndicatorView stopAnimating];
    }

    CGRect imageViewFrame = CGRectInset(self.contentView.frame, 50.0, 20.0);
    [self.imageView setFrame:imageViewFrame];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.detailTextLabel setHidden:YES];
    [self.textLabel setHidden:YES];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    [self setNeedsLayout];
}

@end
