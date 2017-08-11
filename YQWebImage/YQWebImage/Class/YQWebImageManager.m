
//
//  YQOperationManager.m
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/3.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "YQWebImageManager.h"
#import "YQImageCacheManager.h"
#import "YQImageDownloadOperation.h"

@interface YQCombinedOperation : NSObject  <YQWebImageOperationProtocol>
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;
@property (nonatomic, strong) NSOperation *cacheOperation;
@property (nonatomic, strong) YQImageDownloadOperation *downloadOperation;
@end

@implementation YQCombinedOperation
- (void)cancel
{
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.downloadOperation) {
        [self.downloadOperation cancel];
        self.downloadOperation = nil;
    }
}
@end

@interface YQWebImageManager()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *operations;
@end

@implementation YQWebImageManager
+ (instancetype)shareManager
{
    static YQWebImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YQWebImageManager alloc] init];
    });
    return manager;
}


- (void)addOperationWithURL:(NSURL *)url completed:(YQImageDownloadCompletedBlock)completedBlock
{
  
    __block YQCombinedOperation *operation = [YQCombinedOperation new];
    __weak YQCombinedOperation *weakOperation = operation;
    
    
    operation.cacheOperation = [[YQImageCacheManager shareManager] queryCacheOperationForKey:url.absoluteString complete:^(UIImage *image) {
        if (image && completedBlock) {
            completedBlock(image, nil, url);
            return;
        }
        
        // 如果没有图片 需要下载了 使用自定义的Operation 在main中写下载方法
        YQImageDownloadOperation *operation = [[YQImageDownloadOperation alloc] initWithURL:url complete:^(UIImage *image) {
            // 获得图片后 传递图片
            if (completedBlock) completedBlock(image, nil, url);
            // 移除操作
            [self.operations removeObjectForKey:url.absoluteString];
        }];
        [self.queue addOperation:operation];
        weakOperation.downloadOperation = operation;
    }];
    
    [self.operations setObject:operation forKey:url.absoluteString];
}

// 取消操作
- (void)cancleOpeartionWithURL:(NSURL *)url
{
    YQCombinedOperation *operation = self.operations[url.absoluteString];
    if (operation && [operation respondsToSelector:@selector(cancel)]) {
        [operation cancel];
        [self.operations removeObjectForKey:url.absoluteString];
    }
}

- (NSMutableDictionary *)operations
{
    if (_operations == nil) {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}

- (NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 4;
    }
    return _queue;
}



@end
