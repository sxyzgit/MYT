//
//  MateProjectViewController.m
//  MYT
//
//  Created by YUNRUIMAC on 15/12/8.
//  Copyright © 2015年 YunRui. All rights reserved.
//

#import "MateProjectViewController.h"
#import "Utility.h"
#import "QQRequestManager.h"
#import "ButtomView.h"
@interface MateProjectViewController ()
{
    __block NSDictionary* jsonDic;
}
@end

@implementation MateProjectViewController

- (void)viewDidLoad {
    
    _tableview.delegate=self;
    _tableview.dataSource=self;
    [[Utility sharedInstance]setLayerView:_abandon borderW:1 borderColor:[UIColor colorWithRed:96.0f/255.0f green:56.0f/255.0f blue:17.0f/255.0f alpha:0.5] radius:5.0];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    self.navigationController.navigationBarHidden=NO;
    self.navigationItem.leftItemsSupplementBackButton=NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:16],
       
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    if (currentVersion <= 6.1) {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        CGRect statusRe = [[UIApplication sharedApplication] statusBarFrame];
        UIView* status=[[UIView alloc]initWithFrame:CGRectMake(0, -20, statusRe.size.width, statusRe.size.height)];
        status.backgroundColor=[UIColor whiteColor];
        [self.navigationController.navigationBar addSubview:status];
    }
    
    ButtomView* BtmV=[[ButtomView alloc]initWithFrame:CGRectMake(0, ScreenHeight-114, ScreenWidth, 50)];
    [self.view addSubview:BtmV];
    [self loadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[jsonDic objectForKey:@"list"] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[_tableview dequeueReusableCellWithIdentifier:@"cell1"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        //产品名称
        UILabel* productName=[[UILabel alloc]initWithFrame:CGRectMake(20, 12, 100, 20)];
        productName.font=[UIFont systemFontOfSize:14];
        productName.textColor=[UIColor darkGrayColor];
        productName.tag=1000;
        productName.textAlignment=NSTextAlignmentLeft;
        [cell.contentView addSubview:productName];
        //产品需求量
        UILabel* productNeeds=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
        productNeeds.center=CGPointMake(ScreenWidth/2, 22);
        productNeeds.font=[UIFont systemFontOfSize:14];
        productNeeds.textColor=[UIColor darkGrayColor];
        productNeeds.tag=1001;
        productNeeds.textAlignment=NSTextAlignmentCenter;
        [cell.contentView addSubview:productNeeds];
        
        //库存量
        UILabel* save=[[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth-60, 12, 30, 20)];
        save.font=[UIFont systemFontOfSize:14];
        save.textColor=[UIColor darkGrayColor];
        save.tag=1002;
        save.textAlignment=NSTextAlignmentRight;
        [cell.contentView addSubview:save];
    }
    NSArray* arr=[jsonDic objectForKey:@"list"];
    ((UILabel*)[cell.contentView viewWithTag:1000]).text=[[arr objectAtIndex:indexPath.row] objectForKey:@"mattername"];
    ((UILabel*)[cell.contentView viewWithTag:1001]).text=[[arr objectAtIndex:indexPath.row] objectForKey:@"ctdem"];
    ((UILabel*)[cell.contentView viewWithTag:1002]).text=[[arr objectAtIndex:indexPath.row] objectForKey:@"ivtct"];
    return cell;
}

-(void)loadData
{
     NSString* userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    NSMutableDictionary* parDic=[[NSMutableDictionary alloc]init];
    [parDic setValue:userid forKey:@"userid"];
    [parDic setValue:_cusId forKey:@"cusid"];
    [[QQRequestManager sharedRequestManager]GET:[SEVER_URL stringByAppendingString:@"yd/getMatchProdDtel.action"] parameters:parDic showHUD:YES success:^(NSURLSessionDataTask *task, id responseObject) {
        jsonDic=(NSDictionary*)responseObject;
        _mate_name.text=[jsonDic objectForKey:@"custtname"];
        [_tableview reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self qq_performSVHUDBlock:^{
            [SVProgressHUD showErrorWithStatus:@"数据请求错误！"];
        }];

    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickPhone:(id)sender {
    
    
}

- (IBAction)clickBandon:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"请输入放弃理由"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    // 基本输入框，显示实际输入的内容
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    //设置输入框的键盘类型
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeDefault;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSString* text = ((UITextField*)[alertView textFieldAtIndex:0]).text;
        NSString* userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
        NSMutableDictionary* parDic=[[NSMutableDictionary alloc]init];
        NSString* dtlid=[jsonDic objectForKey:@"dtlid"];
        [parDic setValue:dtlid forKey:@"dtlid"];
        [parDic setValue:userid forKey:@"userid"];
        [parDic setValue:text forKey:@"gpReason"];
        [[QQRequestManager sharedRequestManager]GET:[SEVER_URL stringByAppendingString:@"yd/giveupCall.action"] parameters:parDic showHUD:YES success:^(NSURLSessionDataTask *task, id responseObject) {
            int status= ((NSNumber*)[responseObject objectForKey:@"status"]).intValue;
            if (status==1) {
                [self qq_performSVHUDBlock:^{
                    [SVProgressHUD showSuccessWithStatus:[responseObject objectForKey:@"message"]];
                   
                }];
            }else
            {
                [self qq_performSVHUDBlock:^{
                    [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"message"]];
                }];
            }
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self qq_performSVHUDBlock:^{
                [SVProgressHUD showErrorWithStatus:@"数据请求错误！"];
            }];
        }];
    }
}

@end
