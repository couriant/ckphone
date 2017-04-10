//
//  CVAlertToo.m
//  JRCloud
//
//  Created by 张晓龙 on 2016/12/1.
//  Copyright © 2016年 张晓龙. All rights reserved.
//

#import "CVAlertTool.h"
#import "MBProgressHUD.h"
#define HUD_TAG  11111111
@interface CVAlertTool()

@end

@implementation CVAlertTool

+ (void) showTip:(NSString *)tip onView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = tip;
        hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        hud.label.textColor = [UIColor whiteColor];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MBProgressHUD hideHUDForView:view animated:YES];
        });
    });
   
}

+ (void) showActiveTip:(NSString *)tip onView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        hud.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        hud.label.text = tip;
        hud.label.textColor = [UIColor whiteColor];
    });
   
}

+ (void) hideActiveTipFromView:(UIView *) view{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:YES];

    });
}


@end
