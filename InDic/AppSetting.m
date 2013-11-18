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
#define USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK @"bundleManualSaveToWordBook"
#define USER_DEFAULT_KEY_FIRST_OPEN_TAB @"bundleFirstOpenTab"

#define USER_DEFAULT_KEY_FiRST_INITED @"bundleFirstInited"
#define USER_DEFAULT_KEY_FiRST_INFORMATION @"bundleFirstInfo"


#define USER_DEFAULT_KEY_WORDBOOK_ARY @"bundleWordBook"

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)


@implementation AppSetting

@synthesize deviceType;
@synthesize windowSize;
@synthesize languageCode;
@synthesize progress;
@synthesize searchResultWordList;

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
        
        cachedWordBook = nil;
        
        [self checkDefaultValue];
        
        queue = [NSOperationQueue new];
        
        //Async 로 파일을 메모리에 로드해둔다.
        [self requestAsyncCacheWordList];
        
        searchResultWordList = [NSMutableArray new];
        
        lastSearchedWord = nil;
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
    if ([defaults objectForKey:USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK] == nil) [self setManualSaveToWordBook:NO];
    if ([defaults objectForKey:USER_DEFAULT_KEY_FIRST_OPEN_TAB] == nil) [self setFirstOpenTab:1];
    
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

-(BOOL)isManualSaveToWordBook{
    return [defaults boolForKey:USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK];
}

-(void)setManualSaveToWordBook:(BOOL)_bo{
    [defaults setBool:_bo forKey:USER_DEFAULT_KEY_MANUAL_SAVE_TO_WORDBOOK];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 isManualSaveToWordBook : %@",([self isManualSaveToWordBook]?@"YES":@"NO"));
}

-(NSInteger)getFirstOpenTab{
    return [defaults integerForKey:USER_DEFAULT_KEY_FIRST_OPEN_TAB];
}
-(void)setFirstOpenTab:(NSInteger)_tab{
    [defaults setInteger:_tab forKey:USER_DEFAULT_KEY_FIRST_OPEN_TAB];
    [defaults synchronize];
    NSLog(@"다음값으로 값 재설정 getFirstOpenTab : %d",[self getFirstOpenTab]);
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
-(void)defineWord:(NSString*)_word isShowFirstInfo:(BOOL)_showFirst isSaveToWordBook:(BOOL)_saveToWordbook{

    NSLog(@"Search Start : %@",_word);
    
    [self loadingStart];
    //NSLog(@"hasDefine : %@",[UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]?@"YES":@"NO");
    
    
    //    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]) { //return always YES;
    UIReferenceLibraryViewController* ref = [[UIReferenceLibraryViewController alloc] initWithTerm:_word];
    
    UIViewController* rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    
    if ([rootVC presentedViewController] != nil) {
        NSLog(@"modaled detected : %@",[rootVC presentedViewController]);
        [rootVC dismissViewControllerAnimated:NO completion:nil];
    } else {
        NSLog(@"modaled not detected : %@",[rootVC presentedViewController]);

    }
    
    [rootVC presentViewController:ref animated:YES completion:^{
        [self loadingEnd];
        if (_showFirst) {
            [self showFirstInfo];
        }
        
    }];
    //    }
    
    if (_saveToWordbook) {
        
        if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]) {
            
            if ([self isManualSaveToWordBook]) {
                lastSearchedWord = _word;
                UIAlertView* saveAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"areyousavetowordbook", nil),lastSearchedWord] delegate:self cancelButtonTitle:NSLocalizedString(@"n", nil) otherButtonTitles:NSLocalizedString(@"y", nil), nil];
                
                saveAlert.tag = 78237521;
                
                [saveAlert show];
            } else {
                [self addWordBook:_word addDate:[NSDate date] priority:0];
            }
        }
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
    
    CGFloat deviceWidth = [AppSetting sharedAppSetting].windowSize.size.width;
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //NSLog(@"orientation change to %d",orientation);
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight ) {
        deviceWidth = [AppSetting sharedAppSetting].windowSize.size.height;
    }
    
    NSLog(@"switch device width!! : %f",deviceWidth);
    
    CGRect switchFrame = CGRectMake(deviceWidth - _switch.frame.size.width-13,
                                    (_cellView.frame.size.height - _switch.frame.size.height)/2,
                                    _switch.frame.size.width,
                                    _switch.frame.size.height);
    return switchFrame;
    
}

-(void)loadingStart{
    if (self.maskView == nil && [self.maskView superview] == nil){
        NSLog(@"we make loading screen");
        //화면스피너 셋팅. 로딩중을 표시하기 위함.
        windowSize = [[UIScreen mainScreen] bounds];
        //        NSLog(@"windowSize = %f, %f",windowSize.size.width,windowSize.size.height);
        self.maskView = [[UIView alloc] initWithFrame:windowSize];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.alpha = 0.5f;
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.maskView];

        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.spinner setCenter:CGPointMake(windowSize.size.width/2.0, windowSize.size.height/2.0)]; //화면중간에 위치하기위한 포인트.
        [[[[UIApplication sharedApplication] delegate] window] addSubview:self.spinner];

        
        [self.spinner startAnimating];
        

    }
    
}

-(void)loadingEnd{
    
    //    NSLog(@"loading end inapp : %@ (%@)",[self.maskView superview],([self.maskView superview] == nil?@"isNULLok":@"notNULL"));
    if (self.maskView != nil && [self.maskView superview] != nil){
        self.maskView.hidden = YES;
        [self.spinner stopAnimating];
        
        [self.spinner removeFromSuperview];
        [self.maskView removeFromSuperview];

        self.spinner = nil;
        self.maskView = nil;
    }

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
        if ([_wObj.word isEqualToString:_wordObj.word]) {
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

-(NSMutableArray*)getWordbooks{
    NSMutableArray* result = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:USER_DEFAULT_KEY_WORDBOOK_ARY]];

    NSLog(@"getWordbooks SUCCESS : %@",[result description]);
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
            
            for(NSString *curString in targetAry) {
                
                //NSLog(@"SEARCH IN PROGRESS... (%@) == (%@) %d",lastSearchedWord,curString,nowCnt);
                
                if (![lastSearchedWord isEqualToString:_searchTxt]) {
                    NSLog(@"USER INPUT CHANGED STOP!!!");
                    break;
                }
                
                NSRange substringRange = [[curString lowercaseString] rangeOfString:[_searchTxt lowercaseString]];
                if (substringRange.location == 0) {
                    [result addObject:curString];
                    
                    nowCnt++;
                    if (_limit > 0 && nowCnt >= _limit) {
                        break;
                    }
                }
            }
            
            searchResultWordList = [NSMutableArray arrayWithArray:result];
            
            NSLog(@"search end for (%@) %@",_searchTxt, [searchResultWordList description]);
            
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

@end
