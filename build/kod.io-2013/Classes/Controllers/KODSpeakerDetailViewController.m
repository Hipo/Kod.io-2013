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

#import <DTCoreText/DTCoreText.h>

@interface KODSpeakerDetailLinkButton : UIButton

@property (nonatomic, readwrite, assign) NSURL *link;

@end

@implementation KODSpeakerDetailLinkButton

@synthesize link;

@end



@interface KODSpeakerDetailViewController () {
@private
    NSDateFormatter *_timeFormatter;
    KODSession *_session;
    UIImageView *_avatarView;
    UIScrollView *_scrollView;
}

- (void)didTapTwitterButton:(id)sender;
- (void)didTapGithubButton:(id)sender;
- (void)didTapLinkButton:(id)sender;

@end

static CGFloat const kAvatarHolderHeight = 130.0;
static CGFloat const kButtonTopMargin = 30.0;
static CGFloat const kAvatarBorderTopMargin = 20.0;
static CGFloat const kSpeakerTitleTopMargin = 100.0;

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


    CGRect scrollViewFrame = CGRectZero;
    scrollViewFrame.origin.y = CGRectGetMaxY(avatarHolderFrame);
    scrollViewFrame.size.width = self.contentView.frame.size.width;
    scrollViewFrame.size.height = self.contentView.frame.size.height - scrollViewFrame.origin.y;

    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 15.0, 0.0)];
    [_scrollView setAlwaysBounceVertical:YES];

    [self.contentView addSubview:_scrollView];

    NSMutableParagraphStyle *sectionTitleStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [sectionTitleStyle setFirstLineHeadIndent:20.0];

    NSAttributedString *bioTitleText = [[[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(@"Bio", nil)
                                          attributes:@{ NSParagraphStyleAttributeName: sectionTitleStyle }]
                                        autorelease];


    CGRect bioTitleLabelFrame = CGRectZero;
    bioTitleLabelFrame.size.width = self.contentView.frame.size.width;
    bioTitleLabelFrame.size.height = 40.0;

    UILabel *bioTitleLabel = [[[UILabel alloc] initWithFrame:bioTitleLabelFrame] autorelease];
    [bioTitleLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
    [bioTitleLabel setTextAlignment:NSTextAlignmentLeft];
    [bioTitleLabel setTextColor:[UIColor whiteColor]];
    [bioTitleLabel setBackgroundColor:[UIColor sessionsHeaderBackgroundColor]];
    [bioTitleLabel setAttributedText:bioTitleText];
    [_scrollView addSubview:bioTitleLabel];

    NSAttributedString *speechInfoText = [[[NSAttributedString alloc]
                                           initWithString:NSLocalizedString(@"Speech Info", nil)
                                           attributes:@{ NSParagraphStyleAttributeName: sectionTitleStyle}]
                                          autorelease];

    CGRect bioDetailLabelFrame = CGRectZero;
    bioDetailLabelFrame.origin.x = 20.0;
    bioDetailLabelFrame.size.width = self.contentView.frame.size.width - (2.0 * bioDetailLabelFrame.origin.x);
    bioDetailLabelFrame.origin.y = CGRectGetMaxY(bioTitleLabel.frame) + 10.0;
    bioDetailLabelFrame.size.height = CGFLOAT_MAX;

    NSDictionary *options = @{
                              DTDefaultFontFamily : @"TisaOT",
                              DTDefaultFontSize : @(14),
                              DTDefaultTextColor : [UIColor blackColor],
                              DTDefaultLinkColor : [UIColor navigationBarColor],
                              DTDefaultLinkDecoration : @(NO),
                              DTDefaultLineHeightMultiplier: @(1.3)
                              };

    DTHTMLAttributedStringBuilder *bioDetailBuilder = [[[DTHTMLAttributedStringBuilder  alloc]
                                                           initWithHTML:[_session.speakerBio dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:options
                                                           documentAttributes:nil] autorelease];

	DTAttributedTextContentView *bioDetailView = [[DTAttributedTextContentView alloc] initWithFrame:bioDetailLabelFrame];
    [bioDetailView setDelegate:self];

    [bioDetailView setBackgroundColor:[UIColor clearColor]];
    [bioDetailView setAttributedString:bioDetailBuilder.generatedAttributedString];
    [bioDetailView sizeToFit];

    bioDetailLabelFrame = bioDetailView.frame;
    bioDetailLabelFrame.origin.x = 20.0;
    bioDetailLabelFrame.origin.y = CGRectGetMaxY(bioTitleLabel.frame) + 10.0;
    [bioDetailView setFrame:bioDetailLabelFrame];

    [_scrollView addSubview:bioDetailView];


    CGRect speechInfoLabelFrame = CGRectZero;
    speechInfoLabelFrame.size.width = self.contentView.frame.size.width;
    speechInfoLabelFrame.size.height = 40.0;
    speechInfoLabelFrame.origin.y = CGRectGetMaxY(bioDetailLabelFrame) + 15.0;

    UILabel *speechInfoLabel = [[[UILabel alloc] initWithFrame:speechInfoLabelFrame] autorelease];
    [speechInfoLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
    [speechInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [speechInfoLabel setTextColor:[UIColor whiteColor]];
    [speechInfoLabel setBackgroundColor:[UIColor sessionsHeaderBackgroundColor]];
    [speechInfoLabel setAttributedText:speechInfoText];
    [_scrollView addSubview:speechInfoLabel];

    CGRect titleLabelFrame = CGRectZero;
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

    NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [style setLineHeightMultiple:0.8];

    NSAttributedString *speechTitle = [[[NSAttributedString alloc]
                                       initWithString:_session.speechTitle
                                       attributes:@{ NSParagraphStyleAttributeName: style }]
                                       autorelease];

    [titleLabel setAttributedText:speechTitle];
    [_scrollView addSubview:titleLabel];

    [titleLabel sizeToFit];

    titleLabelFrame = titleLabel.frame;
    titleLabelFrame.origin.y = CGRectGetMaxY(speechInfoLabel.frame) + 15.0;
    [titleLabel setFrame:titleLabelFrame];

    CGRect timeLabelFrame = CGRectZero;
    timeLabelFrame.size.width = 70.0;
    timeLabelFrame.size.height = 20.0;
    timeLabelFrame.origin.y = CGRectGetMinY(titleLabelFrame);
    timeLabelFrame.origin.x = self.contentView.frame.size.width - 20.0 - timeLabelFrame.size.width;

    UILabel *timeLabel = [[[UILabel alloc] initWithFrame:timeLabelFrame] autorelease];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor speakerDetailTimeLabelColor]];
    [timeLabel setTextAlignment:NSTextAlignmentRight];
    [timeLabel setFont:[UIFont fontWithName:@"TisaOT-Medi" size:19.0]];
    [timeLabel setText:[_timeFormatter stringFromDate:_session.speechTime]];
    [_scrollView addSubview:timeLabel];

    CGRect speechDetailLabelFrame = CGRectZero;
    speechDetailLabelFrame.origin.x = 20.0;
    speechDetailLabelFrame.size.width = self.contentView.frame.size.width - (2.0 * speechDetailLabelFrame.origin.x);
    speechDetailLabelFrame.origin.y = CGRectGetMaxY(titleLabel.frame) + 10.0;
    speechDetailLabelFrame.size.height = CGFLOAT_MAX;


    DTHTMLAttributedStringBuilder *speechDetailBuilder = [[[DTHTMLAttributedStringBuilder  alloc]
                                                           initWithHTML:[_session.speechDetail dataUsingEncoding:NSUTF8StringEncoding]
                                                           options:options
                                                           documentAttributes:nil] autorelease];

	DTAttributedTextContentView *speechDetailView = [[DTAttributedTextContentView alloc] initWithFrame:speechDetailLabelFrame];
    [speechDetailView setDelegate:self];

    [speechDetailView setBackgroundColor:[UIColor clearColor]];
    [speechDetailView setAttributedString:speechDetailBuilder.generatedAttributedString];
    [speechDetailView sizeToFit];

    speechDetailLabelFrame = speechDetailView.frame;
    speechDetailLabelFrame.origin.x = 20.0;
    speechDetailLabelFrame.origin.y = CGRectGetMaxY(titleLabel.frame) + 10.0;
    [speechDetailView setFrame:speechDetailLabelFrame];

    [_scrollView addSubview:speechDetailView];

    [_scrollView setContentSize:CGSizeMake(self.contentView.frame.size.width,
                                           CGRectGetMaxY(speechDetailLabelFrame))];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"im-back.png"]
                 forState:UIControlStateNormal];

     [backButton addTarget:self.navigationController
                    action:@selector(popViewControllerAnimated:)
          forControlEvents:UIControlEventTouchUpInside];
     [backButton sizeToFit];

     UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
     [self.navigationItem setLeftBarButtonItem:item animated:YES];
}

#pragma mark - Actions

- (void)didTapGithubButton:(id)sender {
    NSURL *url = [NSURL URLWithString:_session.speakerGithub];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didTapTwitterButton:(id)sender {
    NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",
                                          _session.speakerTwitter]];

    NSURL *webURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/%@",
                                          _session.speakerTwitter]];

    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        [[UIApplication sharedApplication] openURL:appURL];
    } else {
        [[UIApplication sharedApplication] openURL:webURL];
    }
}

- (void)didTapLinkButton:(id)sender {
    DTLinkButton *button = (DTLinkButton *)sender;

    [[UIApplication sharedApplication] openURL:button.URL];
}



#pragma mark -  DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                          viewForLink:(NSURL *)url
                           identifier:(NSString *)identifier
                                frame:(CGRect)frame {
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];

    linkButton.URL = url;

    [linkButton addTarget:self
                   action:@selector(didTapLinkButton:)
         forControlEvents:UIControlEventTouchUpInside];

    return linkButton;
}

@end
