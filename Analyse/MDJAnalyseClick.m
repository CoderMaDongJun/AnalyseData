//
//  MDJAnalyseClick.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/2.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "MDJAnalyseClick.h"
#import <LKDBHelper.h>
#import <UIKit/UIKit.h>
#import <AdSupport/ASIdentifierManager.h>

/** 判断字符串是否为空 */
#define DDYStrIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length]<1 ? YES : NO )
#define DDYSpecialKey(pageName) ([NSString stringWithFormat:@"DDY_%@",pageName])
#define DDYForamtNode(node) [NSString stringWithFormat:@"[%@]",node?node:@""]
#define DDYDeviceIDFA [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]
#define DDYDeviceType [[UIDevice currentDevice] model]
#define DDYDeviceSystem [[UIDevice currentDevice] systemVersion]
#define DDYXcodeAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define DDYXcodeAppBuild [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define DDYXcodeAppBundleIdentifier [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define DDYSafePermanentId [[NSUserDefaults standardUserDefaults] objectForKey:@"permanentId"]?:@""
#define DDYSafeDic(attributes,value) [attributes valueForKey:value]?:@""

// 常量
NSString * const DDY_pageIdKey = @"DDY_page_IdKey";
NSString * const DDY_prePageIdKey = @"DDY_prePageIdKey";
NSString * const DDY_pidKey = @"DDY_pidKey";
NSString * const DDY_prePidKey = @"DDY_prePidKey";
NSString * const DDY_exposureTypeKey = @"DDY_exposureTypeKey";
NSString * const DDY_linkurlKey = @"DDY_linkurlKey";
NSString * const DDY_contentKey = @"DDY_contentKey";
NSString * const DDY_expandKey = @"DDY_expandKey";
static NSString * const DDYAppKey = @"DDYAppKey";
static NSString * const DDYAppSecret = @"DDYAppSecret";
static double const DDY_minSecond = 90;
static double const DDY_maxSecond = 86400;
static NSInteger const DDY_sendCount = 10;
static NSString * const DDY_serverUrl = @"http://databack.dangdang.com/eapp.php";
static NSString * const DDY_AnalyseTableName = @"DDYAnalyse.db";

/** 动作类型 */
typedef NS_ENUM (NSUInteger, DDYActionType)
{
    DDYActionTypePV = 1,                    // PV
    DDYActionTypeClick = 2,                 // 点击
    DDYActionTypeAppear = 3,                // 曝光（楼层）
    DDYActionTypeTime = 4,                  // 时间
    DDYActionTypeLastLocation = 7,          // 页面或模块最后位置（推荐用）
};

@interface DDYAnalyticsConfig()
/** optional:  UDID */
@property(nonatomic, copy,nullable) NSString *udId;
/** optional:  custId,default:0 */
@property(nonatomic, copy,nullable) NSString *custId;
/** optional:  APP版本号,default:自动获取 */
@property(nonatomic, copy,nullable) NSString *version;
/** optional:  APP构建build号,default:自动获取 */
@property(nonatomic, copy,nullable) NSString *build;
/** optional:  设备类型:iphone/android/ipad,default:自动获取 */
@property(nonatomic, copy,nullable) NSString *deviceType;
/** optional:  操作系统信息，default:自动获取 */
@property(nonatomic, copy,nullable) NSString *osInfo;
/** optional:  广告标识符,default:自动获取 */
@property(nonatomic, copy,nullable) NSString *ddYIdfa;
@end

@implementation DDYAnalyticsConfig
#pragma mark - private
static DDYAnalyticsConfig *_instanceConfig;
+ (_Nonnull instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceConfig = [[[self class] alloc] init];
        
        // 初始值
        _instanceConfig.appKey = DDYAppKey;
        _instanceConfig.secret = DDYAppSecret;
        _instanceConfig.channelId = @"537-50";
        _instanceConfig.ePolicy = DDYDefault;
        _instanceConfig.eSType = DDY_NORMAL;
    });
    return _instanceConfig;
}

+ (NSString*)getTableName
{
    return NSStringFromClass([self class]);
}

+ (NSString*)getPrimaryKey
{
    return @"appKey";
}

+ (NSArray*)getPrimaryKeyUnionArray
{
    return nil;
}

