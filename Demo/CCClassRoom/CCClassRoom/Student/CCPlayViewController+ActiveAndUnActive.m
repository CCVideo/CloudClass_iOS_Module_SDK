//
//  CCStreamer+ActiveAndUnActive.m
//  CCStreamer
//
//  Created by cc on 17/2/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCPlayViewController+ActiveAndUnActive.h"

@implementation CCPlayViewController (ActiveAndUnActive)
static BOOL isPro;
#pragma mark - 前后台noti
-(void)addObserver_push
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateOri) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        isPro = YES;
    }
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
    {
        isPro = NO;
    }
}

#pragma mark - 旋转保证竖屏
- (void)rotateOri
{
    __weak typeof(self) weakSelf = self;
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    [weakSelf.localStream disableVideo];
    AVCaptureSession *session = [self.stremer getCaptureSession];
    //    [session beginConfiguration];
    //    [session stopRunning];
    //    [session commitConfiguration];
    
    
    NSArray *outputs = session.outputs;
    for (AVCaptureOutput *output in outputs)
    {
        for (AVCaptureConnection *av in output.connections)
        {
            UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
            if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown)
            {
                isPro = YES;
            }
            if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
            {
                isPro = NO;
            }
            CCLog(@"+++++++++++++deviceOri:%@__videoori:%@", @(orientation), @(av.videoOrientation));
            if (orientation != UIDeviceOrientationFaceUp && self.isLandSpace)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.preView.transform = CGAffineTransformIdentity;
                });
            }
            switch (orientation) {
                case UIDeviceOrientationPortraitUpsideDown:
                {
                    if (weakSelf.isLandSpace)
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                            //                             av.videoOrientation = AVCaptureVideoOrientationPortrait;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                            //                             av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                    }
                    else
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                    }
                    //                    av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                }
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                {
                    if (weakSelf.isLandSpace)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.preView.transform = CGAffineTransformMakeRotation(M_PI);
                        });
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                    }
                    else
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationPortrait;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationPortrait;
                    }
                    //                    av.videoOrientation = AVCaptureVideoOrientationPortrait;
                }
                    break;
                case UIDeviceOrientationLandscapeLeft:
                {
                    if (weakSelf.isLandSpace)
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                    }
                    else
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationPortrait;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                    }
                    //                    av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                }
                    break;
                case UIDeviceOrientationPortrait:
                {
                    if (weakSelf.isLandSpace)
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationPortrait;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationPortrait;
                    }
                    else
                    {
                        if (weakSelf.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                            //                            av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        }
                        //                        av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                    }
                    //                    av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                }
                    break;
                case UIDeviceOrientationFaceUp:
                {
                    
                }
                    break;
                case UIDeviceOrientationFaceDown:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
    }
    //    [session startRunning];
    //    [session commitConfiguration];
//    [weakSelf.localStream enableVideo];
    //        });
}

- (void)rotateOri1:(BOOL)chaned
{
    if (chaned)
    {
        isPro = YES;
    }
//    [self.localStream disableVideo];
    __weak typeof(self) weakSelf = self;
    AVCaptureSession *session = [self.stremer getCaptureSession];
    for (AVCaptureOutput *output in session.outputs)
    {
        for (AVCaptureConnection *av in output.connections)
        {
            UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
            CCLog(@"--------------deviceOri:%@__videoori:%@", @(orientation), @(av.videoOrientation));
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.preView.transform = CGAffineTransformIdentity;
            });
            switch (orientation) {
                case UIDeviceOrientationFaceDown:
                case UIDeviceOrientationPortraitUpsideDown:
                {
                    if (self.isLandSpace)
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                        }
                    }
                    else
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                        }
                    }
                }
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                {
                    if (self.isLandSpace)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.preView.transform = CGAffineTransformMakeRotation(M_PI);
                        });
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                        }
                    }
                    else
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                        }
                    }
                }
                    break;
                case UIDeviceOrientationLandscapeLeft:
                {
                    if (self.isLandSpace)
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                        }
                    }
                    else
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                        }
                    }
                }
                    break;
                case UIDeviceOrientationPortrait:
                {
                    if (self.isLandSpace)
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                        }
                    }
                    else
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                        }
                    }
                }
                    break;
                case UIDeviceOrientationFaceUp:
                {
                    if (self.isLandSpace)
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                if (isPro)
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                }
                                else
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                }
                                //                                av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                if (isPro)
                                {
                                    UIInterfaceOrientation interOrientation = [UIApplication sharedApplication].statusBarOrientation;
                                    if (interOrientation == UIInterfaceOrientationLandscapeLeft)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            weakSelf.preView.transform = CGAffineTransformMakeRotation(M_PI);
                                        });
                                        av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                    }
                                    else
                                    {
                                        av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                    }
                                }
                                else
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                }
                                //                                av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                [session commitConfiguration];
                            });
                        }
                    }
                    else
                    {
                        if (self.cameraPosition == AVCaptureDevicePositionBack)
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                if (isPro)
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                                }
                                else
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                }
                                //                                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                                [session commitConfiguration];
                            });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [session beginConfiguration];
                                if (isPro)
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                                }
                                else
                                {
                                    av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                }
                                //                                av.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                                [session commitConfiguration];
                            });
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
//    [self.localStream enableVideo];
}
@end
