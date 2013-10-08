//
//  KODInfoViewController.h
//  kod.io-2013
//
//  Created by Cemal Eker on 30.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <DTCoreText/DTCoreText.h>

#import "KODBaseViewController.h"


@interface KODInfoViewController : KODBaseViewController
<DTAttributedTextContentViewDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (nonatomic, readwrite, assign) id<KODModalViewControllerDelegate> delegate;

@end
