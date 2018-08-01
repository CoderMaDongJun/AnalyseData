//
//  MDJUserStatistics.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "MDJUserStatistics.h"

@implementation MDJUserStatistics

/**
 *  初始化配置，一般在launchWithOption中调用
 */
+ (void)MDJ_configure
{
    
}

#pragma mark -- 页面统计部分

+ (void)MDJ_enterPageViewWithPageID:(NSString *)pageID
{
    //进入页面
    NSLog(@"***模拟发送[进入页面]事件给服务端，页面ID:%@", pageID);
}

+ (void)MDJ_leavePageViewWithPageID:(NSString *)pageID
{
    //离开页面
    NSLog(@"***模拟发送[离开页面]事件给服务端，页面ID:%@", pageID);
}


#pragma mark -- 自定义事件统计部分


+ (void)MDJ_sendEventToServer:(NSString *)eventId
{
    //在这里发送event统计信息给服务端
    NSLog(@"***模拟发送统计事件给服务端，事件ID: %@", eventId);
}
@end