+ (LKDBHelper*)getUsingLKDBHelper
{
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db)
        {
            NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *path = [array.firstObject stringByAppendingPathComponent:@"DDYAnalyse"];
            path = [path stringByAppendingPathComponent:DDY_AnalyseTableName];
            DDYLog(@"\n%@ -- path:%@\n",NSStringFromClass([self class]),path);
            db = [[LKDBHelper alloc] initWithDBPath:path];
        }
    });
    return db;
}

+ (NSMutableArray<DDYAnalyticsConfig *> *)searchAllDatas
{
    NSString *baseSql = [NSString stringWithFormat:@"select * from %@",NSStringFromClass([self class])];
    LKDBHelper *baseHelper = [DDYAnalyticsConfig getUsingLKDBHelper];
    NSMutableArray *baseResults = [baseHelper searchWithSQL:baseSql toClass:[DDYAnalyticsConfig class]];
    return baseResults;
}
@end

/** @brief 统计的个性化定制，创建DDYAnalyticsConfig表，表内字段特点是：需要频繁更改。因App不同，使用规则不同，根据自己业务规则，适当增、删DDYAnalyticsConfig属性，删除之前的运行App，再次运行即可。
 */
@interface DDYAnalyticsNodeConfigure : NSObject
/** optional:  埋点产生时间 */
@property(nonatomic) NSInteger rowid;
/** optional:  埋点产生时间 */
@property(nonatomic, copy) NSString *startTime;
/** optional:  页面id */
@property(nonatomic, copy) NSString *page_id;
/** optional:  当前页标识 */
@property(nonatomic, copy) NSString *pid;
/** optional:  事件id */
@property(nonatomic, copy) NSString *event_id;
/** optional:  页面停留时长 */
@property(nonatomic, copy) NSString *duration;
/** optional:  去向页面标识 */
@property(nonatomic, copy) NSString *linkurl;
/** optional:  页面点击内容 */
@property(nonatomic, copy) NSString *content;
/** optional:  来源页page_id */
@property(nonatomic, copy) NSString *refer_pageid;
/** optional:  来源页标识 */
@property(nonatomic, copy) NSString *refer_detailPageid;
/** optional:  动作类型 */
@property(nonatomic,assign) DDYActionType action_type;
/** optional:  接口给的标示 */
@property(nonatomic, copy) NSString *permanent_id;
/** optional:  扩展，三级ref */
@property(nonatomic, copy) NSString *expand;
@end


@implementation DDYAnalyticsNodeConfigure
#pragma mark - private
+ (NSString*)getTableName
{
    return NSStringFromClass([self class]);
}

+ (NSString*)getPrimaryKey
{
    return @"rowid";
}

+ (NSArray*)getPrimaryKeyUnionArray
{
    return nil;
}
static NSRecursiveLock*_DDYLock;
+ (LKDBHelper*)getUsingLKDBHelper
{
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db)
        {
            _DDYLock = [[NSRecursiveLock alloc] init];
            NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *path = [array.firstObject stringByAppendingPathComponent:@"DDYAnalyse"];
            path = [path stringByAppendingPathComponent:DDY_AnalyseTableName];
            DDYLog(@"\n%@ -- path:%@\n",NSStringFromClass([self class]),path);
            db = [[LKDBHelper alloc] initWithDBPath:path];
        }
    });
    return db;
}

+ (NSMutableArray<DDYAnalyticsNodeConfigure *> *)searchAllDatas
{
    NSString *difSql = [NSString stringWithFormat:@"select * from %@",NSStringFromClass([self class])];
    LKDBHelper *difHelper = [DDYAnalyticsNodeConfigure getUsingLKDBHelper];
    NSMutableArray *difResults = [difHelper searchWithSQL:difSql toClass:[DDYAnalyticsNodeConfigure class]];
    return difResults;
}

- (BOOL)saveToDB
{
    [_DDYLock lock];
    BOOL flag = [super saveToDB];
    [_DDYLock unlock];
    // 检测是否满10条数据
    if (DDYConfigInstance.ePolicy == DDYSend_Count) {
        NSMutableArray<DDYAnalyticsNodeConfigure *> *difResults = [DDYAnalyticsNodeConfigure searchAllDatas];
        DDYLog(@"\n目前数据个数:%lzd",difResults.count);
        if (difResults.count >= DDY_sendCount) {
            [MDJAnalyseClick DDY_sendDataToServer];
        }
    }
    return flag;
}
@end

