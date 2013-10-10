//
//  AdamMobileViewController.h
//  EventsList
//
//  Created by Geunwon,Mo on 11. 9. 2..
//  Copyright (c) 2011년 lomohome.com. All rights reserved.
//

// 현재 2.2.2
// 5776Z1QT141a159aeb6

#import <UIKit/UIKit.h>
#import "AdamAdView.h"

#define ADAM_REFRESH_PERIOD 20 // ~초마다 광고 새로 가져오기 요청
#define ADAM_CLIENT_ID @"5776Z1QT141a159aeb6" //client id
#define ADAM_TEST_CLIENT_ID @"TestClientId"
#define ADAM_HEIGHT 48.0f

@protocol AdamMobileViewControllerDelegate;

@interface AdamMobileViewController : UIViewController <AdamAdViewDelegate> {
    AdamAdView *currentAdamAdView;
    UIViewController* callRootViewController;
}

@property (nonatomic, assign) id<AdamMobileViewControllerDelegate> delegate;
@property (nonatomic, strong) AdamAdView* currentAdamAdView;

- (id)initWithRootViewController:(UIViewController*)_rootViewCont;

- (void)refreshAd:(NSTimer *)timer;
- (BOOL)isADShow;

@end

@protocol AdamMobileViewControllerDelegate <NSObject>

@optional

-(void)adamReceiveSuccess;
-(void)adamReceiveFail;
-(void)adamWillOpen;
-(void)adamWillClose;
-(void)adamDidClose;

@end