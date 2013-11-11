//
//  SettingsViewController.m
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "SettingsViewController.h"

#define SECTION_APP_INFO 0
#define SECTION_DEVELOPER_INFO 1

#define SWITCH_AUTO_KEYBOARD_TAG 742389
#define SWITCH_AUTO_CLIPBOARD_TAG 384954
#define SWITCH_WORDBOOK_WORD_SUGGESTION_TAG 759865

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(orientationChange) name:_NOTIFICATION_ORIENTATION_CHANGE object:nil];
        
        self.title = NSLocalizedString(@"tabbar_settings", nil);
        
        //커스텀 뷰를 만들어 둔다.
        customView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, [AppSetting sharedAppSetting].windowSize.size.width, 200.0f)];

        
        
        //customView.backgroundColor = [UIColor redColor];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_icon"]];
        iconView.frame = CGRectMake(0, 0, 60, 60);
        [customView addSubview:iconView];
        UILabel *labelForAppName = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 20)];
        labelForAppName.text = NSLocalizedString(@"app name", @"어플 이름");
        
#ifdef LITE
        labelForAppName.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"app name", @"어플 이름"),@" - lite"];
#endif
        
        
        labelForAppName.backgroundColor = [UIColor clearColor];
        [customView addSubview:labelForAppName];
        UILabel *labelForAppVer = [[UILabel alloc] initWithFrame:CGRectMake(70, 20, 200, 20)];
        
        NSString* version;
        // 설정에 버전 초기화
        if([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] != nil) {
            version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"] != nil) {
                version = [version stringByAppendingFormat:@"  (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"]];
            }
            
            labelForAppVer.text = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"version str", nil),version];
            labelForAppVer.font = [UIFont systemFontOfSize:13];
            
            labelForAppVer.backgroundColor = [UIColor clearColor];
            labelForAppVer.adjustsFontSizeToFitWidth = YES;
            [customView addSubview:labelForAppVer];
        }
        
        UILabel *labelForAppDesc = [[UILabel alloc] initWithFrame:CGRectMake(70, 40, 200, 20)];
        labelForAppDesc.text = NSLocalizedString(@"app desc", nil);
        labelForAppDesc.adjustsFontSizeToFitWidth = YES;
        labelForAppDesc.textColor = [UIColor grayColor];
        labelForAppDesc.font = [UIFont systemFontOfSize:13];
        labelForAppDesc.backgroundColor = [UIColor clearColor];
        [customView addSubview:labelForAppDesc];
        
        mokoreanEmail = @"mokorean+appleapp@gmail.com";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [nc postNotificationName:_NOTIFICATION_SHOW_AD object:self userInfo:nil];
    
    [self.tableView reloadData];
    //[self.view layoutSubviews];
    //self.view.backgroundColor = UIColorFromRGB(0xff0000);
    //self.tableView.backgroundColor = UIColorFromRGB(0xffcc00);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section == SECTION_DEVELOPER_INFO) return 3;
#ifdef LITE
    else if (section == SECTION_APP_INFO) return 6;
#else
    else if (section == SECTION_APP_INFO) return 5;
#endif
    else return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case SECTION_APP_INFO :
            if (indexPath.row == 0){
                return 76.0f;
            } else {
                return 39.0f;
            }
            break;
        case SECTION_DEVELOPER_INFO :
            return 39.0f;
            break;
        default:
            break;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InfoCell";
    static NSString *CellIdentifier2 = @"InfoCell2";
    
    UITableViewCell *cell;
    
    if (indexPath.section == SECTION_APP_INFO) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else if (indexPath.section == SECTION_DEVELOPER_INFO){
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
    }
    
    
    if (cell == nil) {
        if (indexPath.section == SECTION_DEVELOPER_INFO) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2];
        } else if (indexPath.section == SECTION_APP_INFO){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
    } else {
        if ([cell.contentView viewWithTag:SWITCH_AUTO_CLIPBOARD_TAG]){
            [[cell.contentView viewWithTag:SWITCH_AUTO_CLIPBOARD_TAG] removeFromSuperview];
        }
        
        if ([cell.contentView viewWithTag:SWITCH_AUTO_KEYBOARD_TAG]){
            [[cell.contentView viewWithTag:SWITCH_AUTO_KEYBOARD_TAG] removeFromSuperview];
        }
        
        if ([cell.contentView viewWithTag:SWITCH_WORDBOOK_WORD_SUGGESTION_TAG]){
            [[cell.contentView viewWithTag:SWITCH_WORDBOOK_WORD_SUGGESTION_TAG] removeFromSuperview];
        }
        
    }
    
    // Initialize cell
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    cell.imageView.image = nil;
    
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;

    int rowOffset = 0;
    
