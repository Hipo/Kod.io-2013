//
//  KODOrganizer.m
//  kod.io-2013
//
//  Created by Cemal Eker on 1.10.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODOrganizer.h"

@interface KODOrganizer () {
@private
    NSString *_imageURL;
    NSString *_linkURL;
}

@end

@implementation KODOrganizer

- (void)dealloc {
    [_imageURL release], _imageURL = nil;
    [_linkURL release], _linkURL = nil;


    [super dealloc];
}

+ (KODOrganizer *)organizerWithInfo:(NSDictionary *)info {
    return [[[self alloc] initWithInfo:info] autorelease];
}

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];

    if (self != nil) {
        _imageURL = [[info nonNullValueForKey:@"image"] copy];
        _linkURL = [[info nonNullValueForKey:@"url"] copy];
    }

    return self;
}

@end
