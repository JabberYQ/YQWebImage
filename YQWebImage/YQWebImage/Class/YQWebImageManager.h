//
//  YQOperationManager.h
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/3.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YQImageDownloadOperation.h"
#import <UIKit/UIKit.h>

typedef void (^YQImageDownloadCompletedBlock) (UIImage *image, NSError * error, NSURL *imageURL);

@protocol YQWebImageOperationProtocol <NSObject>
@required
- (void)cancel;
@end

@interface YQWebImageManager : NSObject
/**
 单例
 */
+ (instancetype)shareManager;

/**
 添加操作
 
 @param url 图片的url
 @param completedBlock 完成后回调
 */
- (void)addOperationWithURL:(NSURL *)url completed:(YQImageDownloadCompletedBlock)completedBlock;

/**
 取消操作
 
 @param url 图片的url
 */
- (void)cancleOpeartionWithURL:(NSURL *)url;
@end
