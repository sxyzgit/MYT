//
//  addTableViewController.m
//  MYT
//
//  Created by 熊凯 on 15/12/8.
//  Copyright © 2015年 YunRui. All rights reserved.
//

#import "addTableViewController.h"
#import "Z_NetRequestManager.h"
#import <SVProgressHUD.h>
@interface addTableViewController ()
{
    UIButton* btnSelected;
    NSString* lati;
    NSString* longi;
    NSMutableDictionary* addcusjson;
}
@end

@implementation addTableViewController

//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

-(void)viewWillAppear:(BOOL)animated
{

    if(currentVersion>=7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

}

- (void)viewDidLoad {
    //消除多余空白行
    addcusjson=[[NSMutableDictionary alloc]init];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    //设置背景颜色
    self.tableView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    //设置各个输入框代理方法
    _TF_CusCode.delegate=self;
    _TF_CusName.delegate=self;
    _TF_CusTtName.delegate=self;
    _TF_MobilePhone.delegate=self;
    _TF_Phone.delegate=self;
    _TF_website.delegate=self;
    btnSelected=_btn_qiye;//默认为企业
  
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[textField convertRect:textField.bounds toView:window];
    float y1=rect.origin.y;
    if(y1>200)
    {
        self.tableView.frame=CGRectMake(0, -y1+200, ScreenWidth, ScreenHeight);
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.tableView.frame=CGRectMake(0, 60, ScreenWidth, ScreenHeight-50);
}
- (IBAction)Click_GetLocation:(id)sender {
    [[Z_NetRequestManager sharedInstance]getlongandlati];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        
        NSDictionary *location=[[Z_NetRequestManager sharedInstance] getlongla];
        lati=[location objectForKey:@"lati"];
        longi=[location objectForKey:@"longi"];
        NSLog(@"%@,%@",lati,longi);
        [SVProgressHUD showSuccessWithStatus:@"获取位置成功"];
        
        
    });//得到经纬度得时间会有延迟 详情见map方法

    
    //
}

- (IBAction)click_qiye:(id)sender {
    btnSelected.selected=NO;
    [btnSelected setImage:[UIImage imageNamed:@"quan"] forState:UIControlStateNormal];
    _btn_qiye.selected=YES;
    btnSelected=_btn_qiye;
    
    [btnSelected setImage:[UIImage imageNamed:@"cusTypeSel"] forState:UIControlStateSelected];
}

- (IBAction)click_finish:(id)sender {
    if (_TF_CusName.text&&_TF_CusTtName.text&&_TF_MobilePhone.text&&lati&&longi&&_TF_website.text&&_TF_CusCode&&_TF_Phone) {
        [addcusjson setObject:lati forKey:@"cusName"];
        [addcusjson setObject:lati forKey:@"cusCode"];
        [addcusjson setObject:lati forKey:@"cusTtName"];
        [addcusjson setObject:lati forKey:@"mobilePhone"];
        [addcusjson setObject:lati forKey:@"longitude"];//经度
        [addcusjson setObject:longi forKey:@"latitude"];//纬度
        [addcusjson setObject:lati forKey:@"province"];
        [addcusjson setObject:lati forKey:@"city"];
        [addcusjson setObject:lati forKey:@"district"];
        [addcusjson setObject:lati forKey:@"website"];
        [addcusjson setObject:lati forKey:@"type"];
        [addcusjson setObject:lati forKey:@"phone"];
        /*[[QQRequestManager sharedRequestManager] POST:[SEVER_URL stringByAppendingString:@"yd/addCus.action"] parameters:addcusjson showHUD:YES success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"%@",responseObject);
           
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            
            [self qq_performSVHUDBlock:^{
                [SVProgressHUD showErrorWithStatus:@"账号或密码错误"];
            }];
        }];*/
        // 1.创建请求
             NSURL *url = [NSURL URLWithString:[SEVER_URL stringByAppendingString:@"yd/addCus.action"]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
             request.HTTPMethod = @"POST";
        
             // 2.设置请求头
             [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
             // 3.设置请求体
        
        NSLog(@"%@",addcusjson);
         //    NSData --> NSDictionary
             // NSDictionary --> NSData
             NSData *data = [NSJSONSerialization dataWithJSONObject:addcusjson options:NSJSONWritingPrettyPrinted error:nil];
             request.HTTPBody = data;
                
             // 4.发送请求
             [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                 NSLog(@"%@",[jsonDic objectForKey:@"message"]);

            }];
        if (1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:NO];
            });
            }
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"请填写完信息再提交"];
    }
    
}

- (IBAction)click_person:(id)sender {
    
    btnSelected.selected=NO;
    [btnSelected setImage:[UIImage imageNamed:@"quan"] forState:UIControlStateNormal];
    _btn_person.selected=YES;
    btnSelected=_btn_person;
    
    [btnSelected setImage:[UIImage imageNamed:@"cusTypeSel"] forState:UIControlStateSelected];
}

@end
