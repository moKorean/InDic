//
//  SpeakSettingView.m
//  InDic
//
//  Created by moKorean on 2013. 12. 2..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "SpeakSettingView.h"

#define SWITCH_SPEAK_USE 154389
#define SLIDER_SPEED 6492874

@implementation SpeakSettingView
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(orientationChange) name:_NOTIFICATION_ORIENTATION_CHANGE object:nil];
        
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
    
    self.title = NSLocalizedString(@"speaksettingtitle", nil);
    
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
    
    [self.tableView reloadData];
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

-(void)orientationChange{
    NSIndexSet* reloadSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tableView numberOfSections])];
    [self.tableView reloadData];
    [self.tableView reloadSections:reloadSet withRowAnimation:UITableViewRowAnimationNone];
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
    return 4;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@"speakTTSdesc", nil);
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"optionTabCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    } else {
        if ([cell.contentView viewWithTag:SWITCH_SPEAK_USE]){
            [[cell.contentView viewWithTag:SWITCH_SPEAK_USE] removeFromSuperview];
        }
    }
    
    //cell.textLabel.font = [AppSetting sharedAppSetting].defaultFont;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    // Configure the cell...
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"speakuse", nil);
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (useSpeak == nil){
            useSpeak = [[UISwitch alloc] init];
            [useSpeak addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            // in case the parent view draws with a custom color or gradient, use a transparent color
            useSpeak.backgroundColor = [UIColor clearColor];
            useSpeak.tag = SWITCH_SPEAK_USE;
        }
        useSpeak.frame = [[AppSetting sharedAppSetting] getSwitchFrameWith:useSpeak cellView:cell.contentView];
        
        useSpeak.on = [AppSetting sharedAppSetting].isSpeakUse;
        
        [cell.contentView addSubview:useSpeak];
        
        
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"speakspeed", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([AppSetting sharedAppSetting].getSpeakSpeed == 1) {
            cell.detailTextLabel.text = NSLocalizedString(@"speakspeed_1", nil);
        } else if ([AppSetting sharedAppSetting].getSpeakSpeed == 2) {
            cell.detailTextLabel.text = NSLocalizedString(@"speakspeed_2", nil);
        } else if ([AppSetting sharedAppSetting].getSpeakSpeed == 3) {
            cell.detailTextLabel.text = NSLocalizedString(@"speakspeed_3", nil);
        }
        
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (speedSlider == nil){
            speedSlider = [[UISlider alloc] init];
            [speedSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
            // in case the parent view draws with a custom color or gradient, use a transparent color
            speedSlider.backgroundColor = [UIColor clearColor];
            speedSlider.tag = SLIDER_SPEED;
            speedSlider.minimumValue = 1;
            speedSlider.maximumValue = 3;
            speedSlider.continuous = NO;
            
        }
        NSLog(@"cell width : %f",cell.frame.size.width);
        
        CGFloat deviceWidth = [AppSetting sharedAppSetting].windowSize.size.width;
        
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        //NSLog(@"orientation change to %d",orientation);
        
        if (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight ) {
            deviceWidth = [AppSetting sharedAppSetting].windowSize.size.height;
        }
        
        speedSlider.frame = CGRectMake(20, 0, deviceWidth-40, cell.frame.size.height);
        
        speedSlider.value = [AppSetting sharedAppSetting].getSpeakSpeed;
        
        [cell.contentView addSubview:speedSlider];
        
    } else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"speakvoice", nil);
        
        if ([AppSetting sharedAppSetting].getSpeakVoice == 1) {
            cell.detailTextLabel.text = NSLocalizedString(@"speakvoice_us", nil);
        } else if ([AppSetting sharedAppSetting].getSpeakVoice == 2) {
            cell.detailTextLabel.text = NSLocalizedString(@"speakvoice_gb", nil);
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    return cell;
}



- (void)switchAction:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch* senderSwitch = (UISwitch*)sender;
        if (senderSwitch.tag == SWITCH_SPEAK_USE) {
            [[AppSetting sharedAppSetting] setSpeakUse:[senderSwitch isOn]];
        }
        
        //        else if (senderSwitch.tag == SWITCH_MANUAL_SAVE_TAG){
        //            [[AppSetting sharedAppSetting] setManualSaveToWordBook:[senderSwitch isOn]];
        //
        //        }
        //        else if (senderSwitch.tag == SWITCH_WORDBOOK_WORD_SUGGESTION_TAG){
        //            [[AppSetting sharedAppSetting] setSuggestFromWordbook:[senderSwitch isOn]];
        //        }
    }
    
    
}

- (void)sliderAction:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider* senderSlider = (UISlider*)sender;
        if (senderSlider.tag == SLIDER_SPEED) {
//            [[AppSetting sharedAppSetting] setSpeakUse:[senderSwitch isOn]];
            
            NSLog(@"slider : %f",[senderSlider value]);
            
            NSUInteger index = (NSUInteger)(senderSlider.value + 0.5); // Round the number.
            [speedSlider setValue:index animated:NO];
            
            NSLog(@"index: %i", index);
            
            [[AppSetting sharedAppSetting] setSpeakSpeed:index];
            
            //NSNumber *number = [numbers objectAtIndex:index]; // <-- This is the number you want.
            //NSLog(@"number: %@", number);
            
            [self.tableView reloadData];
            
            
        }
        
        //        else if (senderSwitch.tag == SWITCH_MANUAL_SAVE_TAG){
        //            [[AppSetting sharedAppSetting] setManualSaveToWordBook:[senderSwitch isOn]];
        //
        //        }
        //        else if (senderSwitch.tag == SWITCH_WORDBOOK_WORD_SUGGESTION_TAG){
        //            [[AppSetting sharedAppSetting] setSuggestFromWordbook:[senderSwitch isOn]];
        //        }
    }
    
    
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
    
    UIViewController *nextViewController = nil;
    
    if (indexPath.row == 3) {
        //언어
        nextViewController = [[SpeakVoiceSettingView alloc] initWithStyle:UITableViewStyleGrouped];
    }
    
    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (nextViewController) {
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
    
}


@end