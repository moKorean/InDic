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
//#define USER_DEFAULT_KEY_SUGGEST_WORDBOOK_WORD @"bundleSuggestWordbookWord"
//#define USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK @"bundleManualSaveToWordBook"
#define USER_DEFAULT_KEY_FIRST_OPEN_TAB @"bundleFirstOpenTab"
#define USER_DEFAULT_KEY_WORDBOOK_OPTION @"bundleWordBookOption"

#define USER_DEFAULT_KEY_SPEAK_USE @"bundleTTSUse"
#define USER_DEFAULT_KEY_SPEAK_SPEED @"bundleTTSSpeed"
#define USER_DEFAULT_KEY_SPEAK_VOICE @"bundleTTSVoice"

#define USER_DEFAULT_KEY_FiRST_INITED @"bundleFirstInited"
#define USER_DEFAULT_KEY_FiRST_INFORMATION @"bundleFirstInfo"


#define USER_DEFAULT_KEY_WORDBOOK_ARY @"bundleWordBook"

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)


@implementation AppSetting

@synthesize ref;
@synthesize deviceType;
@synthesize windowSize;
@synthesize languageCode;
@synthesize progress;
@synthesize searchResultWordList;
@synthesize spinner,maskView;

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
        
        [nc addObserver:self selector:@selector(orientationDefineMaterials) name:_NOTIFICATION_ORIENTATION_CHANGE object:nil];

        self.windowSize = [[UIScreen mainScreen] bounds];
        
        // setting 에서 데이터 가져와서 셋팅해준다.
        defaults = [NSUserDefaults standardUserDefaults];
        
        self.languageCode = NSLocalizedString(@"Language code", nil);
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            self.deviceType = @"iPad";
        } else {
            self.deviceType = @"iPhone";
        }
        
        cachedWordBook = nil;
        
        [self checkDefaultValue];
        
        queue = [NSOperationQueue new];
        
        //Async 로 파일을 메모리에 로드해둔다.
        [self requestAsyncCacheWordList];
        
        searchResultWordList = [NSMutableArray new];
        
        lastSearchedWord = nil;
        
        lastSearchIndex = 0;
        
        ref = nil;
        
    }
    
    return self;
}

-(void)checkDefaultValue{
    //기본값이 필요한 값들중 기본값이 없으면 저장해둔다.
    
    //최초 1회만 실행
    if ([defaults objectForKey:USER_DEFAULT_KEY_FiRST_INITED] == nil){
        
        if ([defaults objectForKey:USER_DEFAULT_KEY_AUTO_CLIPBOARD] == nil) [self setAutoClipboard:NO];
        if ([defaults objectForKey:USER_DEFAULT_KEY_AUTO_KEYBOARD] == nil) [self setAutoKeyboard:YES];
        
        if ([defaults objectForKey:USER_DEFAULT_KEY_WORDBOOK_ARY] == nil){
            NSMutableArray* defaultAry = [[NSMutableArray alloc] init];
            
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:defaultAry] forKey:USER_DEFAULT_KEY_WORDBOOK_ARY];
            [defaults synchronize];
        }
        
        //최초 Init 완료.
        [defaults setBool:YES forKey:USER_DEFAULT_KEY_FiRST_INITED];
        [defaults synchronize];
    }
    
    //추가 Migration 키를 따기전까진 여기에 하나하나 추가 (많아지면 Migration 기능으로 옮겨야함)
//    if ([defaults objectForKey:USER_DEFAULT_KEY_SUGGEST_WORDBOOK_WORD] == nil) [self setSuggestFromWordbook:YES];
//    if ([defaults objectForKey:USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK] == nil) [self setManualSaveToWordBook:NO];
    if ([defaults objectForKey:USER_DEFAULT_KEY_FIRST_OPEN_TAB] == nil) [self setFirstOpenTab:1];
    if ([defaults objectForKey:USER_DEFAULT_KEY_WORDBOOK_OPTION] == nil) [self setWordbookOption:1];
    
    if ([defaults objectForKey:USER_DEFAULT_KEY_SPEAK_USE] == nil) [self setSpeakUse:YES];
    if ([defaults objectForKey:USER_DEFAULT_KEY_SPEAK_SPEED] == nil) [self setSpeakSpeed:15];
    if ([defaults objectForKey:USER_DEFAULT_KEY_SPEAK_VOICE] == nil) [self setSpeakVoice:1];
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

//-(BOOL)isManualSaveToWordBook{
//    return [defaults boolForKey:USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK];
//}
//
//-(void)setManualSaveToWordBook:(BOOL)_bo{
//    [defaults setBool:_bo forKey:USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK];
//    [defaults synchronize];
//    NSLog(@"다음값으로 값 재설정 isManualSaveToWordBook : %@",([self isManualSaveToWordBook]?@"YES":@"NO"));
//}

-(NSInteger)getFirstOpenTab{
    return [defaults integerForKey:USER_DEFAULT_KEY_FIRST_OPEN_TAB];
}
-(void)setFirstOpenTab:(NSInteger)_tab{
    [defaults setInteger:_tab forKey:USER_DEFAULT_KEY_FIRST_OPEN_TAB];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 getFirstOpenTab : %d",[self getFirstOpenTab]);
}

-(NSInteger)getWordbookOption{
    return [defaults integerForKey:USER_DEFAULT_KEY_WORDBOOK_OPTION];
}
-(void)setWordbookOption:(NSInteger)_option{
    [defaults setInteger:_option forKey:USER_DEFAULT_KEY_WORDBOOK_OPTION];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 getWordbookOption : %d",[self getWordbookOption]);
}


