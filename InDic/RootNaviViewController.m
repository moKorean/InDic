//
//  RootNaviViewController.m
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "RootNaviViewController.h"

@interface RootNaviViewController ()

@end

@implementation RootNaviViewController

@synthesize firstViewController,tag,naviController;

-(id)init{
    self = [super init];
    if (self){
        //init
        nc = [NSNotificationCenter defaultCenter];
        
//        [nc addObserver:self selector:@selector(showDeleteAllBtn) name:_NOTIFICATION_SHOW_DELETE_ALL_BUTTON object:nil];
//        [nc addObserver:self selector:@selector(closeDeleteAllBtn) name:_NOTIFICATION_HIDE_DELETE_ALL_BUTTON object:nil];
        //self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    return self;
}

-(id)initWithFirstViewController:(UIViewController*) _firstViewController withTag:(int)_tag{
    self = [self init];
    
    if (self){
        //init
        self.firstViewController = _firstViewController;
        self.tag = _tag;
        
        //tabbaritem
        if (self.tag == _TAB_BAR_ITEM_DIC){
            self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_dic", nil) image:[UIImage imageNamed:@"tabbar_dic"] tag:self.tag];        } else
        if (self.tag == _TAB_BAR_ITEM_WORD){
            self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_wordbook", nil) image:[UIImage imageNamed:@"wordbook"] tag:self.tag];
        } else {
            self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar_settings", nil) image:[UIImage imageNamed:@"gears"] tag:self.tag];
            
        }
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.tag == _TAB_BAR_ITEM_DIC){
        
        [self.view addSubview:self.firstViewController.view];
        
    } else {
        self.naviController = [[UINavigationController alloc] initWithRootViewController:self.firstViewController];
        self.naviController.navigationBar.barStyle = UIBarStyleDefault;
        self.naviController.delegate = self;
        
        [self.view addSubview:self.naviController.view];
    }
    
    [self layoutReset:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#ifdef LITE
    [[GlobalADController sharedController] startADViewServiceWithCaller:self];
#endif
}

#pragma mark AD delegate
-(void)layoutReset:(BOOL)_animated{
    
    NSLog(@"--------------------------- LAYOUT RESET!!! -----------------------------");
    NSLog(@"레이아웃 위치 재조정 실시");
    CGFloat animationDuration = _animated ? 0.2f : 0.0f;
    
    CGRect modifiedContentFrame;
    
    CGRect winSize = [AppSetting sharedAppSetting].windowSize;
    
    modifiedContentFrame = CGRectMake(0, 0, winSize.size.width, winSize.size.height - self.tabBarController.tabBar.frame.size.height);
    
    [[AppSetting sharedAppSetting] printCGRect:modifiedContentFrame withDesc:@"first Frame"];
    
    
#ifdef LITE
    //광고영역은 addsubview 될때 자동으로 잡아주게 된다.
    /*
    if ([GlobalADController sharedController].currentADCode > _AD_NO) {
        
        float adHeight;
        
        if ([GlobalADController sharedController].isHideAD){
            
            NSLog(@"AD NOT LOADED or HIDDEN");
            adHeight = 0;
            
        } else {
            
            NSLog(@"need AD SHOW");
            adHeight = [GlobalADController sharedController].adHeight;

        }
        
        NSLog(@">>> adHeight : %f",adHeight);
        modifiedContentFrame.size.height -= adHeight;
        
    }*/
#endif
    
    [[AppSetting sharedAppSetting] printCGRect:modifiedContentFrame withDesc:@"last Frame"];
    
    if (!CGRectEqualToRect(self.view.frame, modifiedContentFrame)){
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             
                             if (self.naviController){
                                 self.naviController.view.frame = modifiedContentFrame;
                                 [self.naviController.view layoutIfNeeded];
                             }
                             
                             self.firstViewController.view.frame = modifiedContentFrame;
                             [self.firstViewController.view layoutIfNeeded];
                             
                             self.view.frame = modifiedContentFrame;
                             [self.view layoutIfNeeded];
                         }];
    }
    
    
    
    NSLog(@"--------------------------- LAYOUT RESET!!! -----------------------------");
}

@end
