//
//  DicViewController.h
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DicViewController : UIViewController <UITextFieldDelegate>{
    UITextField* dicInput;
    UIButton* searchBtn;
    
    UILabel* searchLabel;
    
    //Event 처리용 노티센터
    NSNotificationCenter *nc;
    
    UIView* underline;
    UILabel* swipeInfo;
    
    UIView* swipeInfoBG;
    
    NSTimer* oneTimer;
    UIView* searchResultView;
    BOOL hideSearchInfo;
    
    BOOL isKeyboardOpen;
    
    UIViewController* rootVC;
    
//    NSMutableArray* wordData;
}

-(void)orientationChange;
-(void)repositionControls:(BOOL)_searchMode;

@property (nonatomic, strong) UITextField *dicInput;
@property (nonatomic, strong) UIButton* searchBtn;
@property (nonatomic, strong) UILabel* searchLabel;

@end