-(BOOL)isSpeakUse{
    return [defaults boolForKey:USER_DEFAULT_KEY_SPEAK_USE];
}
-(void)setSpeakUse:(BOOL)_bo{
    [defaults setBool:_bo forKey:USER_DEFAULT_KEY_SPEAK_USE];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 isSpeakUse : %@",([self isSpeakUse]?@"YES":@"NO"));
}
-(NSInteger)getSpeakSpeed{
    return [defaults integerForKey:USER_DEFAULT_KEY_SPEAK_SPEED];
}
-(void)setSpeakSpeed:(NSInteger)_speed{
    [defaults setInteger:_speed forKey:USER_DEFAULT_KEY_SPEAK_SPEED];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 getSpeakSpeed : %d",[self getSpeakSpeed]);
}
-(NSInteger)getSpeakVoice{
    return [defaults integerForKey:USER_DEFAULT_KEY_SPEAK_VOICE];
}
-(void)setSpeakVoice:(NSInteger)_voice{
    [defaults setInteger:_voice forKey:USER_DEFAULT_KEY_SPEAK_VOICE];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 getSpeakVoice : %d",[self getSpeakVoice]);
}

//-(BOOL)isSuggestFromWorkbook{
//    return [defaults boolForKey:USER_DEFAULT_KEY_SUGGEST_WORDBOOK_WORD];
//}

//-(void)setSuggestFromWordbook:(BOOL)_bo{
//    [defaults setBool:_bo forKey:USER_DEFAULT_KEY_SUGGEST_WORDBOOK_WORD];
//    [defaults synchronize];
//    NSLog(@"다음값으로 값 재설정 isSuggestFromWorkbook : %@",([self isSuggestFromWorkbook]?@"YES":@"NO"));
//}

-(BOOL)isIPhone{
    if ([self.deviceType isEqualToString:@"iPhone"]) return YES;
    else return NO;
}

-(BOOL)isIPad{
    if ([self.deviceType isEqualToString:@"iPad"]) return YES;
    else return NO;
}

//-(float)getStatusbarHeight{
//    NSLog(@"Statusbar Size : %f",[[UIApplication sharedApplication] statusBarFrame].size.height);
//    return [[UIApplication sharedApplication] statusBarFrame].size.height;
//}

-(void)setLanguage:(NSString*)lang{
    
    NSLog(@"Language setting : %@",lang);
    [defaults setObject:[NSArray arrayWithObjects:lang, nil] forKey:USER_DEFAULT_KEY_APPLE_LANGUAGE];
    [defaults synchronize];
    
    NSLog(@"before language : %@",self.languageCode);
    self.languageCode = lang;//NSLocalizedString(@"Language code", nil);
    NSLog(@"after language : %@",self.languageCode);
}

#pragma mark DicUtils
-(void)defineWord:(NSString*)_word isShowFirstInfo:(BOOL)_showFirst isSaveToWordBook:(BOOL)_saveToWordbook targetViewController:(UIViewController*)_rcv{

    NSLog(@"Search Start : %@ to %@",_word,_rcv);
    
    if (_rcv == nil){
        _rcv = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    }
    
//    [self loadingStart];
    //NSLog(@"hasDefine : %@",[UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]?@"YES":@"NO");
    
    //    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]) { //return always YES;
    
    ref = nil;
    ref = [[UIReferenceLibraryViewController alloc] initWithTerm:_word];
    
//    ref.view.backgroundColor = [UIColor redColor];
    
    // NSLog(@"%@ - %@",ref.view,ref);
    
    
//    UIKIT_EXTERN NSString *const UIContentSizeCategoryExtraSmall NS_AVAILABLE_IOS(7_0);
//    UIKIT_EXTERN NSString *const UIContentSizeCategorySmall NS_AVAILABLE_IOS(7_0);
//    UIKIT_EXTERN NSString *const UIContentSizeCategoryMedium NS_AVAILABLE_IOS(7_0);
//    UIKIT_EXTERN NSString *const UIContentSizeCategoryLarge NS_AVAILABLE_IOS(7_0);
//    UIKIT_EXTERN NSString *const UIContentSizeCategoryExtraLarge NS_AVAILABLE_IOS(7_0);
//    UIKIT_EXTERN NSString *const UIContentSizeCategoryExtraExtraLarge NS_AVAILABLE_IOS(7_0);
//    UIKIT_EXTERN NSString *const UIContentSizeCategoryExtraExtraExtraLarge NS_AVAILABLE_IOS(7_0);
    
    if ([_rcv presentedViewController] != nil) {
//        NSLog(@"modaled detected : %@",[rootVC presentedViewController]);
        [_rcv dismissViewControllerAnimated:NO completion:^{
                ref = nil;
            }];
    }
//    else {
//        NSLog(@"modaled not detected : %@",[rootVC presentedViewController]);
//
//    }
    
    lastSearchedWord = _word;
    
    [_rcv presentViewController:ref animated:YES completion:^{
        [self loadingEnd];
        
        dispatch_queue_t innerQueue = dispatch_queue_create("com.lomohome.searchEnd", NULL);

        dispatch_async(innerQueue, ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                dispatch_sync(dispatch_get_main_queue(), ^{ //UI처리등 메인스레드에서 먼가 해야할때임.
                    if (_showFirst) {
                        [self showFirstInfo];
                    }
                    
                    CGSize currentSize = [self getCurrentDeviceSizeByOrientation];
                    
                    //////////////////// TTS
                    if ([self isSpeakUse]) {
                        //                    UIView* ttsView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
                        
                        UIImageView* ttsView;
                        
                        if ([self getSpeakVoice] == 1) {
                            NSLog(@"미국식");
                            ttsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speakicon_us"]];
                        } else if ([self getSpeakVoice] == 2){
                            NSLog(@"영국식");
                            ttsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speakicon_uk"]];
                        } else if ([self getSpeakVoice] == 3){
                            NSLog(@"둘돠");
                            ttsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speakicon_usuk"]];
                        } else if ([self getSpeakVoice] == 4){
                            NSLog(@"콩글리시");
                            ttsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"speakicon_ko"]];
                        }
                        
                        
                        ttsView.frame = CGRectMake(currentSize.width/2 - 21.5, currentSize.height, 43, 38);
                        ttsView.userInteractionEnabled = YES;
                        UITapGestureRecognizer *touchGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(speakTTS)];
                        [ttsView addGestureRecognizer:touchGes];
                        
                        ttsView.tag = 772123456;
                        
                        //                    ttsView.backgroundColor = [UIColor redColor];
                        //                    [[[[[UIApplication sharedApplication] delegate] window] rootViewController].view addSubview:ttsView];
                        [ref.view insertSubview:ttsView atIndex:999999];
                        
                        [UIView animateWithDuration:0.2f animations:^{
                            ttsView.frame = CGRectMake(currentSize.width/2 - 21.5, currentSize.height - 42, 43, 38);
                        }];
                        
                        //NSLog(@"REF SUBVIEWS : %@",ref);
                    }
                    
                    if ([languageCode isEqualToString:@"ko"]) {
                        /////////////// Web Search
                        UIView* webSearchView = [[UIView alloc] init];
                        webSearchView.frame = CGRectMake(currentSize.width - 100, currentSize.height - 38, 100, 38);
                        webSearchView.backgroundColor = [UIColor clearColor];
//                        webSearchView.backgroundColor = [UIColor redColor];
                        webSearchView.userInteractionEnabled = YES;
                        
                        webSearchView.tag = 773123456;
                        
                        UITapGestureRecognizer *touchSearchGed = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webSearch)];
                        [webSearchView addGestureRecognizer:touchSearchGed];
                        
                        [ref.view insertSubview:webSearchView atIndex:999998];
                        
                        UIView* tempViewForDisable = [[UIView alloc] init];
                        tempViewForDisable.frame = CGRectMake(0, currentSize.height - 38, 100, 38);
                        tempViewForDisable.backgroundColor = [UIColor clearColor];
//                        tempViewForDisable.backgroundColor = [UIColor redColor];
                        tempViewForDisable.userInteractionEnabled = YES;
                        
                        tempViewForDisable.tag = 774123456;
                        
                        UITapGestureRecognizer *touchToDisable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disableAdding)];
                        
                        [tempViewForDisable addGestureRecognizer:touchToDisable];
                        
                        [ref.view insertSubview:tempViewForDisable atIndex:999997];
                        
        
                        
                        
                    } else {
                        //한국어가 아닐땐 디폴트 웹검색으로 연결하며, 미리 뷰를 죽여 놓는다.
                        ref = nil;
                    }
                                        
                });
                
                
                if (_saveToWordbook && ([self getWordbookOption] != 0)) { //0은 사용안함임.
                    
                    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]) {
                        
                        if ([self getWordbookOption] == 2) { //수동
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{ //UI처리등 메인스레드에서 먼가 해야할때임.
                                UIAlertView* saveAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"areyousavetowordbook", nil),lastSearchedWord] delegate:self cancelButtonTitle:NSLocalizedString(@"n", nil) otherButtonTitles:NSLocalizedString(@"y", nil), nil];
                                
                                saveAlert.tag = 78237521;
                                
                                [saveAlert show];
                            });
                            
                        } else if ([self getWordbookOption] == 1) { //자동
                            [self addWordBook:_word addDate:[NSDate date] priority:0];
                        }
                        //([self getWordbookOption] == 0) //사용안함
                    }
                }
                
