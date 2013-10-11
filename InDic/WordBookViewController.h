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
}

@end
