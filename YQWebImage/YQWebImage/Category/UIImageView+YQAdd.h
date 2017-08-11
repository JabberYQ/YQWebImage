//
//  UIImageView+YQAdd.h
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/3.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQWebImageManager.h"


@interface UIImageView (YQAdd)
/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 */
- (void)setImageWithURL:(NSURL *)url;

/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 @param placeholderImage 占位图片
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;

/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 @param placeholderImage 占位图片
 @param completedBlock 完成回调
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completedBlock:(YQImageDownloadCompletedBlock)completedBlock;
@end