//                dispatch_sync(dispatch_get_main_queue(), ^{ //UI처리등 메인스레드에서 먼가 해야할때임.
//                    
//                });
                

            });
        });
        
        
        
        
    }];
    //    }
    
    
    
}

-(void)speakTTS{
    NSLog(@"speak : %@",lastSearchedWord);
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance * utter = [AVSpeechUtterance speechUtteranceWithString:lastSearchedWord];

    NSLog(@"spped rate : %f, %f, %f",AVSpeechUtteranceMinimumSpeechRate,AVSpeechUtteranceDefaultSpeechRate,AVSpeechUtteranceMaximumSpeechRate);
    NSLog(@"speed %d -> %f",[self getSpeakSpeed],(float)[self getSpeakSpeed]/100);
    [utter setRate:(float)[self getSpeakSpeed]/100];
//    
//    if ([self getSpeakSpeed] == 1){
//        [utter setRate:AVSpeechUtteranceMinimumSpeechRate];
//    } else if ([self getSpeakSpeed] == 2){
//        [utter setRate:AVSpeechUtteranceDefaultSpeechRate];
//    } else if ([self getSpeakSpeed] == 3){
//        [utter setRate:AVSpeechUtteranceMaximumSpeechRate];
//    } else {
//        [utter setRate:AVSpeechUtteranceDefaultSpeechRate];
//    }
    
    NSString *nameRegex = @"[A-Za-z]+";
    NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    
    /**
     * "en_US\0"      "fr_FR\0"      "en_GB\0"      "de_DE\0"      "it_IT\0"      "nl_NL\0"      "nl_BE\0"      "sv_SE\0"
     "es_ES\0"      "da_DK\0"      "pt_PT\0"      "fr_CA\0"      "nb_NO\0"      "he_IL\0"      "ja_JP\0"      "en_AU\0"
     "ar\0\0\0\0"   "fi_FI\0"      "fr_CH\0"      "de_CH\0"      "el_GR\0"      "is_IS\0"      "mt_MT\0"      "el_CY\0"
     "tr_TR\0"      "hr_HR\0"      "nl_NL\0"      "nl_BE\0"      "en_CA\0"      "en_CA\0"      "pt_PT\0"      "nb_NO\0"
     "da_DK\0"      "hi_IN\0"      "ur_PK\0"      "tr_TR\0"      "it_CH\0"      "en\0\0\0\0"   "\0\0\0\0\0\0" "ro_RO\0"
     "grc\0\0\0"    "lt_LT\0"      "pl_PL\0"      "hu_HU\0"      "et_EE\0"      "lv_LV\0"      "se\0\0\0\0"   "fo_FO\0"
     "fa_IR\0"      "ru_RU\0"      "ga_IE\0"      "ko_KR\0"      "zh_CN\0"      "zh_TW\0"      "th_TH\0"      "\0\0\0\0\0\0"
     "cs_CZ\0"      "sk_SK\0"      "\0\0\0\0\0\0" "hu_HU\0"      "bn\0\0\0\0"   "be_BY\0"      "uk_UA\0"      "\0\0\0\0\0\0"
     "el_GR\0"      "sr_CS\0"      "sl_SI\0"      "mk_MK\0"      "hr_HR\0"      "\0\0\0\0\0\0" "de_DE\0"      "pt_BR\0"
     "bg_BG\0"      "ca_ES\0"      "\0\0\0\0\0\0" "gd\0\0\0\0"   "gv\0\0\0\0"   "br\0\0\0\0"   "iu_CA\0"      "cy\0\0\0\0"
     "en_CA\0"      "ga_IE\0"      "en_CA\0"      "dz_BT\0"      "hy_AM\0"      "ka_GE\0"      "es_XL\0"      "es_ES\0"
     "to_TO\0"      "pl_PL\0"      "ca_ES\0"      "fr\0\0\0\0"   "de_AT\0"      "es_XL\0"      "gu_IN\0"      "pa\0\0\0\0"
     "ur_IN\0"      "vi_VN\0"      "fr_BE\0"      "uz_UZ\0"      "en_SG\0"      "nn_NO\0"      "af_ZA\0"      "eo\0\0\0\0"
     */
    
    if ([nameTest evaluateWithObject:lastSearchedWord]) {
        //영문입력일때만 영어발음
        NSLog(@"영어!");
        if ([self getSpeakVoice] == 1) {
            NSLog(@"미국식");
            [utter setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]];
        } else if ([self getSpeakVoice] == 2){
            NSLog(@"영국식");
            [utter setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
        } else if ([self getSpeakVoice] == 3){
            NSLog(@"둘돠");
            [utter setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"]];
            [synthesizer speakUtterance:utter];
            
            [self speakTTSSecond];
            
        } else if ([self getSpeakVoice] == 4){
            NSLog(@"콩글리시");
            [utter setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"ko-KR"]];
        }
        
    }
    
    if ([self getSpeakVoice] != 3){
        [synthesizer speakUtterance:utter];
    }
    
    
}

