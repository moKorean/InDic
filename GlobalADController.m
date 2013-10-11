//
//  GlobalADController.m
//  DDayReminder
//
//  Created by 모근원 on 11. 11. 14..
//  Copyright (c) 2011년 __MyCompanyName__. All rights reserved.
//

#import "GlobalADController.h"

#define ADAM_HEIGHT 48.0f
#define TEMP_AD_VIEW_TAG 453789

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
        
        //targetWindow = nil;
        //adViewCheckTimer = nil;
        //CurrentADViewController = nil;
        
        currentADCode = _AD_NO;
        adamController = nil;
        iadController = nil;
        
        caller = nil;
        
        noadCallerFrame = CGRectZero;
        
        adHeight = 0.0f;
        
        //현재뷰를 참조하고 있는 다른 뷰가 재조정되면 현재뷰의 사이즈를 재조정할 Notification
        nc = [NSNotificationCenter defaultCenter];

//        [nc addObserver:self selector:@selector(orientationChange) name:_NOTIFICATION_ORIENTATION_CHANGE object:nil];

        
//        [nc addObserver:self selector:@selector(requestLayoutReset) name:_NOTIFICATION_LAYOUT_RESET object:nil];
        [nc addObserver:self selector:@selector(showAD) name:_NOTIFICATION_SHOW_AD object:nil];
        [nc addObserver:self selector:@selector(hideAD) name:_NOTIFICATION_HIDE_AD object:nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark GlobalADController

//광고 회전 은 광고가 나오는 뷰에서 한다.
//-(void)orientationChange{
//    [self requestLayoutReset];
//}



//-(void)adCheck{
//    //NSLog(@"** adCheck!");
//    [self startADViewServiceWithCaller:nil];
//}

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

-(float)adHeight{
    if (currentADCode == _AD_NO) return 0;
    else if (currentADCode == _AD_IAD && !iadController.isADShow) return 0;
    else if (currentADCode == _AD_ADAM && !adamController.isADShow) return 0;
    return adHeight;
}

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
    }
    
    [self refreshAD];
    
    [self requestLayoutReset];
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
    if (adamController != nil && currentADCode == _AD_ADAM)
        [adamController refreshAd:nil];
}

-(void)requestLayoutReset{
    
    NSLog(@"리퀘스트 레이아웃 리셋!!");
    if ([caller respondsToSelector:@selector(layoutReset:)]) [(id)caller layoutReset:YES];
    
}

#pragma mark -
#pragma mark AD Creator

-(void)createAdamWithRootViewController:(UIViewController *)_rootVC{
    //아담은 매번 만든다. 어짜피 아담이 싱글턴이기땜에 상관없음.
        //adam
    //currentADCode = _AD_ADAM;
    
        adamController = nil;
        adamController = [[AdamMobileViewController alloc] initWithRootViewController:_rootVC];
        adamController.delegate = self;
    
    [[_rootVC.view viewWithTag:TEMP_AD_VIEW_TAG] removeFromSuperview];
    UILabel* tempView = [[UILabel alloc] initWithFrame:adamController.currentAdamAdView.frame];
    tempView.text = @"AD adam";
    tempView.textAlignment = NSTextAlignmentCenter;
    tempView.tag = TEMP_AD_VIEW_TAG;
    [_rootVC.view addSubview:tempView];
}

-(void)createIADWithRootViewController:(UIViewController *)_rootVC{
 
    //currentADCode = _AD_IAD;
    
        iadController = nil;
        iadController = [[IADViewController alloc] initWithRootViewController:_rootVC];
        iadController.delegate = self;
    
    [[_rootVC.view viewWithTag:TEMP_AD_VIEW_TAG] removeFromSuperview];
    UILabel* tempView = [[UILabel alloc] initWithFrame:iadController.currentIADView.frame];
    tempView.text = @"AD iad";
    tempView.textAlignment = NSTextAlignmentCenter;
    tempView.tag = TEMP_AD_VIEW_TAG;
    [_rootVC.view addSubview:tempView];
    
}

