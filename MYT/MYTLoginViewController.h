//
//  MYTLoginViewController.h
//  MYT
//
//  Created by 熊凯 on 15/12/7.
//  Copyright © 2015年 YunRui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYTLoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *TF_UserName;
@property (weak, nonatomic) IBOutlet UITextField *TF_Password;
- (IBAction)loginInto:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ViewForm;

@end