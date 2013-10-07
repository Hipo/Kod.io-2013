//
//  KODDataManager.m
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODDataManager.h"

#import "KODSession.h"
#import <HPUtils/JSONKit.h>

#define KOD_USELOCALDATA YES

@interface KODDataManager () {
@private
    NSArray *_sessions;
    NSDictionary *_info;
}

@end

static NSString * const kDataPath = @"https://s3.amazonaws.com/kodio/data.json";

NSString * const KODDataManagerFetchedDataNotification = @"KODDataManagerFetchedDataNotification";

@implementation KODDataManager

static KODDataManager * sharedInstance = nil;

+(KODDataManager *)sharedManager {
    if (nil != sharedInstance) {
        return sharedInstance;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KODDataManager alloc] init];
    });

    return sharedInstance;
}

#pragma mark - Fetch Method

- (void)fetchDataWithCompletionBlock:(void (^)(NSError *))block {
    
#ifdef KOD_USELOCALDATA

    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle *mainBundle = [NSBundle mainBundle];

        NSURL *localDataURL = [mainBundle URLForResource:@"data" withExtension:@"json"];
        NSError *readError = nil;

        NSData *localData = [NSData dataWithContentsOfURL:localDataURL
                                                  options:0
                                                    error:&readError];

        if (nil != readError) {
            block (readError);
            return;
        }

        NSError *parseError = nil;
        id jsonObject = [localData objectFromJSONDataWithParseOptions:0
                                                                error:&parseError];


        if (nil != parseError) {
            block (parseError);
            return;
        }

        NSDictionary *resources = (NSDictionary *)jsonObject;

        NSDictionary *infoInfo = [resources nonNullValueForKey:@"info"];
        NSArray *sessionsInfo = [resources nonNullValueForKey:@"sessions"];
        NSMutableArray *sessions = [NSMutableArray array];

        for (NSDictionary *sessionInfo in sessionsInfo) {
            [sessions addObject:[KODSession sessionWithInfo:sessionInfo]];
        }

        [sessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            KODSession *session1 = (KODSession *)obj1;
            KODSession *session2 = (KODSession *)obj2;

            return [session1.speechTime compare:session2.speechTime];
        }];

        [_sessions autorelease];
        _sessions = [[NSArray alloc] initWithArray:sessions];

        [_info autorelease];
        _info = [[NSDictionary alloc] initWithDictionary:infoInfo];

        block (nil);

        [[NSNotificationCenter defaultCenter] postNotificationName:KODDataManagerFetchedDataNotification object:nil];

    });

#else
    HPRequestManager *manager = [HPRequestManager sharedManager];



    HPRequestOperation *request = [manager requestForPath:@""
                                              withBaseURL:kDataPath
                                                 withData:nil
                                                   method:HPRequestMethodGet
                                                   cached:NO];

    [request addCompletionBlock:^(id resources, NSError *error) {
        if (nil == error) {
            NSDictionary *infoInfo = [resources nonNullValueForKey:@"info"];
            NSArray *sessionsInfo = [resources nonNullValueForKey:@"sessions"];
            NSMutableArray *sessions = [NSMutableArray array];

            for (NSDictionary *sessionInfo in sessionsInfo) {
                [sessions addObject:[KODSession sessionWithInfo:sessionInfo]];
            }

            [sessions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                KODSession *session1 = (KODSession *)obj1;
                KODSession *session2 = (KODSession *)obj2;

                return [session1.speechTime compare:session2.speechTime];
            }];

            [_sessions autorelease];
            _sessions = [[NSArray alloc] initWithArray:sessions];

            [_info autorelease];
            _info = [[NSDictionary alloc] initWithDictionary:infoInfo];

            block (nil);
        } else {
            block (error);
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:KODDataManagerFetchedDataNotification object:nil];
    }];
    
    [manager enqueueRequest:request];
#endif

}

@end
