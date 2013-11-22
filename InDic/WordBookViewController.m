//
//  WordBookViewController.m
//  InDic
//
//  Created by moKorean on 13. 10. 10..
//  Copyright (c) 2013년 moKorean. All rights reserved.
//

#import "WordBookViewController.h"
#define DELETE_BUTTON_HEIGHT 60.0f

@interface WordBookViewController ()

@end

@implementation WordBookViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"tabbar_wordbook", nil);
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cmdEdit)];
        
        doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cmdEdit)];
        
        self.navigationItem.rightBarButtonItem = editBtn;
        
        nc = [NSNotificationCenter defaultCenter];
//        self.automaticallyAdjustsScrollViewInsets = NO;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    rootVC = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    
    if (self.tableView.editing){
        self.tableView.editing = NO;
        self.navigationItem.rightBarButtonItem = editBtn;
    }
    
    [self reloadWorkBookData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self closeDeleteAllBtn];
    [super viewWillDisappear:animated];
}

- (void)cmdEdit {
    if (self.tableView.editing) {
        [self closeDeleteAllBtn];
        [self.tableView setEditing:NO animated:YES];
    } else {
        [self showDeleteAllBtn];
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadWorkBookData{
    wordbookData = [[AppSetting sharedAppSetting] getWordbooksFromCache];
    
    //reverse sort
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"idx" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [wordbookData sortUsingDescriptors:sortDescriptors];
    
    [self.tableView reloadData];
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
    return [wordbookData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    WordBookObject *_wObj = [wordbookData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = _wObj.word;
    cell.detailTextLabel.text = [dateFormatter stringFromDate:_wObj.addDate];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WordBookObject *_wObj = [wordbookData objectAtIndex:indexPath.row];
    [self defineWord:_wObj.word];
}

#pragma mark DIC
-(void)defineWord:(NSString*)_word{

    //NSLog(@"Search Start at WordBook : %@",_word);
    
//    if (_word.length == 0) {
//        return;
//    }
    
    [[AppSetting sharedAppSetting] loadingStart:self.view];
    [[AppSetting sharedAppSetting] defineWord:_word isShowFirstInfo:NO isSaveToWordBook:NO targetViewController:rootVC];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WordBookObject *_wObj = [wordbookData objectAtIndex:indexPath.row];
        
        [[AppSetting sharedAppSetting] deleteWordBook:_wObj.idx];
        
//        if ([wordbookData count] == 1) {
//            [self cmdEdit];
//        }
        
        [self reloadWorkBookData];
        
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

-(void)showDeleteAllBtn{
    if (deleteAllBtn == nil){
        deleteAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIScrollView* scView = ((UIScrollView*)self.tableView);
        UIEdgeInsets inset = scView.contentInset;
        contentTop = inset.top;
        
        NSLog(@"\n================================\n\nContentTop %f , %@",contentTop,scView);
        NSLog(@"(%f,%f)",scView.contentSize.width,scView.contentSize.height);
        
//        CGFloat originY = self.naviController.navigationBar.frame.size.height + self.naviController.navigationBar.frame.origin.y;
        
        deleteAllBtn.frame = CGRectMake(0, contentTop+scView.contentOffset.y, self.view.frame.size.width, 0);
        
        [deleteAllBtn setTitle:NSLocalizedString(@"deleteallword", nil) forState:UIControlStateNormal];
        [deleteAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteAllBtn.backgroundColor = [UIColor redColor];
        [deleteAllBtn addTarget:self action:@selector(deleteAllAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self.tableView addSubview:deleteAllBtn];
        [self.tableView bringSubviewToFront:deleteAllBtn];
        
        [UIView animateWithDuration:0.2f animations:^{
            deleteAllBtn.frame = CGRectMake(0, contentTop+scView.contentOffset.y, self.view.frame.size.width, DELETE_BUTTON_HEIGHT);
            
            self.tableView.contentInset = UIEdgeInsetsMake(DELETE_BUTTON_HEIGHT+contentTop, 0,0,0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(DELETE_BUTTON_HEIGHT+contentTop, 0,0,0);
        
            //NSLog(@"y %f (%f) %@\n\n==============================",-DELETE_BUTTON_HEIGHT+scView.contentOffset.y,scView.contentOffset.y,scView);
            
            if((scView.contentSize.height+DELETE_BUTTON_HEIGHT) < scView.frame.size.height){
                [scView setContentOffset:CGPointMake(0, -(DELETE_BUTTON_HEIGHT+contentTop)) animated:YES];
            } else {
                [scView setContentOffset:CGPointMake(0, (scView.contentOffset.y-contentTop)) animated:YES];
            }
            
            //self.view.frame = temp;
            //[self.view layoutIfNeeded];
        }];
        
        self.navigationItem.rightBarButtonItem = doneBtn;
        
    }
}

-(void)closeDeleteAllBtn{
    if (deleteAllBtn != nil){
        [deleteAllBtn removeFromSuperview];
        deleteAllBtn = nil;
        
        [UIView animateWithDuration:0.2f animations:^{
            NSLog(@"ContentTop %f",contentTop);
            self.tableView.contentInset = UIEdgeInsetsMake(contentTop, 0, 0, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(contentTop, 0, 0, 0);
            
            
        }];
        
        self.navigationItem.rightBarButtonItem = editBtn;
        [self.tableView setEditing:NO animated:YES];

    }
    

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"%@, %@",scrollView,deleteAllBtn);
    if (deleteAllBtn != nil){
        deleteAllBtn.frame = CGRectMake(0, contentTop + scrollView.contentOffset.y, self.view.frame.size.width, DELETE_BUTTON_HEIGHT);
    }
    
}

-(void)deleteAllAction{
    NSLog(@"DELETE ALL!!!");
    
    UIAlertView* deleteConfirm = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"areyousuretodelete", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"n", nil) otherButtonTitles:NSLocalizedString(@"y", nil), nil];
    deleteConfirm.tag = 857429;
    [deleteConfirm show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 857429){
        if (buttonIndex == 1) {
            NSLog(@"DELETE ACTION");
            [self closeDeleteAllBtn];
            [[AppSetting sharedAppSetting] deleteAllWordBook];
            [self reloadWorkBookData];
        }
    }
}

@end