#ifdef LITE
    rowOffset++;
#endif
    
    switch (indexPath.section) {
        case SECTION_APP_INFO :

            if (indexPath.row == 0) {
                cell.userInteractionEnabled = NO;
                [cell addSubview:customView];
                break;
            }
#ifdef LITE
            else if (indexPath.row == 1) {
                //프로 버전으로 가기
                
                if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ko"]) {
                    cell.textLabel.text = @"InDic 정식버젼 구입 안내";
                } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"en"]) {
                    cell.textLabel.text = @"Show information of regular version";
                } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ja"]) {
                    cell.textLabel.text = @"正式版を購入案内";
                } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"zh-Hans"]) {
                    cell.textLabel.text = @"Show information of regular version";
                }
                
                break;
            }
#endif
            else if (indexPath.row == (1+rowOffset)) {
                //언어설정
                cell.textLabel.text = NSLocalizedString(@"language setting title", nil);
                
                if ([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ko"]) {
                    cell.detailTextLabel.text = @"한글";
                } else if ([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"en"]) {
                    cell.detailTextLabel.text = @"English";
                } else if ([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ja"]) {
                    cell.detailTextLabel.text = @"日本語";
                } else if ([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"zh-Hans"]) {
                    cell.detailTextLabel.text = @"中文 (简体)";
                }
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                break;
            } else if (indexPath.row == (2+rowOffset)) {
                //클립보드
                cell.textLabel.text = NSLocalizedString(@"setting_auto_clipboard", nil);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (autoClipboard == nil){
                    autoClipboard = [[UISwitch alloc] init];
                    [autoClipboard addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    // in case the parent view draws with a custom color or gradient, use a transparent color
                    autoClipboard.backgroundColor = [UIColor clearColor];
                    autoClipboard.tag = SWITCH_AUTO_CLIPBOARD_TAG;
                }
                autoClipboard.frame = [[AppSetting sharedAppSetting] getSwitchFrameWith:autoClipboard cellView:cell.contentView];

                autoClipboard.on = [AppSetting sharedAppSetting].isAutoClipboard;
                
                [cell.contentView addSubview:autoClipboard];
                
                break;
            } else if (indexPath.row == (3+rowOffset)) {
                //자동키보드
                cell.textLabel.text = NSLocalizedString(@"setting_auto_keyboard", nil);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (autoKeyboard == nil){
                    autoKeyboard = [[UISwitch alloc] init];
                    [autoKeyboard addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    // in case the parent view draws with a custom color or gradient, use a transparent color
                    autoKeyboard.backgroundColor = [UIColor clearColor];
                    autoKeyboard.tag = SWITCH_AUTO_KEYBOARD_TAG;
                }
                autoKeyboard.frame = [[AppSetting sharedAppSetting] getSwitchFrameWith:autoKeyboard cellView:cell.contentView];
                
                autoKeyboard.on = [AppSetting sharedAppSetting].isAutoKeyboard;
                
                [cell.contentView addSubview:autoKeyboard];
                
                break;
            } else if (indexPath.row == (4+rowOffset)) {
                //단어장 단어 자동 추천
                cell.textLabel.text = NSLocalizedString(@"setting_wordbook_word_suggestion", nil);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (suggestWordbook == nil){
                    suggestWordbook = [[UISwitch alloc] init];
                    [suggestWordbook addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    // in case the parent view draws with a custom color or gradient, use a transparent color
                    suggestWordbook.backgroundColor = [UIColor clearColor];
                    suggestWordbook.tag = SWITCH_WORDBOOK_WORD_SUGGESTION_TAG;
                }
                suggestWordbook.frame = [[AppSetting sharedAppSetting] getSwitchFrameWith:suggestWordbook cellView:cell.contentView];
                
                suggestWordbook.on = [AppSetting sharedAppSetting].isSuggestFromWorkbook;
                
                [cell.contentView addSubview:suggestWordbook];
                
                break;
            }
        case SECTION_DEVELOPER_INFO :
            
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"gwIcon"];
                cell.textLabel.text = NSLocalizedString(@"dev name", nil);
                
                cell.detailTextLabel.text = nil;
                cell.userInteractionEnabled = NO;
                break;
            } else if (indexPath.row == 1){
                cell.textLabel.text = @"http://Lomohome.com";
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.detailTextLabel.text = NSLocalizedString(@"homepage desc", nil);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
                break;
            } else if (indexPath.row == 2){
                cell.textLabel.text = @"mokorean@gmail.com";
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.detailTextLabel.text = NSLocalizedString(@"bugreport desc", nil);
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
                break;
            }
            
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIViewController *nextViewController = nil;
    
    int rowOffset = 0;
    
#ifdef LITE
    rowOffset++;
#endif
    
    // Navigation logic may go here. Create and push another view controller.
    switch (indexPath.section) {
            
        case SECTION_APP_INFO :
            if (indexPath.row == (1+rowOffset)) {
                //언어
                nextViewController = [[LanguageSettingView alloc] initWithStyle:UITableViewStyleGrouped];
            } else if (indexPath.row == (2+rowOffset)) {
                //클립보드
//                [[AppSetting sharedAppSetting] setAutoClipboard:![autoClipboard isOn]];
//                [self.tableView reloadData];
//                [self.tableView reloadSections:reloadSet withRowAnimation:UITableViewRowAnimationNone];
            } else if (indexPath.row == (3+rowOffset)){
                //자동키보드
//                [[AppSetting sharedAppSetting] setAutoKeyboard:![autoKeyboard isOn]];
//                [self.tableView reloadData];
//                [self.tableView reloadSections:reloadSet withRowAnimation:UITableViewRowAnimationNone];
            }
#ifdef LITE
            else if (indexPath.row == 1) {
                //프로 버전으로 가기
                NSString* info = nil;
                
                if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ko"]) {
                    info = @"정식버전($0.99)은 광고제거, 가로모드 지원,\n\
무제한 단어장이 제공됩니다.\n\
감사합니다\n\
앱스토어로 가시겠습니까?";
                } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"en"]) {
                    info = @"Full version($0.99) includes these features.\n\
remove Ads, support landscape mode,unlimited add wordbook\n\
Thank you\n\
Would you like to go AppStore?";
                } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ja"]) {
                    info = @"フルバージョン（¥100）は、横モードのサポートは、\n\
広告削除、無制限の単語帳があります。\n\
ありがとうございます\n\
アプリストアに行くか？";
                } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"zh-Hans"]) {
                    info = @"Full version($0.99) includes these features.\n\
                    remove Ads, support landscape mode,unlimited add wordbook\n\
                    Thank you\n\
                    Would you like to go AppStore?";
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:info
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                                          otherButtonTitles:NSLocalizedString(@"confirm", nil),nil] ;
                alertView.tag = 99884;
                [alertView show];
                
                

            }