-(void)speakTTSSecond{
    if ([self getSpeakVoice] == 3){
        
        
        dqueue = dispatch_queue_create("com.lomohome.speaksecond", NULL);
        //    dispatch_semaphore_t exeSignal = dispatch_semaphore_create(2); //한번에 두개의 스레드만 실행
        
        dispatch_async(dqueue, ^{
            //        dispatch_semaphore_wait(exeSignal, DISPATCH_TIME_FOREVER); //semaphoere 실행시 자신의 실행순서가 되었는지 wait
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [NSThread sleepForTimeInterval:0.7f];
                
                NSLog(@"speak : %@",lastSearchedWord);
                
                AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
                AVSpeechUtterance * utter = [AVSpeechUtterance speechUtteranceWithString:lastSearchedWord];
                
                NSLog(@"spped rate : %f, %f, %f",AVSpeechUtteranceMinimumSpeechRate,AVSpeechUtteranceDefaultSpeechRate,AVSpeechUtteranceMaximumSpeechRate);
                NSLog(@"speed %d -> %f",[self getSpeakSpeed],(float)[self getSpeakSpeed]/100);
                [utter setRate:(float)[self getSpeakSpeed]/100];
                
                
                NSString *nameRegex = @"[A-Za-z]+";
                NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
                
                if ([nameTest evaluateWithObject:lastSearchedWord]) {
                    [utter setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"]];
                    [synthesizer speakUtterance:utter];
                    
                }
                
            });
        });
        
        
        
    }
}

-(void)webSearch{
    NSLog(@"websearch : %@",lastSearchedWord);
    
    UIActionSheet* acSt = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"WebSearchTitle", nil),lastSearchedWord] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"naver_dic", nil)
                                             otherButtonTitles:
                           NSLocalizedString(@"daum_dic", nil),
                           NSLocalizedString(@"google", nil),
                           nil];
    acSt.tag = 12457384;
    
//    [acSt showInView:[[[UIApplication sharedApplication].delegate window] rootViewController].view];
    [acSt showInView:ref.view];
    
}

-(void)orientationDefineMaterials{
    NSLog(@"moving moving");
    if (ref){
        NSLog(@"moving moving ref");
        CGSize currentSize = [self getCurrentDeviceSizeByOrientation];
        
        if ([ref.view viewWithTag:772123456]){ //speak
            NSLog(@"moving moving speak");
            [ref.view viewWithTag:772123456].frame = CGRectMake(currentSize.width/2 - 21.5, currentSize.height - 42, 43, 38);
            [self printCGRect:[ref.view viewWithTag:772123456].frame withDesc:@"speak"];
        }
        
        if ([ref.view viewWithTag:773123456]){ //websearch
            NSLog(@"moving moving websearch");
            [ref.view viewWithTag:773123456].frame = CGRectMake(currentSize.width - 100, currentSize.height - 38, 100, 38);
            [self printCGRect:[ref.view viewWithTag:773123456].frame withDesc:@"websearch"];
        }
        
        if ([ref.view viewWithTag:774123456]){ //disable
            NSLog(@"moving moving disable");
            [ref.view viewWithTag:774123456].frame = CGRectMake(0, currentSize.height - 38, 100, 38);
            [self printCGRect:[ref.view viewWithTag:774123456].frame withDesc:@"disable"];
        }
    }
}

