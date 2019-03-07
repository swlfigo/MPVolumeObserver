# MPVolumeObserver
iOS MPVolumeView Control (隐藏iOS系统音量调节View)

因为最近有个需求是按 iPhone 音量键拍照，不显示系统音量调节View和拍照音量不变化.实现后直接将项目文件拖出来独立出来上传

## Usage:
`JNEMPVolumeObserver`是一个单例(单例实现没有写好),全局管理这音量调节View的显示隐藏
```
//创建单例
singleton = [JNEMPVolumeObserver sharedInstance];
//开始监听
[singleton startObserveVolumeChangeEvents];
//停止jianting
[singleton stopObserveVolumeChangeEvents];
```
默认的时候推到后台会停止监听,不需要做太多操作.系统音量调节View会重新出现.切换回前台调节音量会自动隐藏

```
//调节音量(iPhone左边的音量键)按下的回调
//Protocol
-(void) volumeButtonDidClick:(JNEMPVolumeObserver *) button;
```

另外因为需求是拍照音量不减少，所以 `.m` 文件里面写死的音量，音量是监听前的即时音量,音量变化通过 `KVO` 观察

```
//JNEMPVolumeObserver.m

[_obWindow.systemVolumeView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UISlider class]]) {
                [((UISlider*)obj) setValue:_systemVolumeManager.ouputVolume animated:NO];
            }
        }];
        
```
其中 `_systemVolumeManager.ouputVolume` 是之前获得的外放音量.每次改动音量进入 `KVO` , 再通过改系统 `MPVolumeView` 改回去原来音量
