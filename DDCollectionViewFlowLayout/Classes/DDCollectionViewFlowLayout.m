//
//  DDCollectionViewFlowLayout.m
//  DDCollectionViewFlowLayout
//
//  Created by Diaoshu on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "DDCollectionViewFlowLayout.h"

@interface DDCollectionViewFlowLayout(){
    NSMutableArray			*sectionRects;
    NSMutableArray			*columnRectsInSection;
    
    NSMutableArray			*layoutItemAttributes;
    NSDictionary            *headerFooterItemAttributes;
}

@end

@implementation DDCollectionViewFlowLayout

- (CGSize)collectionViewContentSize {
   [super collectionViewContentSize];
    
    CGRect lastSectionRect = [[sectionRects lastObject] CGRectValue];
    CGSize lastsize = CGSizeMake(CGRectGetWidth(self.collectionView.frame),CGRectGetMaxY(lastSectionRect));
    return lastsize;
}

- (void)prepareLayout{
    NSUInteger numberOfSections = self.collectionView.numberOfSections;
    sectionRects = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    columnRectsInSection = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    layoutItemAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    headerFooterItemAttributes = @{UICollectionElementKindSectionHeader:[NSMutableArray array], UICollectionElementKindSectionFooter:[NSMutableArray array]};
    
    for (NSUInteger section = 0; section < numberOfSections; ++section) {
        NSUInteger itemsInSection = [self.collectionView numberOfItemsInSection:section];
        [layoutItemAttributes addObject:[NSMutableArray array]];
        [self prepareSectionLayout:section withNumberOfItems:itemsInSection];
    }
}

- (void)prepareSectionLayout:(NSUInteger)section withNumberOfItems:(NSUInteger)numberOfItems{
    UICollectionView *cView = self.collectionView;
    
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]){
        sectionInsets = [self.delegate collectionView:cView layout:self insetForSectionAtIndex:section];
    }
    
    CGFloat lineSpacing = 0.0f;
    CGFloat interitemSpacing = 0.0f;

    if([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]){
        interitemSpacing = [self.delegate collectionView:cView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]){
        lineSpacing = [self.delegate collectionView:cView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    
    NSIndexPath *sectionPath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    // #1: Define the rect of the section
    CGRect previousSectionRect = [self rectForSectionAtIndex:section - 1];
    CGRect sectionRect;
    sectionRect.origin.x = sectionInsets.left;
    sectionRect.origin.y = CGRectGetMaxY(previousSectionRect)+sectionInsets.top;
    
    NSUInteger numberOfColumns = [self.delegate collectionView:cView layout:self numberOfColumnsInSection:section];
    sectionRect.size.width = CGRectGetWidth(cView.frame) - (sectionInsets.left + sectionInsets.right);
    
    CGFloat columnSpace = sectionRect.size.width - (interitemSpacing * (numberOfColumns-1));
    CGFloat columnWidth = (columnSpace/numberOfColumns);
    
    // store space for each column
    [columnRectsInSection addObject:[NSMutableArray arrayWithCapacity:numberOfColumns]];
    for (NSUInteger colIdx = 0; colIdx < numberOfColumns; ++colIdx)
        [columnRectsInSection[section] addObject:[NSMutableArray array]];
    
    // #2: Define the rect of the header
    CGRect headerFrame;
    headerFrame.origin = sectionRect.origin;
    headerFrame.origin.x = 0.0f;
    headerFrame.size.width = cView.contentSize.width;
    headerFrame.size.height = 0.0f;
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]){
        CGSize headerSize = [self.delegate collectionView:cView layout:self referenceSizeForHeaderInSection:section];
        headerFrame.size.height = headerSize.height;
        headerFrame.size.width = headerSize.width;
    }
    
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes
                                                          layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                          withIndexPath:sectionPath];
    headerAttributes.frame = headerFrame;
    [headerFooterItemAttributes[UICollectionElementKindSectionHeader] addObject:headerAttributes];
    
    // add headerAttributes to layoutItemAttributes arrays
    if (headerFrame.size.height > 0)
        [layoutItemAttributes[section] addObject:headerAttributes];
    
    // #3: Define the rect of the of each item
    for (NSInteger itemIdx = 0; itemIdx < numberOfItems; ++itemIdx) {
        NSIndexPath *itemPath = [NSIndexPath indexPathForItem:itemIdx inSection:section];
        CGSize itemSize = [self.delegate collectionView:cView layout:self sizeForItemAtIndexPath:itemPath];
        
        NSInteger destColumnIdx = [self preferredColumnIndexInSection:section];
        NSInteger destRowInColumn = [self numberOfItemsInColumn:destColumnIdx ofSection:section];
        CGFloat lastItemInColumnOffset = [self lastItemOffsetInColumn:destColumnIdx inSection:section];
        
        CGRect itemRect;
        itemRect.origin.x = sectionRect.origin.x + destColumnIdx * (interitemSpacing + columnWidth);
        itemRect.origin.y = lastItemInColumnOffset + (destRowInColumn > 0 ? lineSpacing: 0.0f);
        itemRect.size.width = columnWidth;
        itemRect.size.height = itemSize.height;
        
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemPath];
        itemAttributes.frame = itemRect;
        [layoutItemAttributes[section] addObject:itemAttributes];
        [columnRectsInSection[section][destColumnIdx] addObject:[NSValue valueWithCGRect:itemRect]];
    }
    
    // #3 Define the rect of the footer
    CGRect footerFrame;
    footerFrame.origin.x = headerFrame.origin.x;
    footerFrame.origin.y = [self heightOfItemsInSection:section] + lineSpacing;
    footerFrame.size.width = headerFrame.size.width;
    footerFrame.size.height = 0.0f;
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]){
        CGSize footerSize = [self.delegate collectionView:cView layout:self referenceSizeForFooterInSection:section];
        footerFrame.size.height = footerSize.height;
        footerFrame.size.width = footerSize.width;
    }
    
    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes
                                                          layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                          withIndexPath:sectionPath];
    footerAttributes.frame = footerFrame;
    [headerFooterItemAttributes[UICollectionElementKindSectionFooter] addObject:footerAttributes];
    
    // add headerAttributes to layoutItemAttributes arrays.
    if (footerFrame.size.height)
        [layoutItemAttributes[section] addObject:footerAttributes];
    
    sectionRect.size.height = (CGRectGetMaxY(footerFrame) - CGRectGetMinY(headerFrame)) + sectionInsets.bottom;
    [sectionRects addObject:[NSValue valueWithCGRect:sectionRect]];
}

