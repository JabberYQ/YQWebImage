//
//  YQImageDownloadOperation.m
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/8.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "YQImageDownloadOperation.h"
#import "YQImageCacheManager.h"
#import "UIImage+Decode.h"

@interface YQImageDownloadOperation()
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) void (^downloadCompleteBlcok)(UIImage *image);
@end

@implementation YQImageDownloadOperation
- (instancetype)initWithURL:(NSURL *)url complete:(void (^)(UIImage *))complete
{
    if (self = [super init]) {
        self.url = url;
        self.downloadCompleteBlcok = complete;
    }
    return self;
}

- (void)main
{
    if (self.url == nil) {
        return;
    }
    
    // 判断是否被取消了
    if (self.isCancelled) {
        return;
    }
    
    // 简单的下载
    NSData *data = [NSData dataWithContentsOfURL:self.url];
    UIImage *image = [UIImage imageWithData:data];
    image = [UIImage decodedImageWithImage:image];
    
    // 保存下来
    [[YQImageCacheManager shareManager] storeImage:image imageData:data forKey:self.url.absoluteString completion:^{
        
    }];
    
    if (self.isCancelled) {
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.downloadCompleteBlcok(image);
    }];
}

@end
