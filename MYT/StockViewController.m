//
//  StockViewController.m
//  MYT
//
//  Created by YUNRUIMAC on 15/12/13.
//  Copyright © 2015年 YunRui. All rights reserved.
//

#import "StockViewController.h"
#import "ButtomView.h"
#import "Node.h"
#import "TreeTableView.h"
@interface StockViewController ()<TreeTableCellDelegate>

@end

@implementation StockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    self.navigationController.navigationBarHidden=NO;
    self.navigationItem.leftItemsSupplementBackButton=NO;
    ButtomView* BtmV=[[ButtomView alloc]initWithFrame:CGRectMake(0, ScreenHeight-114, ScreenWidth, 50)];
    [self.view addSubview:BtmV];
    // Do any additional setup after loading the view.
}
-(void)initData{
    
    //----------------------------------中国的省地市关系图3,2,1--------------------------------------------
    Node *country1 = [[Node alloc] initWithParentId:-1 nodeId:0 name:@"中国" depth:0 expand:YES];
    Node *province1 = [[Node alloc] initWithParentId:0 nodeId:1 name:@"江苏" depth:1 expand:NO];
    Node *city1 = [[Node alloc] initWithParentId:1 nodeId:2 name:@"南通" depth:2 expand:NO];
    //Node *subCity1 = [[Node alloc] initWithParentId:2 nodeId:100 name:@"通州" depth:3 expand:NO];
    //Node *subCity2 = [[Node alloc] initWithParentId:2 nodeId:101 name:@"如东" depth:3 expand:NO];
    Node *city2 = [[Node alloc] initWithParentId:1 nodeId:3 name:@"南京" depth:2 expand:NO];
    Node *city3 = [[Node alloc] initWithParentId:1 nodeId:4 name:@"苏州" depth:2 expand:NO];
    Node *province2 = [[Node alloc] initWithParentId:0 nodeId:5 name:@"广东" depth:1 expand:NO];
    Node *city4 = [[Node alloc] initWithParentId:5 nodeId:6 name:@"深圳" depth:2 expand:NO];
    Node *city5 = [[Node alloc] initWithParentId:5 nodeId:7 name:@"广州" depth:2 expand:NO];
    Node *province3 = [[Node alloc] initWithParentId:0 nodeId:8 name:@"浙江" depth:1 expand:NO];
    Node *city6 = [[Node alloc] initWithParentId:8 nodeId:9 name:@"杭州" depth:2 expand:NO];
    //----------------------------------美国的省地市关系图0,1,2--------------------------------------------
    Node *country2 = [[Node alloc] initWithParentId:-1 nodeId:10 name:@"美国" depth:0 expand:YES];
    Node *province4 = [[Node alloc] initWithParentId:10 nodeId:11 name:@"纽约州" depth:1 expand:NO];
    Node *province5 = [[Node alloc] initWithParentId:10 nodeId:12 name:@"德州" depth:1 expand:NO];
    Node *city7 = [[Node alloc] initWithParentId:12 nodeId:13 name:@"休斯顿" depth:2 expand:NO];
    Node *province6 = [[Node alloc] initWithParentId:10 nodeId:14 name:@"加州" depth:1 expand:NO];
    Node *city8 = [[Node alloc] initWithParentId:14 nodeId:15 name:@"洛杉矶" depth:2 expand:NO];
    Node *city9 = [[Node alloc] initWithParentId:14 nodeId:16 name:@"旧金山" depth:2 expand:NO];
    
    //----------------------------------日本的省地市关系图0,1,2--------------------------------------------
    Node *country3 = [[Node alloc] initWithParentId:-1 nodeId:17 name:@"日本" depth:0 expand:YES];
    Node *province7 = [[Node alloc] initWithParentId:17 nodeId:18 name:@"东京" depth:1 expand:NO];
    Node *province8 = [[Node alloc] initWithParentId:17 nodeId:19 name:@"东京1" depth:1 expand:NO];
    Node *province9 = [[Node alloc] initWithParentId:17 nodeId:20 name:@"东京2" depth:1 expand:NO];
    
    
    //NSArray *data = [NSArray arrayWithObjects:country1,country2,country3, nil];
    
    //NSArray *data = [NSArray arrayWithObjects:country1,province1,province2,province3,country2,province4,province5,province6,country3, nil];
    
    NSArray *data = [NSArray arrayWithObjects:country1,province1,city1,city2,city3,province2,city4,city5,province3,city6,country2,province4,province5,city7,province6,city8,city9,country3,province7,province8,province9, nil];
    
    
    TreeTableView *tableview = [[TreeTableView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), self.view.frame.size.height-133) withData:data];
    tableview.treeTableCellDelegate = self;
    [self.view addSubview:tableview];
}

#pragma mark - TreeTableCellDelegate
-(void)cellClick:(Node *)node{
    NSLog(@"%@",node.name);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
