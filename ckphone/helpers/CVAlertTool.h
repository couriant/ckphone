//
//  CVAlertToo.h
//  JRCloud
//  弹出提示框提示类
//  Created by 张晓龙 on 2016/12/1.
//  Copyright © 2016年 张晓龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CVAlertTool : NSObject
/*
 * @brief 弹框提示
 * @param tip 提示语
 * @param view 展示的视图
 */
+ (void) showTip:(NSString *)tip onView:(UIView *)view;


/*
 * @brief 指示器提示
 * @param tip 提示语
 * @param view 展示的视图
 */
+ (void) showActiveTip:(NSString *)tip onView:(UIView *)view;

/*
 * @brief 隐藏指示器提示
 */
+ (void) hideActiveTipFromView:(UIView *) view;


@end
