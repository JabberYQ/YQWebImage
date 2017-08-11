//
//  UIImage+Decode.h
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/10.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Decode)
/**
 编码图片
 
 @param image 需要编码的图片
 */
+ (UIImage *)decodedImageWithImage:(UIImage *)image;
@end
