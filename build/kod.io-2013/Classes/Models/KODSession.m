//
//  KODSession.m
//  kod.io-2013
//
//  Created by Cemal Eker on 25.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODSession.h"

@interface KODSession () {
@private
    NSString *_speakerName;
    NSString *_speakerTitle;
    NSString *_speakerBio;
    NSString *_speakerTwitter;
    NSString *_speakerGithub;
    NSString *_speakerAvatar;
    NSDate *_speechTime;
    NSString *_speechTitle;
    NSString *_speechDetail;
}

@end

@implementation KODSession

@synthesize speakerName     = _speakerName;
@synthesize speakerTitle    = _speakerTitle;
@synthesize speakerBio      = _speakerBio;
@synthesize speakerTwitter  = _speakerTwitter;
@synthesize speakerGithub   = _speakerGithub;
@synthesize speakerAvatar   = _speakerAvatar;
@synthesize speechTime      = _speechTime;
@synthesize speechTitle     = _speechTitle;
@synthesize speechDetail    = _speechDetail;

- (void)dealloc {
    [_speakerName release], _speakerName = nil;
    [_speakerTitle release], _speakerTitle = nil;
    [_speakerBio release], _speakerBio = nil;
    [_speakerTwitter release], _speakerTwitter = nil;
    [_speakerGithub release], _speakerGithub = nil;
    [_speakerAvatar release], _speakerAvatar = nil;
    [_speechTime release], _speechTime = nil;
    [_speechTitle release], _speechTitle = nil;
    [_speechDetail release], _speechDetail = nil;

    [super dealloc];
}

- (id)initWithInfo:(NSDictionary *)info {
    self = [self init];

    if (nil != self) {
        NSLocale *usLocale = [NSLocale localeWithLocaleIdentifier:@"en_US"];

        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"]; //RFC2822-Format
        [formatter setLocale:usLocale];

        _speakerName = [[info nonNullValueForKey:@"name"] copy];
        _speakerTitle = [[info nonNullValueForKey:@"title"] copy];
        _speakerBio = [[info nonNullValueForKey:@"bio_html"] copy];
        _speakerTwitter = [[info nonNullValueForKey:@"twitter"] copy];
        _speakerGithub = [[info nonNullValueForKey:@"github"] copy];
        _speakerAvatar = [[info nonNullValueForKey:@"avatar"] copy];
        _speechTime = [[formatter dateFromString:[info nonNullValueForKey:@"speech_time"]] retain];
        _speechTitle = [[info nonNullValueForKey:@"speech_title"] copy];
        _speechDetail = [[info nonNullValueForKey:@"speech_detail_html"] copy];
    }

    return self;
}

+ (KODSession *)sessionWithInfo:(NSDictionary *)info {
    return  [[[KODSession alloc] initWithInfo:info] autorelease];
}



@end
