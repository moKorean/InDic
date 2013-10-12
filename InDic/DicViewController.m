//
//  DicViewController.m
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "DicViewController.h"

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
        
        self.searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.searchBtn.frame = CGRectMake(self.dicInput.frame.origin.x + self.dicInput.frame.size.width + 0, self.dicInput.frame.origin.y, 80, self.dicInput.frame.size.height);
        [self.searchBtn setTitle:NSLocalizedString(@"Search Btn", nil) forState:UIControlStateNormal];
//        [self.searchBtn setBackgroundColor:[UIColor redColor]];
        [self.searchBtn addTarget:self action:@selector(defineWord) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.searchBtn];
        
        
        swipeInfo = [[UILabel alloc] initWithFrame:CGRectMake(self.dicInput.frame.origin.x , self.dicInput.frame.origin.y + self.dicInput.frame.size.height + 20, [AppSetting sharedAppSetting].windowSize.size.width - 20, 30)];
        
        swipeInfo.numberOfLines = 1;
        swipeInfo.font = [UIFont systemFontOfSize:10];
        swipeInfo.adjustsFontSizeToFitWidth = YES;
        
        swipeInfo.text = NSLocalizedString(@"Swipe Info Text", nil);
        [swipeInfo sizeToFit];
        [self.view addSubview:swipeInfo];
        
        [self orientationChange];
        
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
    
    if ([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:_word]) {
        UIReferenceLibraryViewController* ref = [[UIReferenceLibraryViewController alloc] initWithTerm:_word];
        
        [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:ref animated:YES completion:^{
                [[AppSetting sharedAppSetting] loadingEnd];
                [[AppSetting sharedAppSetting] showFirstInfo];
            }];
    }
    
    [[AppSetting sharedAppSetting] addWordBook:_word addDate:[NSDate date] priority:0];
    
    
}

#pragma mark UITextField
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
    
//    textField.selectedTextRange = [textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument];
    
}
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
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //NSLog(@"orientation change to %d",orientation);
    
    CGFloat baseY,marginBetween,baseWidth;

    baseY = 40;
    marginBetween = 20;
    
    baseWidth = [AppSetting sharedAppSetting].windowSize.size.width;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight ) {
        baseY = 20;
        marginBetween = 7;
        
        baseWidth = [AppSetting sharedAppSetting].windowSize.size.height;
    }
    
//    self.searchLabel.backgroundColor = [UIColor redColor];
//    self.dicInput.backgroundColor = [UIColor yellowColor];
//    self.searchBtn.backgroundColor = [UIColor purpleColor];
//    underline.backgroundColor = [UIColor blueColor];
//    swipeInfo.backgroundColor = [UIColor greenColor];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         
                         self.searchLabel.frame = CGRectMake(10,
                                                             baseY,
                                                             baseWidth - 20,
                                                             60);
                         
                         self.dicInput.frame = CGRectMake(self.searchLabel.frame.origin.x,
                                                          self.searchLabel.frame.origin.y + self.searchLabel.frame.size.height + marginBetween,
                                                          baseWidth - 100,
                                                          30);
                         
                         self.searchBtn.frame = CGRectMake(self.dicInput.frame.origin.x + self.dicInput.frame.size.width + 0,
                                                           self.dicInput.frame.origin.y,
                                                           80,
                                                           self.dicInput.frame.size.height);
                         
                         underline.frame = CGRectMake(self.dicInput.frame.origin.x,
                                                      self.dicInput.frame.origin.y + self.dicInput.frame.size.height,
                                                      self.dicInput.frame.size.width,
                                                      1);
                         
                         swipeInfo.frame = CGRectMake(self.dicInput.frame.origin.x ,
                                                      self.dicInput.frame.origin.y + self.dicInput.frame.size.height + marginBetween,
                                                      baseWidth - 20,
                                                      30);
                         
                     }];
    

}



@end
