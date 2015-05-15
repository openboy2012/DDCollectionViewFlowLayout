//
//  aterfallViewController.m
//  DDCollectionViewFlowLayout
//
//  Created by Diaoshu on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "WaterfallViewController.h"
#import "DDCollectionViewFlowLayout.h"
#import "MJRefresh.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface WaterfallCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *photo;

@end

@implementation WaterfallCell

@end

@interface WaterfallViewController ()<DDCollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    NSMutableArray *dataList;
    NSMutableArray *sectionOne;
}

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

@end

@implementation WaterfallViewController

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
    layout.enableStickyHeaders = YES;
    [self.collectionView setCollectionViewLayout:layout];
    
    [self loadAssets];
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
    if(section == [self numberOfSectionsInCollectionView:collectionView] - 1){
        return dataList.count;
    }
    return sectionOne.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == [self numberOfSectionsInCollectionView:collectionView] - 1){
        WaterfallCell *cell = (WaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
        ALAsset *set = dataList[indexPath.item];
        [cell.photo setImage:[UIImage imageWithCGImage:set.thumbnail]];
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
        header.backgroundColor = [UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:0.5f];
        UILabel *lblTitle = (UILabel *)[header viewWithTag:2];
        lblTitle.text = [NSString stringWithFormat:@"Header %d",(int)indexPath.section + 1];
        return header;
    }else if(kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        footer.backgroundColor = [UIColor colorWithRed:rand()%255/255.0 green:rand()%255/255.0 blue:rand()%255/255.0 alpha:1.0f];
        UILabel *lblTitle = (UILabel *)[footer viewWithTag:2];
        lblTitle.text = [NSString stringWithFormat:@"Footer %d",(int)indexPath.section + 1];
        return footer;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    ALAsset *set = dataList[indexPath.item];
    return CGSizeMake(100, 100 + indexPath.item % 20);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(self.view.bounds.size.width, 44);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(self.view.bounds.size.width, 44);
//}

- (void)loadAssets {
    
    // Initialise
    dataList = [NSMutableArray new];
    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Run in the background as it takes a while to get all assets from the library
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
        NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
        
        // Process assets
        void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result != nil) {
                if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                    NSURL *url = result.defaultRepresentation.url;
                    [_assetLibrary assetForURL:url
                                   resultBlock:^(ALAsset *asset) {
                                       if (asset) {
                                           @synchronized(dataList) {
                                               [dataList addObject:asset];
                                           }
                                       }
                                   }
                                  failureBlock:^(NSError *error){
                                      NSLog(@"operation was not successfull!");
                                  }];
                    
                }
            }
        };
        
        // Process groups
        void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group != nil) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                [assetGroups addObject:group];
            }
            if (dataList.count > 0) {
                // Added first asset so reload data
                [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
