# 客服MM公共库

为电商部门不同的产品提供客服模块，目前支持“自动问题、客服提问、刷新客服回复、向客户服发送图片”的功能。
使用之前，产品需向客户后台申请一个productId

## 配置产品参数
在使用客服模块之前，请通过以下接口配置产品参数

```
+ [NFBManager configWithProduct:(NSString*)productId
                  version:(NSString*)version
                  channel:(NSString*)channel
                 deviceId:(NSString*)deviceId]
```

提供一个`cywt.json`文件来配置自动回复问题，如果通过cocopods集成这个库，不会附带这个文件，请到这个git工程里面拷贝一份，修改后添加到主工程资源。


## 刷新消息

主程序启动以后，可以通过以下接口来启动消息刷新，客户模块会之后会自动刷新。

```
[NFBManager startMessagePolling];
```

每当刷新完成后，会发出NFeedBackUnreadMessageCountChangedNotification通知。

主程序可以通过下面的接口，获取当前未读消息的数量：

```
[NFBManager currentUnreadMessageCount];
```

## 客服主页面
建议产品从`NFBViewController`派生一个controller。
并实现 openUrl方法，这个方法在需要打开url的时候被调用；毕竟只有具体产品才知道如何打开一个url。


### 定制视觉效果
客服模块包含一个视觉文件包`feedback.bundle`，里面包含所有用图片资源。
如果产品需要修改某些图片，可以实现protocol `NFBAppearance`，

``` 
	//实现NFBAppearance的接口来定制视觉效果，未实现的接口将保持默认效果
	@interface CustomAppearance : NSObject<NFBAppearance>
	{
	    //提供需要定制的视觉值
		- (UIColor*)mainViewBackgroundColor {
			return [ColorFactory customColor];
		}
	}
	
	NFBViewController *controller = [NFBViewController new];
	[controller setApperance:[CustomAppearance new]];
```

### 自定义主页
如果对NFBViewController的整体结构不满意，可以从NFBViewControllerBase派生一个自定义的客服主页面，此时，需要你实现消息的输入、显示。 NFBViewController也是从NFBViewControllerBase派生而来的，可以参考它的源码。


## 网络诊断

客服系统集成了网络诊断服务LDNetDiagnoService，如果用户输入的反馈的内容有“网络”字样，会启动网络诊断，并提交诊断结果到客服系统。



## 测试报告

###设备兼容性测试

* iPhone5  7.1.2 wifi WCDMA



