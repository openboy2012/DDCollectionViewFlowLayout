//
//  DDCollectionViewFlowLayout.h
//  DDCollectionViewFlowLayout
//
//  Created by DeJohn Dong on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  DDCollectionViewFlowLayout;

@protocol DDCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@required
/**
 *  The delegate method set the collectionView will flow layout as the number columns in each section.
 *
 *  @param collectionView The effect collectionView.
 *  @param layout         The DDCollectionViewFlowLayout initialization object.
 *  @param section        The section index.
 *
 *  @return The number of columns in each section.
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(DDCollectionViewFlowLayout *)layout
   numberOfColumnsInSection:(NSInteger)section;

@optional

/**
 The delegate methods set the collectionView section background color

 @param collectionView       The effect collectionView.
 @param collectionViewLayout The DDCollectionViewFlowLayout initialization object.
 @param section              The section index.
 @return The color of the section background view.
 */
- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)collectionViewLayout backgroundColorForSectionAtIndex:(NSInteger)section;

@end

@interface DDCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) IBOutlet id<DDCollectionViewDelegateFlowLayout> delegate;
/**
 *  Defalut is NO, set it's YES the collectionView's header will sticky on the section top.
 */
@property (nonatomic) IBInspectable BOOL enableStickyHeaders;

@end
