//
//  KODSessionsViewController.m
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODSessionsViewController.h"

#import "KODSpeakerDetailViewController.h"
#import "KODNavigationController.h"
#import "KODInfoViewController.h"
#import "KODDataManager.h"
#import "KODSession.h"

#import "UIColor+Kodio.h"
#import "UIView+CircularMask.h"

static NSString * const KODSessionsViewControllerRequestIdentifier = @"KODSessionsViewControllerRequestIdentifier";

@interface KODSessionsViewController () {
    UITableView *_tableView;
    NSDateFormatter *_timeFormatter;
}

- (void)didTapInfoButton:(id)sender;

- (void)dataManagerDidFetchData:(NSNotification *)notification;


- (void)cancelAllLoadOperations;
- (void)cancelAllProcessOperations;
- (void)cancelLoadOperationsForHiddenCells;
- (void)cancelProcessOperationsForHiddenCells;

@end

@implementation KODSessionsViewController

- (void)dealloc {
    [_tableView release], _tableView = nil;
    [_timeFormatter release], _timeFormatter = nil;

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];

    if (nil != self) {
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [infoButton setImage:[UIImage imageNamed:@"im-info.png"] forState:UIControlStateNormal];
        [infoButton sizeToFit];
        [infoButton addTarget:self
                       action:@selector(didTapInfoButton:)
             forControlEvents:UIControlEventTouchUpInside];

        UIBarButtonItem *infoBarButton = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
        [self.navigationItem setRightBarButtonItem:infoBarButton];

        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"HH:mm"];
    }

    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *headerLabel = [[[UILabel alloc]
                             initWithFrame:CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, 40.0)]
                            autorelease];
    [headerLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setBackgroundColor:[UIColor sessionsHeaderBackgroundColor]];
    [headerLabel setText:NSLocalizedString(@"Speakers", nil)];
    [self.contentView addSubview:headerLabel];

    CGRect tableViewFrame = self.contentView.bounds;
    tableViewFrame.origin.y = CGRectGetMaxY(headerLabel.frame);
    tableViewFrame.size.height -= tableViewFrame.origin.y;

    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame
                                              style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setRowHeight:90.0];
    [self.contentView addSubview:_tableView];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataManagerDidFetchData:)
                                                 name:KODDataManagerFetchedDataNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController
     setNavigationBarHidden:NO
     animated:animated];

}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self cancelLoadOperationsForHiddenCells];
	[self cancelProcessOperationsForHiddenCells];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    KODDataManager *dataManager = [KODDataManager sharedManager];

    return dataManager.sessions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    KODSession *session = [[[KODDataManager sharedManager] sessions] objectAtIndex:section];
    return [_timeFormatter stringFromDate:session.speechTime];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect viewFrame = CGRectZero;
    viewFrame.size.width = tableView.bounds.size.width;
    viewFrame.size.height = [self tableView:tableView heightForHeaderInSection:section];

    UIView *headerView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    [headerView setBackgroundColor:[UIColor sessionsTimeBackgroundColor]];

    UIImageView *clockView = [[[UIImageView
                                alloc]
                               initWithImage:[UIImage imageNamed:@"im-clock"]]
                              autorelease];

    {
        [clockView sizeToFit];

        CGRect viewFrame = clockView.frame;
        viewFrame.origin.x = 10.0;
        viewFrame.origin.y = roundf((headerView.frame.size.height - clockView.frame.size.height) / 2.0);
        [clockView setFrame:viewFrame];
        [headerView addSubview:clockView];
    }

    {
        CGRect viewFrame = CGRectZero;
        viewFrame.origin.x = CGRectGetMaxX(clockView.frame) + 5.0;
        viewFrame.origin.y = clockView.frame.origin.y;
        viewFrame.size.height = clockView.frame.size.height;
        viewFrame.size.width = headerView.frame.size.width - viewFrame.origin.x - 10.0;

        UILabel *headerLabel = [[[UILabel alloc] initWithFrame:viewFrame] autorelease];
        [headerLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:13.0]];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [headerLabel setText:[self tableView:tableView titleForHeaderInSection:section]];
        [headerView addSubview:headerLabel];
    }

    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const CellIdentifier = @"CellIdentifier";
    static NSInteger const AvatarViewTag = 888;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (nil == cell) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:CellIdentifier]
                autorelease];

        [cell setBackgroundColor:[UIColor sessionsCellBackgroundColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:13.0]];
        [cell.detailTextLabel setTextColor:[UIColor sessionsCellDetailLabelColor]];

        [cell.imageView setImage:[UIImage imageNamed:@"bg-avatar.png"]];

        UIImageView *disclosureView = [[[UIImageView alloc]
                                        initWithImage:[UIImage imageNamed:@"im-arrow.png"]]
                                       autorelease];
        [cell setAccessoryView:disclosureView];

        UIView *avatarView = [[[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 60.0, 60.0)] autorelease];
        [avatarView setTag:AvatarViewTag];
        [avatarView setBackgroundColor:[UIColor lightGrayColor]];
        [avatarView applyCircularMask];
        [cell.imageView addSubview:avatarView];
    }

    KODSession *session = [[[KODDataManager sharedManager] sessions] objectAtIndex:indexPath.section];

    [cell.textLabel setText:session.speakerName];
    [cell.detailTextLabel setText:session.speakerTitle];

    [[HPRequestManager sharedManager] loadImageAtURL:session.speakerAvatar
                                       withIndexPath:indexPath
                                          identifier:Nil
                                          scaleToFit:CGSizeMake(60.0, 60.0)
                                         contentMode:UIViewContentModeScaleAspectFill
                                     completionBlock:^(id resource, NSError *error) {
                                         if (nil == error) {
                                             UIImage *image = (UIImage *)resource;
                                             UIImageView *view = (UIImageView *)[cell viewWithTag:AvatarViewTag];

                                             [view setImage:image];
                                         }
                                     }];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KODSession *session = [[[KODDataManager sharedManager] sessions] objectAtIndex:indexPath.section];

    KODSpeakerDetailViewController *controller = [[[KODSpeakerDetailViewController alloc]
                                                   initWithSession:session]
                                                  autorelease];

    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Actions

