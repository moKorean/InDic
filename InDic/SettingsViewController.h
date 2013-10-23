//
//  SettingsViewController.h
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "LanguageSettingView.h"

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate,UIActionSheetDelegate>{

    UIView *customView;
    NSString* mokoreanEmail;
    UIDevice* curDevice;
    
    NSNotificationCenter *nc;
    
    UISwitch* autoClipboard;
    UISwitch* autoKeyboard;
    UISwitch* suggestWordbook;

}

-(void)sendBugReport;
-(void)sendBugReportViaApp;
-(void)sendBugReportViaInApp;
-(NSString*)getEmailBody;
-(void)goLomohome;
-(void)openAlert:(NSString*)_message;
- (void)switchAction:(id)sender;

@end
