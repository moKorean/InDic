//
//  AppSetting.h
//  EventsList
//
//  Created by Geunwon,Mo on 11. 6. 13..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSetting : NSObject{
    //Event 처리용 노티센터
    NSNotificationCenter *nc;
    
    NSUserDefaults *defaults;
    
    NSString* languageCode;

    NSString* deviceType;

}

//싱글턴 객체
+(AppSetting*) sharedAppSetting;

@property (nonatomic, strong) NSString* deviceType;
@property (nonatomic, assign) CGRect windowSize;

@property (nonatomic, strong) NSString* languageCode;

-(void)checkDefaultValue;

#pragma mark APP Settings
-(BOOL)isIPhone;
-(BOOL)isIPad;

-(void)setLanguage:(NSString*)lang;

-(BOOL)isAutoKeyboard;
-(void)setAutoKeyboard:(BOOL)_bo;
-(BOOL)isAutoClipboard;
-(void)setAutoClipboard:(BOOL)_bo;

#pragma mark UTils
-(void)printCGRect:(CGRect)_rect withDesc:(NSString*)_desc;
-(void)exitAlertTitle:(NSString*)_title andMsg:(NSString*)_msg andConfirmBtn:(NSString*)_cfnBtn andCancelBtn:(NSString*)_canBtn;
-(CGRect)getSwitchFrameWith:(UISwitch*)_switch cellView:(UIView*)_cellView;


@end
