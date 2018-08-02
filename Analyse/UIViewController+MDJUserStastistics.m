//
//  UIViewController+MDJUserStastistics.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "UIViewController+MDJUserStastistics.h"
#import "MDJHookUtility.h"
#import "MDJAnalyseClick.h"

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
    BOOL timer = [self DDY_pageTimer];
    BOOL EV = [self DDY_pageEV];
    NSString *pageID = [self MDJ_pageEventID];
    
    // 是否需要计时
    if (timer) {
        [MDJAnalyseClick DDY_beginLogPageView:pageID];
    }
    
    // 是否需要统计曝光
    if (EV) {
        [MDJAnalyseClick DDY_exposureFromPage:pageID];
    }
}

- (void)inject_viewWillDisappear
{
    BOOL timer = [self DDY_pageTimer];
    NSString *pageID = [self MDJ_pageEventID];
    if (timer) {
        [MDJAnalyseClick DDY_endLogPageView:pageID];
    }
}

- (BOOL)DDY_pageEV
{
    NSDictionary *configDict = DDYAdditionInstance.configurePlist;
    NSString *selfClassName = NSStringFromClass([self class]);
    return [configDict[selfClassName][@"PageIDs"][@"EV"] boolValue];
}

- (BOOL)DDY_pageTimer
{
    NSDictionary *configDict = DDYAdditionInstance.configurePlist;
    NSString *selfClassName = NSStringFromClass([self class]);
    return [configDict[selfClassName][@"PageIDs"][@"Timer"] boolValue];
}

- (NSString *)MDJ_pageEventID
{
    NSDictionary *configDict = DDYAdditionInstance.configurePlist;
    NSString *selfClassName = NSStringFromClass([self class]);
    return configDict[selfClassName][@"PageEventIDs"][@"PageId"];
}

@end
