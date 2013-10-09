//
//  KODDataManager.h
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const KODDataManagerFetchedDataNotification;

@interface KODDataManager : NSObject

+ (KODDataManager *)sharedManager;
- (void)fetchDataWithCompletionBlock:(void(^)(NSError *error))block;

@property (nonatomic, readonly, retain) NSArray *sessions;
@property (nonatomic, readonly, retain) NSDictionary *info;

@property (nonatomic, readonly, retain) NSError *fetchError;
@property (nonatomic, readonly, retain) NSDate *fetchTime;
@end
