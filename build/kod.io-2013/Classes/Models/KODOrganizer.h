//
//  KODOrganizer.h
//  kod.io-2013
//
//  Created by Cemal Eker on 1.10.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KODOrganizer : NSObject

@property (nonatomic, readonly) NSString *imageURL;
@property (nonatomic, readonly) NSString *linkURL;

- (id)initWithInfo:(NSDictionary *)info;
+ (KODOrganizer *)organizerWithInfo:(NSDictionary *)info;

@end
