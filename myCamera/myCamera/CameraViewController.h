//
//  CameraViewController.h
//  myCamera
//
//  Created by MagicLGD on 2017/5/15.
//  Copyright © 2017年 com.zcbl.BeiJingJiaoJing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController

@property (weak, nonatomic)  UIButton *changeFlashBtn;
@property (weak, nonatomic)  UIButton *changeCameraBtn;

@property (weak, nonatomic)  UIButton *closeButton;

@property (weak, nonatomic)  UIButton *takePhotoBtn;



@property (weak, nonatomic) IBOutlet UIView * flashView;

///闪光灯：自动、打开、关闭 view 的宽
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashViewWidthConstraints;




- (IBAction)changeFlash:(UIButton *)sender;
- (IBAction)changeCamera:(UIButton *)sender;

- (IBAction)changeflashState:(UIButton *)sender;




@end
