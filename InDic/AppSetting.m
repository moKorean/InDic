//
//  AppSetting.m
//  EventsList
//
//  Created by Geunwon,Mo on 11. 6. 13..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import "AppSetting.h"

#define USER_DEFAULT_KEY_APPLE_LANGUAGE @"AppleLanguages"
#define USER_DEFAULT_KEY_DONATE @"bundleSettedDonate"

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
    //if ([defaults objectForKey:USER_DEFAULT_KEY_DONATE] == nil) [self setDonated:NO];
}

#pragma mark APP Settings
-(BOOL)isDonated{
    //NSLog(@"현재 셋팅된 DONATED : %@",([defaults boolForKey:USER_DEFAULT_KEY_DONATE]?@"YES":@"NO"));
    return [defaults boolForKey:USER_DEFAULT_KEY_DONATE];
    //return YES;
}

-(void)setDonated:(BOOL)_donated{
    [defaults setBool:_donated forKey:USER_DEFAULT_KEY_DONATE];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 DONATED : %@",([self isDonated]?@"YES":@"NO"));
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

@end