-(void)disableAdding{
    NSLog(@"disable adding!");
    
    [self showToast:@"'관리'를 한번 더 눌러주세요." duration:2.0f targetView:ref.view];
    
    [[ref.view viewWithTag:773123456] removeFromSuperview]; //websearch
    [[ref.view viewWithTag:774123456] removeFromSuperview]; //disablebtn
    
    CGSize currentSize = [self getCurrentDeviceSizeByOrientation];
    
    [UIView animateWithDuration:0.2f animations:^{ //speakbtn
        [ref.view viewWithTag:772123456].frame = CGRectMake(currentSize.width/2 - 21.5, currentSize.height, 43, 38);
    } completion:^(BOOL finished) {
        [[ref.view viewWithTag:772123456] removeFromSuperview];
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 12457384){
        NSLog(@"buttonIndex : %d",buttonIndex);
        NSString *stringURL;
        
        // Encode all the reserved characters, per RFC 3986
        // (<http://www.ietf.org/rfc/rfc3986.txt>)
        NSString *encodedSubject =
        (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                               (CFStringRef)lastSearchedWord,
                                                                               NULL,
                                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                               kCFStringEncodingUTF8));
        
        if (buttonIndex == 0){ //lastSearchedWord
            stringURL  = [NSString stringWithFormat:@"http://m.search.naver.com/search.naver?query=%@&where=m_ldic&sm=msv_hty",encodedSubject];
        } else if (buttonIndex == 1){ //http://dic.daum.net/search.do?q=indic
            stringURL  = [NSString stringWithFormat:@"http://dic.daum.net/search.do?q=%@",encodedSubject];
        } else if (buttonIndex == 2){
            stringURL  = [NSString stringWithFormat:@"https://www.google.com/search?q=%@",encodedSubject];;
        } else {
            return;
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
    }
    
}


#pragma mark label utils

-(void)showFirstInfo{
    if ([defaults objectForKey:USER_DEFAULT_KEY_FiRST_INFORMATION] == nil){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"firstInfoTxt", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"confirm", nil)
                                                  otherButtonTitles:nil] ;
        [alertView show];
        
        //최초 Init 완료.
        [defaults setBool:YES forKey:USER_DEFAULT_KEY_FiRST_INFORMATION];
        [defaults synchronize];
    }
}

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
    alertView.tag = 287325;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 287325) {
        if (buttonIndex == 1) {
            
            UIView* maskView2 = [[UIView alloc] initWithFrame:windowSize];
            maskView2.backgroundColor = [UIColor blackColor];
            maskView2.alpha = 0;
            
            [[[[UIApplication sharedApplication] delegate] window] addSubview:maskView2];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(forceExit)];
            [UIView setAnimationDuration:0.7f];
            maskView2.alpha = 1;
            [UIView commitAnimations];
            
            //exit(0);
        }
    } else if (alertView.tag == 78237521){
        if (buttonIndex == 1) {
            NSLog(@"MANuAL SAVE : %@",lastSearchedWord);
            [self addWordBook:lastSearchedWord addDate:[NSDate date] priority:0];
        }
    }
	
}

-(void)forceExit{
    NSLog(@"force exit");
    exit(0);
}

-(CGRect)getSwitchFrameWith:(UISwitch*)_switch cellView:(UIView*)_cellView{
    
    CGSize currentSize = [self getCurrentDeviceSizeByOrientation];
    
    NSLog(@"switch device width!! : %f",currentSize.width);
    
    CGRect switchFrame = CGRectMake(currentSize.width - _switch.frame.size.width-13,
                                    (_cellView.frame.size.height - _switch.frame.size.height)/2,
                                    _switch.frame.size.width,
                                    _switch.frame.size.height);
    return switchFrame;
    
}

-(void)loadingStart:(UIView *)_targetView{
    if (self.spinner == nil && [self.spinner superview] == nil){
        NSLog(@"we make loading screen at %@",_targetView);
        //화면스피너 셋팅. 로딩중을 표시하기 위함.
        CGRect baseRect = CGRectZero;
        
        if (_targetView == nil){
            baseRect = [[UIScreen mainScreen] bounds];
            
        } else {
            baseRect = _targetView.frame;
            if ([_targetView isKindOfClass:[UITableView class]]) {
                baseRect.origin.y += ((UITableView*)_targetView).contentOffset.y;
            }
        }

        //        NSLog(@"windowSize = %f, %f",windowSize.size.width,windowSize.size.height);
        self.maskView = [[UIView alloc] initWithFrame:baseRect];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0.5f;
        
        if (_targetView == nil){
                [[[[UIApplication sharedApplication] delegate] window] addSubview:self.maskView];
        } else {
            [_targetView addSubview:self.maskView];
        }
        
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setCenter:CGPointMake(baseRect.size.width/2.0, baseRect.size.height/2.0 + baseRect.origin.y)]; //화면중간에 위치하기위한 포인트.
        

        if (_targetView == nil) {
            [[[[UIApplication sharedApplication] delegate] window] addSubview:self.spinner];
        } else {
            [_targetView addSubview:self.spinner];
        }
        
        [self.spinner startAnimating];
        

    }
    
}

-(void)loadingEnd{
    
    //    NSLog(@"loading end inapp : %@ (%@)",[self.maskView superview],([self.maskView superview] == nil?@"isNULLok":@"notNULL"));
    if (self.spinner != nil && [self.spinner superview] != nil){
        self.maskView.hidden = YES;
        [self.spinner stopAnimating];
        
        [self.spinner removeFromSuperview];
        [self.maskView removeFromSuperview];

        self.spinner = nil;
        self.maskView = nil;
    }

}

-(void)showToast:(NSString*)_str duration:(CGFloat)_duration targetView:(UIView*)_view{
    UIView* toastView;
    
    CGSize currentSize = [self getCurrentDeviceSizeByOrientation];
    
    CGSize labelSize = CGSizeMake(300, 20);
    
    toastView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];

    toastView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.95];
    
    UILabel* toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, labelSize.width, labelSize.height)];
    toastLabel.backgroundColor = [UIColor clearColor];
    toastLabel.text = _str;
    
    toastLabel.textColor = [UIColor whiteColor];
    
    CGSize adjustedSize = [toastLabel sizeThatFits:labelSize];
    
    NSLog(@"adjustedSize : %f,%f == %f,%f",labelSize.width,labelSize.height,adjustedSize.width,adjustedSize.height);
    if (adjustedSize.width > labelSize.width) {
        toastLabel.adjustsFontSizeToFitWidth = YES;
        toastLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        [toastLabel sizeToFit];
    }
    
    [toastView addSubview:toastLabel];
    
    CGRect _frame = toastView.frame;
    _frame.size.width = toastLabel.frame.size.width + 20;
    
    toastView.frame = _frame;
    
    //toastView.layer.borderColor = [UIColor blackColor].CGColor;
    //toastView.layer.borderWidth = 2.0;
    toastView.layer.cornerRadius = 10.0;
    //toastView.layer.borderColor = UIColorFromRGB(0xFFFFFF).CGColor;
    //toastView.layer.borderWidth = 3;
    
    toastView.alpha = 1;
    
    [self printCGRect:toastView.frame withDesc:@"toast view"];
    
    toastView.frame = CGRectMake(currentSize.width/2-toastView.frame.size.width/2, currentSize.height*0.8-toastView.frame.size.height, toastView.frame.size.width, toastView.frame.size.height);
    
    if (_view == nil){
        _view = [[[[UIApplication sharedApplication] delegate] window] rootViewController].view;
    }
    
    [_view insertSubview:toastView atIndex:9999999];
    
    
    //    dispatch_queue_t dqueue;
    
    dqueue = dispatch_queue_create("com.lomohome.toast", NULL);
    //    dispatch_semaphore_t exeSignal = dispatch_semaphore_create(2); //한번에 두개의 스레드만 실행
    
    dispatch_async(dqueue, ^{
        //        dispatch_semaphore_wait(exeSignal, DISPATCH_TIME_FOREVER); //semaphoere 실행시 자신의 실행순서가 되었는지 wait
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [NSThread sleepForTimeInterval:_duration];
            
            dispatch_sync(dispatch_get_main_queue(), ^{ //UI처리등 메인스레드에서 먼가 해야할때임.
                [UIView animateWithDuration:0.4f animations:^{
                    toastView.alpha = 0;
                } completion:^(BOOL finished) {
                    [toastView removeFromSuperview];
                }];
                
            });
            
        });
    });
    
    
}