#endif
            
            break;
            
        case SECTION_DEVELOPER_INFO :
            if (indexPath.row == 1) {
                [self goLomohome];
            } else if (indexPath.row == 2) {
                [self sendBugReport];
            }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If we got a new view controller, push it .
    if (nextViewController) {
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
}

-(void)orientationChange{
    NSIndexSet* reloadSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])];
    [self.tableView reloadData];
    [self.tableView reloadSections:reloadSet withRowAnimation:UITableViewRowAnimationNone];
}

#ifdef LITE
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99884) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                        @"https://itunes.apple.com/us/app/indic-simple-fast-dictionary/id723205033?l=ko&ls=1&mt=8"]];
        } else {
            //cancel
        }
    }
}
#endif



- (void)switchAction:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch* senderSwitch = (UISwitch*)sender;
        if (senderSwitch.tag == SWITCH_AUTO_CLIPBOARD_TAG) {
            [[AppSetting sharedAppSetting] setAutoClipboard:[senderSwitch isOn]];
        } else if (senderSwitch.tag == SWITCH_AUTO_KEYBOARD_TAG){
            [[AppSetting sharedAppSetting] setAutoKeyboard:[senderSwitch isOn]];
        
        } else if (senderSwitch.tag == SWITCH_WORDBOOK_WORD_SUGGESTION_TAG){
            [[AppSetting sharedAppSetting] setSuggestFromWordbook:[senderSwitch isOn]];
        }
    }

    /*
    NSIndexSet* reloadSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])];
    [self.tableView reloadData];
    [self.tableView reloadSections:reloadSet withRowAnimation:UITableViewRowAnimationNone];
    */
    
}

-(void)sendBugReport{
    NSLog(@"send email");
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self sendBugReportViaInApp];
		}
		else
		{
			[self sendBugReportViaApp];
		}
	}
	else
	{
		[self sendBugReportViaApp];
	}
    
}

