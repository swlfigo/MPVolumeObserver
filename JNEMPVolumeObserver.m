//
//  JNEMPVolumeObserver.m
//  beautyCamera
//
//  Created by Sylar on 19-03-7.
//
//

#import "JNEMPVolumeObserver.h"
#import <AVFoundation/AVFoundation.h>

@interface JNEMPVolumeObserver()<JNEMPVolumeManagerProtocol> {

}
@property(nonatomic,strong)JNEMPVolumeObserverWindow *obWindow;
@property(nonatomic,strong)JNEMPVolumeManager *systemVolumeManager;
@end

@implementation JNEMPVolumeObserver

+ (JNEMPVolumeObserver*) sharedInstance {
    static JNEMPVolumeObserver *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JNEMPVolumeObserver alloc] init];
    });
    
    return instance;
}

- (void)dealloc {

}

- (instancetype)init {
    self = [super init];
    if ( self ) {

    }
    return self;
}

- (void)startObserveVolumeChangeEvents {
    if (_systemVolumeManager) return;
    
    UIViewController *vc = [[UIViewController alloc]init];
    _obWindow = [[JNEMPVolumeObserverWindow alloc]initWithViewController:vc];
    _systemVolumeManager = [[JNEMPVolumeManager alloc]init];
    _systemVolumeManager.delegate = self;
    
}

- (void)MPVolumeManager:(JNEMPVolumeManager *)manager DidChangeVolumeFromOld:(CGFloat)oldVolume ToNewValue:(CGFloat)newVolume{
    if (_obWindow.systemVolumeView) {
        [_obWindow.systemVolumeView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UISlider class]]) {
                [((UISlider*)obj) setValue:_systemVolumeManager.ouputVolume animated:NO];
            }
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(volumeButtonDidClick:)]) {
        [self.delegate volumeButtonDidClick:self];
    }
}


- (void)stopObserveVolumeChangeEvents {
    _obWindow = nil;
    _systemVolumeManager = nil;
}


@end


@interface JNEMPVolumeObserverWindow()
@property(nonatomic,strong)UIViewController *containerVC;


@end

@implementation JNEMPVolumeObserverWindow

- (instancetype)initWithViewController:(UIViewController *)vc{
    if (self = [super initWithFrame:CGRectZero]) {
        _containerVC = vc;
        _systemVolumeView = [[MPVolumeView alloc]initWithFrame:CGRectZero];
        _systemVolumeView.hidden = NO;
        _systemVolumeView.clipsToBounds = YES;
        _systemVolumeView.showsRouteButton = NO;
        _systemVolumeView.alpha = 0.0001;
        
        [self setUserInteractionEnabled:NO];
        [self setHidden:NO];
        self.windowLevel = UIWindowLevelNormal;
        _containerVC.view.hidden = YES;
        self.rootViewController = _containerVC;
        [self addSubview:_systemVolumeView];
        _containerVC.view.layer.masksToBounds = YES;
        self.frame = CGRectZero;
        _containerVC.view.frame = CGRectZero;
    }
    return self;
}

@end



@interface JNEMPVolumeManager()

@property(nonatomic,assign)BOOL isObservingSystemVolumeChanges;

-(void)startObserveVolumeChangeEvents;

-(void)stopObserveVolumeChangeEvents;

-(void)startObserveApplicationStateChanges;

-(void)stopObserveApplicationStateChanges;
@end

@implementation JNEMPVolumeManager

- (void)dealloc
{
    [self stopObserveVolumeChangeEvents];
    [self stopObserveApplicationStateChanges];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isObservingSystemVolumeChanges = NO;
        [self startObserveVolumeChangeEvents];
        [self startObserveApplicationStateChanges];
    }
    return self;
}

//Volume Change
- (void)startObserveVolumeChangeEvents{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    _ouputVolume = [AVAudioSession sharedInstance].outputVolume;
    if (!_isObservingSystemVolumeChanges) {
        _isObservingSystemVolumeChanges = YES;
        [[AVAudioSession sharedInstance] addObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(outputVolume))
                                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                             context:nil];
    }
}

- (void)stopObserveVolumeChangeEvents{
    if (_isObservingSystemVolumeChanges) {
        [[AVAudioSession sharedInstance] removeObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(outputVolume))];
        _isObservingSystemVolumeChanges = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([change isKindOfClass:[NSDictionary class]]) {
        NSNumber *volumeNumNew = change[@"new"];
        NSNumber *volumeNumOld = change[@"old"];
        if (volumeNumNew && volumeNumOld && _delegate && [_delegate respondsToSelector:@selector(MPVolumeManager:DidChangeVolumeFromOld:ToNewValue:)]) {
            
            [_delegate MPVolumeManager:self DidChangeVolumeFromOld:[volumeNumOld floatValue]ToNewValue:[volumeNumNew floatValue]];
        }
    }
}


//Application
- (void)startObserveApplicationStateChanges{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(suspendObserveVolumeChangeEvents:)
                                                 name:UIApplicationWillResignActiveNotification     // -> Inactive
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumeObserveVolumeButtonEvents:)
                                                 name:UIApplicationDidBecomeActiveNotification      // <- Active
                                               object:nil];
}

- (void)suspendObserveVolumeChangeEvents:(NSNotification *)notification {
    
    [self stopObserveVolumeChangeEvents];
    
}

- (void)resumeObserveVolumeButtonEvents:(NSNotification *)notification {
    
    [self startObserveVolumeChangeEvents];
    
}

- (void)stopObserveApplicationStateChanges{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
