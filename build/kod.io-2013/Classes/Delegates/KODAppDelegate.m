//
//  KODAppDelegate.m
//  kod.io 2013
//
//  Created by Cemal Eker on 23.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "KODAppDelegate.h"

#import "KODNavigationController.h"
#import "KODSplashViewController.h"
#import "KODSessionsViewController.h"
#import "KODDataManager.h"

#import "UIColor+Kodio.h"

static NSTimeInterval const animationStisfactionInterval = 1.0;

@interface KODAppDelegate () {
    UIWindow *_window;
}

@end

@implementation KODAppDelegate

-(void)dealloc {
    [_window release], _window = nil;

    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];

    // Controller hierarchy
    // ====================

    KODSplashViewController *splashController = [[[KODSplashViewController alloc]
                                                  initWithNibName:nil
                                                  bundle:nil]
                                                 autorelease];


    KODSessionsViewController *rootController = [[[KODSessionsViewController alloc]
                                                  initWithNibName:nil bundle:nil]
                                                 autorelease];

    KODNavigationController *navigationController = [[[KODNavigationController alloc]
                                                      initWithRootViewController:rootController]
                                                     autorelease];

    [_window setRootViewController:navigationController];

    [navigationController presentViewController:splashController
                                       animated:NO
                                     completion:nil];

    // UIAppearance Calls

    if ([navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [navigationController.navigationBar setBarTintColor:[UIColor navigationBarColor]];
        [navigationController.navigationBar setTranslucent:NO];
    } else {
        [navigationController.navigationBar setTintColor:[UIColor navigationBarColor]];
    }


    // Loading animation and prersentation
    // ===================================

    __block BOOL animationSatisfied = NO;
    __block BOOL dataFetched = NO;

    dispatch_block_t presentation = ^{
        [rootController dismissViewControllerAnimated:YES completion:nil];
    };

    double delayInSeconds = animationStisfactionInterval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        animationSatisfied = YES;

        if (dataFetched) {
            presentation ();
        }

    });

    [[KODDataManager sharedManager] fetchDataWithCompletionBlock:^(NSError *error) {
        dataFetched = YES;

        if (animationSatisfied) {
            presentation ();
        }
    }];


    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
