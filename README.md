# YQWebImage
简单的异步下载图片和本地获取图片，轻量级的SDWebImage

![YQWebImage](http://upload-images.jianshu.io/upload_images/2312304-c5e5414e53515a95.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

终于，再看了多遍SDWebImage源码和多次debug之后，写出了迷你版本YQWebImage。这一次终于不再出现掉帧和内存暴涨的问题了。
额，怎么说呢，这次也是一个比较好的契机，公司比较闲，空闲时间多，刚好在写图片展示器，就想着写个图片下载缓存器来配合他。平常用的都是SDWebImage，也没仔细看他的源码，这次也能好好研究一下。
# 效果
### 下载图片
![DownloadImageEffect.gif](http://upload-images.jianshu.io/upload_images/2312304-91284c4fb158b9ba.gif?imageMogr2/auto-orient/strip)

### 从磁盘取图片

![DiskImageEffect.gif](http://upload-images.jianshu.io/upload_images/2312304-1da19db511ba4571.gif?imageMogr2/auto-orient/strip)

### 下载图片内存情况

![MemoryEffect1.gif](http://upload-images.jianshu.io/upload_images/2312304-0b51d4f44f41b513.gif?imageMogr2/auto-orient/strip)

### 磁盘取内存情况

![MemoryEffect2.gif](http://upload-images.jianshu.io/upload_images/2312304-f56f10e953ad0bf9.gif?imageMogr2/auto-orient/strip)

# 项目结构

![项目结构.png](http://upload-images.jianshu.io/upload_images/2312304-eabfb91a3398329c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其中，`` YQDisplayPhotoContainerView``类来自上一篇文章[自造小轮子：图片展示器（类似微博首页）](http://www.jianshu.com/p/4e52165aa0a7)。`` YQWebImage``文件就是本次轮子的全部。``data``文件夹内是本demo的数据来源。

### Category
#####  UIImageView+YQAdd
``UIImageView+YQAdd``目的只是提供一个接口，方便使用者调用。用过SDWebImage一定不会陌生。
```
/**
 通过url设置图片（来源：网络或本地）
 
 @param url 图片的url
 @param placeholderImage 占位图片
 @param completedBlock 完成回调
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage completedBlock:(YQImageDownloadCompletedBlock)completedBlock;
```
##### UIImage+Decode
``UIImage+Decode``完全来自SDWebImage，在图片从网络或者本地获取之后调用，将图片编码，再呈现到界面上。我发现如果不用该方法，从网络下载图片会使得内存暴涨，本地也一样，还会严重掉帧。因此我也把它放进来了。

### Class
#####  YQWebImageManager
``YQWebImageManager``继承``NSObject ``，功能为管理下载图片和本地获取图片操作。相当于只要执行``YQWebImageManager``对象的`` addOperationWithURL``方法，就会异步去获得图片再回调。
```
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
```

#####  YQImageCacheManager
``YQImageCacheManager``继承``NSObject ``，作用为异步查询和保存图片。
```
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

```
#####  YQImageDownloadOperation
``YQImageDownloadOperation``继承``NSOperation``,在``- (void)main``方法中下载图片后返回。
```
/**
 初始化一个操作 异步执行
 
 @param url 图片的url
 @param complete 完成后回调
 */
- (instancetype)initWithURL:(NSURL *)url complete:(void (^)(UIImage *image))complete;
```
# 思路&代码
其实，思路可以说和SDWebImage一模一样。
首先通过分类`` UIImageView+YQAdd``的`` - (void)setImageWithURL ``方法，设置图片。

在`` - (void)setImageWithURL ``中，使用`` YQWebImageManager ``添加一个获图操作。当然需要把之前的操作移除。
```
NSString *lastKey = [self getURLKey];

[[YQWebImageManager shareManager] cancleOpeartionWithURL:[NSURL URLWithString:lastKey]];
         
[[YQWebImageManager shareManager] addOperationWithURL:url completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
        self.image = image;
        if (completedBlock) completedBlock(image, nil, url);
}];

[self setURLKey:url.absoluteString];
```
``- (NSString *)getURLKey ``方法为通过runtime获得``urlKey``属性。
``- (void)setURLKey:(NSString *)urlStr``方法为通过runtime设置``urlKey``属性。
```
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
```
也就是说，每当给一个imageView对象设置图片时，就会先获得上一次保存的``urlKey ``，然后不管``urlKey``对应的这个操作完成与否，都取消掉。然后重新添加操作并且设置新的``urlKey ``。这样做的目的也很简单，当快速滑动tableView的时候，如果不取消上一次，操作就会越来越多。在网络不稳定的情况下，也许后设置的图片比早设置的图片先获取到，那么图片显示的图片将出错。

然后，进入``- (void)addOperationWithURL:(NSURL *)url completed:(YQImageDownloadCompletedBlock)completedBlock ``方法，看看如何添加操作。
在这之前要说说方法里用到的`` YQCombinedOperation``类。
这个类就是把本地获取操作和下载操作结合成同一个操作，这样便于管理。
这个类遵循``<YQWebImageOperationProtocol> ``协议，也就需要实现`` - (void)cancel``方法。
```
@protocol YQWebImageOperationProtocol <NSObject>
@required
- (void)cancel;
@end
```
```
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
```
可以看到，`` - (void)cancel``方法中也是将两个子操作一个个取消，没啥特别的。

下面直接把添加操作的代码放上来。
```
- (void)addOperationWithURL:(NSURL *)url completed:(YQImageDownloadCompletedBlock)completedBlock
{
  
    __block YQCombinedOperation *operation = [YQCombinedOperation new];
    __weak YQCombinedOperation *weakOperation = operation;
    
    // 设置本地获取的操作，完成后执行回调
    operation.cacheOperation = [[YQImageCacheManager shareManager] queryCacheOperationForKey:url.absoluteString complete:^(UIImage *image) {
        // 完成了，如果有图片就直接把图片传回去并返回，也就是不需要下载了
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
        // 添加到队列中，开始异步下载 
        [self.queue addOperation:operation];
        // 设置结合操作的下载操作
        weakOperation.downloadOperation = operation;
    }];
    // 添加到字典 便于取消
    [self.operations setObject:operation forKey:url.absoluteString];
}

// 取消操作
- (void)cancleOpeartionWithURL:(NSURL *)url
{
    // 从字典取出操作 取消
    YQCombinedOperation *operation = self.operations[url.absoluteString];
    if (operation && [operation respondsToSelector:@selector(cancel)]) {
        [operation cancel];
        [self.operations removeObjectForKey:url.absoluteString];
    }
}
```

到现在，思路还是很清晰的。下面进入到``YQImageCacheManager ``去看看本地图片的存取代码。
异步查询并获得本地图片：
```
- (NSOperation *)queryCacheOperationForKey:(NSString *)key complete:(void (^)(UIImage *))completedBlock
{
    // 条件先判断一下
    if (!key) {
        if (completedBlock) {
            completedBlock(nil);
        }
        return nil;
    }
    
    // 从缓存中取呀
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        if (completedBlock) {
            completedBlock(image);
        }
        return nil;
    }
    
    // 缓存中没有呀 异步去磁盘
    NSOperation *operation = [NSOperation new];
    dispatch_async(self.ioQueue, ^{ // 异步执行
        if (operation.isCancelled) {
            return;
        }
        
        @autoreleasepool {
            UIImage *diskImage = [self diskImageForKey:key];
            
            if (diskImage) {
                [self.imageCache setObject:diskImage forKey:key];
            }
            
            if (completedBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completedBlock(diskImage);
                });
            }
        }
    });
    
    return operation;
}
```
异步保存图片到本地和缓存
```
- (void)storeImage:(UIImage *)image imageData:(NSData *)imageData forKey:(NSString *)key completion:(void (^)())completedBlock
{
    if (!image || !key) {
        if (completedBlock) {
            completedBlock();
        }
        return;
    }
    
    // 缓存
    [self.imageCache setObject:image forKey:key];
    
    dispatch_async(self.ioQueue, ^{
        @autoreleasepool {
            if (![self diskImageForKey:key]) {
                [imageData writeToFile:[self getFilePathWithURLStr:key] atomically:YES];
            }
        }
        
        if (completedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock();
            });
        }
    });
}
```
so easy啊。但是要提一下这个异步取图片的操作。从代码中看是创建`` NSOperation ``后，使用GCD来异步操作。而在GCD中，又通过判断``if (operation.isCancelled) ``来决定是否结束本次异步操作。
其实这里也可以通过NSOperation来实现，但是使用GCD更加简便。

最后来看``YQImageDownloadOperation ``，主要看``- (void)main``方法
```
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
```
同样的，思路也很清晰，首先判断操作是否被取消，然后下载图片并保存，最后主线程返回图片。

以上就是全部思路，我把它一层层分解开来，再分析应该会便于理解。其实SD也是这样的思路，只是他考虑的更多，功能也更加强大。

# 简书地址
[自造小轮子：轻量级SDWebImage](http://www.jianshu.com/p/f7acc8c1eaf2)

# 最后
本次轮子的思路来源SDWebImage，本次轮子的数据文件来自YYKit。