@interface DDYAddition ()
@property (nonatomic, strong,readwrite) NSDictionary *configurePlist;
@end
@implementation DDYAddition
static DDYAddition *_instanceAddition;
+ (_Nonnull instancetype)sharedAddition
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceAddition = [[[self class] alloc] init];
    });
    return _instanceAddition;
}

- (NSDictionary *)configurePlist
{
    if (!_configurePlist) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"GlobalConfig" ofType:@"plist"];
        _configurePlist = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return _configurePlist;
}

@end

@interface DDYSendModel : NSObject
/** 待发送的拼接数据*/
@property (nonatomic ,copy) NSMutableString *DDY_sendDatas;
/** 数据的rowid，备成功后删除使用 */
@property (nonatomic ,strong) NSMutableArray *rowids;
@end

@implementation DDYSendModel
@end


typedef void (^DDYResponseCallback)(BOOL success);
@interface DDYNetworkAPI : NSObject
+ (void)postData:(NSString *)data complete:(DDYResponseCallback)callback;
@end

@implementation DDYNetworkAPI
+ (void)postData:(NSString *)string complete:(nonnull DDYResponseCallback)callback
{
#if 1
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        callback(YES);
    });
#else
    // post
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DDY_serverUrl]];
    requestM.HTTPMethod = @"POST";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 创建请求 Task
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:requestM fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSString *msg = error.userInfo[@"NSLocalizedDescription"];
            DDYLog(@"%s-%d:%@",__FILE__,__LINE__,msg);
            callback(NO);
        }else{
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            long status = [dic[@"status"] longValue];
            if (status == 200) {
                callback(YES);
            }else if (status == 403){
                DDYLog(@"\n 数据格式异常拒绝访问\n");
            }else if (status == 404){
                DDYLog(@"\n 未找到kafka相关配置\n");
            }
        }
    }];
    [uploadTask resume];
#endif
}

@end

@implementation MDJAnalyseClick
#pragma mark - private
- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

+ (NSString *)DDY_stringTime:(nonnull NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark - public
#pragma mark - 初始化基础配置
static NSTimer *_timer = nil;
+ (void)DDY_startWithConfigure:(nonnull DDYAnalyticsConfig *)config
{
    // 附加基础属性赋值
    config.udId = config.udId;
    config.version = DDYXcodeAppVersion;
    config.build = DDYXcodeAppBuild;
    config.deviceType = DDYDeviceType;
    config.osInfo = [NSString stringWithFormat:@"%@,%@,%.1f,%.1f",DDYDeviceSystem,TARGET_IPHONE_SIMULATOR?@"x86_64":DDYDeviceType,CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds)];
    config.custId = @"0";
    config.ddYIdfa = config.needIdfa?DDYDeviceIDFA:@"";
    [config saveToDB];
     
    // 发送策略判断
    if (config.ePolicy == DDYSend_Interval && _timer) {
        [_timer fire];
    }else if (config.ePolicy == DDYDefault){
        [self DDY_sendDataToServer];
    }
}

+ (void)DDY_setLogSendInterval:(double)second
{
#if DEBUG
    NSAssert((second>=DDY_minSecond && second<=DDY_maxSecond), @"定时器时间设置有误，应在90~86400秒之内");
#endif
    if (second < DDY_minSecond || second > DDY_maxSecond) return;
    
    // 定时器设定，触发发送统计结果
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:second target:self selector:@selector(DDY_sendDataToServer) userInfo:nil repeats:YES];
        _timer = timer;
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}
+ (void)DDY_setCustId:(NSString *)custId
{
    DDYConfigInstance.custId = custId;
    [DDYConfigInstance saveToDB];
}

#pragma mark -- 计时统计
+ (void)DDY_beginLogPageView:(nonnull NSString *)pageId
{
    if (DDYStrIsEmpty(pageId)) return;
    
    NSDate *start = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:start forKey:DDYSpecialKey(pageId)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)DDY_endLogPageView:(nonnull NSString *)pageId
{
    [self DDY_endLogPageView:pageId attributes:nil];
}

