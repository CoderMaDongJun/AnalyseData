//
//  UIControl+MDJUserStastistics.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "UIControl+MDJUserStastistics.h"
#import "MDJHookUtility.h"
#import "MDJUserStatistics.h"

@implementation UIControl (MDJUserStastistics)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(sendAction:to:forEvent:);
        SEL swizzledSelector = @selector(swiz_sendAction:to:forEvent:);
        [MDJHookUtility MDJ_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}


#pragma mark - Method Swizzling

- (void)swiz_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;
{
    //插入埋点代码
    [self performUserStastisticsAction:action to:target forEvent:event];
    [self swiz_sendAction:action to:target forEvent:event];
}

- (void)performUserStastisticsAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;
{
    //NSLog(@"\n***hook success.\n[1]action:%@\n[2]target:%@ \n[3]event:%@", NSStringFromSelector(action), target, event);
    NSString *eventID = nil;
    //只统计触摸结束时
    if ([[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
        NSString *actionString = NSStringFromSelector(action);
        NSString *targetName = NSStringFromClass([target class]);
        NSDictionary *configDict = [self dictionaryFromUserStatisticsConfigPlist];
        eventID = configDict[targetName][@"ControlEventIDs"][actionString];
    }
    if (eventID != nil) {
        [MDJUserStatistics MDJ_sendEventToServer:eventID];
    }
}

- (NSDictionary *)dictionaryFromUserStatisticsConfigPlist
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MDJGlobalUserStatisticsConfig" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return dic;
}

@end
