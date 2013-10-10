//
//  AppDelegate.h
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootNaviViewController.h"

#import "DicViewController.h"
#import "WordBookViewController.h"
#import "SettingsViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate>{
    //Event 처리용 노티센터
    NSNotificationCenter *nc;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
