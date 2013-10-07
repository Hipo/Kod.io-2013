//
//  KODInfoViewController.m
//  kod.io-2013
//
//  Created by Cemal Eker on 30.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "KODInfoViewController.h"
#import "KODDataManager.h"
#import "KODOrganizer.h"
#import "KODImageLoadingCell.h"

#import "UIColor+Kodio.h"

@interface KODInfoViewController () {
@private
    UITableView *_tableView;

    CLLocationCoordinate2D _location;
    MKCoordinateSpan _span;
    NSString *_title;
    NSString *_detailHTML;

    NSArray *_organizerGroups;
    NSArray *_organizerTitles;

    NSCache *_imageCache;

    id<KODModalViewControllerDelegate> _delegate;
}

- (void)didTapUserButton:(id)sender;

@end

static CGFloat const kTitleLabelHeight = 40.0;
static CGFloat const kMapViewHeight = 180.0;
static CGFloat const kInfoLabelHeight = 115.0;
static NSString * const kInfoViewControllerImageLoadIdentifier;

@implementation KODInfoViewController

@synthesize delegate = _delegate;

- (void)dealloc {
    [_tableView release], _tableView = nil;

    [_title release], _title = nil;
    [_detailHTML release], _detailHTML = nil;

    [_organizerGroups release], _organizerGroups = nil;
    [_organizerTitles release], _organizerTitles = nil;

    [_imageCache release], _imageCache = nil;

    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (nil != self) {
        KODDataManager *dataManager = [KODDataManager sharedManager];

        _title = [[dataManager.info nonNullValueForKey:@"title"] copy];
        _detailHTML = [[dataManager.info nonNullValueForKey:@"detail_html"] copy];

        NSArray *organizerGroupsInfo = [dataManager.info objectForKey:@"organizers"];

        NSMutableArray *organizerTitles = [NSMutableArray array];
        NSMutableArray *organizerGroups = [NSMutableArray array];


        for (NSDictionary *organizerGroupInfo in organizerGroupsInfo) {
            NSString *title = [organizerGroupInfo nonNullValueForKey:@"title"];

            NSArray *organizersInfo = [organizerGroupInfo nonNullValueForKey:@"companies"];
            NSMutableArray *organizerGroup = [NSMutableArray array];

            for (NSDictionary *organizerInfo in organizersInfo) {
                [organizerGroup addObject:[KODOrganizer organizerWithInfo:organizerInfo]];
            }

            [organizerTitles addObject:title];
            [organizerGroups addObject:[NSArray arrayWithArray:organizerGroup]];
        }

        _organizerTitles = [[NSArray alloc] initWithArray:organizerTitles];
        _organizerGroups = [[NSArray alloc] initWithArray:organizerGroups];

        _imageCache = [[NSCache alloc] init];

        NSDictionary *location = [dataManager.info nonNullValueForKey:@"location"];
        NSDictionary *span = [dataManager.info nonNullValueForKey:@"span"];
        NSNumber *lat = [location nonNullValueForKey:@"lat"];
        NSNumber *lon = [location nonNullValueForKey:@"long"];
        NSNumber *spanlat = [span nonNullValueForKey:@"lat"];
        NSNumber *spanlon = [span nonNullValueForKey:@"long"];

        _location = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
        _span = MKCoordinateSpanMake(spanlat.doubleValue, spanlon.doubleValue);

    }

    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor infoBackgroundColor]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.contentView addSubview:_tableView];

    KODDataManager *dataManager = [KODDataManager sharedManager];

    CGRect headerViewFrame = CGRectZero;

    UIView *headerView = [[[UIView alloc] initWithFrame:headerViewFrame] autorelease];
    [headerView setBackgroundColor:[UIColor infoBackgroundColor]];

    CGRect locationTitleLabelFrame = CGRectZero;
    locationTitleLabelFrame.size.width = self.contentView.frame.size.width;
    locationTitleLabelFrame.size.height = kTitleLabelHeight;

    UILabel *locationTitleLabel = [[[UILabel alloc] initWithFrame:locationTitleLabelFrame] autorelease];
    [locationTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [locationTitleLabel setBackgroundColor:[UIColor sessionsHeaderBackgroundColor]];
    [locationTitleLabel setTextColor:[UIColor whiteColor]];
    [locationTitleLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
    [locationTitleLabel setText:NSLocalizedString(@"Location", nil)];
    [headerView addSubview:locationTitleLabel];

    headerViewFrame = CGRectUnion(headerViewFrame, locationTitleLabelFrame);

    CGRect mapViewFrame = CGRectZero;
    mapViewFrame.size.width = self.contentView.frame.size.width;
    mapViewFrame.size.height = kMapViewHeight;
    mapViewFrame.origin.y = CGRectGetMaxY(locationTitleLabelFrame);

    MKCoordinateRegion region = MKCoordinateRegionMake(_location, _span);

    MKMapView *mapView = [[[MKMapView alloc] initWithFrame:mapViewFrame] autorelease];
    [mapView setRegion:region];
    [headerView addSubview:mapView];

    MKPointAnnotation *annotation = [[[MKPointAnnotation alloc] init] autorelease];
    [annotation setCoordinate:_location];
    [mapView addAnnotation:annotation];

    headerViewFrame = CGRectUnion(headerViewFrame, mapViewFrame);

    CGRect infoLabelFrame = CGRectZero;
    infoLabelFrame.size.width = self.contentView.frame.size.width;
    infoLabelFrame.size.height = kInfoLabelHeight;
    infoLabelFrame.origin.y = CGRectGetMaxY(mapViewFrame);

    NSDictionary *options = @{
                              DTDefaultFontFamily : @"TisaOT",
                              DTDefaultFontSize : @(14),
                              DTDefaultTextColor : [UIColor blackColor]
                              };

    DTHTMLAttributedStringBuilder *builder = [[[DTHTMLAttributedStringBuilder  alloc]
                                               initWithHTML:[[dataManager.info
                                                              nonNullValueForKey:@"detail_html"]
                                                             dataUsingEncoding:NSUTF8StringEncoding]
                                               options:options
                                               documentAttributes:nil] autorelease];

	DTAttributedTextContentView *infoLabel = [[DTAttributedTextContentView alloc] initWithFrame:infoLabelFrame];
    [infoLabel setDelegate:self];

    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setAttributedString:builder.generatedAttributedString];
    [infoLabel sizeToFit];

    [headerView addSubview:infoLabel];

    headerViewFrame = CGRectUnion(headerViewFrame, infoLabelFrame);
    [headerView setFrame:headerViewFrame];

    [_tableView setTableHeaderView:headerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"im-user.png"]
                forState:UIControlStateNormal];

    [backButton addTarget:self
                   action:@selector(didTapUserButton:)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _organizerTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *organizerGroup = [_organizerGroups objectAtIndex:section];

    return organizerGroup.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_organizerTitles objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[[UILabel alloc]
                             initWithFrame:CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, 40.0)]
                            autorelease];
    [headerLabel setFont:[UIFont fontWithName:@"NoticiaText-Regular" size:15.0]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setBackgroundColor:[UIColor sessionsHeaderBackgroundColor]];
    [headerLabel setText:[self tableView:tableView titleForHeaderInSection:section]];

    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const CellIdentifier = @"CellIdentifier";

    KODImageLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (nil == cell) {
        cell = [[[KODImageLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier]
                autorelease];
    }

    KODOrganizer *organizer = [[_organizerGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([_imageCache objectForKey:indexPath] == nil) {
        [cell setLoading:YES];
        [cell.imageView setImage:nil];
        [[HPRequestManager sharedManager] loadImageAtURL:organizer.imageURL
                                           withIndexPath:indexPath
                                              identifier:kInfoViewControllerImageLoadIdentifier
                                              scaleToFit:CGSizeMake(tableView.frame.size.width - 100.0, 100.0)
                                             contentMode:UIViewContentModeScaleAspectFit
                                         completionBlock:^(id resource, NSError *error) {
                                             if (nil == error) {
                                                 UIImage *image = (UIImage *)resource;
                                                 [cell.imageView setImage:image];

                                                 [_imageCache setObject:image forKey:indexPath];
                                                 [tableView reloadRowsAtIndexPaths:@[indexPath]
                                                                  withRowAnimation:UITableViewRowAnimationAutomatic];

                                             }
                                             
                                             [cell setLoading:NO];
                                         }];
    } else {
        [cell.imageView setImage:[_imageCache objectForKey:indexPath]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KODOrganizer *organizer = [[_organizerGroups objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:organizer.linkURL]];
}

- (void)tableView:(UITableView *)tableView
didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	for (HPImageOperation *operation in [[HPRequestManager sharedManager] activeProcessOperations]) {
        if ([operation.identifier isEqualToString:kInfoViewControllerImageLoadIdentifier]
            && [operation.indexPath isEqual:indexPath]) {
            [operation cancel];
        }
    }

	for (HPRequestOperation *request in [[HPRequestManager sharedManager] activeRequestOperations]) {
        if ([request.identifier isEqualToString:kInfoViewControllerImageLoadIdentifier]
            && [request.indexPath isEqual:indexPath]) {
            [request cancel];
        }
    }



}

#pragma mark - Actions

- (void)didTapUserButton:(id)sender {
    [self.delegate modalViewControllerDidDismiss:self];
}





@end
