//
//  MDJAnalyseClick.h
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/2.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 发送策略 */
typedef enum {
    DDYDefault = 1,          // 启动发送
    DDYSend_Interval = 2,    // 最小间隔发送
    DDYSend_Count = 3,       // 满10条发送
} DDY_ReportPolicy;

/** 统计的场景类别 */
typedef NS_ENUM (NSUInteger, DDY_eScenarioType)
{
    DDY_NORMAL = 0,    // default value
    DDY_OTHER = 1,      // 保留字段
};

/** 页面id常量 */
extern NSString *_Nonnull const DDY_pageIdKey;
/** 产品详细id常量 */
extern NSString *_Nonnull const DDY_pidKey;
/** 上一页面id常量 */
extern NSString *_Nonnull const DDY_prePageIdKey;
/** 上一页产品详细id常量 */
extern NSString *_Nonnull const DDY_prePidKey;
/** 去向页面标识常量 */
extern NSString *_Nonnull const DDY_linkurlKey;
/** 页面点击内容 */
extern NSString *_Nonnull const DDY_contentKey;
/** 扩展三级refer */
extern NSString *_Nonnull const DDY_expandKey;
/** 页面曝光类型 */
extern NSString *_Nonnull const DDY_exposureTypeKey;

#ifdef DEBUG
# define DDYLog(...) NSLog(__VA_ARGS__)
#else
# define DDYLog(...)
#endif

/** @brief 基础数据配置，数据库（DDYAppInfo）建立。。
 */
#define DDYConfigInstance [DDYAnalyticsConfig sharedInstance]
@interface DDYAnalyticsConfig : NSObject
/** optional:  appkey ,保留字段 */
@property(nonatomic, copy,nullable) NSString *appKey;
/** optional:  secret,保留字段 */
@property(nonatomic, copy,nullable) NSString *secret;
/** optional:  渠道id，default: "App Store"即537-50 */
@property(nonatomic, copy,nullable) NSString *channelId;
/** optional:  发送策略,default: DDYDefault */
@property(nonatomic) DDY_ReportPolicy   ePolicy;
/** optional:  统计的场景类别,default: DDY_NORMAL */
@property(nonatomic) DDY_eScenarioType  eSType;
/** optional: idfa采集,default:NO,不采集 */
@property(nonatomic) BOOL needIdfa;

/** 初始化调用该方法即可 */
+ (_Nonnull instancetype)sharedInstance;

@end

/**
 *  @brief 附加数据配置
 */
#define DDYAdditionInstance [DDYAddition sharedAddition]
@interface DDYAddition : NSObject
@property (nonatomic, strong,readonly) NSDictionary *configurePlist;
/** optional，若需要，去该页面将属性赋值即可 */
@property (nonatomic ,copy,nullable) NSString *DDYContent;
/** optional，若需要，去该页面将属性赋值即可 */
@property (nonatomic ,copy,nullable) NSString *DDYLinkUrl;
/** optional，扩展保留属性，启用时直接赋值即可 */
@property (nonatomic ,copy,nullable) NSString *DDY_expand;

+ (_Nonnull instancetype)sharedAddition;
@end

@interface MDJAnalyseClick : NSObject

#pragma mark basics
//-------------------------------------------------
// @name  初始化统计
//-------------------------------------------------
/** 初始化"当当云"统计模块
 @param config 实例类,具体参照该类成员的参数定义
 在AppDelegate.m内 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions方法中添加以下任一策略的代码即可
 示例代码 :
 
 1.DDYDefault
 [MDJAnalyseClick DDY_startWithConfigure:DDYConfigInstance];
 
 2.DDYSend_Interval
 DDYConfigInstance.ePolicy = DDYSend_Interval;
 [MDJAnalyseClick DDY_setLogSendInterval:90];
 [MDJAnalyseClick DDY_startWithConfigure:DDYConfigInstance];
 
 3.DDYSend_Count
 DDYConfigInstance.ePolicy = DDYSend_Count;
 [MDJAnalyseClick DDY_startWithConfigure:DDYConfigInstance];
 */
+ (void)DDY_startWithConfigure:(nonnull DDYAnalyticsConfig *)config;

