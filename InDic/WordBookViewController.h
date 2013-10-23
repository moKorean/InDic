//
//  WordBookViewController.h
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordBookObject.h"

@interface WordBookViewController : UITableViewController{
    NSDateFormatter* dateFormatter;
    
    NSMutableArray* wordbookData;
    
    UIBarButtonItem *editBtn,*doneBtn;
    
    //TODO: 인덱스를 붙이자.
}

@end

/**
 뭔가 뒤에서 자동으로 똑똑한척하며 장난을 치는데,
 
 self.automaticallyAdjustsScrollViewInsets = NO;
 
 이렇게 하고 저는 수동으로 모두 처리했습니다.
 기본적으로 scrollView 포함한 webView나 tableView는 scrollView.view.frame = self.view.bounds;
 해주고 contentInset와 scrollIndicatorInsets 만 적절히 할당해주면 처리가 되더군요.
*/