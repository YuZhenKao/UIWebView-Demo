
//
//  ViewController.m
//  UIWebView深度交互Demo
//
//  Created by YuZhenKao on 16/7/10.
//  Copyright © 2016年 YuZhenKao. All rights reserved.
//

#import "ViewController.h"

#import <WebViewJavascriptBridge.h>

#import <SDWebImageManager.h>

#import "YYPhotoGroupView.h"

#import <YYImage.h>

@interface ViewController ()<UIWebViewDelegate>

@property (strong ,nonatomic) UIWebView *webView;

@property (strong ,nonatomic) WebViewJavascriptBridge *bridge;

@property (copy ,nonatomic) NSString *HTMLBoday;

@property (strong ,nonatomic) NSMutableArray *downloadImageArray;

@property (strong ,nonatomic) UIImageView *tappedImageView;

@end

@implementation ViewController

#pragma mark - Properties Getter And Setter
-(UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:_webView];
    }
    return _webView;
}

-(WebViewJavascriptBridge *)bridge {
    if (_bridge == nil) {
        _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
        [_bridge setWebViewDelegate:self];
        [WebViewJavascriptBridge enableLogging];
    }
    return _bridge;
}

- (NSMutableArray *)downloadImageArray {
    if (_downloadImageArray == nil) {
        _downloadImageArray = [NSMutableArray array];
    }
    return _downloadImageArray;
}
-(UIImageView *)tappedImageView {
    if (_tappedImageView == nil) {
        _tappedImageView = [UIImageView new];
    }
    return _tappedImageView;
}
-(NSString *)HTMLBoday {
    return @"<span style=\"background-color:#F0E7B4;\">台湾刚刚发生的雄风导弹误射事件，引发从解放军到蔡英文的纷纷瞩目，一时竟形成比美国总统吃错药还要热闹的新闻效果。<br />\r\n</span><span style=\"color:#464646;font-family:'Microsoft YaHei', 'Helvetica Neue', SimSun;font-size:14px;line-height:21px;background-color:#F0E7B4;\"></span>\r\n<div align=\"center\" style=\"color:#464646;font-family:'Microsoft YaHei', 'Helvetica Neue', SimSun;font-size:14px;background-color:#F0E7B4;\">\r\n\t<span><a href=\"http://photo.blog.sina.com.cn/showpic.html#blogid=476745f60102wh7i&amp;url=http://album.sina.com.cn/pic/001j4tDwzy733IivyVr59\" target=\"_blank\"><img src=\"http://s10.sinaimg.cn/mw690/001j4tDwzy733IivyVr59&amp;690.png\" height=\"271\" width=\"490\" alt=\"不靠谱的日本兵——自卫队各型兵器误射谱\" title=\"不靠谱的日本兵——自卫队各型兵器误射谱\" /></a><br />\r\n</span>\r\n</div>\r\n<span style=\"background-color:#F0E7B4;\">然而，日本自卫队对此反应淡定。究其原因，“吴氏者，初从文，三年不中，后习武，校场发矢，中鼓吏……”误中友军这种事情，在大日本自卫队，可不要太多。也许正因为经常打错靶，自卫队的这些糗事儿反而不常被人注意到，且随手把这些不靠谱的日本兵找几个出来，几乎每一例都不得不说反映出无限的创造力。<br />\r\n<br />\r\n台湾发生的是雄风导弹误射事件，肇事的是金江号导弹艇。无独有偶，日本的导弹艇也很不老实。2006年9月5日晚上七点多，日本海上自卫队青森基地大凑码头的官兵们刚吃完晚餐，忽闻一阵炮声，基地的弹药库突遭排炮袭击。<br />\r\n<br />\r\n是拉登的二大爷来袭击啦？惊魂难定的自卫队员们好一阵子才弄明白是港湾里停泊在6号突堤泊位的三号导弹艇发生了误射——共有10发20毫米机关炮炮弹打向了自家的仓库和附近的居民区，这十发炮弹居然品种还不一样，共有爆破弹4发，曳光弹2发和实心弹（教练弹）4发。幸运的是没有造成人员伤亡。</span>";
}
#pragma mark - Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self demo_createBridge];
    [self demo_loadHTML];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)demo_createBridge{
    
    [self.bridge callHandler:@"getImageUrlsArray" data:nil responseCallback:^(id responseData) {
        //拿到img的所有url并开始下载
        [self demo_downloadImages:responseData[@"data"]];
    }];
    
    [self.bridge registerHandler:@"imageDidClicked" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSInteger index = [[data objectForKey:@"index"] integerValue];
        CGFloat originX = [[data objectForKey:@"x"] floatValue];
        CGFloat originY = [[data objectForKey:@"y"] floatValue];
        CGFloat width  = [[data objectForKey:@"width"] floatValue];
        CGFloat height  = [[data objectForKey:@"height"] floatValue];
        
        self.tappedImageView.frame = CGRectMake(originX, originY, width, height);
        self.tappedImageView.image = [YYImage imageWithContentsOfFile:self.downloadImageArray[index]];
        
        responseCallback(@"OC已经收到JS的imageDidClicked了");
        //点击放大图片
        YYPhotoGroupItem *item = [[YYPhotoGroupItem alloc]init];
        item.thumbView = self.tappedImageView;
        item.largeImageURL = [NSURL URLWithString:self.downloadImageArray[index]];
        YYPhotoGroupView *view = [[YYPhotoGroupView alloc]initWithGroupItems:@[item]];
        view.blurEffectBackground = NO;
        [view presentFromImageView:self.tappedImageView toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:^{
            
        }];
    }];
    
    
    
}

