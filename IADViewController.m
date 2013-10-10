//
//  IADViewController.m
//  DDayReminder
//
//  Created by 모근원 on 12. 5. 16..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "IADViewController.h"

@implementation IADViewController

@synthesize delegate,currentIADView;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

-(id)initWithRootViewController:(UIViewController *)_rootViewCont{
    self = [super init];
    if (self) {
        NSLog(@"IAD INIT");
        // Do any additional setup after loading the view.
        
        //iAD 초기화
        launchedAD = NO;
        // --- WARNING ---
        // If you are planning on creating banner views at runtime in order to support iOS targets that don't support the iAd framework
        // then you will need to modify this method to do runtime checks for the symbols provided by the iAd framework
        // and you will need to weaklink iAd.framework in your project's target settings.
        // See the iPad Programming Guide, Creating a Universal Application for more information.
        // http://developer.apple.com/iphone/library/documentation/general/conceptual/iPadProgrammingGuide/Introduction/Introduction.html
        // --- WARNING ---
        
        // Depending on our orientation when this method is called, we set our initial content size.
        // If you only support portrait or landscape orientations, then you can remove this check and
        // select either ADBannerContentSizeIdentifierPortrait (if portrait only) or ADBannerContentSizeIdentifierLandscape (if landscape only).

        //여러방향 iAD를 쓸때 주석을 푼다.
//        NSString *contentSize;
//        contentSize = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
        
        
        // Calculate the intial location for the banner.
        // We want this banner to be at the bottom of the view controller, but placed
        // offscreen to ensure that the user won't see the banner until its ready.
        // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
        
        CGRect frame;
        frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        frame.origin = CGPointMake(0.0f, _rootViewCont.view.frame.size.height - frame.size.height);
        
        
        //TODO: 왜 iOS7만??
        //if ([AppSetting sharedAppSetting].overIOS7){
            frame.origin.y -= _rootViewCont.tabBarController.tabBar.frame.size.height;
        //}
        
        //    CurrentADViewController.view.frame = CGRectMake(
        //                                                    ((CGRectGetMaxX((caller).view.bounds)/2) - (frame.size.width/2)),
        //                                                    CGRectGetMaxY((caller).view.bounds) - frame.size.height
        //
        //                                                    + [AppSetting sharedAppSetting].getStatusBarHeight
        //
        //                                                    ,
        //                                                    frame.size.width,
        //                                                    frame.size.height
        //                                                    );
        //
        //    CurrentADViewController.view.backgroundColor = [UIColor clearColor];
        
        // Now to create and configure the banner view
        
        //[[AppUtils sharedAppUtils] printCGRect:frame withDesc:@"IAD FRAME"];
        
        self.currentIADView = [[ADBannerView alloc] initWithFrame:frame];
        // Set the delegate to self, so that we are notified of ad responses.
        self.currentIADView.delegate = self;
        // Set the autoresizing mask so that the banner is pinned to the bottom
        self.currentIADView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // | UIViewAutoresizingFlexibleTopMargin;
        self.currentIADView.tag = _AD_IAD + 100;
        
        // Since we support all orientations in this view controller, support portrait and landscape content sizes.
        // If you only supported landscape or portrait, you could remove the other from this set
        self.currentIADView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
        // At this point the ad banner is now be visible and looking for an ad.
        
        //self.view.frame = frame;
        
        [_rootViewCont.view addSubview:self.currentIADView];

        //    [bannerView release];
        //    self.view.backgroundColor = UIColorFromRGB(0xffcc00);
        
        //TODO
        //self.view.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; //UIViewAutoresizingFlexibleWidth
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

-(BOOL)isADShow{
    return self.currentIADView.bannerLoaded;
    //return launchedAD;
}
/*
-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		self.currentIADView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
    else
        self.currentIADView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50; 
    bannerHeight = self.currentIADView.bounds.size.height; 
	
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if(self.currentIADView.bannerLoaded)
    {
        contentFrame.size.height -= bannerHeight;
		bannerOrigin.y -= bannerHeight;
    }
    else
    {
		bannerOrigin.y += bannerHeight;
    }
    
    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
//                         contentView.frame = contentFrame;
//                         [contentView layoutIfNeeded];
                         self.currentIADView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, self.currentIADView.frame.size.width, self.currentIADView.frame.size.height);
                     }];
}
*/
#pragma mark -
#pragma mark iAD ADBannerViewDelegate methods
//광고 얻어오기 성공
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iad bannerViewDidLoadAd");
    launchedAD = YES;
    
    if (delegate && [delegate respondsToSelector:@selector(iADReceiveSuccess)]){
        [delegate iADReceiveSuccess];
    }
}

//광고 얻어오기 실패
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iad didFailToReceiveAdWithError : %@",error.localizedDescription);
    
    if (delegate && [delegate respondsToSelector:@selector(iADReceiveSuccess)]){
        [delegate iADReceiveFail];
    }
}

//광고 클릭시
-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"iad bannerViewActionShouldBegin");
    
    if (delegate && [delegate respondsToSelector:@selector(iADWillOpen)]){
        [delegate iADWillOpen];
    }
    
    return YES;
}


-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    NSLog(@"iad bannerViewActionDidFinish");
   
    if (delegate && [delegate respondsToSelector:@selector(iADDidClose)]){
        [delegate iADDidClose];
    }
    
}


@end
