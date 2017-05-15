//
//  ViewController.m
//  myCamera
//
//  Created by MagicLGD on 2017/5/15.
//  Copyright © 2017年 com.zcbl.BeiJingJiaoJing. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showCameraView:(id)sender {
    CameraViewController *cameraVCL =[[CameraViewController alloc]init];
    [self.navigationController pushViewController:cameraVCL animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