#pragma mark -
#pragma mark IAD Controller
-(void)iADReceiveSuccess{
    NSLog(@"IAD receive success in global controller");
    
    currentADCode = _AD_IAD;
    
    [[self.caller.view viewWithTag:TEMP_AD_VIEW_TAG] removeFromSuperview];
    
    if (adamController != nil) [adamController.currentAdamAdView removeFromSuperview];
    
    adHeight = iadController.currentIADView.frame.size.height;
    
    [self showAD];
       
}

-(void)iADReceiveFail{
    NSLog(@"IAD receive fail in global controller");
    
    //iAD 실패시 아담 만들음.
    if (!iadController.isADShow){
        NSLog(@"iad 가져오기 실패하고 기표시 광고가 없음");
        NSLog(@"iAD실패로 아담 생성");
        if(iadController != nil) [iadController.currentIADView removeFromSuperview];
        currentADCode = _AD_NO;
        [self requestLayoutReset];
        [self createAdamWithRootViewController:self.caller];
    } else {
        NSLog(@"iad 가져오기 실패하였지만 기표시 광고가 있음");
    }

}

-(void)iADWillOpen{
    NSLog(@"IAD will open in global controller");
    [self hideAD];
}

-(void)iADDidClose{
    NSLog(@"IAD did close in global controller");
    [self showIADAgain];
    
}

-(void)showIADAgain{
    
    CGFloat x,y;
    x = y = 0;
    
    x = ((CGRectGetMaxX((caller).view.bounds)/2) - (iadController.currentIADView.frame.size.width/2));
    
    y = CGRectGetMaxY((caller).view.bounds) - adHeight;
    
    y -= caller.tabBarController.tabBar.frame.size.height;
    
    
    iadController.currentIADView.frame = CGRectMake(
                                                    x, 
                                                    y
                                                    , 
                                                    iadController.currentIADView.frame.size.width, 
                                                    adHeight
                                                    );

    [self showAD];
    
}

#pragma mark -
#pragma mark ADAM Controller
-(void)adamReceiveSuccess{
    NSLog(@"AD@m receive success in global controller");
    
    currentADCode = _AD_ADAM;
    
    [[self.caller.view viewWithTag:TEMP_AD_VIEW_TAG] removeFromSuperview];
    
    if(iadController != nil) [iadController.currentIADView removeFromSuperview];
    
    adHeight = ADAM_HEIGHT;
    
    adamController.currentAdamAdView.frame = CGRectMake(0.0, caller.view.frame.size.height - ADAM_HEIGHT, caller.view.frame.size.width, ADAM_HEIGHT); //self.view.bounds.size.width
    
    
    CGRect frame = adamController.currentAdamAdView.frame;
    frame.origin.y -= caller.tabBarController.tabBar.frame.size.height;
    adamController.currentAdamAdView.frame = frame;
    
    [self showAD];
}

-(void)adamReceiveFail{
    NSLog(@"AD@m receive fail in global controller");
    
    if (!adamController.isADShow){
        NSLog(@"adam 가져오기 실패하고 기표시 광고가 없음");
        NSLog(@"아담실패로 iAD 생성");
        if (adamController != nil) [adamController.currentAdamAdView removeFromSuperview];
        currentADCode = _AD_NO;
        [self requestLayoutReset];
        [self createIADWithRootViewController:self.caller];
    } else{
        NSLog(@"adam 가져오기 실패하였지만 기표시 광고가 있음");
    }
    
}

-(void)adamWillOpen{
    NSLog(@"AD@m will open in global controller");
    
}

-(void)adamWillClose{
    NSLog(@"AD@m will close in global controller");
    
    [self requestLayoutReset];
}

-(void)adamDidClose{
    NSLog(@"AD@m did close in global controller");
    
}

@end
