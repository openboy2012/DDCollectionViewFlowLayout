# DDCollectionViewFlowLayout
a CollectionViewFlowLayout implement the Waterfall Effect

##Effects
<img src="http://ipa-download.qiniudn.com/loadingmore.gif" width="276"/>
<img src="http://ipa-download.qiniudn.com/waterfall.gif" width="276"/>

##Installation

[![Version](http://cocoapod-badges.herokuapp.com/v/DDCollectionViewFlowLayout/badge.png)](http://cocoadocs.org/docsets/DDCollectionViewFlowLayout/) [![Platform](http://cocoapod-badges.herokuapp.com/p/DDCollectionViewFlowLayout/badge.png)](http://cocoadocs.org/docsets/DDCollectionViewFlowLayout/)   
DDCollectionViewFlowLayout is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "DDCollectionViewFlowLayout"
Alternatively, you can just drag the files from `DDCollectionViewFlowLayout / Classes` into your own project. 

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.

import `DDCollectionViewFlowLayout.h` in your project    

import `@interface ViewController ()<DDCollectionViewDelegateFlowLayout,UICollectionViewDataSource>` protocol

for example:
```
    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
    layout.delegate = self;
    [self.collectionView setCollectionViewLayout:layout];
    
```

implemention the `DDCollectionViewDelegateFlowLayout & UICollectionViewDataSource` @required or @optional methods

`DDCollectionViewDelegateFlowLayout` inherit `UICollectionViewDelegateFlowLayout` Protocol.

code:
```
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
```

## Protocol Methods

`- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section;` 

`DDCollectionViewDelegateFlowLayout` inherit `UICollectionViewDelegateFlowLayout` Protocol. so you can use all the `UICollectionViewDelegateFlowLayout` protocal methods in `DDCollectionViewDelegateFlowLayout`

## Requirements

- Xcode 6
- iOS 6.0

## Author

DeJohn Dong, dongjia_9251@126.com

## License

DDCollectionViewFlowLayout is available under the MIT license. See the LICENSE file for more info.