- (void)didTapInfoButton:(id)sender {
    KODInfoViewController *controller = [[[KODInfoViewController alloc]
                                          initWithNibName:nil
                                          bundle:nil]
                                         autorelease];
    [controller setDelegate:self];

    KODNavigationController *navController = [[[KODNavigationController alloc]
                                              initWithRootViewController:controller]
                                             autorelease];

    [self.navigationController
     presentViewController:navController
     animated:YES
     completion:nil];

    if ([navController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [navController.navigationBar setBarTintColor:[UIColor navigationBarColor]];
        [navController.navigationBar setTranslucent:NO];
    } else {
        [navController.navigationBar setTintColor:[UIColor navigationBarColor]];
    }
}

#pragma mark - Notifications

- (void)dataManagerDidFetchData:(NSNotification *)notification {
    [_tableView reloadData];
}

#pragma mark - Cancelation

- (void)cancelAllProcessOperations {
	for (HPImageOperation *operation in [[HPRequestManager sharedManager] activeProcessOperations]) {
        if ([operation isKindOfClass:[HPImageOperation class]]
            && [operation isExecuting]
            && [operation.identifier isEqualToString:KODSessionsViewControllerRequestIdentifier]) {
            [operation cancel];
        }
    }

}

- (void)cancelProcessOperationsForHiddenCells {
	for (HPImageOperation *operation in [[HPRequestManager sharedManager] activeProcessOperations]) {
        if ([operation isKindOfClass:[HPImageOperation class]]
            && [operation isExecuting]
            && operation.indexPath != nil
            && [operation.identifier isEqualToString:KODSessionsViewControllerRequestIdentifier]
            && [_tableView cellForRowAtIndexPath:operation.indexPath] == nil) {
            [operation cancel];
        }
    }
}

- (void)cancelAllLoadOperations {
	for (HPRequestOperation *request in [[HPRequestManager sharedManager] activeRequestOperations]) {
        if ([request isExecuting]
            && [request.identifier isEqualToString:KODSessionsViewControllerRequestIdentifier]) {
            [request cancel];
        }
    }
}

- (void)cancelLoadOperationsForHiddenCells {
	for (HPRequestOperation *request in [[HPRequestManager sharedManager] activeRequestOperations]) {
        if ([request.identifier isEqualToString:KODSessionsViewControllerRequestIdentifier]
            && request.indexPath != nil
            && [_tableView cellForRowAtIndexPath:request.indexPath] == nil) {
            [request cancel];
        }
    }
}

#pragma mark - KODModalViewControllerDelegate

- (void)modalViewControllerDidDismiss:(UIViewController *)controller {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}



@end
