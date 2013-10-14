//
//  GlobalADController.h
//  DDayReminder
//
//  Created by 모근원 on 11. 11. 14..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdamMobileViewController.h"
#import "IADViewController.h"

@interface GlobalADController : NSObject <AdamMobileViewControllerDelegate,IADViewControllerDelegate>{
    CGRect noadCallerFrame;
    
    //UIWindow* targetWindow; //광고를 띄울 키 윈도우.
    UIViewController* caller; //광고를 띄울 루트뷰 컨트롤러
    
    //Event 처리용 노티센터
    NSNotificationCenter *nc;
    
    //각 광고의 컨트롤러 (예네는 뷰를 가지지 않는다.)
    AdamMobileViewController* adamController;
    IADViewController* iadController;
    
    int currentADCode;
    
    int errorCnt;
    
    //NSTimer *adViewCheckTimer;
    
//    float adHeight;
}

+(GlobalADController*) sharedController;

//GLOBAL AD INSTANCE
//-(void)orientationChange;
//-(float)adHeight;

@property (nonatomic, strong) UIViewController* caller;

//-(void)adCheck;
-(void)startADViewServiceWithCaller:(UIViewController*)_caller;
-(CGRect)getADRect;
-(int)currentADCode;

-(void)showAD;
-(void)hideAD;
-(BOOL)isHideAD;

-(void)requestLayoutReset;
-(void)refreshAD;

///adam
-(void)createAdamWithRootViewController:(UIViewController*)_rootVC;

//i_ad
-(void)createIADWithRootViewController:(UIViewController*)_rootVC;
-(void)showIADAgain;

@end

@protocol GlobalADControllerDelegate <NSObject>

@required
-(void)layoutReset:(BOOL)_animated;
@optional

@end
