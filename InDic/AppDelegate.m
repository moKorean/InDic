//
//  AppDelegate.m
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
#ifdef LITE
    NSLog(@"Lite-Version");
#else
    NSLog(@"Full-Version");
#endif
    
    
    CGRect windowSize = [AppSetting sharedAppSetting].windowSize;
    
    self.window = [[UIWindow alloc] initWithFrame:windowSize];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    DicViewController *dicVC = [[DicViewController alloc] init];
    WordBookViewController *wordVC = [[WordBookViewController alloc] initWithStyle:UITableViewStylePlain];
    SettingsViewController *settingVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    RootNaviViewController *naviDicVC = [[RootNaviViewController alloc] initWithFirstViewController:dicVC withTag:_TAB_BAR_ITEM_DIC];
    RootNaviViewController *naviWordVC = [[RootNaviViewController alloc] initWithFirstViewController:wordVC withTag:_TAB_BAR_ITEM_WORD];
    RootNaviViewController *naviSettingVC = [[RootNaviViewController alloc] initWithFirstViewController:settingVC withTag:_TAB_BAR_ITEM_SETTING];
    
    NSArray *controllers = [NSArray arrayWithObjects:naviDicVC,naviWordVC,naviSettingVC, nil];
    self.tabBarController.viewControllers = controllers;
    self.tabBarController.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.delegate = self;
    
    [self.tabBarController setSelectedIndex:[AppSetting sharedAppSetting].getFirstOpenTab-1];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    nc = [NSNotificationCenter defaultCenter];
    
    
    return YES;
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
   
    if ([viewController isKindOfClass:[RootNaviViewController class]]) {
        RootNaviViewController *selectedTabViewCont = (RootNaviViewController*)viewController;
        NSLog(@"Selected %d",selectedTabViewCont.tag);
        
        if (selectedTabViewCont.tag == _TAB_BAR_ITEM_DIC){
            if ([AppSetting sharedAppSetting].isAutoKeyboard) {
                [nc postNotificationName:_NOTIFICATION_SHOW_DIC_KEYBOARD object:nil];
            }
        }
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [self.tabBarController setSelectedIndex:[AppSetting sharedAppSetting].getFirstOpenTab-1];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [nc postNotificationName:_NOTIFICATION_PASTE_FROM_CLIPBOARD object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation{
    [nc postNotificationName:_NOTIFICATION_ORIENTATION_CHANGE object:nil];
}

-(void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame{
    [nc postNotificationName:_NOTIFICATION_ORIENTATION_CHANGE object:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    
    NSString *URLString = [url absoluteString];
    
#ifdef LITE
    URLString = [[URLString stringByReplacingOccurrencesOfString:@"InDicLite://" withString: @""] stringByReplacingOccurrencesOfString:@"indiclite://" withString: @""];
#else
    URLString = [[URLString stringByReplacingOccurrencesOfString:@"InDic://" withString: @""]stringByReplacingOccurrencesOfString:@"indic://" withString: @""];
#endif
    
    URLString = [URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"Received url : %@",URLString);
    
    if ([URLString length] > 0){
     [[AppSetting sharedAppSetting] defineWord:URLString isShowFirstInfo:NO isSaveToWordBook:YES targetViewController:[[[UIApplication sharedApplication] delegate] window].rootViewController];
    }

    return YES;
}

@end
