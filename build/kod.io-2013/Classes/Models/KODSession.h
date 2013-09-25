//
//  KODSession.h
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KODSession : NSObject

@property (nonatomic, readonly, copy) NSString *speakerName;
@property (nonatomic, readonly, copy) NSString *speakerTitle;
@property (nonatomic, readonly, copy) NSString *speakerBio;
@property (nonatomic, readonly, copy) NSString *speakerTwitter;
@property (nonatomic, readonly, copy) NSString *speakerGithub;
@property (nonatomic, readonly, copy) NSString *speakerAvatar;
@property (nonatomic, readonly, copy) NSDate *speechTime;
@property (nonatomic, readonly, copy) NSString *speechTitle;
@property (nonatomic, readonly, copy) NSString *speechDetail;

+ (KODSession *)sessionWithInfo:(NSDictionary *)info;
- (id)initWithInfo:(NSDictionary *)info;

@end
