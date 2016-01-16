//
//  ContactsTableViewController.m
//  MYT
//
//  Created by 熊凯 on 16/1/16.
//  Copyright © 2016年 YunRui. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "QQRequestManager.h"
#import "Z_NetRequestManager.h"
#import "NetRequestManager.h"
@interface ContactsTableViewController ()
{
    __block NSArray* jsonAry;
}
@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    [super viewDidLoad];
    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [jsonAry count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identif=@"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identif];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identif];
        
        //姓名
        UILabel* name=[[UILabel alloc]initWithFrame:CGRectMake(10, 11, 60, 20)];
        name.font=[UIFont systemFontOfSize:14];
        name.textColor=[UIColor darkGrayColor];
        name.tag=1000;
        [cell.contentView addSubview:name];
        
        //电话号码
        UILabel* phone=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
        phone.center=CGPointMake(ScreenWidth/2, 21);
        phone.textAlignment=NSTextAlignmentCenter;
        phone.font=[UIFont systemFontOfSize:14];
        phone.textColor=[UIColor darkGrayColor];
        phone.tag=1001;
        [cell.contentView addSubview:phone];
        
        //电话图标
        UIButton* call=[[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth-40, 7, 30, 30)];
        call.tag=1002;
        [cell.contentView addSubview:call];
    }
    
    ((UILabel*)[cell.contentView viewWithTag:1000]).text=[[jsonAry objectAtIndex:indexPath.row] objectForKey:@"contactsname"];
    ((UILabel*)[cell.contentView viewWithTag:1001]).text=[[jsonAry objectAtIndex:indexPath.row] objectForKey:@"mobilephone"];
    //电话按钮
    UIButton* btn=(UIButton*)[cell.contentView viewWithTag:1002];
    [btn setImage:[UIImage imageNamed:@"电话小"] forState:0];
    [btn addTarget:self action:@selector(callPhoneNum:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag=10000+indexPath.row;
    
    
    return cell;
}

-(void)loadData
{
    NSMutableDictionary* parDic=[[NSMutableDictionary alloc]init];
    [parDic setValue:_cusid forKey:@"cusid"];
    [parDic setValue:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"] forKey:@"userid"];
    [[QQRequestManager sharedRequestManager]GET:[SEVER_URL stringByAppendingString:@"yd/getCusContracts.action"] parameters:parDic showHUD:YES success:^(NSURLSessionDataTask *task, id responseObject) {
        jsonAry=[responseObject objectForKey:@"list"];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self qq_performSVHUDBlock:^{
            [SVProgressHUD showErrorWithStatus:@"网络请求错误！"];
        }];
    }];
}

-(void)callPhoneNum:(UIButton*)btn
{
    int index=btn.tag-10000;
    NSString* contId=[[jsonAry objectAtIndex:index] objectForKey:@"contactsid"];
    btn.tag=(int)[[jsonAry objectAtIndex:index] objectForKey:@"mobilephone"];
    NSString* talkTime=[[Z_NetRequestManager sharedInstance]call:btn view:self.view];
    //判断一下  如果dtlid入库提醒明细id存在就上传通话记录 否则不上传
    if (_dtlid) {
        //上传通话记录
        NSString* userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
        NSDateFormatter* formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString* calltime=[formatter stringFromDate:[NSDate date]];
        [self UploadCallRecoredByUserId:userid Dtlid:_dtlid Contid:contId Calltime:calltime Talktime:talkTime];
    }
}

-(void)UploadCallRecoredByUserId:(NSString*)userid Dtlid:(NSString*)dtlid Contid:(NSString*)contid Calltime:(NSString*)calltime Talktime:(NSString*)talktime
{
    NSMutableDictionary* UpLoadJson=[[NSMutableDictionary alloc]init];
    [UpLoadJson setValue:userid forKey:@"userid"];
    [UpLoadJson setValue:dtlid forKey:@"dtlid"];
    [UpLoadJson setValue:contid forKey:@"contid"];
    [UpLoadJson setValue:calltime forKey:@"calltime"];
    [UpLoadJson setValue:talktime forKey:@"talktime"];
   NSString* jsonStr= [[NetRequestManager sharedInstance]DataToJsonString:UpLoadJson];
    NSMutableDictionary* parDic=[[NSMutableDictionary alloc]init];
    [parDic setValue:jsonStr forKey:@"paraMap"];
    [[QQRequestManager sharedRequestManager]POST:[SEVER_URL stringByAppendingString:@"yd/addCallRecord.action"] parameters:parDic success:^(NSURLSessionDataTask *task, id responseObject) {
        int status=((NSNumber*)[responseObject objectForKey:@"status"]).intValue;
        if (status==1) {
            [self qq_performSVHUDBlock:^{
                [SVProgressHUD showSuccessWithStatus:[responseObject objectForKey:@"message"]];
            }];
        }
        else
        {
            [self qq_performSVHUDBlock:^{
                [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self qq_performSVHUDBlock:^{
            [SVProgressHUD showErrorWithStatus:@"通话记录上传失败！"];
        }];
    }];
   }


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
