//
//  ViewController.m
//  DDCollectionViewFlowLayout
//
//  Created by Diaoshu on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "ViewController.h"
#import "DDCollectionViewFlowLayout.h"

@interface ViewController ()<DDCollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    NSMutableArray *dataList;
    BOOL isLoadingMore;
    BOOL hasMore;
    UIActivityIndicatorView *loadingMoreIndicator;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if(!dataList)
        dataList = [[NSMutableArray alloc] initWithCapacity:0];
    [dataList removeAllObjects];

    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
    layout.delegate = self;
    [self.collectionView setCollectionViewLayout:layout];
    
    [self addSize:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return dataList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:2];
    lblTitle.text = [NSString stringWithFormat:@"{%ld,%ld}",indexPath.section,indexPath.item];
    cell.backgroundColor = dataList[indexPath.row][@"color"];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
    if(!hasMore){
        [loadingMoreIndicator stopAnimating];
        [loadingMoreIndicator removeFromSuperview];
        loadingMoreIndicator = nil;
        return footer;
    }
    if(!loadingMoreIndicator)
        loadingMoreIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0f)];
    loadingMoreIndicator.center = CGPointMake(footer.center.x, 15.0f);
    loadingMoreIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [footer addSubview:loadingMoreIndicator];
    [loadingMoreIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(!isLoadingMore && hasMore){
            [self addSize:YES];
        }
    });
    return footer;
}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(6.0f, 6.0, 0.0, 6.0f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [dataList[indexPath.row][@"size"] CGSizeValue];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 44.0f);
}

#pragma mark - dataSource methods


- (void)addSize:(BOOL)isMore{
    if(isLoadingMore)
        return;
    isLoadingMore = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSInteger item = dataList.count;
        for (int i = 0; i < 20; ++i ) {
            NSDictionary *dict = @{@"size":[NSValue valueWithCGSize:CGSizeMake(150.0, 150.0 + rand()%30)],
                                   @"color":[UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1.0f]};
            [dataList addObject:dict];
            [indexPaths addObject:[NSIndexPath indexPathForItem:item + i inSection:0]];
        }
        if(isMore){
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        }else
            [self.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isLoadingMore = NO;
            hasMore = YES;
        });
    });


}

@end
