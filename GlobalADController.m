//
//  GlobalADController.m
//  DDayReminder
//
//  Created by 모근원 on 11. 11. 14..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import "GlobalADController.h"

#define ADAM_HEIGHT 48.0f

#define MAX_ERROR_CNT 3

@implementation GlobalADController
@synthesize caller;

static GlobalADController* _sharedController = nil;

+(GlobalADController*) sharedController{
    @synchronized(self)     {
		if (!_sharedController){
			_sharedController = [[self alloc] init];
		}
		return _sharedController;
	}
    
	return nil; //요건 그냥 컴파일러 에러 방지용.
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSLog(@"########### GLOBAL AD Service 초기화");
        NSLog(@"########### GLOBAL AD Service initial");
        
        
        currentADCode = _AD_NO;
        adamController = nil;
        iadController = nil;
        
        caller = nil;
        
        noadCallerFrame = CGRectZero;
        
        errorCnt = 0;
        
        //현재뷰를 참조하고 있는 다른 뷰가 재조정되면 현재뷰의 사이즈를 재조정할 Notification
        nc = [NSNotificationCenter defaultCenter];

        [nc addObserver:self selector:@selector(showAD) name:_NOTIFICATION_SHOW_AD object:nil];
        [nc addObserver:self selector:@selector(hideAD) name:_NOTIFICATION_HIDE_AD object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark GlobalADController

-(void)startADViewServiceWithCaller:(UIViewController*)_caller{
    
    NSLog(@"try to MAKE ADs - before Caller : %@",caller);
    
    if (_caller != nil)
        self.caller = _caller;
    
    if (self.caller == nil) // || targetWindow == nil
        return;
    
    if (CGRectEqualToRect(noadCallerFrame, CGRectZero)){
        noadCallerFrame = self.caller.view.frame;
        
        NSLog(@"최초의 광고 호출. 아무것도 호출하지 않은 caller 의 프레임 : %f,%f,%f,%f",noadCallerFrame.origin.x,noadCallerFrame.origin.y,noadCallerFrame.size.width,noadCallerFrame.size.height);
    } else {
        NSLog(@"이전 광고 호출 있음.");
    }
    
    
    NSLog(@"LET'S MAKE ADs - setted Caller : %@",caller);
    
    if (currentADCode == _AD_NO) {
        if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ko"]) {
            NSLog(@"%@ ADAM 만듭니다. (새로만듬. 최초실행)",self);
            [self createAdamWithRootViewController:self.caller];
            
        } else {
            NSLog(@"%@ iAD 만듭니다. (새로만듬. 최초실행)",self);
            [self createIADWithRootViewController:self.caller];
            
        }
    } else if (currentADCode == _AD_ADAM){
        NSLog(@"%@ ADAM 만듭니다. (기존것 끌어옴) ",self);
        [self createAdamWithRootViewController:self.caller];
    } else if (currentADCode == _AD_IAD){
        NSLog(@"%@ iAD 만듭니다. (기존것 끌어옴)",self);
        [self createIADWithRootViewController:self.caller];
    }
    
    [self requestLayoutReset];
         
}

//-(float)adHeight{
//    if (currentADCode == _AD_NO) return 0;
//    else if (currentADCode == _AD_IAD && !iadController.isADShow) return 0;
//    else if (currentADCode == _AD_ADAM && !adamController.isADShow) return 0;
//    return adHeight;
//}

-(CGRect)getADRect{
    if (currentADCode == _AD_IAD){
        return iadController.currentIADView.frame; //[self.caller.view viewWithTag:_AD_IAD+100].frame;
    } else if (currentADCode == _AD_ADAM){
        return adamController.currentAdamAdView.frame; //[self.caller.view viewWithTag:_AD_ADAM+100].frame;
    } else {
        return CGRectZero;
    }
}

-(int)currentADCode{
    return currentADCode;
}

-(void)showAD{
    NSLog(@">>> showAD");

    if (currentADCode == _AD_IAD && iadController.isADShow){
        [iadController.currentIADView setHidden:NO]; //[[self.caller.view viewWithTag:_AD_IAD+100] setHidden:NO];
    } else if (currentADCode == _AD_ADAM && adamController.isADShow){
        [adamController.currentAdamAdView setHidden:NO]; //[[self.caller.view viewWithTag:_AD_ADAM+100] setHidden:NO];
        [self refreshAD];
    }
    
    NSLog(@"리퀘스트 레이아웃 리셋!!");
    if ([caller respondsToSelector:@selector(layoutReset:)]) [(id)caller layoutReset:YES];

    //[self requestLayoutReset];
    
}
-(void)hideAD{
    NSLog(@">>> hideAD");
    
    if (currentADCode == _AD_ADAM){
        [adamController.currentAdamAdView setHidden:YES]; //[[self.caller.view viewWithTag:_AD_ADAM+100] setHidden:YES];
    } else {
        [iadController.currentIADView setHidden:YES]; //[[self.caller.view viewWithTag:_AD_IAD+100] setHidden:YES];
    }

    [self requestLayoutReset];
}
-(BOOL)isHideAD{
    
    if (currentADCode == _AD_IAD){
        
//        NSLog(@">>> isHideAD IAD : %@",([self.caller.view viewWithTag:_AD_IAD+100].hidden?@"넴":@"아뇽"));;
//        return [self.caller.view viewWithTag:_AD_IAD+100].hidden;
        NSLog(@">>> isHideAD IAD : %@",(iadController.currentIADView.hidden?@"넴":@"아뇽"));;
        return iadController.currentIADView.hidden;
    } else if (currentADCode == _AD_ADAM){
//        NSLog(@">>> isHideAD ADAM : %@",([self.caller.view viewWithTag:_AD_ADAM+100].hidden?@"넴":@"아뇽"));;
//        return [self.caller.view viewWithTag:_AD_ADAM+100].hidden;
        NSLog(@">>> isHideAD ADAM : %@",(adamController.currentAdamAdView.hidden?@"넴":@"아뇽"));;
        return adamController.currentAdamAdView.hidden; //[self.caller.view viewWithTag:_AD_ADAM+100].hidden;
    }
    
    NSLog(@"isHideAD ERROR");
    return NO;
}

-(void)refreshAD{
    if (adamController != nil && currentADCode == _AD_ADAM){
            [adamController refreshAd:nil];
    } else if (iadController != nil && currentADCode == _AD_IAD){
        //iAD Refresh 방법이 없음.
    }
    

}

-(void)requestLayoutReset{
    
    //먼저 광고의 위치를 다시 잡아주고.
    if (adamController != nil && currentADCode == _AD_ADAM){
        [self showAdamAgain];
    } else if (iadController != nil && currentADCode == _AD_IAD){
        [self showIADAgain];
    }
    
    NSLog(@"리퀘스트 레이아웃 리셋!!");
    if ([caller respondsToSelector:@selector(layoutReset:)]) [(id)caller layoutReset:YES];
    
}

#pragma mark -
#pragma mark AD Creator

-(void)createAdamWithRootViewController:(UIViewController *)_rootVC{
    //아담은 매번 만든다. 어짜피 아담이 싱글턴이기땜에 상관없음.
        //adam
    currentADCode = _AD_ADAM;
    
        adamController = nil;
        adamController = [[AdamMobileViewController alloc] initWithRootViewController:_rootVC withCustomRootFrame:noadCallerFrame];
        adamController.delegate = self;
}

-(void)createIADWithRootViewController:(UIViewController *)_rootVC{
 
    currentADCode = _AD_IAD;
    
        iadController = nil;
        iadController = [[IADViewController alloc] initWithRootViewController:_rootVC withCustomRootFrame:noadCallerFrame];
        iadController.delegate = self;
    
    
}

#pragma mark -
#pragma mark IAD Controller
-(void)iADReceiveSuccess{
    NSLog(@"IAD receive success in global controller");
    
    currentADCode = _AD_IAD;

    if (adamController != nil) {
        [adamController.currentAdamAdView removeFromSuperview];
        adamController = nil;
    }
    
    
    
//    adHeight = iadController.currentIADView.frame.size.height;
    [self showIADAgain];
       
}

-(void)iADReceiveFail{
    
    //기존 광고 있다면 패스
    if (iadController != nil && iadController.isADShow){
        NSLog(@"기존 iad있어서 패스");
        return;
    }
    
    errorCnt++;
    
    NSLog(@"IAD receive fail in global controller : %d",errorCnt);
    
    if (errorCnt >= MAX_ERROR_CNT) {
        errorCnt = 0;
        
        if(iadController != nil) {
            [iadController.currentIADView removeFromSuperview];
            [iadController.currentIADView cancelBannerViewAction];
            iadController = nil;
            
            NSLog(@"iAD실패로 아담 생성");
            [self createAdamWithRootViewController:self.caller];
        }
        
        
    }

}

-(void)iADWillOpen{
    NSLog(@"IAD will open in global controller");
    [self hideAD];
}

-(void)iADDidClose{
    NSLog(@"IAD did close in global controller");
    [self requestLayoutReset];
    
}

-(void)showIADAgain{
    
    CGFloat x,y;
    x = y = 0;
    
    x = ((CGRectGetMaxX(noadCallerFrame)/2) - (iadController.currentIADView.frame.size.width/2));
    
    y = CGRectGetMaxY(noadCallerFrame) - iadController.currentIADView.frame.size.height;
    
    y -= caller.tabBarController.tabBar.frame.size.height;
    
    iadController.currentIADView.frame = CGRectMake(
                                                    x, 
                                                    y
                                                    , 
                                                    iadController.currentIADView.frame.size.width, 
                                                    iadController.currentIADView.frame.size.height //adHeight
                                                    );

    [self showAD];
    
}

#pragma mark -
#pragma mark ADAM Controller
-(void)adamReceiveSuccess{
    NSLog(@"AD@m receive success in global controller");
    
    currentADCode = _AD_ADAM;

    if(iadController != nil) {
        [iadController.currentIADView removeFromSuperview];
        iadController = nil;
    }
    
    [self showAdamAgain];
}

-(void)adamReceiveFail{
    
    //기존 광고 있다면 패스
    if (adamController != nil && adamController.isADShow){
        NSLog(@"기존 adam있어서 패스");
        return;
    }
    
    errorCnt++;
    
    NSLog(@"AD@m receive fail in global controller : %d",errorCnt);
    
    if (errorCnt >= MAX_ERROR_CNT) {
        errorCnt = 0;
        
        if(adamController != nil) {
            [adamController.currentAdamAdView stopAutoRequestAd];
            [adamController.currentAdamAdView removeFromSuperview];
            adamController = nil;
            
            NSLog(@"아담실패로 iAD 생성");
            [self createIADWithRootViewController:self.caller];
        }
        
        
    }
    
}

-(void)adamWillOpen{
    NSLog(@"AD@m will open in global controller");
    
}

-(void)adamWillClose{
    NSLog(@"AD@m will close in global controller");
    
    //[self requestLayoutReset];
}

-(void)adamDidClose{
    NSLog(@"AD@m did close in global controller");
    
}

-(void)showAdamAgain{
    
    CGFloat x,y;
    x = y = 0;
    
    x = ((CGRectGetMaxX(noadCallerFrame)/2) - (adamController.currentAdamAdView.frame.size.width/2));
    
    y = CGRectGetMaxY(noadCallerFrame) - ADAM_HEIGHT;// - adHeight;
    
    y -= caller.tabBarController.tabBar.frame.size.height;
    
    adamController.currentAdamAdView.frame = CGRectMake(x, y, noadCallerFrame.size.width, ADAM_HEIGHT);
    
    [self showAD];
    
}


@end
