//
//  CCEncodeConfig.h
//  demo
//
//  Created by cc on 17/1/5.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>

/** 镜像类型 */
typedef NS_ENUM(NSInteger,HSMirrorType) {
    /** 预览启用镜像，推流不启用镜像 */
    HSMirrorType_PreviewMirrorPublishNoMirror,
    /** 预览启用镜像，推流启用镜像 */
    HSMirrorType_PreviewCaptureBothMirror,
    /** 预览不启用镜像，推流不启用镜像 */
    HSMirrorType_PreviewCaptureBothNoMirror,
    /** 预览不启用镜像，推流启用镜像 */
    HSMirrorType_PreviewNoMirrorPublishMirror
};

/*!
 * @brief 分辨率
 */
typedef enum{
    /*!
     *  320*240
     */
    CCResolution_240,
    /*!
     *  640*480
     */
    CCResolution_480,
    /*!
     *  1280*720
     */
    CCResolution_720
}CCResolution;

/*!
 @brief  视频配置信息
 */
@interface CCEncodeConfig : NSObject
/*!
 @brief  推流分辨率
*/
@property(assign, nonatomic)CCResolution reslution;

@end
