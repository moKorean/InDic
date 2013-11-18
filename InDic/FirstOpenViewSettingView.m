//
//  FirstOpenViewSettingView.m
//  InDic
//
//  Created by moKorean on 2013. 11. 18..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "FirstOpenViewSettingView.h"

@implementation FirstOpenViewSettingView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

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
    
    self.title = NSLocalizedString(@"firstopentabtitle", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backAction)];
    
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"openTabCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.textLabel.font = [AppSetting sharedAppSetting].defaultFont;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    // Configure the cell...
    
    if (indexPath.row == 0 && ([AppSetting sharedAppSetting].getFirstOpenTab == 1)) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else if (indexPath.row == 1 && ([AppSetting sharedAppSetting].getFirstOpenTab == 2)){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"tabbar_dic", nil);
        cell.imageView.image = [UIImage imageNamed:@"tabbar_dic"];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"tabbar_wordbook", nil);
        cell.imageView.image = [UIImage imageNamed:@"wordbook"];
    } 
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
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
    
    if(([AppSetting sharedAppSetting].getFirstOpenTab == 1)) {
        selectionIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if(([AppSetting sharedAppSetting].getFirstOpenTab == 2)) {
        selectionIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:selectionIndexPath];
    checkedCell.accessoryType = UITableViewCellAccessoryNone;
    
    // Set the checkmark accessory for the selected row.
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    // 체크하면 업데이트 해준다.
    if (indexPath.row == 0) {
        //사전
        [[AppSetting sharedAppSetting] setFirstOpenTab:1];

    } else if (indexPath.row == 1) {
        //단어장
        [[AppSetting sharedAppSetting] setFirstOpenTab:2];

    }
    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end