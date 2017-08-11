//
//  UIImageView+YQAdd.m
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/3.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "UIImageView+YQAdd.h"
#import "YQImageCacheManager.h"
#import <objc/runtime.h>

static char urlKey;

@implementation UIImageView (YQAdd)
- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil completedBlock:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage
{
    [self setImageWithURL:url placeholderImage:placeholderImage completedBlock:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completedBlock:(YQImageDownloadCompletedBlock)completedBlock
{
    if (placeholderImage) {
        self.image = placeholderImage;
    } else {
        self.image = [UIImage imageNamed:@""];
    }
            
    
    if (url == nil || url.absoluteString.length == 0) {
        completedBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil], nil);
        return;
    }
    
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    

    // 获取当前视图 上一次的 urlkey
    NSString *lastKey = [self getURLKey];
    
    // 移除
    [[YQWebImageManager shareManager] cancleOpeartionWithURL:[NSURL URLWithString:lastKey]];
    
    
    
    [[YQWebImageManager shareManager] addOperationWithURL:url completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
        self.image = image;
        if (completedBlock) completedBlock(image, nil, url);
    }];
    
    [self setURLKey:url.absoluteString];
}

// 获取urlkey
- (NSString *)getURLKey
{
    return objc_getAssociatedObject(self, &urlKey);
}

// 设置urlkey
- (void)setURLKey:(NSString *)urlStr
{
    objc_setAssociatedObject(self, &urlKey, urlStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
