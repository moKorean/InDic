//
//  LanguageSettingView.m
//  EventsList
//
//  Created by Geunwon,Mo on 11. 6. 28..
//  Copyright 2011 mokorean@gmail.com (http://Lomohome.com). All rights reserved.
//

#import "LanguageSettingView.h"


@implementation LanguageSettingView
@synthesize beforeL,afterL;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.beforeL = nil;
        self.afterL = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"language setting title", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backAction)];

    self.beforeL = [[AppSetting sharedAppSetting] languageCode];
    self.afterL = self.beforeL;

}


-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![self.beforeL isEqualToString:self.afterL]) {
    
        //            textMsg = @"언어설정이 완료되었습니다.\n변경된 어플을 적용하시려면 어플리케이션을 다시 시작하셔야합니다.";
        //            confirmBtn = @"확인";
        //        } else {
        //            textMsg = @"Setting language is complete\nPlease, re-launch application.";
        //            confirmBtn = @"Confirm";
        //        }
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
        //                                                            message:NSLocalizedString(@"opposite language setting complete", nil)
        //                                                           delegate:nil
        //                                                  cancelButtonTitle:NSLocalizedString(@"opposite confirm", nil)
        //                                                  otherButtonTitles:nil] ;
        //        [alertView show];
        NSString *_msg = [NSString stringWithFormat:@"opposite language setting complete_%@",self.afterL];
        NSString *_yes = [NSString stringWithFormat:@"opposite yes_%@",self.afterL];
        NSString *_no = [NSString stringWithFormat:@"opposite no_%@",self.afterL];
        //[[AppSetting sharedAppSetting] resetFirstRun];
        
        [[AppSetting sharedAppSetting] exitAlertTitle:nil andMsg:NSLocalizedString(_msg, nil) andConfirmBtn:NSLocalizedString(_yes, nil) andCancelBtn:NSLocalizedString(_no, nil)];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"languageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.textLabel.font = [AppSetting sharedAppSetting].defaultFont;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell...
    
    if (indexPath.row == 0 && [[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ko"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 1 && [[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"en"]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (indexPath.row == 2 && [[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ja"]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"한글";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"English";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"日本語";
    }
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"language setting footer", nil);
    }
    return nil;
    
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *selectionIndexPath;
    
    if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ko"]) {
        selectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"en"]) {
        selectionIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    } else if([[[AppSetting sharedAppSetting] languageCode] isEqualToString:@"ja"]) {
        selectionIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:selectionIndexPath];
    checkedCell.accessoryType = UITableViewCellAccessoryNone;
    
    // Set the checkmark accessory for the selected row.
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];    
    
    // 체크하면 업데이트 해준다.
    if (indexPath.row == 0) {
        //한국어
        [[AppSetting sharedAppSetting] setLanguage:@"ko"];
        self.afterL = @"ko";
    } else if (indexPath.row == 1) {
        //영어
        [[AppSetting sharedAppSetting] setLanguage:@"en"];
        self.afterL = @"en";
    } else if (indexPath.row == 2){
        //일본어
        [[AppSetting sharedAppSetting] setLanguage:@"ja"];
        self.afterL = @"ja";
    }
    
    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
