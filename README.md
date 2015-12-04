# DDCollectionViewFlowLayout
a CollectionViewFlowLayout implement the Waterfall Effect, it's also supported mutiple sections.  
you can custom the header & footer, you also can custom the UICollectionViewCell.   
now, you can set header sticky on the top when you scroll the collectionView in version 0.5. 

##Effects
<img src="http://ipa-download.qiniudn.com/effect1.gif" width="276"/>
<img src="http://ipa-download.qiniudn.com/effect2.gif" width="276"/>

##Installation

[![Build Status](https://travis-ci.org/openboy2012/DDCollectionViewFlowLayout.svg?branch=master)](https://travis-ci.org/openboy2012/DDCollectionViewFlowLayout)&nbsp;
[![Version](http://cocoapod-badges.herokuapp.com/v/DDCollectionViewFlowLayout/badge.png)](http://cocoadocs.org/docsets/DDCollectionViewFlowLayout/)&nbsp;[![Platform](http://cocoapod-badges.herokuapp.com/p/DDCollectionViewFlowLayout/badge.png)](http://cocoadocs.org/docsets/DDCollectionViewFlowLayout/)   
DDCollectionViewFlowLayout is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "DDCollectionViewFlowLayout"
Alternatively, you can just drag the files from `DDCollectionViewFlowLayout / Classes` into your own project. 

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first.

**1.example like Wechat photo wall effect** 
```objective-c
    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
    layout.delegate = self;
    layout.enableStickyHeaders = YES; //set the header sticky if you want
    [self.collectionView setCollectionViewLayout:layout];
    
```

implemention the `DDCollectionViewDelegateFlowLayout & UICollectionViewDataSource` @required or @optional methods

`DDCollectionViewDelegateFlowLayout` inherit `UICollectionViewDelegateFlowLayout` Protocol.

code:
```objective-c

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
//        header.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5f];
        UILabel *lblTitle = (UILabel *)[header viewWithTag:2];
        lblTitle.text = sortedArray[indexPath.section];
        return header;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80, 80);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 30);
}

```

**2.effect like waterfall**

example code:
```objective-c
#pragma mark - UICollectionView DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return dataList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WaterfallCell *cell = (WaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    ALAsset *set = dataList[indexPath.item];
    [cell.photo setImage:[UIImage imageWithCGImage:set.thumbnail]];
    return cell;
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
    return CGSizeMake(100, 100 + indexPath.item % 20);
}

```

## Protocol Methods

`- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section;` 

`DDCollectionViewDelegateFlowLayout` inherit `UICollectionViewDelegateFlowLayout` Protocol. so you can use all the `UICollectionViewDelegateFlowLayout` protocal methods in `DDCollectionViewDelegateFlowLayout`

## Updates

* 0.5 add the header sticky feature
* 0.4 code optimzation about the UI

## Requirements

- Xcode 6
- iOS 6.0

## Author

DeJohn Dong, dongjia_9251@126.com

## License

DDCollectionViewFlowLayout is available under the MIT license. See the LICENSE file for more info.
