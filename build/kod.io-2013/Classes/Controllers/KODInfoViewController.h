//
//  KODInfoViewController.h
//  kod.io-2013
//
//  Created by Cemal Eker on 30.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODBaseViewController.h"
#import <DTCoreText/DTCoreText.h>

@interface KODInfoViewController : KODBaseViewController
<DTAttributedTextContentViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite, assign) id<KODModalViewControllerDelegate> delegate;

@end
