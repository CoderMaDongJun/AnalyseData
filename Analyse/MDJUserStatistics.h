//
//  MDJUserStatistics.h
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDJUserStatistics : NSObject

/**
 *  初始化配置，一般在launchWithOption中调用
 */
+ (void)MDJ_configure;

+ (void)MDJ_enterPageViewWithPageID:(NSString *)pageID;

+ (void)MDJ_leavePageViewWithPageID:(NSString *)pageID;

+ (void)MDJ_sendEventToServer:(NSString *)eventId;

@end
