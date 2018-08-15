//
//  BMChartComponent.m
//  BMBaseLibrary
//
//  Created by XHY on 2017/10/18.
//

#import "BMChartComponent.h"
#import <WeexSDK/WXSDKInstance_private.h>
#import <WeexSDK/WXComponent_internal.h>
#import <WebKit/WebKit.h>
#import "WXUtility.h"
#import "YYModel.h"


NSString * const ChartInfo = @"options";

@interface BMChartComponent()<WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic,strong) WKWebView *webview;    /**< webView */
@property (nonatomic,copy) NSString *chartInfo;     /**< 图标数据 */
@property (nonatomic, copy) NSString *src; /**< html文件路径 */

/** event */
@property (nonatomic,assign) BOOL finishEvent; /**< 图表加载完毕事件 */
@property (nonatomic,assign) BOOL clickEvent; /**< 图片点击事件 */

@end

@implementation BMChartComponent

WX_EXPORT_METHOD(@selector(reloadWithOption:))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        
        _finishEvent = NO;
        _clickEvent = NO;
        
        if (attributes[ChartInfo]) {
            _chartInfo = [NSString stringWithFormat:@"%@",attributes[ChartInfo]];
        }
        
        if (attributes[@"src"]) {
            self.src = [WXConvert NSString:attributes[@"src"]];
        }
        
        [self createWebView];
        
    }
    return self;
}

- (void)createWebView
{
    WXPerformBlockOnMainThread(^{
        //进行配置控制器
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        //实例化对象
        configuration.userContentController = [WKUserContentController new];
        
        //调用JS方法
        [configuration.userContentController addScriptMessageHandler:self name:@"click"];
        
        WKWebView *webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        webview.navigationDelegate = self;
        webview.scrollView.scrollEnabled = NO;
        webview.opaque = NO;
        self.webview = webview;
    
        if (!self.src) {
            [self loadHtmlFormBundle];
            return;
        }
        
        NSURL *htmlURL = [NSURL URLWithString:self.src];
        if ([htmlURL.scheme isEqualToString:BM_LOCAL]) {
            NSURL *htmlURL = TK_RewriteBMLocalURL(self.src);
            NSString *htmlStr = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:nil];
            [self.webview loadHTMLString:htmlStr baseURL:htmlURL];
        }
    });
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"click"]) {
        if(_clickEvent){
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message.body options:NSJSONWritingPrettyPrinted error:&error];
            NSString *data = @"{}";
            
            if (jsonData) {
                data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            [self fireEvent:@"click" params:@{@"status":@1,@"data":data}];
        }
    }
}

- (void)reloadWithOption:(NSDictionary *)attributes{
    if (attributes[ChartInfo]) {
        self.chartInfo = [NSString stringWithFormat:@"%@",attributes[ChartInfo]];
    }
    [self.webview reload];
}
/** 从工程中加载 html */
- (void)loadHtmlFormBundle
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bm-chart" ofType:@"html"];
    NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void)fillAttributes:(NSDictionary *)attributes
{
    if (attributes[ChartInfo]) {
        NSString *info = [NSString stringWithFormat:@"%@",attributes[ChartInfo]];;
        
        if (![info isEqualToString:self.chartInfo]) {
            self.chartInfo = info;
            WXPerformBlockOnMainThread(^{
                [self runChatInfo];
            });
        }
        
    }
}

- (void)addEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"finish"]) {
        _finishEvent = YES;
    }
    
    if ([eventName isEqualToString:@"click"]) {
        _clickEvent = YES;
    }
}

- (UIView *)loadView
{
    return self.webview;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    [self fillAttributes:attributes];
}

- (void)_updateAttributesOnComponentThread:(NSDictionary *)attributes
{
    [super _updateAttributesOnComponentThread:attributes];
    
    [self fillAttributes:attributes];
}

- (void)webViewRunScript:(NSString *)script
{
    [self.webview evaluateJavaScript:script completionHandler:^(id _Nullable dict, NSError * _Nullable error) {
        if (error) {
            WXLogError(@"Run script:%@ Error:%@",script,error);
        }
    }];
}

- (void)runChatInfo
{
    NSString *script = [NSString stringWithFormat:@"setOption(%@)",self.chartInfo];
    [self.webview evaluateJavaScript:script completionHandler:^(id _Nullable dict, NSError * _Nullable error) {
        if (error) {
            WXLogError(@"Run script:%@ Error:%@",script,error);
        }
        else if (_finishEvent) {
            [self fireEvent:@"finish" params:nil];
        }
    }];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    WXLogInfo(@"\n【webView】didStartProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    WXLogInfo(@"\n【webView】didFinishNavigation");
    
    if (!self.chartInfo) {
        return;
    }
    
//    NSString *echartJsPath = [[NSBundle mainBundle] pathForResource:@"echarts.min" ofType:@"js"];
//    NSString *echartJsStr = [NSString stringWithContentsOfFile:echartJsPath encoding:NSUTF8StringEncoding error:nil];
//    [self webViewRunScript:echartJsStr];
    //    NSString *script = @"setOption({'tooltip':{'show':true},'legend':{'data':['数量（吨）']},'xAxis':[{'type':'category','data':['桔子','香蕉','苹果','西瓜']}],'yAxis':[{'type':'value'}],'series':[{'name':'数量（吨）','type':'bar','data':[100,200,300,400]}]})";
    
    [self runChatInfo];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error) {
        WXLogError(@"%@",error);
    }
}

@end
