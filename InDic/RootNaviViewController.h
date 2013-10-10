//
//  RootNaviViewController.h
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef LITE
#import "GlobalADController.h"
#endif

@interface RootNaviViewController : UIViewController <UINavigationControllerDelegate
#ifdef LITE
,GlobalADControllerDelegate
#endif
>{
    UIViewController* firstViewController;
    
    NSNotificationCenter *nc;
}

@property (strong, nonatomic) UIViewController* firstViewController;
@property (strong, nonatomic) UINavigationController* naviController;
@property (assign, nonatomic) int tag;

-(id)initWithFirstViewController:(UIViewController*) _firstViewController withTag:(int)_tag;

@end
