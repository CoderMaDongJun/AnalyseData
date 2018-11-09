//
//  UITableView+MDJTableView.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/10/9.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "UITableView+MDJTableView.h"
#import "MDJHookUtility.h"

@implementation UITableView (MDJTableView)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(tableView:didSelectRowAtIndexPath:);
        SEL swizzledSelector = @selector(swiz_tableView:didSelectRowAtIndexPath:);
        [MDJHookUtility MDJ_swizzlingInClass:[self class] originalSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}

#pragma mark - Method Swizzling
- (void)swiz_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath.row:%zd",indexPath.row);
    
    [self swiz_tableView:tableView didSelectRowAtIndexPath:indexPath];
}
@end