+ (void)DDY_endLogPageView:(nonnull NSString *)pageId attributes:(nullable NSDictionary *)attributes
{
    if (DDYStrIsEmpty(pageId)) return;
    
    NSDate *start = [[NSUserDefaults standardUserDefaults] objectForKey:DDYSpecialKey(pageId)];
    if (!start) return;
    NSDate *end = [NSDate date];
    NSTimeInterval different = [end timeIntervalSinceDate:start];
    NSInteger duration = nearbyintl(different);
    
    // 移除保存的时间
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DDYSpecialKey(pageId)];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 记录曝光时间
    DDYAnalyticsNodeConfigure *configure = [[DDYAnalyticsNodeConfigure alloc] init];
    configure.startTime = [self DDY_stringTime:start];
    configure.page_id = pageId;
    configure.event_id = @"6002";
    configure.duration = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:duration]];
    configure.action_type = DDYActionTypeTime;
    configure.permanent_id = DDYSafePermanentId;
    
    if (attributes && attributes.count > 0) {
        // pid
        configure.pid = DDYSafeDic(attributes, DDY_pidKey);
        
        // prePageid
        configure.refer_pageid = DDYSafeDic(attributes, DDY_prePageIdKey);
        
        // prePid
        configure.refer_detailPageid = DDYSafeDic(attributes, DDY_prePidKey);
    }
    [configure saveToDB];
}

#pragma mark - 事件统计
+ (void)DDY_event:(nonnull NSString *)eventId
{
    [self DDY_event:eventId attributes:nil];
}

+ (void)DDY_event:(nonnull NSString *)eventId attributes:(nullable NSDictionary *)attributes
{
    if (DDYStrIsEmpty(eventId)) return;
    
    DDYAnalyticsNodeConfigure *configure = [[DDYAnalyticsNodeConfigure alloc] init];
    configure.startTime = [self DDY_stringTime:[NSDate date]];
    configure.event_id = eventId;
    configure.action_type = DDYActionTypeClick;
    configure.permanent_id = DDYSafePermanentId;
    
    // 记录详细数据
    if (attributes && attributes.count > 0) {
        // pageId
        configure.page_id = DDYSafeDic(attributes,DDY_pageIdKey);
        
        // pid
        configure.pid = DDYSafeDic(attributes,DDY_pidKey);
        
        // linkurl
        configure.linkurl = DDYSafeDic(attributes,DDY_linkurlKey);
        
        // content
        configure.content = DDYSafeDic(attributes,DDY_contentKey);
        
        // expand
        configure.expand = DDYSafeDic(attributes,DDY_expandKey);
    }
    [configure saveToDB];
}

+ (void)DDY_exposureFromPage:(NSString *)pageId
{
    [self DDY_exposureFromPage:pageId attributes:nil];
}

+ (void)DDY_exposureFromPage:(nonnull NSString *)pageId attributes:(nullable NSDictionary *)attributes
{
    if (DDYStrIsEmpty(pageId)) return;
    
    DDYAnalyticsNodeConfigure *configure = [[DDYAnalyticsNodeConfigure alloc] init];
    configure.startTime = [self DDY_stringTime:[NSDate date]];
    configure.event_id = @"6000";
    configure.action_type = DDYActionTypePV;// 默认是页面曝光
    configure.permanent_id = DDYSafePermanentId;
    configure.page_id = pageId;
    
    // 记录详细数据
    if (attributes && attributes.count > 0) {
        // pid
        configure.pid = DDYSafeDic(attributes, DDY_pidKey);
        
        // prePageid
        configure.refer_pageid = DDYSafeDic(attributes, DDY_prePageIdKey);
        
        // prePid
        configure.refer_detailPageid = DDYSafeDic(attributes, DDY_prePidKey);
        
        // actionType
        if ([attributes.allKeys containsObject:DDY_exposureTypeKey]) {
            NSInteger exposureType = [attributes[DDY_exposureTypeKey] integerValue];
            configure.action_type = exposureType;
        }
        
    }
    [configure saveToDB];
}

