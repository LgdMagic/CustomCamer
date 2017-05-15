//
//  CameraManager.h
//  myCamera
//
//  Created by MagicLGD on 2017/5/15.
//  Copyright © 2017年 com.zcbl.BeiJingJiaoJing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#define MAX_PINCH_SCALE_NUM   3.f
#define MIN_PINCH_SCALE_NUM   1.f

typedef NS_ENUM(NSInteger, CaptureType) {
    
    ///自定义相机采集图片
    CapturePicture = 0,
    ///采集视频
    CaptureVedio,
    ///只拍照
    CaptureOnlyPicture
};

typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);

@interface CameraManager : NSObject

///采集类型
@property (assign, nonatomic) CaptureType    captureType;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
//@property (nonatomic, strong) UIImage *stillImage;

//pinch
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;

@property (nonatomic, assign) BOOL  isFront;

///未设置开启相机访问，取消设置
@property (nonatomic, copy) void(^cancelSet)();

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect;

- (void)configureWithParentLayer:(UIView *)parent;

- (void)takePicture:(DidCapturePhotoBlock)block;
- (void)switchCamera:(BOOL)isFrontCamera;
- (void)pinchCameraViewWithScalNum:(CGFloat)scale;
- (void)pinchCameraView:(UIPinchGestureRecognizer*)gesture;
- (void)switchFlashMode:(UIButton*)sender;
- (void)focusInPoint:(CGPoint)devicePoint;
- (void)switchGrid:(BOOL)toShow;

- (void)removeAllInput;


/**
 *  闪光灯状态
 *
 */
- (NSInteger)flashState;


/**
 *  切换前后镜
 *
 */
- (void)switchCamera:(BOOL)isFrontCamera didFinishChanceBlock:(void(^)())block;


/**
 *  拍照
 *
 *  @param block 原图 比例图 裁剪图
 */
- (void)takePhotoWithImageBlock:(void(^)(UIImage *originImage,UIImage *scaledImage,UIImage *croppedImage))block;

@end
