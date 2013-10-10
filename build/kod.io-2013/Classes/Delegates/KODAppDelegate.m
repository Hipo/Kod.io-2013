//
//  KODAppDelegate.m
//  kod.io 2013
//
//  Created by Cemal Eker on 23.9.13.
//  Copyright (c) 2013 kod.io. All rights reserved.
//

#import "TestFlight.h"
#import "Mixpanel.h"

#import "KODAppDelegate.h"
#import "KODNavigationController.h"
#import "KODSplashViewController.h"
#import "KODSessionsViewController.h"
#import "KODDataManager.h"

#import "UIColor+Kodio.h"


static NSTimeInterval const animationStisfactionInterval = 6.0;
static NSTimeInterval const dataRefetchInterval = 3600.0;
static NSString * const KODMixPanelToken = @"707075da25dc6bcec22982543ec61181";


@interface KODAppDelegate () {
    UIWindow *_window;
}

@end


@implementation KODAppDelegate

- (void)dealloc {
    [_window release], _window = nil;

    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [TestFlight setDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [TestFlight takeOff:@"31f2973a-ebcb-49a5-9df6-eaf7141a7297"];
    
    [Mixpanel sharedInstanceWithToken:KODMixPanelToken];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];

    // Controller hierarchy
    // ====================


    KODSessionsViewController *rootController = [[[KODSessionsViewController alloc]
                                                  initWithNibName:nil bundle:nil]
                                                 autorelease];

    KODNavigationController *navigationController = [[[KODNavigationController alloc]
                                                      initWithRootViewController:rootController]
                                                     autorelease];

    [_window setRootViewController:navigationController];

    // UIAppearance Calls

    if ([navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [navigationController.navigationBar setBarTintColor:[UIColor navigationBarColor]];
        [navigationController.navigationBar setTranslucent:NO];
    } else {
        [navigationController.navigationBar setTintColor:[UIColor navigationBarColor]];
    }

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound)];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self fetchDataAndPresentWhenReady];
    
    [[Mixpanel sharedInstance] track:@"App Launch"];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

#pragma mark - Private

- (void)fetchDataAndPresentWhenReady {
    // Loading animation and prersentation
    // ===================================

    UINavigationController *navController = (UINavigationController *)_window.rootViewController;

    __block BOOL animationSatisfied = NO;
    __block BOOL dataFetched = NO;

    dispatch_block_t presentation = ^{
        if ([[KODDataManager sharedManager] fetchError]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:NSLocalizedString(@"There was an error while fetching data.", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"Retry", nil)
                                                      otherButtonTitles:nil];

            [alertView show];
            [alertView release];
        } else {
            [navController dismissViewControllerAnimated:YES completion:nil];
        }
    };

    double delayInSeconds = animationStisfactionInterval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        animationSatisfied = YES;

        if (dataFetched) {
            presentation ();
        }

    });

    KODDataManager *dataManager = [KODDataManager sharedManager];

    if (dataManager.fetchError == nil
        && dataManager.fetchTime
        && [[NSDate date] timeIntervalSinceDate:dataManager.fetchTime] < dataRefetchInterval) {
        presentation();
    } else {
        UINavigationController *navController = (UINavigationController *)_window.rootViewController;

        if (![navController.presentedViewController isKindOfClass:[KODSplashViewController class]]) {
            KODSplashViewController *splashController = [[[KODSplashViewController alloc]
                                                          initWithNibName:nil
                                                          bundle:nil]
                                                         autorelease];

            [navController presentViewController:splashController
                                        animated:NO
                                      completion:nil];
        }

        [navController popToRootViewControllerAnimated:NO];

        [dataManager fetchDataWithCompletionBlock:^(NSError *error) {
            dataFetched = YES;

            if (animationSatisfied) {
                presentation ();
            }
        }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self fetchDataAndPresentWhenReady];
}

#pragma mark - Push notifications

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[[Mixpanel sharedInstance] people] addPushDeviceToken:deviceToken];
}

@end