/** 当DDY_ReportPolicy == DDYSend_Interval 时设定log发送间隔
 @param second 单位为秒,最小90秒,最大86400秒(24hour).
 */
+ (void)DDY_setLogSendInterval:(double)second;
+ (void)DDY_setCustId:(nonnull NSString*)custId;

//------------------------------------------------------
// @name  页面计时
//------------------------------------------------------
/** 自动页面时长统计, 开始记录某个页面展示时长.
 使用方法：必须配对调用DDY_beginLogPageView:和DDY_endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用DDY_beginLogPageView:，当退出该页面时调用DDY_endLogPageView:
 @param pageId 页面唯一标识id.
 */
+ (void)DDY_beginLogPageView:(nonnull NSString *)pageId;

/** 自动页面时长统计, 结束记录某个页面展示时长.
 使用方法：必须配对调用DDY_beginLogPageView:和DDY_endLogPageView:两个函数来完成自动统计，若只调用某一个函数不会生成有效数据。
 在该页面展示时调用DDY_beginLogPageView:，当退出该页面时调用DDY_endLogPageView:
 @param pageId 页面唯一标识id.
 */
+ (void)DDY_endLogPageView:(nonnull NSString *)pageId;

/** 动统计页面时长，当需要记录页面标识时调用此方法。
 @param pageId 页面唯一标识id
 @param attributes 附加属性字典,目前仅支持3个key
 示例代码:
 [MDJAnalyseClick DDY_endLogPageView:@"pageId" attributes:@{DDY_pidKey:@"pid",DDY_prePageIdKey:@"prePageId",DDY_prePidKey:@"prePid"
 }];
 */
+ (void)DDY_endLogPageView:(nonnull NSString *)pageId attributes:(nullable NSDictionary *)attributes;

//-------------------------------------------------------
// @name  事件统计
//-------------------------------------------------------
/** 自定义事件,数量统计.
 *  @param eventId 相应的事件ID.
 */
+ (void)DDY_event:(nonnull NSString *)eventId;

/** 自定义事件,数量统计.
 * @param eventId 相应的事件ID.
 * @param attributes 附加属性字典，目前仅支持5个key
 * 示例代码
 [MDJAnalyseClick DDY_event:@"eventId_4002" attributes:@{
 DDY_pageIdKey:@"pageId_1003",
 DDY_pidKey:@"pid=2378",
 DDY_linkurlKey:@"product://pid=40082",
 DDY_contentKey:@"floor=xxx#tab=xxx",
 DDY_expandKey:@"(1002||||floor=B版主题馆1-1)(||||)(||||)"
 }];
 */
+ (void)DDY_event:(nonnull NSString *)eventId attributes:(nullable NSDictionary *)attributes;

//-------------------------------------------------------
// @name  曝光统计 exposure
//-------------------------------------------------------
+ (void)DDY_exposureFromPage:(nonnull NSString *)pageId;

/** 自定义事件,曝光统计.
 * @param pageId 曝光的页面id.
 * @param attributes 附加属性字典,目前仅支持4个key
 * 示例代码
 [MDJAnalyseClick DDY_exposure:@"exposureId" attributes:@{
 DDY_pidKey:@"pid",
 DDY_prePageIdKey:@"pageId",
 DDY_prePidKey:@"prePid",
 DDY_exposureTypeKey:3 (页面曝光类型，传nil。模块曝光，传3)
 }];
 */
+ (void)DDY_exposureFromPage:(nonnull NSString *)pageId attributes:(nullable NSDictionary *)attributes;

/** 发送数据接口*/
+ (void)DDY_sendDataToServer;

/********************* ↓↓↓ Temp Code ↓↓↓ *******************/
/** 获取计时数据给服务端 ，暂时写此处 */
+ (nonnull id)DDY_getBuryNodeFromSql;

/** 删除记录数据 */
+ (void)DDY_deleteWithRowids:(nonnull NSArray *)rowids;

/** 删除整张表 */
+ (void)DDY_clearTableDataWithTableName:(nullable NSString *)tableName;
/********************* ↑↑↑ Temp Code ↑↑↑ *******************/
@end
