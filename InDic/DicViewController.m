//
//  DicViewController.m
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "DicViewController.h"

#ifdef LITE
#import "GlobalADController.h"
#endif

#define TABbarSize 49.0f
#define TABbarSizeIPAD 56.0f

@interface DicViewController ()

@end

@implementation DicViewController
@synthesize dicInput;
@synthesize searchBtn;
@synthesize searchLabel;

-(id)init{
    self = [super init];
    if (self){
        //init
        
        self.view.backgroundColor = [UIColor whiteColor];
//        self.view.backgroundColor = [UIColor blueColor];
        
//        self.view.frame = CGRectMake(0, 0, self.view.frame.size.height - , 100);
        
        self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, [AppSetting sharedAppSetting].windowSize.size.width - 20, 60)];
        

        self.searchLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.searchLabel.numberOfLines = 0;
        self.searchLabel.font = [UIFont systemFontOfSize:25];
//        self.searchLabel.textColor = UIColorFromRGB(0x007aff);

        self.searchLabel.text = NSLocalizedString(@"Search Text", nil);
//        self.searchLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [self.searchLabel sizeToFit];
        [self.view addSubview:self.searchLabel];
        
        self.dicInput = [[UITextField alloc] initWithFrame:CGRectMake(self.searchLabel.frame.origin.x, self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height + 20, [AppSetting sharedAppSetting].windowSize.size.width - 100, 30)];
        self.dicInput.delegate = self;
        self.dicInput.keyboardType = UIKeyboardTypeDefault;
        self.dicInput.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.dicInput.borderStyle = UITextBorderStyleNone;
        self.dicInput.clearButtonMode = UITextFieldViewModeAlways;
        self.dicInput.returnKeyType = UIReturnKeySearch;
        self.dicInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.dicInput.placeholder = NSLocalizedString(@"Word placeholder", nil);
        [self.dicInput addTarget:self action:@selector(textFieldChanged) forControlEvents:UIControlEventEditingChanged];

//        self.dicInput.acc
        
        [self.view addSubview:self.dicInput];
        
        underline = [[UIView alloc] initWithFrame:CGRectMake(self.dicInput.frame.origin.x, self.dicInput.frame.origin.y + self.dicInput.frame.size.height, self.dicInput.frame.size.width, 1)];
        underline.backgroundColor = [UIColor blackColor];
        [self.view addSubview:underline];
        
        UISwipeGestureRecognizer *keyDownG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(keyDown)];
        keyDownG.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:keyDownG];
        
        UISwipeGestureRecognizer *keyUpG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(keyUp)];
        keyUpG.direction = UISwipeGestureRecognizerDirectionUp;
        [self.view addGestureRecognizer:keyUpG];
        
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyUp) name:_NOTIFICATION_SHOW_DIC_KEYBOARD object:nil];
        [nc addObserver:self selector:@selector(pasteFromClipboard) name:_NOTIFICATION_PASTE_FROM_CLIPBOARD object:nil];
        
        [nc addObserver:self selector:@selector(orientationChange) name:_NOTIFICATION_ORIENTATION_CHANGE object:nil];
        
        [nc addObserver:self
               selector:@selector(keyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
        
        self.searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.searchBtn.frame = CGRectMake(self.dicInput.frame.origin.x + self.dicInput.frame.size.width + 0, self.dicInput.frame.origin.y, 80, self.dicInput.frame.size.height);
        [self.searchBtn setTitle:NSLocalizedString(@"Search Btn", nil) forState:UIControlStateNormal];
//        [self.searchBtn setBackgroundColor:[UIColor redColor]];
        [self.searchBtn addTarget:self action:@selector(defineWord) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.searchBtn];

        
        swipeInfo = [[UILabel alloc] initWithFrame:CGRectMake(self.dicInput.frame.origin.x , self.view.frame.size.height - TABbarSize - 30, [AppSetting sharedAppSetting].windowSize.size.width - 20, 30)];
        
        if ([AppSetting sharedAppSetting].isIPad) {
            swipeInfo.frame = CGRectMake(self.dicInput.frame.origin.x , self.view.frame.size.height - TABbarSizeIPAD - 30, [AppSetting sharedAppSetting].windowSize.size.width - 20, 30);
        }

#ifdef LITE
        CGRect temp1 = swipeInfo.frame;
        
        NSLog(@"GLOBAL AD HEIGHT : %f",[GlobalADController sharedController].getADRect.size.height);
        
        temp1.origin.y -= [GlobalADController sharedController].getADRect.size.height;
        swipeInfo.frame = temp1;
#endif
        
        swipeInfo.numberOfLines = 1;
        swipeInfo.font = [UIFont systemFontOfSize:10];
        swipeInfo.adjustsFontSizeToFitWidth = YES;
        //swipeInfo.backgroundColor = [UIColor redColor];
        
        swipeInfo.text = NSLocalizedString(@"Swipe Info Text", nil);
        //[swipeInfo sizeToFit];
        [self.view addSubview:swipeInfo];
        
        swipeInfoBG = [[UIView alloc] initWithFrame:CGRectMake(0, swipeInfo.frame.origin.y, [AppSetting sharedAppSetting].windowSize.size.width, 30)];
        swipeInfoBG.backgroundColor = UIColorFromRGB(0xd8dbe0);
        [self.view insertSubview:swipeInfoBG belowSubview:swipeInfo];
        
        searchResultView = nil;
        hideSearchInfo = NO;
        
        [self repositionControls:NO];
        
        [[AppSetting sharedAppSetting] printCGRect:self.view.frame withDesc:@"init frame"];
        
        isKeyboardOpen = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self pasteFromClipboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"DicView will appear");
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([AppSetting sharedAppSetting].isAutoKeyboard) {
        [self keyUp];
    }
}

