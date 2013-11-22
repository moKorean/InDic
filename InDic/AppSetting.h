//
//  AppSetting.h
//  EventsList
//
//  Created by Geunwon,Mo on 11. 6. 13..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordBookObject.h"
#import "DDFileReader.h"
#import <dispatch/dispatch.h>   //GCD 를 이용한 멀티스레딩에 사용

@interface AppSetting : NSObject{
    //Event 처리용 노티센터
    NSNotificationCenter *nc;
    
    NSUserDefaults *defaults;
    
    NSString* languageCode;

    NSString* deviceType;
    
    NSMutableArray* cachedWordBook;
    
    NSMutableArray* cachedWordList;
    
    NSMutableArray* searchResultWordList;
    
    NSOperationQueue *queue;
    
    dispatch_queue_t dqueue;
    
    NSString* lastSearchedWord;
    
    int lastSearchIndex;
    
    UIReferenceLibraryViewController* ref;

}

//싱글턴 객체
+(AppSetting*) sharedAppSetting;

@property (nonatomic, strong) UIReferenceLibraryViewController* ref;

@property (nonatomic, strong) NSString* deviceType;
@property (nonatomic, assign) CGRect windowSize;

@property (nonatomic, strong) NSString* languageCode;

@property (nonatomic, strong) UIActivityIndicatorView * spinner;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIProgressView* progress;

@property (nonatomic, strong) NSMutableArray* searchResultWordList;

-(void)checkDefaultValue;

#pragma mark APP Settings
-(BOOL)isIPhone;
-(BOOL)isIPad;

-(void)setLanguage:(NSString*)lang;

-(BOOL)isAutoKeyboard;
-(void)setAutoKeyboard:(BOOL)_bo;
-(BOOL)isAutoClipboard;
-(void)setAutoClipboard:(BOOL)_bo;
//-(BOOL)isManualSaveToWordBook;
//-(void)setManualSaveToWordBook:(BOOL)_bo;
-(NSInteger)getFirstOpenTab;
-(void)setFirstOpenTab:(NSInteger)_tab;
-(NSInteger)getWordbookOption;
-(void)setWordbookOption:(NSInteger)_option;
//-(BOOL)isSuggestFromWorkbook;
//-(void)setSuggestFromWordbook:(BOOL)_bo;
//-(float)getStatusbarHeight;

#pragma mark DicUtils
-(void)defineWord:(NSString*)_word isShowFirstInfo:(BOOL)_showFirst isSaveToWordBook:(BOOL)_saveToWordbook targetViewController:(UIViewController*)_rcv;

#pragma mark UTils
-(void)showFirstInfo;
-(void)printCGRect:(CGRect)_rect withDesc:(NSString*)_desc;
-(void)exitAlertTitle:(NSString*)_title andMsg:(NSString*)_msg andConfirmBtn:(NSString*)_cfnBtn andCancelBtn:(NSString*)_canBtn;
-(CGRect)getSwitchFrameWith:(UISwitch*)_switch cellView:(UIView*)_cellView;

-(void)loadingStart:(UIView*)_targetView;
-(void)loadingEnd;

#pragma mark wordBook
-(void)addWordBook:(NSString*)_word addDate:(NSDate*)_addDate priority:(int)_priority;
-(void)addWordBook:(WordBookObject*)_wordObj;
-(void)deleteWordBook:(int)_idx;
-(void)deleteAllWordBook;
-(NSMutableArray*)getWordbooks;
-(NSMutableArray*)getWordbooksFromCache;
-(NSMutableArray*)searchInWordBook:(NSString*)_searchTxt limit:(int)_limit;

#pragma mark fileReading
-(void)searchInTextFile:(NSString*)_searchTxt limit:(int)_limit;

/*
#pragma mark DEV
-(void)createIndexForDev;
-(void)detectNoWord;
*/

@end
