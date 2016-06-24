//
//  ViewController.m
//  DDCollectionViewFlowLayout
//
//  Created by DeJohn Dong on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "PhotoViewController.h"
#import "DDCollectionViewFlowLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDate+DDKit.h"

@interface PhotoCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *photo;

@end

@implementation PhotoCell

@end

@interface PhotoViewController ()<DDCollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    NSMutableDictionary *dataDict;
    NSArray *sortedArray;
}

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@property (nonatomic, weak) IBOutlet DDCollectionViewFlowLayout *layout;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"照片墙";
    
    if(!dataDict)
        dataDict = [NSMutableDictionary new];

//    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
//    layout.delegate = self;
//    layout.enableStickyHeaders = YES;
//    [self.collectionView setCollectionViewLayout:layout];
//    self.layout.enableStickyHeaders = YES;
    
    [self loadAssets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[dataDict allKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    sortedArray = [[dataDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [dataDict[sortedArray[section]] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    NSURL *url = dataDict[sortedArray[indexPath.section]][indexPath.row];
    [_assetLibrary assetForURL:url
                   resultBlock:^(ALAsset *asset) {
                       [cell.photo setImage:[UIImage imageWithCGImage:asset.thumbnail]];
                   }
                  failureBlock:^(NSError *error) {
                  }];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if(kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        UILabel *lblTitle = (UILabel *)[header viewWithTag:2];
        lblTitle.text = sortedArray[indexPath.section];
        return header;
    }
    else if(kind == UICollectionElementKindSectionFooter)
    {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footer.backgroundColor = [UIColor colorWithRed:indexPath.section * 10/255.0 green:indexPath.section * 5/255.0 blue:indexPath.section * 8/255.0 alpha:1.0f];
        return footer;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80, [UIScreen mainScreen].bounds.size.width/4 - 2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 30);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(self.view.bounds.size.width, 40);
//}

#pragma mark - dataSource methods

- (void)loadAssets {
    
    // Initialise
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *dataList = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [dataList addObject:result];
                }
            }else{
                if(dataList.count == 0){
                    return;
                }
                NSDate *lastDate = nil;
                NSMutableArray *sectionItems = [NSMutableArray new];
                for (int i = 0; i < dataList.count; i++) {
                    NSDate *date = [dataList[i] valueForProperty:ALAssetPropertyDate];
                    if([lastDate isSameToMonth:date]){
                        NSURL *url = ((ALAsset *)dataList[i]).defaultRepresentation.url;
                        [sectionItems addObject:url];
                    }else{
                        if(!lastDate || sectionItems.count == 0){
                            lastDate = date;
                            continue;
                        }
                        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                        [formater setDateFormat:@"yyyy-MM"];
                        [dataDict setObject:[sectionItems mutableCopy]?:@"" forKey:[formater stringFromDate:lastDate]];
                        [sectionItems removeAllObjects];
                    }
                    lastDate = date;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
        };
        
        // Process!
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                         usingBlock:assetGroupEnumerator
                                       failureBlock:^(NSError *error) {
                                           NSLog(@"There is an error");
                                       }];
        
    });
    
}


@end
