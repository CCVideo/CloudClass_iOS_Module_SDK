//
//  CCUploadFile.m
//  CCClassRoom
//
//  Created by cc on 17/8/8.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCUploadFile.h"
#import "CCPhotoNotPermissionVC.h"
#import <Photos/Photos.h>
#import <AFNetworking.h>
#import "CCDocListViewController.h"
#import "TZImagePickerController.h"
#import "AppDelegate.h"
#import <UIAlertView+BlocksKit.h>

@interface CCUploadFile()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CCUploadFileBlock _completion;
}
@property (strong, nonatomic)UINavigationController *navigationController;
@property (strong, nonatomic)UIImagePickerController *picker;
@property (strong, nonatomic)NSString *roomID;
@property (assign, nonatomic)BOOL isUploading;

@property (strong, nonatomic)CCRoom *room;
@property (copy, nonatomic)NSString *docName;
@property (assign, nonatomic)int docSize;
@end

@implementation CCUploadFile
- (void)uploadImage:(UINavigationController *)nav roomID:(NSString *)roomID completion:(CCUploadFileBlock)completion
{
    if (self.isUploading)
    {
        if (completion)
        {
            completion(NO);
        }
    }
    else
    {
        _completion = completion;
        self.navigationController = nav;
        self.roomID = roomID;
        [self selectImage];
    }
}

- (void)selectImage
{
    __block CCPhotoNotPermissionVC *_photoNotPermissionVC;
    WS(ws)
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    [ws pickImage];
                } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                    _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
                    });
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            [ws pickImage];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            NSLog(@"4");
            _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
            });
        }
            break;
        default:
            break;
    }
}

-(void)pickImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pickImageOnMainThread];
    });
}

-(void)pickImageOnMainThread {
#ifndef USELOCALPHOTOLIBARY
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        [ws pushImagePickerController];
    });
#else
    if([self isPhotoLibraryAvailable]) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.view.backgroundColor = [UIColor clearColor];
        UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _picker.sourceType = sourcheType;
        _picker.delegate = self;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController presentViewController:_picker animated:YES completion:nil];
        });
    }
#endif
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark 发送图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __block UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        //发送图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%@", info);
            NSData *dataImage = [CCUploadFile zipImageWithImage:image];
            [ws upload_getUploadUrl:dataImage];
        });
        ws.picker = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        ws.picker = nil;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"])
    {
        NSLog(@"%s__%@__%@", __func__, change, object);
        NSProgress *pro = object;
        CGFloat percent = pro.fractionCompleted;
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiUploadFileProgress object:nil userInfo:@{@"pro":@(percent)}];
        if (percent == 1)
        {
            [pro removeObserver:self forKeyPath:@"fractionCompleted"];
        }
    }
}

#pragma mark - 给个通知，返回主界面的streamview试试，然后再用CCDocVideoView加载相应的图片，否则在此处分身乏术。
- (void)getProWithDocID:(NSString *)docID
{
    WS(ws);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getProWithDocID" object:nil userInfo:@{@"docID":docID}];
}

- (void)notiInfoRefresh{
    self.isUploading = NO;
    if (_completion)
    {
        _completion(YES);
    }
}

- (NSString *)randomName:(int)len
{
    return [NSString stringWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
}

+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 5*1024*1024;
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (void)pushImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.allowEdited = NO;
    __weak typeof(self) weakSelf = self;
    __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
    
    WS(ws);
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakPicker dismissViewControllerAnimated:YES completion:^{
            if (photos.count > 0)
            {
                weakSelf.isUploading = YES;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *dataImage = [CCUploadFile zipImageWithImage:photos.lastObject];
                    [ws upload_getUploadUrl:dataImage];
                });
            }
        }];
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        
    }];
    imagePickerVc.modalPresentationStyle = 0;
    [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (CCRoom *)room
{
    return [[CCStreamerBasic sharedStreamer]getRoomInfo];
}

//获取上传图片地址
- (void)upload_getUploadUrl:(NSData *)dataImage
{
    int totalSize = 104857600;
    if (dataImage.length > totalSize)
    {
        [self showMessage:@"尺寸超过限制！"];
        return;
    }
    
    //预发布环境:https://ccapi-pre.csslcloud.net/api/v1/serve/doc/add
    //线上环境:https://ccapi.csslcloud.net/api/v1/serve/doc/add
    NSString *urlString = @"https://ccapi.csslcloud.net/api/v1/serve/doc/add";
    //    if (DEBUG) {
    //        urlString = @"https://ccapi.csslcloud.net/api/v1/serve/doc/add";;
    //    }
    
    NSString *userID = GetFromUserDefaults(LIVE_USERID);
    
    self.docName = [self randomName:0];
    self.docSize = (int)dataImage.length;
    NSDictionary *par = @{
        @"account_id":userID,
        @"doc_name":self.docName,
        @"doc_size":@(self.docSize),
        @"room_id":self.roomID
    };
    __weak typeof(self)weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:urlString parameters:par success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *dicRes = responseObject;
        NSString *result = dicRes[@"result"];
        if (![result isEqualToString:@"OK"])
        {
            [weakSelf showMessage:@"获取上传地址异常!"];
            return ;
        }
        NSString *uploadAddress = dicRes[@"data"][@"upload_url"];
        [weakSelf upload_uploadFile:dataImage urlString:uploadAddress];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf showMessage:error.domain];
    }];
}
//上传图片
- (void)upload_uploadFile:(NSData *)dataUpload urlString:(NSString *)urlString
{
    NSString *urlL = [NSString stringWithFormat:@"%@",urlString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:urlL relativeToURL:manager.baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:dataUpload name:@"file" fileName:self.docName mimeType:@"image/jpeg"];
    } error:&serializationError];
    if (serializationError)
    {
        NSLog(@"%s__%d__%@", __func__, __LINE__, serializationError);
    }
    WS(ws);
    NSProgress *progress = nil;
    __block NSURLSessionDataTask *task = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        [progress removeObserver:ws forKeyPath:@"fractionCompleted"];
        
        if (error) {
            if (_completion)
            {
                _completion(NO);
            }
        } else {
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            NSLog(@"%s__%d__%@", __func__, __LINE__, info);
            NSError *err;
            id jsonValue = [NSJSONSerialization JSONObjectWithData:responseObject
                                                           options:NSJSONReadingMutableLeaves
                                                             error:&err];
            BOOL res = [jsonValue[@"success"] boolValue];
            if (res)
            {
                NSString *docid = [jsonValue[@"datas"] objectForKey:@"docId"];
                [ws getProWithDocID:docid];
            }
        }
    }];
    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
    [task resume];
}

- (void)showMessage:(NSString *)msg
{
    UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"提示" message:msg];
    [alertV bk_setCancelButtonWithTitle:@"确定" handler:^{
    }];
    [alertV show];
}

@end
