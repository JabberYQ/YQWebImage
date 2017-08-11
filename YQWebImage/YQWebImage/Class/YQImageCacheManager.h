//
//  YQCacheManager.h
//  YQImageExhibition
//
//  Created by 俞琦 on 2017/8/2.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YQImageCacheManager : NSObject
/**
 单例
 */
+ (instancetype)shareManager;

/**
 保存图片到缓存和本地 异步执行
 
 @param image 图片
 @param imageData 数据
 @param key memory中cache的key
 @param completedBlock 完成后回调
 */
- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key completion:(void (^)())completedBlock;

/**
 查询缓存或本地是否有图片 异步执行
 
 @param key memory中cache的key
 @param completedBlock 完成后回调
 */
- (NSOperation *)queryCacheOperationForKey:(NSString *)key complete:(void (^)(UIImage *image))completedBlock;

- (void)deleteAllMemory;
@end
