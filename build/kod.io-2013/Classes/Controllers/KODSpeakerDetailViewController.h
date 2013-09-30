//
//  KODSpeakerDetailViewController.h
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODBaseViewController.h"

#import <DTCoreText/DTCoreText.h>

@class KODSession;

@interface KODSpeakerDetailViewController : KODBaseViewController
<DTAttributedTextContentViewDelegate>

- (id)initWithSession:(KODSession *)session;

@end
