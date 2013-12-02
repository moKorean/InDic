//
//  SpeakSettingView.h
//  InDic
//
//  Created by moKorean on 2013. 12. 2..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpeakVoiceSettingView.h"

@interface SpeakSettingView : UITableViewController{
    
    UISlider* speedSlider;
    UISwitch* useSpeak;
    NSNotificationCenter *nc;
    
    
}

@end
