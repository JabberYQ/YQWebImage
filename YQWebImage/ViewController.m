//
//  ViewController.m
//  YQWebImage
//
//  Created by 俞琦 on 2017/8/10.
//  Copyright © 2017年 俞琦. All rights reserved.
//

#import "ViewController.h"
#import "YQDisplayPhotoContainerView.h"

@interface YQTableViewCell : UITableViewCell
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) YQDisplayPhotoContainerView *displayView;
@property (nonatomic, strong) NSArray *photoArray;
@end

@implementation YQTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(0, 0, 300, 40);
        [self addSubview:label];
        self.label = label;
        
        
        YQDisplayPhotoContainerView *display = [[YQDisplayPhotoContainerView alloc] initWithFrame:CGRectMake(0, 40, 300, 0)];
        [self addSubview:display];
        self.displayView = display;
    }
    return self;
}

- (void)setPhotoArray:(NSArray *)photoArray
{
    _photoArray = photoArray;
    
    self.label.text = [NSString stringWithFormat:@"这一行有%ld个图片", photoArray.count];
    CGFloat height = [YQDisplayPhotoContainerView heightForWidth:300 photoArray:photoArray];
    
    CGRect frame = self.displayView.frame;
    frame.size.height = height;
    self.displayView.frame = frame;
    self.displayView.photoArray = photoArray;
}

@end

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [self getSource];
    
    NSLog(@"%@", NSHomeDirectory());
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YQDisplayPhotoContainerView heightForWidth:300 photoArray:self.listArray[indexPath.row]] + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    YQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[YQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.photoArray = self.listArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)getSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 7; i++) {
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"weibo_%d.json",i] ofType:@""]];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *statusArray = dic[@"statuses"]; // 微博数组
            for (NSDictionary *statusDic in statusArray) {
                NSDictionary *pic_infos = statusDic[@"pic_infos"];
                if (pic_infos) {
                    NSMutableArray *photoArray = [NSMutableArray array];
                    [pic_infos enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                        NSDictionary *photoDic = obj;
                        
                        NSDictionary *bmiddleDic = photoDic[@"large"];
                        if ([bmiddleDic[@"type"] isEqualToString:@"GIF"])
                            return;
                        
                        YQPhotoMetaData *bmiddle = [[YQPhotoMetaData alloc] initWithPicDic:photoDic[@"large"]];
                        
                        YQPhotoMetaData *original = [[YQPhotoMetaData alloc] initWithPicDic:photoDic[@"original"]];
                        
                        YQPhoto *photo = [[YQPhoto alloc] init];
                        photo.picID = photoDic[@"pic_id"];
                        photo.bmiddle = bmiddle;
                        photo.original = original;
                        
                        [photoArray addObject:photo];
                    }];
                    if (photoArray.count != 0)
                        [self.listArray addObject:photoArray];
                }
            }
        }
        [self.listArray addObjectsFromArray:self.listArray];
        [self.listArray addObjectsFromArray:self.listArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = [NSString stringWithFormat:@"加载了%d条", (int)self.listArray.count];
            [self.tableView reloadData];
        });
    });
}

- (NSMutableArray *)listArray
{
    if (_listArray == nil) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}


@end
