//
//  AdamMobileViewController.m
//  EventsList
//
//  Created by Geunwon,Mo on 11. 9. 2..
//  Copyright (c) 2011년 lomohome.com. All rights reserved.
//

#import "AdamMobileViewController.h"

@implementation AdamMobileViewController
@synthesize delegate,currentAdamAdView;

-(id)initWithRootViewController:(UIViewController *)_rootViewCont{
    self = [super init];
    if (self) {
        //isLoaded = NO;
        
        //광고뷰를 싱글턴에서 가져온다.
        currentAdamAdView = [AdamAdView sharedAdView];
        currentAdamAdView.delegate = self;
        currentAdamAdView.clientId = ADAM_CLIENT_ID;// ADAM_TEST_CLIENT_ID; //ADAM_CLIENT_ID;
        currentAdamAdView.transitionStyle = AdamAdViewTransitionStyleCurl;
        currentAdamAdView.tag = _AD_ADAM+100;
        
        if (![currentAdamAdView.superview isEqual:_rootViewCont.view]) {
            
            currentAdamAdView.frame = CGRectMake(0.0, _rootViewCont.view.frame.size.height - ADAM_HEIGHT, _rootViewCont.view.frame.size.width, ADAM_HEIGHT); //self.view.bounds.size.width
            
            
                CGRect frame = currentAdamAdView.frame;
                frame.origin.y -= _rootViewCont.tabBarController.tabBar.frame.size.height;
                currentAdamAdView.frame = frame;
            
            currentAdamAdView.backgroundColor = [UIColor redColor];
            currentAdamAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth; //UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //UIViewAutoresizingFlexibleWidth
            
            //[self.view addSubview:currentAdView];
//            self.view = adamAdView;
            [_rootViewCont.view addSubview:currentAdamAdView];
            
            if (!currentAdamAdView.usingAutoRequest) {
                [currentAdamAdView startAutoRequestAd:ADAM_REFRESH_PERIOD];
            }
        }
        
        //self.view.autoresizingMask =  UIViewAutoresizingFlexibleWidth ; //UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //UIViewAutoresizingFlexibleWidth
        //self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //self.view.backgroundColor = UIColorFromRGB(0xff0000);
    }
    
    return self;
}


// 광고를 가져왔다. 타이머를 지정해서 광고를 일정시간마다 갱신하도록 할 수 있다.
-(void)didReceiveAd:(AdamAdView *)adView{
    NSLog(@"AD@m getter success!!!");
            
    if (delegate && [delegate respondsToSelector:@selector(adamReceiveSuccess)]){
        [delegate adamReceiveSuccess];
    }

}

// 광고 가져오기를 실패했다. 이전 광고가 있다면 계속 보여줄 수도 있고, 광고 view 를 해지할 수도 있다.
/**
 - AdamErrorTypeNoFillAd
 현재 노출 가능한 광고가 없음.
 
 - AdamErrorTypeNoClientId 
 Client ID 가 설정되지 않았음.
 
 - AdamErrorTypeTooSmallAdView 
 광고 뷰의 크기가 기준보다 작음.
 
 - AdamErrorTypeInvisibleAdView
 광고 뷰가 화면에 보여지지 않고 있음.
 
 - AdamErrorTypeAlreadyUsingAutoRequest
 이미 광고 자동요청 기능을 사용하고 있는 상태임.
 
 - AdamErrorTypeTooShortRequestInterval
 허용되는 최소 호출 간격보다 짧은 시간 내에 광고를 재요청 했음.
 
 - AdamErrorTypePreviousRequestNotFinished
 이전 광고 요청에 대한 처리가 아직 완료되지 않았음.
 
 */

-(void)didFailToReceiveAd:(AdamAdView *)adView error:(NSError *)error{

    NSLog(@"AD@m getter fail!!! : %@",error.localizedDescription);
    //꼬인 레이아웃 재설정
    //[nc postNotificationName:@"LAYOUT_RESET" object:self userInfo:nil];
    
    if (delegate && [delegate respondsToSelector:@selector(adamReceiveFail)]){
        [delegate adamReceiveFail];
    }
}

- (void)refreshAd:(NSTimer *)timer {
    NSLog(@"AD@m refresh");
    [currentAdamAdView requestAd];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)isADShow{
    NSLog(@"광고가 보여지고 있는가?? %@",([currentAdamAdView hasAd]?@"넴":@"아뇽"));
//    return [currentAdView hasAd]; // 시간상의 오류로 사용안함
//    return isLoaded;
    return [currentAdamAdView hasAd];
}

-(void)willOpenFullScreenAd:(AdamAdView *)adView{
    NSLog(@"AD@m will open!!!");
    
    if (delegate && [delegate respondsToSelector:@selector(adamWillOpen)]){
        [delegate adamWillOpen];
    }
    
}

-(void)didCloseFullScreenAd:(AdamAdView *)adView{
    NSLog(@"AD@m did close!!!");
    
    if (delegate && [delegate respondsToSelector:@selector(adamDidClose)]){
        [delegate adamDidClose];
    }
}

-(void)willResignByAd:(AdamAdView *)adView{
    NSLog(@"AD@M : willResideAd : 어플이 Foreground 에서 내려갈때.");
}

- (void)willCloseFullScreenAd:(AdamAdView *)adView{
    NSLog(@"AD@m will close!!!");
    
    if (delegate && [delegate respondsToSelector:@selector(adamWillClose)]){
        [delegate adamWillClose];
    }
}
@end
