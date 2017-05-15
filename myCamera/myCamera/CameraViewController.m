//
//  CameraViewController.m
//  myCamera
//
//  Created by MagicLGD on 2017/5/15.
//  Copyright © 2017年 com.zcbl.BeiJingJiaoJing. All rights reserved.
//

#import "CameraViewController.h"
#import <CoreMotion/CMMotionManager.h>
#import "CameraManager.h"
#import "Masonry.h"
#import "UIImage+Resize.h"
#import "UIView+Additions.h"
#import "ViewController.h"

#define SCREEN_WIDTH   [UIScreen mainScreen].applicationFrame.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].applicationFrame.size.height
#define LoadImage(imageName) [UIImage imageNamed:imageName]

@interface CameraViewController ()
{
    UIView    * _topBar;
    UIView    * _bottomBar;
}

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;

@property (nonatomic,strong) CameraManager *manager;

@property (nonatomic, strong) CMMotionManager     *motionManager;
@property (nonatomic, assign) UIDeviceOrientation  deviceOrientation;


@end

@implementation CameraViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    
    if (![self.manager.session isRunning]) {
        [self.manager.session startRunning];
    }
    
    [UIView animateWithDuration:.25 animations:^{
        self.navigationController.navigationBar.hidden =YES;
    } completion:^(BOOL finished) {
    }];
    
    //禁止 屏幕锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    [self showCameraCover:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //启动 螺旋仪监听-判断屏幕方向
    [self startMotionManager];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    if ([self.manager.session isRunning]) {
        [self.manager.session stopRunning];
    }
    
    //停止 螺旋仪监听-判断屏幕方向
    [self stopMotionManager];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.manager removeAllInput];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //打开 屏幕锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (void)loadView
{
    [super loadView];
    [self loadTopBar];
    [self loadBottomBar];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    [self configCameraManager];
    
    //拍照时遮盖层
    [self addCameraCover];
    
    NSArray *flashStates =@[@"btn_flash_close",@"btn_flash_open",@"btn_flash_automatic"];
    [_changeFlashBtn setImage:LoadImage(flashStates[[self.manager flashState]]) forState:UIControlStateNormal];
    
    [_changeCameraBtn setImage:LoadImage(@"btn_camera_n") forState:UIControlStateNormal];

}

#pragma mark - 启动 螺旋仪监听-判断屏幕方向
- (void)startMotionManager{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1/15.0;
    if (_motionManager.deviceMotionAvailable) {
        //DLog(@"Device Motion Available");
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                            }];
    } else {
        //DLog(@"No device motion on device.");
        [self setMotionManager:nil];
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    
    UIDeviceOrientation orientation;
    CGFloat radian;
    
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            //DLog(@"deviceOrientation = UIDeviceOrientationPortraitUpsideDown");
            orientation = UIDeviceOrientationPortraitUpsideDown;
            radian = M_PI;
        } else {
            //DLog(@"deviceOrientation = UIDeviceOrientationPortrait");
            orientation = UIDeviceOrientationPortrait;
            radian =0;
        }
    }
    else
    {
        if (x >= 0){
            //DLog(@"deviceOrientation = UIDeviceOrientationLandscapeRight");
            orientation = UIDeviceOrientationLandscapeRight;
            radian =-M_PI_2;
        } else {
            //DLog(@"deviceOrientation = UIDeviceOrientationLandscapeLeft");
            orientation = UIDeviceOrientationLandscapeLeft;
            radian =M_PI_2;
        }
    }
    
    if(self.deviceOrientation != orientation)
    {
        self.deviceOrientation = orientation;
        [self changeControlOrientatio:radian];
    }
}

- (void)stopMotionManager
{
    [_motionManager stopDeviceMotionUpdates];
}

- (void)changeControlOrientatio:(CGFloat)radian
{
    [UIView animateWithDuration:0.25 animations:^{
        //CGAffineTransform transform = CGAffineTransformIdentity;
        //self.changeFlashBtn.transform =CGAffineTransformRotate(transform, radian)
        self.changeFlashBtn.transform= CGAffineTransformMakeRotation(radian);
        self.changeCameraBtn.transform = CGAffineTransformMakeRotation(radian);
        self.closeButton.transform =CGAffineTransformMakeRotation(radian);
    }];
}

#pragma mark - 加载上下toolBar
- (void)loadTopBar
{
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"CameraTopBarView" owner:self options:nil];
    //通过这个方法,取得我们的视图
    UIView* subXibView = [nibViews objectAtIndex:0];
    _topBar = subXibView;
    _topBar.width =SCREEN_WIDTH;
    _topBar.top =0;
    _topBar.left = 0;
    _topBar.backgroundColor =[UIColor blackColor];
    
     [self.view addSubview:_topBar];
    [_topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.leading.mas_equalTo(self.view);
        
        make.width.mas_equalTo(@(SCREEN_WIDTH));
        make.height.mas_equalTo(@(40));
    }];
    self.flashViewWidthConstraints.constant =0;
}

- (void)loadBottomBar
{
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:@"CameraBottomBar" owner:self options:nil];
    //通过这个方法,取得我们的视图
    UIView* subXibView = [nibViews objectAtIndex:0];
    _bottomBar = subXibView;
    _bottomBar.backgroundColor =[UIColor blackColor];
    _bottomBar.left =0;
    
    [self.view addSubview:_bottomBar];
    
    [_bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(@(100));
    }];
    
}

