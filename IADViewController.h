//
//  IADViewController.h
//  DDayReminder
//
//  Created by 모근원 on 12. 5. 16..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@protocol IADViewControllerDelegate;

@interface IADViewController : UIViewController <ADBannerViewDelegate>{
    ADBannerView *currentIADView;
    BOOL launchedAD;
}

@property (nonatomic, assign) id<IADViewControllerDelegate> delegate;
@property (nonatomic, strong) ADBannerView *currentIADView;

-(id)initWithRootViewController:(UIViewController*)_rootViewCont;
-(BOOL)isADShow;

@end

@protocol IADViewControllerDelegate <NSObject>

@optional

-(void)iADReceiveSuccess;
-(void)iADReceiveFail;
-(void)iADWillOpen;
-(void)iADWillClose;
-(void)iADDidClose;

@end