- (CGFloat)heightOfItemsInSection:(NSUInteger)sectionIdx {
    CGFloat maxHeightBetweenColumns = 0.0f;
    NSArray *columnsInSection = columnRectsInSection[sectionIdx];
    for (NSUInteger columnIdx = 0; columnIdx < columnsInSection.count; ++columnIdx) {
        CGFloat heightOfColumn = [self lastItemOffsetInColumn:columnIdx inSection:sectionIdx];
        maxHeightBetweenColumns = MAX(maxHeightBetweenColumns,heightOfColumn);
    }
    return maxHeightBetweenColumns;
}

- (NSInteger)numberOfItemsInColumn:(NSInteger)columnIdx ofSection:(NSInteger)sectionIdx {
    return [columnRectsInSection[sectionIdx][columnIdx] count];
}

- (CGFloat)lastItemOffsetInColumn:(NSInteger)columnIdx inSection:(NSInteger)sectionIdx {
    NSArray *itemsInColumn = columnRectsInSection[sectionIdx][columnIdx];
    if (itemsInColumn.count == 0) {
        CGRect headerFrame = [headerFooterItemAttributes[UICollectionElementKindSectionHeader][sectionIdx] frame];
        return CGRectGetMaxY(headerFrame);
    } else {
        CGRect lastItemRect = [[itemsInColumn lastObject] CGRectValue];
        return CGRectGetMaxY(lastItemRect);
    }
}

- (NSInteger)preferredColumnIndexInSection:(NSInteger)sectionIdx {
    NSUInteger shortestColumnIdx = 0;
    CGFloat heightOfShortestColumn = CGFLOAT_MAX;
    for (NSUInteger columnIdx = 0; columnIdx < [columnRectsInSection[sectionIdx] count]; ++columnIdx) {
        CGFloat columnHeight = [self lastItemOffsetInColumn:columnIdx inSection:sectionIdx];
        if (columnHeight < heightOfShortestColumn) {
            shortestColumnIdx = columnIdx;
            heightOfShortestColumn = columnHeight;
        }
    }
    return shortestColumnIdx;
}

- (CGRect)rectForSectionAtIndex:(NSInteger)sectionIdx {
    if (sectionIdx < 0 || sectionIdx >= sectionRects.count)
        return CGRectZero;
    return [sectionRects[sectionIdx] CGRectValue];
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return headerFooterItemAttributes[kind][indexPath.section];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    return layoutItemAttributes[indexPath.section][indexPath.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)visibleRect {
    return [self searchVisibleLayoutAttributesInRect:visibleRect];
}

- (NSArray *)searchVisibleLayoutAttributesInRect:(CGRect)visibleRect {
    NSMutableArray *itemAttrs = [[NSMutableArray alloc] init];
    NSIndexSet *visibleSections = [self sectionIndexesInRect:visibleRect];
    [visibleSections enumerateIndexesUsingBlock:^(NSUInteger sectionIdx, BOOL *stop) {
        for (UICollectionViewLayoutAttributes *itemAttr in layoutItemAttributes[sectionIdx]) {
            CGRect itemRect = itemAttr.frame;
            BOOL isVisible = CGRectIntersectsRect(visibleRect, itemRect);
            if (isVisible)
                [itemAttrs addObject:itemAttr];
        }
    }];
    return itemAttrs;
}

- (NSIndexSet *)sectionIndexesInRect:(CGRect)aRect {
    CGRect theRect = aRect;
    NSMutableIndexSet *visibleIndexes = [[NSMutableIndexSet alloc] init];
    NSUInteger numberOfSections = self.collectionView.numberOfSections;
    for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx) {
        CGRect sectionRect = [sectionRects[sectionIdx] CGRectValue];
        BOOL isVisible = CGRectIntersectsRect(theRect, sectionRect);
        if (isVisible)
            [visibleIndexes addIndex:sectionIdx];
    }
    return visibleIndexes;
}

@end