-(void)sendBugReportViaApp{
    // 메일 APP으로 이동
    NSString *mailto = mokoreanEmail;
    NSString *cc = @"";
    
    NSString *liteStr = @"";
#ifdef LITE
    liteStr = @"-lite";
#endif
    
    NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"email subject", nil),liteStr];
    NSString *body = [self getEmailBody];
    NSString *urlFormat = [NSString stringWithFormat:@"mailto://%@?cc=%@&amp;subject=%@&amp;body=%@",mailto,cc,subject,body];
    
    NSString *stringURL = [[[NSString alloc] initWithString:urlFormat]
                           stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

-(void)sendBugReportViaInApp{
    MFMailComposeViewController *emailForm = [[MFMailComposeViewController alloc] init];
	emailForm.mailComposeDelegate = self;

    NSString *liteStr = @"";
#ifdef LITE
    liteStr = @"-lite";
#endif
    
    NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"email subject", nil),liteStr];
    
	[emailForm setSubject:subject];
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:mokoreanEmail];

	[emailForm setToRecipients:toRecipients];
    //	[emailForm setCcRecipients:ccRecipients];
    //	[emailForm setBccRecipients:bccRecipients];
	
	// Attach an image to the email
    //	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    //    NSData *myData = [NSData dataWithContentsOfFile:path];
    //	[emailForm addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
	NSString *emailBody = [self getEmailBody];
	[emailForm setMessageBody:emailBody isHTML:NO];
	
    [nc postNotificationName:_NOTIFICATION_HIDE_AD object:self userInfo:nil];

    [[[[UIApplication sharedApplication].delegate window] rootViewController] presentViewController:emailForm animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//message.text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			//message.text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			//message.text = @"Result: sent";
            [self openAlert:NSLocalizedString(@"email sent", nil)];
			break;
		case MFMailComposeResultFailed:
			//message.text = @"Result: failed";
            [self openAlert:NSLocalizedString(@"email fail", nil)];
			break;
		default:
			//message.text = @"Result: not sent";
            [self openAlert:NSLocalizedString(@"email fail", nil)];
			break;
	}
    
	//[self dismissModalViewControllerAnimated:YES];
    
    [[[[UIApplication sharedApplication].delegate window] rootViewController] dismissViewControllerAnimated:YES completion:nil];
    
    [nc postNotificationName:_NOTIFICATION_SHOW_AD object:self userInfo:nil];
}

-(NSString*)getEmailBody{
    curDevice = [UIDevice currentDevice];
    
    NSString* emailBody = [NSString stringWithFormat: @"%@\n\n\n- Device Information",NSLocalizedString(@"email body first", nil)];
    
    NSLocale *locale =[NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleIdentifier];
    
    emailBody = [emailBody stringByAppendingFormat:@"\nLocale : %@",countryCode];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    emailBody = [emailBody stringByAppendingFormat:@"\nLanguage : %@",currentLanguage];
    
    //device information
    //emailBody = [emailBody stringByAppendingFormat:@"\nUDID : %@",curDevice.uniqueIdentifier];
    emailBody = [emailBody stringByAppendingFormat:@"\nModel : %@",curDevice.model];
    emailBody = [emailBody stringByAppendingFormat:@"\niOS Version : %@ (%@)",curDevice.systemName,curDevice.systemVersion];
    
    
    
    if([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] != nil) {
		emailBody = [emailBody stringByAppendingFormat:@"\nApp Build : %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        
        if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] != nil) {
            emailBody = [emailBody stringByAppendingFormat:@"\nVersion : %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        }
        
        if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"] != nil) {
            emailBody = [emailBody stringByAppendingFormat:@"\nBuild date : %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBuildDate"]];
        }
    }
    
    return emailBody;
    
}

-(void)openAlert:(NSString*)_message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"email alert title", nil) message:_message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"confirm", nil),nil];
    [alert show];
}

-(void)goLomohome{
	//NSString *stringURL = [[NSString alloc] initWithString:@"http://lomohome.com"];
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
    
    UIActionSheet* acSt = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Where will you go?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:NSLocalizedString(@"goto str facebook", nil)
                                             otherButtonTitles:
                           NSLocalizedString(@"goto str lomohome", nil),
                           NSLocalizedString(@"goto str twitter", nil),
                           nil];
    acSt.tag = 8934734;
    
    [acSt showInView:[[[UIApplication sharedApplication].delegate window] rootViewController].view];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 8934734) {
        NSString *stringURL;
        
        if (buttonIndex == 0){
            stringURL  = @"http://about.me/mokorean";//@"http://lomohome.com";
        } else if (buttonIndex == 1){
            stringURL  = @"http://lomohome.com";//@"http://facebook.com/mokorean";
        } else if (buttonIndex == 2){
            stringURL  = @"http://twitter.com/mokorean";
        } else {
            return;
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
    }
    
}

@end
