//
//  MPVolumeObserver.h
//  beautyCamera
//
//  Created by Sylar on 19-03-7.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>


@interface JNEMPVolumeObserverWindow:UIWindow
-(instancetype)initWithViewController:(UIViewController*)vc;
@property(nonatomic,strong)MPVolumeView *systemVolumeView;
@end


@class JNEMPVolumeManager;
@protocol JNEMPVolumeManagerProtocol <NSObject>
-(void)MPVolumeManager:(JNEMPVolumeManager*)manager DidChangeVolumeFromOld:(CGFloat)oldVolume ToNewValue:(CGFloat)newVolume;
@end
@interface JNEMPVolumeManager:NSObject
@property(nonatomic,assign)CGFloat ouputVolume;
@property(nonatomic,weak)id<JNEMPVolumeManagerProtocol> delegate;
@end


@class JNEMPVolumeObserver;
@protocol MPVolumeObserverProtocol <NSObject>
-(void) volumeButtonDidClick:(JNEMPVolumeObserver *) button;
@end

@interface JNEMPVolumeObserver : NSObject
@property (nonatomic, weak) id<MPVolumeObserverProtocol> delegate;

+(JNEMPVolumeObserver*) sharedInstance;

-(void)startObserveVolumeChangeEvents;

-(void)stopObserveVolumeChangeEvents;


@end