-(CGSize)getCurrentDeviceSizeByOrientation{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize windowSizeCurrent = [self windowSize].size;
    CGFloat baseWidth = windowSizeCurrent.width;
    CGFloat baseHeight = windowSizeCurrent.height;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight ) {
        baseWidth = windowSizeCurrent.height;
        baseHeight = windowSizeCurrent.width;
    }
    
    return CGSizeMake(baseWidth, baseHeight);;
}


#pragma mark wordBook
-(void)addWordBook:(NSString*)_word addDate:(NSDate*)_addDate priority:(int)_priority{
    WordBookObject* inObj = [[WordBookObject alloc] init];
    inObj.word = _word;
    inObj.addDate = _addDate;
    inObj.priority = _priority;
    
    [self addWordBook:inObj];
}
-(void)addWordBook:(WordBookObject*)_wordObj{
    
    NSMutableArray* result = [self getWordbooksFromCache];

    _wordObj.idx = [self getMaxIdxFromWordBook];
    
    for (WordBookObject *_wObj in result) {
        if ([[_wObj.word lowercaseString] isEqualToString:[_wordObj.word lowercaseString]]) {
            [result removeObject:_wObj];
            break;
        }
    }
    
#ifdef LITE
    if ([result count] >= 10) { //10개 이상이면 삭제.
        [result removeObjectAtIndex:0];
    }
#endif
    
    [result addObject:_wordObj];
    
    cachedWordBook = [NSMutableArray arrayWithArray:result];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:result] forKey:USER_DEFAULT_KEY_WORDBOOK_ARY];
    [defaults synchronize];
    
}
-(void)deleteWordBook:(int)_idx{
    
    NSMutableArray* result = [self getWordbooks];
    
    for (WordBookObject *_wObj in result) {
        if (_wObj.idx == _idx) {
            [result removeObject:_wObj];
            break;
        }
    }
    
    cachedWordBook = [NSMutableArray arrayWithArray:result];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:result] forKey:USER_DEFAULT_KEY_WORDBOOK_ARY];
    [defaults synchronize];
    
}

-(void)deleteAllWordBook{
    cachedWordBook = [[NSMutableArray alloc] init];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:cachedWordBook] forKey:USER_DEFAULT_KEY_WORDBOOK_ARY];
    [defaults synchronize];
}

-(NSMutableArray*)getWordbooks{
    NSMutableArray* result = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:USER_DEFAULT_KEY_WORDBOOK_ARY]];

    //NSLog(@"getWordbooks SUCCESS : %@",[result description]);
    return result;
}

-(NSMutableArray*)getWordbooksFromCache{
    
    if(cachedWordBook == nil){
        NSLog(@"memory cache is null. repetch");
        cachedWordBook = [NSMutableArray arrayWithArray:[self getWordbooks]];
    }
    
//    NSLog(@"getWordbooks from CACHE SUCCESS : %@",[cachedWordBook description]);
    NSLog(@"getWordbooks from CACHE SUCCESS : %d",[cachedWordBook count]);
    return cachedWordBook;
}

-(int)getMaxIdxFromWordBook{
    
    NSMutableArray* result = [self getWordbooksFromCache];
    
    int maxIdx = 0;
    
    for (WordBookObject *_wObj in result) {
        if (_wObj.idx >= maxIdx) {
            maxIdx = _wObj.idx;
        }
    }
    maxIdx++;
    
    NSLog(@"MAX IDX : %d",maxIdx);
    
    return maxIdx;
    
}

-(NSMutableArray*)searchInWordBook:(NSString*)_searchTxt limit:(int)_limit{
    NSMutableArray* targetAry = [self getWordbooksFromCache];
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", result];
//    BOOL result1 = [predicate evaluateWithObject:_searchTxt];
    
    int nowCnt = 0;
    
    for (WordBookObject *_wObj in targetAry) {
        NSLog(@"SEARCH IN PROGRESS... %d",nowCnt);
        
        if (contains(_wObj.word, _searchTxt)) {
            [result addObject:_wObj.word];
            nowCnt++;
            if (_limit > 0 && nowCnt >= _limit) {
                break;
            }
        }
    }
    
    NSLog(@"search[%@] result : %d",_searchTxt,[result count]);
    
    return result;
}

#pragma mark fileReading