-(void)pasteFromClipboard{
    if ([AppSetting sharedAppSetting].isAutoClipboard) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if (pasteboard.string.length > 0) {
            self.dicInput.text = pasteboard.string;
        }
    }
    
    if ([AppSetting sharedAppSetting].isAutoKeyboard) {
        [self keyUp];
    }
}

-(void)keyUp{
    [self.dicInput becomeFirstResponder];
}

-(void)keyDown{
    [self.dicInput resignFirstResponder];
}

#pragma mark DIC
-(void)defineWord{ //:(NSString*)_word
    
    NSString *_word = self.dicInput.text;
    
    NSLog(@"Search Start : %@",_word);
    
    if (_word.length == 0) {
        [self keyDown];
        return;
    }
    
    [[AppSetting sharedAppSetting] loadingStart];
    //NSLog(@"hasDefine : %@",[UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]?@"YES":@"NO");
    
    
//    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]) { //return always YES;
        UIReferenceLibraryViewController* ref = [[UIReferenceLibraryViewController alloc] initWithTerm:_word];
        
        [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:ref animated:YES completion:^{
                [[AppSetting sharedAppSetting] loadingEnd];
                [[AppSetting sharedAppSetting] showFirstInfo];
            }];
//    }
    
    [[AppSetting sharedAppSetting] addWordBook:_word addDate:[NSDate date] priority:0];
    
    
}

#pragma mark UITextField
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
//    textField.selectedTextRange = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
}

-(void)textFieldChanged{    //addTarget 으로 텍스트 변경시마다 호출.
    NSLog(@"textFieldChanged : %@",self.dicInput.text);
    
    if (oneTimer == nil && [AppSetting sharedAppSetting].isSuggestFromWorkbook) {
        oneTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(repositionControls:) userInfo:@YES repeats:NO];
    }
}

//한글일땐 문제가 있다.
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSString* candidateString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSLog(@"in : %@",candidateString);
// 
//    
//    [self repositionControls:string];
//    return YES;
//}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
//
//- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
              // called when 'return' key pressed. return NO to ignore.
    
    [self defineWord];//:textField.text];
    
    [self keyDown];
    
    return YES;
}

#pragma mark orientation
-(void)orientationChange{
    [self repositionControls:NO];
}

