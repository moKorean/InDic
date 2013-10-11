//
//  AppSetting.m
//  EventsList
//
//  Created by Geunwon,Mo on 11. 6. 13..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import "AppSetting.h"

#define USER_DEFAULT_KEY_APPLE_LANGUAGE @"AppleLanguages"
#define USER_DEFAULT_KEY_AUTO_KEYBOARD @"bundleAutoKeyboard"
#define USER_DEFAULT_KEY_AUTO_CLIPBOARD @"bundleAutoClipboard"

@implementation AppSetting

@synthesize deviceType;
@synthesize windowSize;
@synthesize languageCode;

static AppSetting* _sharedAppSetting = nil;

+(AppSetting*) sharedAppSetting{
    //NSLog(@"### APP SETTING CALLED BY SINGLETON ");
    @synchronized(self)     {
		if (!_sharedAppSetting){
            //NSLog(@"### APP SETTING : NEW ");
			_sharedAppSetting = [[self alloc] init];
		} 
#if TEST_MODE_DEVICE_LOG
        else {
            //NSLog(@"### APP SETTING : EXIST ");
        }
#endif
		//NSLog(@"### APP SETTING : %@ ",_sharedAppSetting);
		return _sharedAppSetting;
	}
    
    //NSLog(@"### APP SETTING : ????? ");
	//return nil; //요건 그냥 컴파일러 에러 방지용.
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSLog(@"########### APP SETTING 초기화");
        
        //현재뷰를 참조하고 있는 다른 뷰가 재조정되면 현재뷰의 사이즈를 재조정할 Notification
        nc = [NSNotificationCenter defaultCenter];

        self.windowSize = [[UIScreen mainScreen] bounds];
        
        // setting 에서 데이터 가져와서 셋팅해준다.
        defaults = [NSUserDefaults standardUserDefaults];
        
        self.languageCode = NSLocalizedString(@"Language code", nil);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            self.deviceType = @"iPad";
        } else {
            self.deviceType = @"iPhone";
        }
        
        [self checkDefaultValue];
    }
    
    return self;
}

-(void)checkDefaultValue{
    //기본값이 필요한 값들중 기본값이 없으면 저장해둔다.
    if ([defaults objectForKey:USER_DEFAULT_KEY_AUTO_CLIPBOARD] == nil) [self setAutoClipboard:YES];
    if ([defaults objectForKey:USER_DEFAULT_KEY_AUTO_KEYBOARD] == nil) [self setAutoKeyboard:YES];
}

#pragma mark APP Settings
-(BOOL)isAutoKeyboard{
    return [defaults boolForKey:USER_DEFAULT_KEY_AUTO_KEYBOARD];
}

-(void)setAutoKeyboard:(BOOL)_bo{
    [defaults setBool:_bo forKey:USER_DEFAULT_KEY_AUTO_KEYBOARD];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 isAutoKeyboard : %@",([self isAutoKeyboard]?@"YES":@"NO"));
}

-(BOOL)isAutoClipboard{
    return [defaults boolForKey:USER_DEFAULT_KEY_AUTO_CLIPBOARD];
}

-(void)setAutoClipboard:(BOOL)_bo{
    [defaults setBool:_bo forKey:USER_DEFAULT_KEY_AUTO_CLIPBOARD];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 isAutoClipboard : %@",([self isAutoClipboard]?@"YES":@"NO"));
}

-(BOOL)isIPhone{
    if ([self.deviceType isEqualToString:@"iPhone"]) return YES;
    else return NO;
}

-(BOOL)isIPad{
    if ([self.deviceType isEqualToString:@"iPad"]) return YES;
    else return NO;
}

-(void)setLanguage:(NSString*)lang{
    
    NSLog(@"Language setting : %@",lang);
    [defaults setObject:[NSArray arrayWithObjects:lang, nil] forKey:USER_DEFAULT_KEY_APPLE_LANGUAGE];
    [defaults synchronize];
    
    NSLog(@"before language : %@",self.languageCode);
    self.languageCode = lang;//NSLocalizedString(@"Language code", nil);
    NSLog(@"after language : %@",self.languageCode);
}

#pragma mark label utils
-(void)printCGRect:(CGRect)_rect withDesc:(NSString*)_desc{
#if TEST_MODE_DEVICE_LOG
    NSLog(@"🎾 PRINT CGRECT - %@ : %f,%f,%f,%f",_desc,
          _rect.origin.x,
          _rect.origin.y,
          _rect.size.width,
          _rect.size.height);
#endif
}

-(void)exitAlertTitle:(NSString*)_title andMsg:(NSString*)_msg andConfirmBtn:(NSString*)_cfnBtn andCancelBtn:(NSString*)_canBtn{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_title
                                                        message:_msg
                                                       delegate:self
                                              cancelButtonTitle:_canBtn
                                              otherButtonTitles:_cfnBtn,nil] ;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
        
        UIView* maskView = [[UIView alloc] initWithFrame:windowSize];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0;
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:maskView];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(forceExit)];
        [UIView setAnimationDuration:0.7f];
        maskView.alpha = 1;
        [UIView commitAnimations];
        
        //exit(0);
    }
    
}

-(void)forceExit{
    NSLog(@"force exit");
    exit(0);
}

-(CGRect)getSwitchFrameWith:(UISwitch*)_switch cellView:(UIView*)_cellView{
    
    CGFloat deviceWidth = [AppSetting sharedAppSetting].windowSize.size.width;
    NSLog(@"switch device width!! : %f",deviceWidth);
    
    CGRect switchFrame = CGRectMake(deviceWidth - _switch.frame.size.width-13,
                                    (_cellView.frame.size.height - _switch.frame.size.height)/2,
                                    _switch.frame.size.width,
                                    _switch.frame.size.height);
    return switchFrame;
    
}

@end