-(void)searchInTextFile:(NSString*)_searchTxt limit:(int)_limit{
    
    
    if (lastSearchIndex > 0) {
        if ([lastSearchedWord length] < [_searchTxt length]) {
//            lastSearchIndex 유지.
            NSLog(@"계속입력중. index 유지");
        } else {
            NSLog(@"BACK SPACE!!!! index 초기화");
            lastSearchIndex = 0;
        }
    }
    
    lastSearchedWord = _searchTxt;
    
    if ([_searchTxt length] <= 0) {
        [nc postNotificationName:_NOTIFICATION_FINISH_SEARCH object:nil userInfo:[NSDictionary dictionaryWithObject:_searchTxt forKey:@"searchTxt"]];
        return;
    }
    
    NSMutableArray* targetAry = [self cachedWordList];
    
    //GCD 는 중간에 메서드 작동을 중지할수 없다 -_- 다시 NSOperation 으로 회귀
    //GCD를 이용한 멀티 스레드 시작
    //NSLog(@"dispatch : %@",dqueue);
//    dispatch_queue_t dqueue;
    
    dqueue = dispatch_queue_create("com.lomohome.searchThread", NULL);
//    dispatch_semaphore_t exeSignal = dispatch_semaphore_create(2); //한번에 두개의 스레드만 실행
    
    dispatch_async(dqueue, ^{
//        dispatch_semaphore_wait(exeSignal, DISPATCH_TIME_FOREVER); //semaphoere 실행시 자신의 실행순서가 되었는지 wait
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Seatch in Thread start");
            
            //[NSThread sleepForTimeInterval:2.0];
            
            NSMutableArray* result = [[NSMutableArray alloc] init];
            

            int nowCnt = 0;
            
            int i=0;
            
            if (lastSearchIndex == 0){
                NSString* startChar = [[_searchTxt substringToIndex:1] lowercaseString];
                NSLog(@"START CHAR : %@",startChar);
                
                //fast search cursor defending on wordlist.csv
                if ([startChar isEqualToString:@"a"]) {
                    i=0;
                } else if ([startChar isEqualToString:@"b"]) {
                    i=3776;
                } else if ([startChar isEqualToString:@"c"]) {
                    i=6859;
                } else if ([startChar isEqualToString:@"d"]) {
                    i=12343;
                } else if ([startChar isEqualToString:@"e"]) {
                    i=15704;
                } else if ([startChar isEqualToString:@"f"]) {
                    i=18156;
                } else if ([startChar isEqualToString:@"g"]) {
                    i=20514;
                } else if ([startChar isEqualToString:@"h"]) {
                    i=22401;
                } else if ([startChar isEqualToString:@"i"]) {
                    i=24601;
                } else if ([startChar isEqualToString:@"j"]) {
                    i=27283;
                } else if ([startChar isEqualToString:@"k"]) {
                    i=27852;
                } else if ([startChar isEqualToString:@"l"]) {
                    i=28441;
                } else if ([startChar isEqualToString:@"m"]) {
                    i=30341;
                } else if ([startChar isEqualToString:@"n"]) {
                    i=33752;
                } else if ([startChar isEqualToString:@"o"]) {
                    i=35117;
                } else if ([startChar isEqualToString:@"p"]) {
                    i=36669;
                } else if ([startChar isEqualToString:@"q"]) {
                    i=41356;
                } else if ([startChar isEqualToString:@"r"]) {
                    i=41623;
                } else if ([startChar isEqualToString:@"s"]) {
                    i=44627;
                } else if ([startChar isEqualToString:@"t"]) {
                    i=50770;
                } else if ([startChar isEqualToString:@"u"]) {
                    i=53629;
                } else if ([startChar isEqualToString:@"v"]) {
                    i=55728;
                } else if ([startChar isEqualToString:@"w"]) {
                    i=56772;
                } else if ([startChar isEqualToString:@"x"]) {
                    i=58129;
                } else if ([startChar isEqualToString:@"y"]) {
                    i=58163;
                } else if ([startChar isEqualToString:@"z"]) {
                    i=58343;
                }
                
            } else {
                i =  lastSearchIndex;
            }
            
            for (; i<[targetAry count]; i++) {
                NSString* curString = [targetAry objectAtIndex:i];
//            }
//            for(NSString *curString in targetAry) {
                
                //NSLog(@"SEARCH IN PROGRESS...[%d] (%@) == ([%d] %@) %d",lastSearchIndex,lastSearchedWord,i,curString,nowCnt);
                
                if (![lastSearchedWord isEqualToString:_searchTxt]) {
                    NSLog(@"USER INPUT CHANGED STOP!!!");
                    lastSearchIndex = 0;
                    break;
                }
                
                NSRange substringRange = [[curString lowercaseString] rangeOfString:[_searchTxt lowercaseString]];
                //NSLog(@"location : %d",substringRange.location);
                if (substringRange.location == 0) {
                    
                    if (nowCnt == 0) lastSearchIndex = i;
                    
                    [result addObject:curString];
                    
                    nowCnt++;
                    
                    
                    if (_limit > 0 && nowCnt >= _limit) {
                        break;
                    }
                    
                } else if (nowCnt > 0){
                    break;
                }
            }
            
            searchResultWordList = [NSMutableArray arrayWithArray:result];
            
            //NSLog(@"search end for (%@) %@",_searchTxt, [searchResultWordList description]);
            
            dispatch_sync(dispatch_get_main_queue(), ^{ //UI처리등 메인스레드에서 먼가 해야할때임.
                [nc postNotificationName:_NOTIFICATION_FINISH_SEARCH object:nil userInfo:[NSDictionary dictionaryWithObject:_searchTxt forKey:@"searchTxt"]];
            });
            
            
//            dispatch_semaphore_signal(exeSignal); //semaphore 설정시 할일 끝났으니 다음스레드 실행하라고 신호보냄
        });
    });
    
    //dispatch_release(dqueue); //ARC에선 릴리즈 필요없음.
    //GCD를 이용한 멀티 스레드 끝.
    
    //NSLog(@"result is %@",[searchResultWordList description]);
    
    //return result;
    
    
//    NSInvocationOperation* operation = [[NSInvocationOperation alloc]
//                                        initWithTarget:self
//                                        selector:@selector(asyncCacheWordList)
//                                        object:nil];
//    [queue addOperation:operation];
    
    
}


-(void)requestAsyncCacheWordList{

//    [queue setMaxConcurrentOperationCount:1];
    NSLog(@"----------------> Async cache request!!!!!!!");
    NSInvocationOperation* operation = [[NSInvocationOperation alloc]
                 initWithTarget:self
                 selector:@selector(asyncCacheWordList)
                 object:nil];
    [queue addOperation:operation];
     
    //[self asyncCacheWordList];
}