#pragma mark - 数据的获取
+ (DDYSendModel *)DDY_getBuryNodeFromSql
{
    // 获取 DDYAppInfo表 基础数据(1条)
    NSMutableArray<DDYAnalyticsConfig *> *baseResults = [DDYAnalyticsConfig searchAllDatas];
    NSAssert(baseResults.count>0, @"数据库 DDYAnalyticsConfig表 出现问题");
    
    // 获取 DDYAnalyticsNodeConfigure表 差异数据(n条)
    NSMutableArray<DDYAnalyticsNodeConfigure *> *difResults = [DDYAnalyticsNodeConfigure searchAllDatas];
    
    // 组合成要发送的数据格式
    NSMutableString *datas = [NSMutableString stringWithString:@"log_data="];
    [difResults enumerateObjectsUsingBlock:^(DDYAnalyticsNodeConfigure * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *data = [self DDY_takeDatasWithInfo:baseResults[0] configureation:obj];
        [datas appendString:data];
        [datas appendString:@"\n"];
    }];
    
    // 最终要发送出去的数据
    DDYSendModel *model = [[DDYSendModel alloc] init];
    model.DDY_sendDatas = datas;
    model.rowids = [difResults valueForKeyPath:@"self.rowid"];
    
    DDYLog(@"\n==rowids:%@ sendDatas== %@ \n",model.rowids,model.DDY_sendDatas);
    
    return model;
}

// 按文档要求拼接字段
+ (NSString *)DDY_takeDatasWithInfo:(nonnull DDYAnalyticsConfig *)info configureation:(nonnull DDYAnalyticsNodeConfigure *)configure
{
    NSMutableString *data = [[NSMutableString alloc] init];
    [data appendString:DDYForamtNode(configure.startTime)];
    [data appendString:DDYForamtNode(info.udId)];
    [data appendString:DDYForamtNode(info.custId)];
    [data appendString:DDYForamtNode(configure.page_id)];
    [data appendString:DDYForamtNode(configure.event_id)];
    [data appendString:DDYForamtNode(info.deviceType)];
    [data appendString:DDYForamtNode(info.version)];
    [data appendString:DDYForamtNode(info.osInfo)];
    [data appendString:DDYForamtNode(configure.pid)];
    [data appendString:DDYForamtNode(configure.duration)];
    [data appendString:DDYForamtNode(info.channelId)];
    [data appendString:DDYForamtNode(configure.linkurl)];
    [data appendString:DDYForamtNode(configure.content)];
    [data appendString:DDYForamtNode(configure.refer_pageid)];
    [data appendString:DDYForamtNode(configure.refer_detailPageid)];
    [data appendString:DDYForamtNode((NSNumber*)(@(configure.action_type)))];
    [data appendString:DDYForamtNode(configure.permanent_id)];
    [data appendString:(configure.action_type == DDYActionTypeClick) ? DDYForamtNode(configure.expand):@"[(||||)(||||)(||||)]"];
    [data appendString:@"[]"];
    [data appendString:DDYForamtNode(info.ddYIdfa)];
    return data;
}

#pragma mark - 删除
+ (void)DDY_deleteWithRowids:(nonnull NSArray *)rowids
{
    [_DDYLock lock];
    NSString *sql = [NSString stringWithFormat:@"rowid in %@",rowids];
    BOOL flag = [DDYAnalyticsNodeConfigure deleteWithWhere:sql];
    [_DDYLock unlock];
    DDYLog(@"\n数据删除结果,flag:%d \n",flag);
}

+ (void)DDY_clearTableDataWithTableName:(nullable NSString *)tableName
{
    // 删除所有的表
    //    LKDBHelper* globalHelper = [DDYAnalyticsNodeConfigure getUsingLKDBHelper];
    //    [globalHelper dropAllTable];
    
    // 删除某个表内所有数据
    tableName = tableName?tableName:@"DDYAnalyticsNodeConfigure";
    [LKDBHelper clearTableData:NSClassFromString(tableName)];
}

#pragma mark - 发送
+ (void)DDY_sendDataToServer
{
    __weak __typeof(self)weakSelf = self;
    [_DDYLock lock];
    DDYSendModel *model = [MDJAnalyseClick DDY_getBuryNodeFromSql];
    [_DDYLock unlock];
    if (model.rowids.count == 0){
        DDYLog(@"\n一条数据也没有，暂停本次发送%@\n",[NSThread currentThread]);
        return;
    }
    
    [DDYNetworkAPI postData:model.DDY_sendDatas complete:^(BOOL success) {
        
        if (success) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            DDYLog(@"\n发送数据成功\n rowid:%@ \n data:%@\n",model.rowids[0],[model.DDY_sendDatas substringFromIndex:9]);
            
            [strongSelf DDY_deleteWithRowids:model.rowids];
        }
    }];
}

@end
