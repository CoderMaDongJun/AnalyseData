//
//  MDJHookUtility.h
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDJHookUtility : NSObject
+ (void)MDJ_swizzlingInClass:(Class)cls originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
@end
