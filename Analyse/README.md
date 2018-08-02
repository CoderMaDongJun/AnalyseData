# DDYAnalyse SDK
简单易用的埋点SDK
初始化项目，在AppDelegate.m内
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions方法内添加以下任一发送策略的代码即可
## 无埋点操作原理
### 1、初始化
### 2、通过顶层数据采集window将target、action写入到plist文件内
### 3、将内部发送数据的url改为自己的服务器url即可。
#### 缺点：无法附加内部精确数据
#### 优点：需要统计的点，（采集工程）屏幕圈选即可，发版工程仅需写2行左右初始化代码即可，不用侵入工程。
#### 目前代码状态是未写入数据采集window，plist还需要手动维护，相对侵入工程的埋点，已简化很多。待下次补充。


## 初始化
### 1.发送策略：DDYDefault
``` objc
[DDYClick DDY_startWithConfigure:DDYConfigInstance];
```
### 2.发送策略：DDYSend_Interval
``` objc
DDYConfigInstance.ePolicy = DDYSend_Interval;
[DDYClick DDY_setLogSendInterval:90];
[DDYClick DDY_startWithConfigure:DDYConfigInstance];
```
### 3.发送策略：DDYSend_Count
``` objc
DDYConfigInstance.ePolicy = DDYSend_Count;
[DDYClick DDY_startWithConfigure:DDYConfigInstance];
```
## 页面计时事件
### 1.页面开始计时的地方
``` objc
- (void)viewWillAppear:(BOOL)animated
{
[super viewWillAppear:animated];

[DDYClick DDY_beginLogPageView:@"pageId"];
}
```
### 2.页面计时结束的地方
#### attributes根据自己的埋点规则可自定义，也可为nil
``` objc
- (void)viewWillDisappear:(BOOL)animated
{
[super viewWillDisappear:animated];

[DDYClick DDY_endLogPageView:@"pageId" attributes:@{DDY_pidKey:@"pid=1"
,DDY_permanent_idKey:@"API_id"
}];
}
```
## 页面点击事件
#### attributes根据自己的埋点规则可自定义，也可为nil
``` objc
[DDYClick DDY_event:@"eventId_4002" attributes:@{
DDY_pageIdKey:@"pageId_1003",
DDY_pidKey:@"pid=2378",
DDY_linkurlKey:@"product://pid=40082",
DDY_contentKey:@"floor=xxx#tab=xxx",
DDY_expandKey:@"(1002||||floor=B版主题馆1-1)(||||)(||||)"
}];
```

## 使用情况举例
### DDYGlobalPageIDConfig.plist 内的数据结构解析:
1、name:页面名称
2、EventIDs:进入该页面的点击事件统称，如有n个按钮点击都进入目标页面，那么n个按钮的点击事件都为该值
3、PageIDs 下有3个字段，Enter代表目标页面pageId，EV代表目标页面是否需要曝光，Timer代表目标页面是否需要曝光计时

### 点击事件解析
##### 情况1 继承UIControl的事件添加都能统计。

### 曝光事件解析
##### 情况1 页面曝光：将需要曝光统计的页面的名称，按格式写入DDYGlobalPageIDConfig.plist即可完成统计
##### 情况2 模块曝光：在触发模块曝光的位置调用```+ (void)DDY_exposureFromPage:(nonnull NSString *)pageId attributes:(nullable NSDictionary *)attributes;``` ，完成参数(参数见方法注释)传入，即可完成模块曝光统计

### 页面计时事件解析
##### 情况1 页面计时：将需要计时统计的页面的名称，按格式写入DDYGlobalPageIDConfig.plist即可完成统计
##### 情况2 模块计时：在触发模块的位置先调用```+ (void)DDY_beginLogPageView:(nonnull NSString *)pageId;``` ，在模块退出的位置调用```+ (void)DDY_endLogPageView:(nonnull NSString *)pageId attributes:(nullable NSDictionary *)attributes;```，完成参数(参数见方法注释)传入，即可完成模块计时统计


