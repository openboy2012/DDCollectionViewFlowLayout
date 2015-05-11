//
//  ViewController.m
//  DDCollectionViewFlowLayout
//
//  Created by Diaoshu on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "ViewController.h"
#import "DDCollectionViewFlowLayout.h"
#import <MJRefresh.h>

@interface ViewController ()<DDCollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    NSMutableArray *dataList;
    NSMutableArray *data2;
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
    
    if(!data2)
        data2 = [[NSMutableArray alloc] initWithCapacity:0];
    [data2 removeAllObjects];

    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
    layout.delegate = self;
    [self.collectionView setCollectionViewLayout:layout];
    
    [self addSize:NO];
    
//    __weak typeof(self) weakOfSelf = self;
//    [self.collectionView addLegendFooterWithRefreshingBlock:^{
//        [weakOfSelf addSize:YES];
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 1)
        return dataList.count;
    return data2.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
        UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:2];
        lblTitle.text = [NSString stringWithFormat:@"{%ld,%ld}",indexPath.section,indexPath.item];
        cell.backgroundColor = dataList[indexPath.row][@"color"];
        return cell;
    }else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
        UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:2];
        lblTitle.text = [NSString stringWithFormat:@"{%ld,%ld}",indexPath.section,indexPath.item];
        cell.backgroundColor = [UIColor yellowColor];
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if(kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        header.backgroundColor = [UIColor greenColor];
        return header;
    }else if(kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footer.backgroundColor = [UIColor blueColor];
//        if(!isLoadingMore){
//            [self addSize:YES];
//        }
        return footer;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(section == 0)
        return UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
    return UIEdgeInsetsMake(6, 6, 6, 6);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1)
        return [dataList[indexPath.row][@"size"] CGSizeValue];
    return CGSizeMake(150, 150);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 55);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 55);
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
        for (int i = 0; i < 10; ++i ) {
            [data2 addObject:@(i)];
        }
        [self.collectionView.legendFooter endRefreshing];
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

- (IBAction)segmentControl:(id)sender{
    [self.collectionView removeFooter];
    [dataList removeAllObjects];
    [data2 removeAllObjects];
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([(UISegmentedControl *)sender selectedSegmentIndex] == 0){
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            [self.collectionView setCollectionViewLayout:layout];
        }else{
            DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
            layout.delegate = self;
            [self.collectionView setCollectionViewLayout:layout];
            __weak typeof(self) weakOfSelf = self;
            [self.collectionView addLegendFooterWithRefreshingBlock:^{
                [weakOfSelf addMore];
            }];
        }
        [self addSize:NO];
        [self.collectionView reloadData];

    });
}

- (void)addMore{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger item = dataList.count;
    for (int i = 0; i < 20; ++i ) {
        NSDictionary *dict = @{@"size":[NSValue valueWithCGSize:CGSizeMake(150.0, 150.0 + rand()%30)],
                               @"color":[UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1.0f]};
        [dataList addObject:dict];
        [indexPaths addObject:[NSIndexPath indexPathForItem:item + i inSection:1]];
    }
    [self.collectionView.legendFooter endRefreshing];
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

@end
