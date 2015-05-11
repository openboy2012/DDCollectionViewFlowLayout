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
    NSMutableArray *sectionOne;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if(!dataList)
        dataList = [[NSMutableArray alloc] initWithCapacity:0];
    [dataList removeAllObjects];
    
    if(!sectionOne)
        sectionOne = [[NSMutableArray alloc] initWithCapacity:0];
    [sectionOne removeAllObjects];

    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
    layout.delegate = self;
    [self.collectionView setCollectionViewLayout:layout];
    
    [self setData];
    
    __weak typeof(self) weakOfSelf = self;
    [self.collectionView addLegendFooterWithRefreshingBlock:^{
        [weakOfSelf addMore];
    }];
    [self.collectionView addLegendHeaderWithRefreshingBlock:^{
        [weakOfSelf setData];
    }];
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
    if(section == [self numberOfSectionsInCollectionView:collectionView] - 1){
//        NSLog(@"dataList.count = %d",(int)dataList.count);
        return dataList.count;
    }
    return sectionOne.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == [self numberOfSectionsInCollectionView:collectionView] - 1){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
        UILabel *lblTitle = (UILabel *)[cell.contentView viewWithTag:2];
        lblTitle.text = [NSString stringWithFormat:@"{%ld,%ld}",indexPath.section,indexPath.item];
        NSLog(@"lblTitle = %@",lblTitle.text);
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
        return footer;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 8;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(6, 6, 6, 6);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == [self numberOfSectionsInCollectionView:collectionView] - 1)
        return [dataList[indexPath.row][@"size"] CGSizeValue];
    return CGSizeMake(150, 150);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 44);
}

#pragma mark - dataSource methods


- (void)setData{
    [dataList removeAllObjects];
    [sectionOne removeAllObjects];
    for (int i = 0; i < 10; ++i ) {
        NSDictionary *dict = @{@"size":[NSValue valueWithCGSize:CGSizeMake(150.0, 150.0 + rand()%30)],
                               @"color":[UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1.0f]};
        [dataList addObject:dict];
        [sectionOne addObject:dict];
    }
    [self.collectionView.header endRefreshing];
    [self.collectionView reloadData];
}

//- (IBAction)segmentControl:(id)sender{
//    if([(UISegmentedControl *)sender selectedSegmentIndex] == 0){
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//        [self.collectionView setCollectionViewLayout:layout];
//    }else{
//        DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
//        layout.delegate = self;
//        [self.collectionView setCollectionViewLayout:layout];
//    }
//    [self setData];
//}

- (void)addMore{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger item = dataList.count;
    for (int i = 0; i < 10; ++i ) {
        NSDictionary *dict = @{@"size":[NSValue valueWithCGSize:CGSizeMake(150.0, 150.0 + rand()%30)],
                               @"color":[UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1.0f]};
        [dataList addObject:dict];
        [indexPaths addObject:[NSIndexPath indexPathForItem:item + i inSection:[self numberOfSectionsInCollectionView:self.collectionView] - 1]];
    }
//    NSLog(@"indexPaths = %@",indexPaths);
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
//    [self.collectionView reloadData];
    
    [self.collectionView.legendFooter endRefreshing];
}

@end