-(void)repositionControls:(BOOL)_searchMode{
    
    NSLog(@"SearchMode : %@",(_searchMode)?@"Y":@"N");
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //NSLog(@"orientation change to %d",orientation);
    
    CGFloat baseY,searchY,marginBetween,baseWidth,baseHeight;
    
    baseY = 40;
    marginBetween = 20;
    
    baseWidth = [AppSetting sharedAppSetting].windowSize.size.width;
    baseHeight = [AppSetting sharedAppSetting].windowSize.size.height;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight ) {
        baseY = 20;
        marginBetween = 7;
        
        baseWidth = [AppSetting sharedAppSetting].windowSize.size.height;
        baseHeight = [AppSetting sharedAppSetting].windowSize.size.width;
    }
    
    int buttonIdx = 0;
    
    if (_searchMode && [AppSetting sharedAppSetting].isSuggestFromWorkbook) {
        
        NSMutableArray* searchResult = [[AppSetting sharedAppSetting] searchInWordBook:self.dicInput.text limit:15];
        if (searchResultView == nil) {
            searchResultView = [[UIView alloc] initWithFrame:CGRectMake(10, underline.frame.origin.y + underline.frame.size.height + 10, baseWidth - 20, 300)];
            //searchResultView.backgroundColor = [UIColor redColor];
        } else {
            [[searchResultView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
        }
        //searchResultView.alpha = 0;
        searchResultView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if ([searchResult count] > 0) {
            hideSearchInfo = YES;
            
            buttonIdx = 0;
            for (WordBookObject *_wObj in searchResult) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn.frame = CGRectMake(0, 30*buttonIdx, baseWidth-20, 30);
                //btn.backgroundColor = [UIColor blueColor];
                [btn setTitle:_wObj.word forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont italicSystemFontOfSize:15];
                btn.titleLabel.textColor = UIColorFromRGB(0x007aff);
                btn.userInteractionEnabled = YES;
                [btn addTarget:self action:@selector(labelTab:) forControlEvents:UIControlEventTouchUpInside];
                
                //UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTab:)];
                //[btn addGestureRecognizer:tapGesture];
                [searchResultView addSubview:btn];
                buttonIdx++;
            }
            

            
        }
        
//        else {
//            
//            hide = NO;
//        }
        
        if (self.dicInput.text.length == 0) {
            hideSearchInfo = NO;
        }
        
    } else {
        hideSearchInfo = NO;
    }
    
//    self.searchLabel.backgroundColor = [UIColor redColor];
//    self.dicInput.backgroundColor = [UIColor yellowColor];
//    self.searchBtn.backgroundColor = [UIColor purpleColor];
//    underline.backgroundColor = [UIColor blueColor];
//    swipeInfo.backgroundColor = [UIColor greenColor];
    
    if(hideSearchInfo){
        //self.searchLabel.hidden = YES;
        //self.searchLabel.alpha = 1;
        searchY = baseY;
//        swipeInfo.hidden = YES;
//        swipeInfoBG.hidden = YES;
    } else {
//        self.searchLabel.hidden = NO;
        //self.searchLabel.alpha = 0;
        searchY = baseY + self.searchLabel.frame.size.height + marginBetween;
//        swipeInfo.hidden = NO;
//        swipeInfoBG.hidden = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        
        
        self.searchLabel.frame = CGRectMake(10,
                                                                                       baseY,
                                                                                       baseWidth - 20,
                                                                                       60);
        
        self.dicInput.frame = CGRectMake(self.searchLabel.frame.origin.x,
                                         searchY,
                                         baseWidth - 100,
                                         30);
        
        self.searchBtn.frame = CGRectMake(self.dicInput.frame.origin.x + self.dicInput.frame.size.width + 0,
                                          searchY,
                                          80,
                                          self.dicInput.frame.size.height);
        
        underline.frame = CGRectMake(self.dicInput.frame.origin.x,
                                     searchY + self.dicInput.frame.size.height,
                                     self.dicInput.frame.size.width,
                                     1);
        
        if (!isKeyboardOpen){
            if ([AppSetting sharedAppSetting].isIPad){
                swipeInfo.frame = CGRectMake(self.dicInput.frame.origin.x ,
                                             baseHeight-30-TABbarSizeIPAD,
                                             baseWidth - 20,
                                             30);
            } else {
                swipeInfo.frame = CGRectMake(self.dicInput.frame.origin.x ,
                                             baseHeight-30-TABbarSize,
                                             baseWidth - 20,
                                             30);
            }
            
#ifdef LITE
            CGRect temp1 = swipeInfo.frame;
            
            NSLog(@"GLOBAL AD HEIGHT : %f",[GlobalADController sharedController].getADRect.size.height);
            
            temp1.origin.y -= [GlobalADController sharedController].getADRect.size.height;
            swipeInfo.frame = temp1;
#endif
            
            swipeInfoBG.frame = CGRectMake(0, swipeInfo.frame.origin.y, baseWidth, 30);
        }
        
        if ([AppSetting sharedAppSetting].isSuggestFromWorkbook) {
            if (hideSearchInfo) {
                NSLog(@"Show search result");
                self.searchLabel.alpha = 0;
                swipeInfo.alpha = 0;
                swipeInfoBG.alpha = 0;
                
                //searchResultView.alpha = 1;
                if (searchResultView != nil){
                    searchResultView.frame = CGRectMake(self.dicInput.frame.origin.x, underline.frame.origin.y + underline.frame.size.height + 10, baseWidth - 20, (buttonIdx * 30));
                    [self.view addSubview:searchResultView];
                }
                
            } else {
                NSLog(@"hide search result");
                self.searchLabel.alpha = 1;
                swipeInfo.alpha = 1;
                swipeInfoBG.alpha = 1;
                
                //searchResultView.alpha = 0;
                if (searchResultView != nil){
                    [[searchResultView subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
                    [searchResultView removeFromSuperview];
                    searchResultView = nil;
                }
            }
        }
    
    } completion:^(BOOL finished) {
        oneTimer = nil;
    }];
    

}

-(void)labelTab:(id)_sel{
    UIButton* clicked = (UIButton*)_sel;
    NSLog(@"labelTab : %@ [%@] ",_sel,clicked.titleLabel.text);
    
    self.dicInput.text = clicked.titleLabel.text;
    [self defineWord];
}

- (void)keyboardDidShow:(NSNotification *)note {
    NSLog(@"KeyShow!");
    
    isKeyboardOpen = YES;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //NSLog(@"orientation change to %d",orientation);
    
    CGFloat baseWidth;
    
    
    baseWidth = [AppSetting sharedAppSetting].windowSize.size.width;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight ) {
        
        baseWidth = [AppSetting sharedAppSetting].windowSize.size.height;
    }

    

    //3.1.x 와 4.0 호환 키보드 붙이기
    for( UIWindow *keyboardWindow in [[UIApplication sharedApplication] windows] ){
        for( UIView *keyboard in [keyboardWindow subviews] ){
            NSString *desc = [keyboard description];
            if( [desc hasPrefix:@"<UIKeyboard"]==YES ||
               [desc hasPrefix:@"<UIPeripheralHostView"] == YES ||
               [desc hasPrefix:@"<UISnap"] == YES )
            {
                //NSLog(@"keyboard rect %f,%f,%f,%f",keyboard.frame.origin.x,keyboard.frame.origin.y,keyboard.frame.size.width,keyboard.frame.size.height);
                
                
                [UIView animateWithDuration:0.2f animations:^{
                
                    swipeInfo.frame = CGRectMake(10 ,
                                                 keyboard.frame.origin.y-30,
                                                 baseWidth - 20,
                                                 30);
                    
                    swipeInfoBG.frame = CGRectMake(0, swipeInfo.frame.origin.y, baseWidth, 30);
                    
                }];
                
                
                return;
            }
        }
    }
    
}

