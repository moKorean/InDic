//
//  IADViewController.m
//  DDayReminder
//
//  Created by 모근원 on 12. 5. 16..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "IADViewController.h"


@interface BannerViewManager : NSObject

@property (nonatomic, readonly) ADBannerView *bannerView;

+ (BannerViewManager *)sharedInstance;

@end


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

-(id)initWithRootViewController:(UIViewController *)_rootViewCont withCustomRootFrame:(CGRect)_cFrame;{
    self = [super init];
    if (self) {
        NSLog(@"IAD INIT");
        // Do any additional setup after loading the view.
        
        self.currentIADView = [BannerViewManager sharedInstance].bannerView;
        
        NSLog(@"initWithRootViewController iad ");
        
        //위치는 광고 가져온다음 다시 조정된다. 이것은 임시 위치값.
        CGRect frame = self.currentIADView.frame;
        
        frame.origin = CGPointMake(0.0f, _cFrame.size.height - frame.size.height);
        frame.origin.y -= _rootViewCont.tabBarController.tabBar.frame.size.height;
        
        [[AppSetting sharedAppSetting] printCGRect:frame withDesc:@"IAD FRAME"];
        
        self.currentIADView.frame = frame;
        self.currentIADView.delegate = self;
        // Set the autoresizing mask so that the banner is pinned to the bottom
        self.currentIADView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // | UIViewAutoresizingFlexibleTopMargin;
        self.currentIADView.tag = _AD_IAD + 100;
        
        //TODO: TEST
        self.currentIADView.backgroundColor = UIColorFromRGB(0xefeff4);

        if (![self.currentIADView.superview isEqual:_rootViewCont.view]) {
            
            [_rootViewCont.view addSubview:self.currentIADView];

        }
        
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

-(BOOL)isADShow{
    return self.currentIADView.bannerLoaded;
    //return launchedAD;
}

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
    NSLog(@"iad : %@",error.localizedDescription);
    
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



@implementation BannerViewManager {
    //ADBannerView *_bannerView; //@property 에서 선언하면 자동으로 내부 _변수 (언더바 변수)를 생성해서 @synthersize 를 걸어줌.
    //NSMutableSet *_bannerViewControllers;
}

+ (BannerViewManager *)sharedInstance
{
    static BannerViewManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BannerViewManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _bannerView = [[ADBannerView alloc] init];
        }
        
//        NSLog(@"_bannerview instance %@ from manager",_bannerView);
        //_bannerView.delegate = self;
        //_bannerViewControllers = [[NSMutableSet alloc] init];
    }
    return self;
}

@end