- (void)configCameraManager
{
    //    UIView *pickView = [[UIView alloc]initWithFrame:CGRectMake(0, _topBar.bottom, SCREEN_WIDTH,_bottomBar.top -_topBar.bottom)];
    UIView *pickView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT-40-100)];
    pickView.backgroundColor =[UIColor whiteColor];
    
    [self.view addSubview:pickView];
    
    [pickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_topBar.mas_bottom);
        make.bottom.mas_equalTo(_bottomBar.mas_top);
        make.width.mas_equalTo(self.view);
    }];
    
    CameraManager *manager = [[CameraManager alloc] init];
    // 传入View的frame 就是摄像的范围
    [manager configureWithParentLayer:pickView];
    //    manager.delegate = self;
    self.manager = manager;
    
    __weak typeof(self)weakSelf =self;
    self.manager.cancelSet=^(){
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark - 显示切换闪光灯选项
- (IBAction)changeFlash:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if(sender.selected)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.flashViewWidthConstraints.constant =151;
            _flashView.alpha =1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.flashViewWidthConstraints.constant =0;
            _flashView.alpha =0.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

#pragma mark - 切换闪光灯状态
- (IBAction)changeflashState:(UIButton *)sender
{
    sender.selected = YES;
    for(UIView *tvw in  [_flashView subviews])
    {
        if([tvw isKindOfClass:[UIButton class]])
        {
            UIButton *tBtn = (UIButton *)tvw;
            if(tBtn != sender)
            {
                tBtn.selected = NO;
            }
        }
    }
    NSArray *flashStates =@[@"btn_flash_close",@"btn_flash_open",@"btn_flash_automatic"];
    [_changeFlashBtn setImage:LoadImage(flashStates[sender.tag]) forState:UIControlStateNormal];
    [self.manager switchFlashMode:sender];
    [self changeFlash:_changeFlashBtn];
}

#pragma mark - 切换摄像头
- (IBAction)changeCamera:(UIButton *)sender
{
    sender.selected = !sender.selected;
    sender.enabled = NO;
    [self.manager switchCamera:sender.selected didFinishChanceBlock:^{
        sender.enabled = YES;
    }];
}

#pragma mark -点击关闭叉号
- (IBAction)closeClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - 点击拍照/拍视频
- (IBAction)takePicture:(UIButton *)sender
{
    //停止 螺旋仪监听-判断屏幕方向
    [self stopMotionManager];
    [self changeControlOrientatio:0];
    
    if(self.manager.captureType == CaptureVedio)
    {
        sender.selected = !sender.selected;
        if(sender.selected)
        {
            NSString *filePath =nil;//[AHDPublicObject getCaptureVideoFilePathString];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                sender.selected = NO;
                return;
            }
            // [self.manager recordMovie];
        }
        else
        {
            //[self.manager stopCurrentVideoRecording];
        }
        return;
    }
    //点击拍照时取相需要时间，连续快速点击会出错，点击后立即禁止接受点击事件避免出错
    _takePhotoBtn.userInteractionEnabled = NO;
    //[self.manager takePicture:self.needCrop];
    
    //显示遮盖层
    [self showCameraCover:YES];
    
    //显示转转
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    __weak typeof(self)weakSelf =self;
    [self.manager takePhotoWithImageBlock:^(UIImage *originImage, UIImage *scaledImage, UIImage *croppedImage) {

        _takePhotoBtn.userInteractionEnabled = YES;
        
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        
        //DLog(@"deviceOrientation ---- %i",self.deviceOrientation);
        if (self.deviceOrientation != UIDeviceOrientationPortrait) {
            CGFloat degree = 0;
            if (self.deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                degree = 180;// M_PI;
            } else if (self.deviceOrientation == UIDeviceOrientationLandscapeLeft) {
                degree = ((!self.manager.isFront)?-90:90);// -M_PI_2;
            } else if (self.deviceOrientation == UIDeviceOrientationLandscapeRight) {
                degree = ((!self.manager.isFront)?90:-90);// M_PI_2;
            }
            originImage = [originImage rotatedByDegrees:degree];
        }
        ViewController *vc = weakSelf.navigationController.viewControllers[0];
        vc.imageView.image = originImage;
        [weakSelf.navigationController popViewControllerAnimated:YES];
      
    }];
}

- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, _topBar.bottom, SCREEN_WIDTH, 0)];
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomBar.top, SCREEN_WIDTH, 0)];
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    self.doneCameraDownView = downView;
}

- (void)showCameraCover:(BOOL)toShow {
    
    [UIView animateWithDuration:0.38f animations:^{
        CGRect upFrame = _doneCameraUpView.frame;
        upFrame.size.height = (toShow ? (SCREEN_HEIGHT - _topBar.height-_bottomBar.height)*0.5f : 0);
        _doneCameraUpView.frame = upFrame;
        _doneCameraUpView.top += 10;
        
        CGRect downFrame = _doneCameraDownView.frame;
        downFrame.origin.y = (toShow ? _topBar.height+(SCREEN_HEIGHT - _topBar.height-_bottomBar.height)*0.5f: _bottomBar.top);
        
        downFrame.size.height = (toShow ? (SCREEN_HEIGHT - _topBar.height-_bottomBar.height)*0.5f : 0);
        _doneCameraDownView.frame = downFrame;
        _doneCameraDownView.top += 20;
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
