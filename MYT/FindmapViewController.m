//
//  FindmapViewController.m
//  MYT
//
//  Created by yunruiinfo on 16/1/12.
//  Copyright © 2016年 YunRui. All rights reserved.
//

#import "FindmapViewController.h"

@interface FindmapViewController ()
{
    CLLocationManager* v;
    CLGeocoder* _geocoder;
    __block NSArray *palceinfor;
    UIAlertView *alert ;
    CLLocationCoordinate2D touchMapCoordinate;//手势点击的那个点的经纬度
}
@end

@implementation FindmapViewController

- (void)viewDidLoad {
     palceinfor=[[NSArray alloc]init];
    _mapsearch.delegate=self;
    [self initGUI];
     _geocoder=[[CLGeocoder alloc]init];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开");
        return;
    }
    //如果没有授权则请求授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        //设置代理
        _locationManager.delegate=self;
        //设置定位精度
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=1.0;//一米定位一次
        _locationManager.distanceFilter=distance;
        //启动跟踪定位
        [_locationManager startUpdatingLocation];
    }
    UITapGestureRecognizer *mTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
    [_mapView addGestureRecognizer:mTap];
    alert = [[UIAlertView alloc] initWithTitle:@"添加客户位置"
                                                    message:@"确定客户位置在大头针处？"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"YES",nil];
    alert.delegate=self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==0) {
        [_mapView removeAnnotations:_mapView.annotations];
        NSLog(@"你点击了取消");
        
    }else if (buttonIndex==1){
        
        NSString* lati=[NSString stringWithFormat:@"%f",touchMapCoordinate.latitude];
        NSString* longi=[NSString stringWithFormat:@"%f",touchMapCoordinate.longitude];
        NSDictionary *dic =  [NSDictionary dictionaryWithObjectsAndKeys:lati,@"lati",longi,@"longi",nil];;
        //添加监听
       [[NSNotificationCenter defaultCenter] postNotificationName:@"coordinate" object:nil userInfo:dic];
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"你点击了确定");
        
    }
    
}
- (void)tapPress:(UIGestureRecognizer*)gestureRecognizer {
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];//这里touchPoint是点击的某点在地图控件中的位置
    touchMapCoordinate =[_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];//这里touchMapCoordinate就是该点的经纬度了
    [self addAnnotation:touchMapCoordinate.latitude jingdu:touchMapCoordinate.longitude];
    [alert show];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *find=[searchText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self getCoordinateByAddress:find];//获取经纬度的数组
    if(palceinfor)
    {
    CLPlacemark *placemark=[palceinfor firstObject];
    CLLocation *location=placemark.location;//位置
    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
    NSLog(@"经度%f,纬度%f",coordinate.longitude,coordinate.latitude);
    CLLocationCoordinate2D loca=CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        
        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(loca, 200  ,200 );
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
        [_mapView setRegion:adjustedRegion animated:YES];
    }
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *find=searchBar.text;
    [self getCoordinateByAddress:find];//获取经纬度的数组
    if(palceinfor)
    {
        CLPlacemark *placemark=[palceinfor firstObject];
        CLLocation *location=placemark.location;//位置
        CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
        NSLog(@"经度%f,纬度%f",coordinate.longitude,coordinate.latitude);
        CLLocationCoordinate2D loca=CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        
        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(loca, 200  ,200 );
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
        [_mapView setRegion:adjustedRegion animated:YES];
    }

       [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
//延迟一会才调用而不是之间启动跟踪定位后立马调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [_locationManager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
            
            
    }
}


#pragma mark 添加地图控件
-(void)initGUI{
    //设置代理
    _mapView.delegate=self;
    
    //请求定位服务
    _locationManager=[[CLLocationManager alloc]init];
    if(![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
    _mapView.userTrackingMode=MKUserTrackingModeFollow;
    
    //设置地图类型
    _mapView.mapType=MKMapTypeStandard;
   
    
    
}


#pragma mark 添加大头针
-(void)addAnnotation:(float)lati jingdu:(float)longi
{
    CLLocationCoordinate2D location1=CLLocationCoordinate2DMake(lati, longi);
    KCAnnotation *annotation1=[[KCAnnotation alloc]init];
    annotation1.coordinate=location1;
    [_mapView addAnnotation:annotation1];
    
   
 
    
}


#pragma mark - CoreLocation 代理
#pragma mark 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
//可以通过模拟器设置一个虚拟位置，否则在模拟器中无法调用此方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location=[locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
    //如果不需要实时定位，使用完即使关闭定位服务
     [_locationManager stopUpdatingLocation];
}


//////////////地理编码/////////////
#pragma mark 根据地名确定地理坐标
-(void)getCoordinateByAddress:(NSString *)address{
    //地理编码
  
    [_geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        //取得第一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
        
        CLPlacemark *placemark=[placemarks firstObject];
        palceinfor=[NSArray arrayWithArray:placemarks];
        CLLocation *location=placemark.location;//位置
        NSLog(@"%@",location);
        CLRegion *region=placemark.region;//区域
        NSDictionary *addressDic= placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
        //        NSString *name=placemark.name;//地名
        //        NSString *thoroughfare=placemark.thoroughfare;//街道
        //        NSString *subThoroughfare=placemark.subThoroughfare; //街道相关信息，例如门牌等
        //        NSString *locality=placemark.locality; // 城市
        //        NSString *subLocality=placemark.subLocality; // 城市相关信息，例如标志性建筑
        //        NSString *administrativeArea=placemark.administrativeArea; // 州
        //        NSString *subAdministrativeArea=placemark.subAdministrativeArea; //其他行政区域信息
        //        NSString *postalCode=placemark.postalCode; //邮编
        //        NSString *ISOcountryCode=placemark.ISOcountryCode; //国家编码
        //        NSString *country=placemark.country; //国家
        //        NSString *inlandWater=placemark.inlandWater; //水源、湖泊
        //        NSString *ocean=placemark.ocean; // 海洋
        //        NSArray *areasOfInterest=placemark.areasOfInterest; //关联的或利益相关的地标
        NSLog(@"位置:%@,区域:%@,详细信息:%@",location,region,addressDic);
    }];
  
}

#pragma mark 根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSLog(@"详细信息:%@",placemark.addressDictionary);
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

@end
