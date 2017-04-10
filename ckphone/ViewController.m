//
//  ViewController.m
//  ckphone
//
//  Created by 张晓龙 on 2017/4/5.
//  Copyright © 2017年 张晓龙. All rights reserved.
//

#import "ViewController.h"
#import "CVAlertTool.h"
#import <CallKit/CallKit.h>
#import "UIView+Extension.h"

@interface ViewController (){
    BOOL isBack;
}
@property (weak, nonatomic) IBOutlet UIButton *ckBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isBack = NO;
    self.title = @"CallKit使用";
    [self reloadSubViews];
    
}

- (void)viewDidAppear:(BOOL)animated {
    if(isBack) {
        isBack = NO;
        [self saveCallKitData];
    } else {
        isBack = YES;
    }
}


- (void) reloadSubViews{
    float space = 20;
    float width = (ScrW - space *3) / 2;
    float y = _phoneLabel.y + _phoneLabel.height + 10;
    self.ckBtn.frame = CGRectMake(space, y,width, 44);
    self.phoneBtn.frame = CGRectMake(width + 2*space, y, width, 44);
    self.ckBtn.layer.cornerRadius = 5.0;
    [self.ckBtn autoresizingMask];
    self.phoneBtn.layer.cornerRadius = 5.0;
    [self.phoneBtn autoresizingMask];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)ckBtnClick:(id)sender {
    
    NSString *name = _nameLabel.text;
    NSString *phone = _phoneLabel.text;
    if([name isEqualToString:@""]){
        [CVAlertTool showTip:@"来电提示不能为空" onView:self.navigationController.view];
        return ;
    }
    
    if([phone isEqualToString:@""]){
        [CVAlertTool showTip:@"电话号码不能为空" onView:self.navigationController.view];
        return ;
    }
    [self checkpermission];
    
}

//拨打电话
- (IBAction)phoneBtnClick:(id)sender {
    NSString *phone =  _phoneLabel.text;
    if([phone isEqualToString:@""]){
        [CVAlertTool showTip:@"电话号码不能为空" onView:self.navigationController.view];
        return ;
    }
    NSString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phone];
    [self openScheme:str];
}

- (void)openScheme:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{}
           completionHandler:^(BOOL success) {
               NSLog(@"Open %@: %d",scheme,success);
           }];
    } else {
        BOOL success = [application openURL:URL];
        NSLog(@"Open %@: %d",scheme,success);
    }
}




//检查是否获得电话  来电阻止和身份识别的系统权限
- (void)checkpermission {
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    // 获取权限状态
    [manager getEnabledStatusForExtensionWithIdentifier:@"com.demo.ckphone.PhoneCallKit" completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
        NSString *title = nil;
        int perStatus = 0;
        if (!error) {
            if (enabledStatus == CXCallDirectoryEnabledStatusDisabled) {
                /*
                 CXCallDirectoryEnabledStatusUnknown = 0,
                 CXCallDirectoryEnabledStatusDisabled = 1,
                 CXCallDirectoryEnabledStatusEnabled = 2,
                 */
                title = @"来电弹屏功能未授权，请在'设置'->'电话'->'来电阻止与身份识别'中授权";
                perStatus = 0;
            }else if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
                title = @"来电弹屏功能已授权";
                 perStatus = 1;
                
            }else if (enabledStatus == CXCallDirectoryEnabledStatusUnknown) {
                title = @"未知错误";
                 perStatus = -1;
            }
        }else{
            title = @"有错误";
        }
       
        if(perStatus == 1){
            [self saveCallKitData];
        } else if(perStatus == 0){
            [self showAlertMsg:title];
            
        } else {
            [CVAlertTool showTip:title onView:self.navigationController.view];
        }
    }];

}

- (BOOL)saveCallKitData {
    NSString *name = _nameLabel.text;
    NSString *phone = [NSString stringWithFormat:@"86%@", _phoneLabel.text ];
    if([name isEqualToString:@""]){
        return NO;
    }
    
    if([phone isEqualToString:@"86"]){
        return NO;
    }
    NSDictionary *data = @{
                           @"name" : name,
                           @"phone" : phone
                           };
   
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ckphone.app"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/callKitData"];
    
    [containerURL removeAllCachedResourceValues];
    BOOL result = [data writeToURL:containerURL atomically:YES];
    if (!result) {
        [CVAlertTool showTip:@"数据保存失败！" onView:self.navigationController.view];
    } else {
        [CVAlertTool showTip:@"数据保存成功！" onView:self.navigationController.view];
        [self updateCallKitData];
    }
    return result;
}

- (void)updateCallKitData{
    CXCallDirectoryManager *manager = [CXCallDirectoryManager sharedInstance];
    [manager reloadExtensionWithIdentifier:@"com.demo.ckphone.PhoneCallKit" completionHandler:^(NSError * _Nullable error) {
        
        NSString *message;
        if (error == nil) {
            message = @"弹屏数据更新成功";
        }else{
            message = @"弹屏数据更新失败";
        }
       
        [CVAlertTool showTip:message onView:self.navigationController.view];
       
    }];
}

- (void) showAlertMsg:(NSString *)alertMsg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertMsg message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = @"App-Prefs:root=Phone";
        [self openScheme:url];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    });
   
}






@end