#pragma mark - Actions

- (void)demo_loadHTML{
    //获取本地HTML路径
    NSString* HTMLPath = [[NSBundle mainBundle] pathForResource:@"HTMLDemo" ofType:@"html"];
    //获取HTML字符串
    NSMutableString* HTMLString = [NSMutableString stringWithContentsOfFile:HTMLPath encoding:NSUTF8StringEncoding error:nil];
    //设定需要替换的字符串
    NSRange range = [HTMLString rangeOfString:@"<P>mainviews</P>"];
    //将字符串中的src标签都替换掉，防止加载HTML的时候预加载图片
    NSString *replace = [self.HTMLBoday stringByReplacingOccurrencesOfString:@"src=" withString:@"esrc="];
    //将字符串替换调
    [HTMLString replaceOccurrencesOfString:@"<P>mainviews</P>" withString:replace options:NSCaseInsensitiveSearch range:range];
    //根据正则表达式查找img标签
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img[^>]+esrc=\")(\\S+)\"" options:0 error:nil];
    //给img标签添加点击事件
    NSString *finalHTMLString = [regex stringByReplacingMatchesInString:HTMLString options:0 range:NSMakeRange(0, HTMLString.length) withTemplate:@"<img esrc=\"$2\" onClick=\"javascript:onImageClick('$2')\" "];
    //加载HTML
    [self.webView loadHTMLString:finalHTMLString baseURL:[NSURL fileURLWithPath:HTMLPath]];
}

- (void)demo_downloadImages:(NSArray *)imageUrlArray{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //假如没有截取图片则不执行方法
    if (imageUrlArray.count == 0) {
        return;
    }
    //预防数组越界处理
    for (NSUInteger i = 0; i < imageUrlArray.count; i++) {
        [self.downloadImageArray addObject:[NSNull null]];
    }
    
    for (NSUInteger i = 0; i < imageUrlArray.count; i++) {
        NSString *_url = imageUrlArray[i];
        //SDWebImage下载图片
        [manager downloadImageWithURL:[NSURL URLWithString:_url] options:SDWebImageHighPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            if (image) {
                //拿到存储的key
                NSString *key = [manager cacheKeyForURL:imageURL];
                //将url转换成string
                NSString *old = [imageURL absoluteString];
                //根据key拿到本地存储路径
                NSString *localCachePath = [manager.imageCache defaultCachePathForKey:key];
                [self.downloadImageArray removeObjectAtIndex:i];
                [self.downloadImageArray insertObject:localCachePath atIndex:i];
                //将本地缓存图片的地址传到webView
                [self.bridge callHandler:@"imagesDownloadComplete" data:@{@"old":old,@"new":localCachePath} responseCallback:^(id responseData) {
                }];
            }
            
        }];
        
    }
}

#pragma webView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    
}


@end
