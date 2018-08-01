//
//  UIViewController+MDJUserStastistics.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "UIViewController+MDJUserStastistics.h"
#import "MDJHookUtility.h"
#import "MDJUserStatistics.h"

@implementation UIViewController (MDJUserStastistics)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(swiz_viewWillAppear:);
        [MDJHookUtility MDJ_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
        
        SEL originalSelector2 = @selector(viewWillDisappear:);
        SEL swizzledSelector2 = @selector(swiz_viewWillDisappear:);
        [MDJHookUtility MDJ_swizzlingInClass:[self class] originalSelector:originalSelector2 swizzledSelector:swizzledSelector2];
    });
}

#pragma mark - Method Swizzling

- (void)swiz_viewWillAppear:(BOOL)animated
{
    //插入需要执行的代码
    [self inject_viewWillAppear];
    [self swiz_viewWillAppear:animated];
}

- (void)swiz_viewWillDisappear:(BOOL)animated
{
    [self inject_viewWillDisappear];
    [self swiz_viewWillDisappear:animated];
}

// 利用hook 统计所有页面的停留时长
- (void)inject_viewWillAppear
{
    NSString *pageID = [self MDJ_pageEventID:YES];
    if (pageID) {
        [MDJUserStatistics MDJ_sendEventToServer:pageID];
    }
}

- (void)inject_viewWillDisappear
{
    NSString *pageID = [self MDJ_pageEventID:NO];
    if (pageID) {
        [MDJUserStatistics MDJ_sendEventToServer:pageID];
    }
}

- (NSString *)MDJ_pageEventID:(BOOL)bEnterPage
{
    NSDictionary *configDict = [self MDJ_dictionaryFromUserStatisticsConfigPlist];
    NSString *selfClassName = NSStringFromClass([self class]);
    return configDict[selfClassName][@"PageEventIDs"][bEnterPage ? @"Enter" : @"Leave"];
}

- (NSDictionary *)MDJ_dictionaryFromUserStatisticsConfigPlist
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MDJGlobalUserStatisticsConfig" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dic;
}
@end