- (void)keyboardWillHide:(NSNotification *)note {
    NSLog(@"KeyHide!");
    
    isKeyboardOpen = NO;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //NSLog(@"orientation change to %d",orientation);
    
    CGFloat baseWidth;
    
    
    baseWidth = [AppSetting sharedAppSetting].windowSize.size.width;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight ) {
        
        baseWidth = [AppSetting sharedAppSetting].windowSize.size.height;
    }
    
    
    [UIView animateWithDuration:0.2f animations:^{
        swipeInfo.frame = CGRectMake(10 ,
                                     self.view.frame.size.height - 30,
                                     baseWidth - 20,
                                     30);
        
#ifdef LITE
//        CGRect temp1 = swipeInfo.frame;
//        
        NSLog(@"GLOBAL AD HEIGHT : %f",[GlobalADController sharedController].getADRect.size.height);
        [[AppSetting sharedAppSetting] printCGRect:self.view.frame withDesc:@"SELFVIEWWWW"];
//        
//        temp1.origin.y -= [GlobalADController sharedController].getADRect.size.height;
//        swipeInfo.frame = temp1;
#endif
        
        swipeInfoBG.frame = CGRectMake(0, swipeInfo.frame.origin.y, baseWidth, 30);
    }];
    
    
    /*
    for (UIWindow *keyboardWindow in [[UIApplication sharedApplication] windows]) {
        for (UIView *keyboard in [keyboardWindow subviews]) {
            NSString *desc = [keyboard description];
            if ([desc hasPrefix:@"<UIKeyboard"] == YES || [desc hasPrefix:@"<UIPeripheralHostView"] == YES || [desc hasPrefix:@"<UISnap"] == YES) {
                for(UIView *subview in [keyboard subviews]) {
                    //[subview removeFromSuperview];
                }
            }
        }
    }
    */
    //[nc removeObserver:self];
}


@end
