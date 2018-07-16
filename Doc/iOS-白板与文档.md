[TOC]

# 白板与文档组件

# 1. 白板与文档组件

白板与文档组件的核心类是CCDocViewManager;

```objc
//在工程需要的地方引入头文件
#import <CCDocLibrary/CCDocLibrary.h>

//1、类的实例化
- (CCDocVideoView *)ccVideoView
{
    if (!_ccVideoView) {
        CGRect frame = CGRectMake(0, 0, 200, 100);
        _ccVideoView = [[CCDocVideoView alloc]initWithFrame:frame];
        [_ccVideoView addObserverNotify];
    }
    return _ccVideoView;
}
//2、与BaseSDK建立联系
- (void)addBasicClient:(CCStreamerBasic *)basic;
```

# 2. 开始加载内容
进入房间成功后调用
```objc
- (void)startDocView;
```