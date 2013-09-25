//
//  KODSpeakerDetailViewController.m
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODSpeakerDetailViewController.h"

#import "KODSession.h"

#import "UIColor+Kodio.h"
#import "UIView+CircularMask.h"
#import "TTTAttributedLabel.h"

#import <DTCoreText/DTCoreText.h>

@interface KODSpeakerDetailViewController () {
@private
    NSDateFormatter *_timeFormatter;
    KODSession *_session;
    UIImageView *_avatarView;
}

- (void)didTapTwitterButton:(id)sender;
- (void)didTapGithubButton:(id)sender;

@end

static CGFloat const kAvatarHolderHeight = 130.0;
static CGFloat const kButtonTopMargin = 30.0;
static CGFloat const kAvatarBorderTopMargin = 20.0;
static CGFloat const kSpeakerTitleTopMargin = 100.0;
static CGFloat const kTitleLabelTopMargin = 190.0;


@implementation KODSpeakerDetailViewController

- (void)dealloc {
    [_session release], _session = nil;
    [_timeFormatter release], _timeFormatter = nil;
    [_avatarView release], _avatarView = nil;

    [super dealloc];
}

- (id)initWithSession:(KODSession *)session {
    self = [self initWithNibName:nil bundle:nil];

    if (nil != self) {
        _session = [session retain];

        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"HH:mm"];
    }

    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.contentView setBackgroundColor:[UIColor speakerDetailBackgroundColor]];

    UILabel *headerLabel = [[[UILabel alloc]
                             initWithFrame:CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, 40.0)]
                            autorelease];
    [headerLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setBackgroundColor:[UIColor sessionsHeaderBackgroundColor]];
    [headerLabel setText:_session.speakerName];
    [self.contentView addSubview:headerLabel];

    CGRect avatarHolderFrame = CGRectZero;
    avatarHolderFrame.origin.y = CGRectGetMaxY(headerLabel.frame);
    avatarHolderFrame.size.width = self.contentView.frame.size.width;
    avatarHolderFrame.size.height = kAvatarHolderHeight;

    UIView *avatarHolderView = [[[UIView alloc] initWithFrame:avatarHolderFrame] autorelease];
    [avatarHolderView setBackgroundColor:[UIColor sessionsCellBackgroundColor]];
    [self.contentView addSubview:avatarHolderView];

    UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [twitterButton setImage:[UIImage imageNamed:@"im-twitter.png"]
                   forState:UIControlStateNormal];
    [twitterButton sizeToFit];
    [twitterButton addTarget:self
                      action:@selector(didTapTwitterButton:)
            forControlEvents:UIControlEventTouchUpInside];

    CGRect twitterButtonFrame = twitterButton.frame;
    twitterButtonFrame.origin.x = roundf(((avatarHolderFrame.size.width / 2.0) - twitterButtonFrame.size.width) / 2.0);
    twitterButtonFrame.origin.y = kButtonTopMargin;
    [twitterButton setFrame:twitterButtonFrame];
    [avatarHolderView addSubview:twitterButton];

    UIButton *githubButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [githubButton setImage:[UIImage imageNamed:@"im-github.png"]
                  forState:UIControlStateNormal];
    [githubButton sizeToFit];
    [githubButton addTarget:self
                     action:@selector(didTapGithubButton:)
           forControlEvents:UIControlEventTouchUpInside];

    CGRect githubButtonFrame = githubButton.frame;
    githubButtonFrame.origin.x = twitterButtonFrame.origin.x + roundf(avatarHolderFrame.size.width / 2.0);
    githubButtonFrame.origin.y = kButtonTopMargin;
    [githubButton setFrame:githubButtonFrame];
    [avatarHolderView addSubview:githubButton];

    CGRect borderViewFrame = CGRectZero;
    borderViewFrame.size.width = avatarHolderFrame.size.width;
    borderViewFrame.size.height = 1.0;
    borderViewFrame.origin.y = CGRectGetMaxY(avatarHolderView.bounds) - 1.0;

    UIView *borderView = [[[UIView alloc] initWithFrame:borderViewFrame] autorelease];
    [borderView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.2]];
    [avatarHolderView addSubview:borderView];

    UIImageView *avatarBorder = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-avatar.png"]] autorelease];
    [avatarBorder sizeToFit];

    CGRect avatarBorderFrame = avatarBorder.frame;
    avatarBorderFrame.origin.x = roundf((avatarHolderView.frame.size.width - avatarBorderFrame.size.width) / 2.0);
    avatarBorderFrame.origin.y = kAvatarBorderTopMargin;
    [avatarBorder setFrame:avatarBorderFrame];
    [avatarHolderView addSubview:avatarBorder];

    _avatarView = [[UIImageView alloc] initWithFrame:CGRectInset(avatarBorder.bounds, 5.0, 5.0)];
    [_avatarView setBackgroundColor:[UIColor lightGrayColor]];
    [_avatarView applyCircularMask];
    [avatarBorder addSubview:_avatarView];

    [[HPRequestManager sharedManager] loadImageAtURL:_session.speakerAvatar
                                       withIndexPath:nil
                                          identifier:nil
                                          scaleToFit:_avatarView.frame.size
                                         contentMode:UIViewContentModeScaleAspectFill
                                     completionBlock:^(id resource, NSError *error) {
                                         if (error == nil) {
                                             UIImage *image = (UIImage *)resource;
                                             [_avatarView setImage:image];
                                         }
                                     }];

    CGRect speakerTitleLabelFrame = CGRectZero;
    speakerTitleLabelFrame.size.width = avatarHolderView.frame.size.width;
    speakerTitleLabelFrame.size.height = 20.0;
    speakerTitleLabelFrame.origin.x = 0.0;
    speakerTitleLabelFrame.origin.y = kSpeakerTitleTopMargin;

    UILabel *speakerTitleLabel = [[[UILabel alloc] initWithFrame:speakerTitleLabelFrame] autorelease];
    [speakerTitleLabel setText:_session.speakerTitle];
    [speakerTitleLabel setBackgroundColor:[UIColor clearColor]];
    [speakerTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [speakerTitleLabel setTextColor:[UIColor sessionsCellDetailLabelColor]];
    [speakerTitleLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:12.0]];
    [avatarHolderView addSubview:speakerTitleLabel];

    CGRect titleLabelFrame = CGRectZero;
    titleLabelFrame.origin.y = kTitleLabelTopMargin;
    titleLabelFrame.origin.x = 20.0;
    titleLabelFrame.size.width = 210.0;
    titleLabelFrame.size.height = CGFLOAT_MAX;

    UILabel *titleLabel = [[[UILabel alloc] initWithFrame:titleLabelFrame] autorelease];
    [titleLabel setNumberOfLines:0];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor navigationBarColor]];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setFont:[UIFont fontWithName:@"TisaOT-Medi" size:19.0]];
    [titleLabel setText:_session.speechTitle];
    [self.contentView addSubview:titleLabel];

    [titleLabel sizeToFit];

    titleLabelFrame = titleLabel.frame;
    titleLabelFrame.origin.y = kTitleLabelTopMargin;
    [titleLabel setFrame:titleLabelFrame];

    CGRect timeLabelFrame = CGRectZero;
    timeLabelFrame.size.width = 50.0;
    timeLabelFrame.size.height = 20.0;
    timeLabelFrame.origin.y = kTitleLabelTopMargin + roundf((titleLabelFrame.size.height - timeLabelFrame.size.height) / 2.0);
    timeLabelFrame.origin.x = self.contentView.frame.size.width - 20.0 - timeLabelFrame.size.width;

    UILabel *timeLabel = [[[UILabel alloc] initWithFrame:timeLabelFrame] autorelease];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor speakerDetailTimeLabelColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont fontWithName:@"TisaOT-Medi" size:19.0]];
    [timeLabel setText:[_timeFormatter stringFromDate:_session.speechTime]];
    [self.contentView addSubview:timeLabel];

    CGRect speechDetailLabelFrame = CGRectZero;
    speechDetailLabelFrame.origin.x = 20.0;
    speechDetailLabelFrame.size.width = self.contentView.frame.size.width - (2.0 * speechDetailLabelFrame.origin.x);
    speechDetailLabelFrame.origin.y = CGRectGetMaxY(titleLabel.frame) + 10.0;
    speechDetailLabelFrame.size.height = CGFLOAT_MAX;


    NSDictionary *options = @{
                              DTDefaultFontFamily : @"TisaOT",
                              DTDefaultFontSize : @(12),
                              DTDefaultTextColor : [UIColor blackColor]
                              };

    DTHTMLAttributedStringBuilder *builder = [[DTHTMLAttributedStringBuilder  alloc]
                                              initWithHTML:[_session.speechDetail dataUsingEncoding:NSUTF8StringEncoding]
                                              options:options
                                              documentAttributes:nil];

	DTAttributedTextContentView *speechDetailView = [[DTAttributedTextContentView alloc] initWithFrame:speechDetailLabelFrame];

    [speechDetailView setBackgroundColor:[UIColor clearColor]];
    [speechDetailView setAttributedString:builder.generatedAttributedString];
    [speechDetailView sizeToFit];

    speechDetailLabelFrame = speechDetailView.frame;
    speechDetailLabelFrame.origin.x = 20.0;
    speechDetailLabelFrame.origin.y = CGRectGetMaxY(titleLabel.frame) + 10.0;
    [speechDetailView setFrame:speechDetailLabelFrame];

    [self.contentView addSubview:speechDetailView];

}

#pragma mark - Actions

- (void)didTapGithubButton:(id)sender {
    NSURL *url = [NSURL URLWithString:_session.speakerGithub];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didTapTwitterButton:(id)sender {
    NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",
                                          _session.speakerTwitter]];

    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        [[UIApplication sharedApplication] openURL:appURL];
    }
}


@end