-(void)asyncCacheWordList{
    @synchronized(self)     {
		if(cachedWordList == nil){
            NSMutableArray* result = [[NSMutableArray alloc] init];
            
//            NSString *__documentPath;
//            if (__documentPath==nil)
//            {
//                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                     NSUserDomainMask, YES);
//                __documentPath = [paths objectAtIndex:0];
//                
//            }
            //    NSString* pathToMyFile = [__documentPath stringByAppendingPathComponent:@"5desk.txt" ];
            
            NSString *__resourcePath = [[NSBundle mainBundle] resourcePath];
            
            NSString* pathToMyFile = [__resourcePath stringByAppendingPathComponent:@"wordlist.csv" ];
            
            NSLog(@"----------------> pathToMyFile : %@",pathToMyFile);
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:pathToMyFile];
            NSLog(@"TOTAL LENGTH : %llu",[reader totalFileLength]);
            [reader enumerateLinesUsingBlock:^(NSString * line, BOOL * stop) {
                //[self showFileLoadProgress:];
                //[self performSelectorOnMainThread:@selector(showFileLoadProgress:) withObject:[NSNumber numberWithFloat:((float)[reader currentOffset] / (float)[reader totalFileLength] * 100)] waitUntilDone:NO];
                [result addObject:line];
            }];
            
            NSLog(@"----------------> memory cache word list is null. repetched (%d)",[result count]);
            
            cachedWordList = [NSMutableArray arrayWithArray:result];
            
//            [self readFinishToMainThread];
            
            ///////////////////DEV/////////////////
            
            //[self createIndexForDev];
//            [self detectNoWord];
            
            ///////////////////DEV/////////////////
            
            
            [self performSelectorOnMainThread:@selector(readFinishToMainThread) withObject:nil waitUntilDone:NO];
            
        }
        
//        else {
//            NSLog(@"----------------> cachedWordList already loaded!");
//        }
	}
}

-(NSMutableArray*)cachedWordList{
    if(cachedWordList == nil){
        [self requestAsyncCacheWordList];
    }
    NSLog(@"----------------> cached word list : %d",[cachedWordList count]);
    return cachedWordList;
}

-(void)readFinishToMainThread{
    [nc postNotificationName:_NOTIFICATION_FINISH_READ_DIC_FILE object:nil];
}

-(void)showFileLoadProgress:(NSNumber*)_progress{
    
    float fProgress = [_progress floatValue];
    
    if (self.progress == nil && [self.progress superview] == nil){
       
        NSLog(@"we make progress");
        windowSize = [[UIScreen mainScreen] bounds];
        
        self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        self.progress.frame = CGRectMake(0 , 50, windowSize.size.width, 20);
        self.progress.backgroundColor = [UIColor redColor];
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.progress];
        
    } else {
        if (fProgress < 100) {
            //NSLog(@"%f",fProgress);
            self.progress.progress = fProgress;
        } else {
            if (self.progress != nil && [self.progress superview] != nil){
                NSLog(@"%f : finish!!",fProgress);
                [self.progress removeFromSuperview];
                self.progress = nil;
            }
        }
        
    }
    
}

/*
 //NETWORK 파일 다운로딩 프로그레스.

-(void)downloadShowingProgress
{
    progress.progress = 0.0;
    
    currentURL=@"http://www.selab.isti.cnr.it/ws-mate/example.pdf";
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:currentURL]];
    AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MY_FILENAME_WITH_EXTENTION.pdf"];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        progress.progress = (float)totalBytesRead / totalBytesExpectedToRead;
        
    }];
    
    [operation setCompletionBlock:^{
        NSLog(@"downloadComplete!");
        
    }];
    [operation start];
    
}

-(void)downloadWithNsurlconnection
{
    
    NSURL *url = [NSURL URLWithString:currentURL];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    receivedData = [[NSMutableData alloc] initWithLength:0];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self     startImmediately:YES];
    
    
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    progress.hidden = NO;
    [receivedData setLength:0];
    expectedBytes = [response expectedContentLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    float progressive = (float)[receivedData length] / (float)expectedBytes;
    [progress setProgress:progressive];
    
    
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:    (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:[currentURL stringByAppendingString:@".mp3"]];
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [receivedData writeToFile:pdfPath atomically:YES];
    progress.hidden = YES;
}

*/

/*
#pragma mark DIC DEV
-(void)createIndexForDev{
    NSMutableArray* targetAry = [self cachedWordList];
    
    NSString* firstChar = nil;
    
    int tempIdx = 0;
    
    NSString* sourceCode = @"";
    
    for (NSString* word in targetAry) {
        if (firstChar == nil || ![firstChar isEqualToString:[[word substringToIndex:1] lowercaseString]]) {
            firstChar = [[word substringToIndex:1] lowercaseString];
            
            if ([sourceCode isEqualToString:@""]) {
                
                sourceCode = [sourceCode stringByAppendingString:[NSString stringWithFormat:@"if ([startChar isEqualToString:@\"%@\"]) {\n",firstChar]];
                sourceCode = [sourceCode stringByAppendingString:[NSString stringWithFormat:@"\ti=%d;\n",tempIdx]];
            } else {
                sourceCode = [sourceCode stringByAppendingString:[NSString stringWithFormat:@"} else if ([startChar isEqualToString:@\"%@\"]) {\n",firstChar]];
                sourceCode = [sourceCode stringByAppendingString:[NSString stringWithFormat:@"\ti=%d;\n",tempIdx]];
            }
        }
        tempIdx++;
    }
    sourceCode = [sourceCode stringByAppendingString:@"}"];
    
    NSLog(@"created sourcode\n%@",sourceCode);

}

-(void)detectNoWord{
    NSMutableArray* targetAry = [self cachedWordList];
    
    int tempIdx = 0;
    int allIdx = 0;

    NSLog(@"=============== START =================== ");
    int i=0;//8yj23100+22800;
    for ( ; i<[targetAry count]; i++) {
        NSString* word = [targetAry objectAtIndex:i];
        allIdx++;
        
        if (![UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:word]) {
            tempIdx++;
            NSLog(@"%d ---->,%@,# : %d",tempIdx,word,allIdx);
            
        }
        
        
    }
    
    NSLog(@"=============== FINISH =================== ");

}
    */
@end
