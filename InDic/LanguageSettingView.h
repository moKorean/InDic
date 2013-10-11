//
//  LanguageSettingView.h
//  EventsList
//
//  Created by Geunwon,Mo on 11. 6. 28..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LanguageSettingView : UITableViewController{
    NSString *beforeL;
    NSString *afterL;
    
}

@property (nonatomic, strong) NSString* beforeL;
@property (nonatomic, strong) NSString* afterL;


@end
