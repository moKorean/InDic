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
    
    BOOL donated;
}

//싱글턴 객체
+(AppSetting*) sharedAppSetting;

@property (nonatomic, strong) NSString* deviceType;
@property (nonatomic, assign) CGRect windowSize;

@property (nonatomic, strong) NSString* languageCode;

-(void)checkDefaultValue;

#pragma mark APP Settings
-(BOOL)isDonated;
-(void)setDonated:(BOOL)_donated;

-(BOOL)isIPhone;
-(BOOL)isIPad;

@end
