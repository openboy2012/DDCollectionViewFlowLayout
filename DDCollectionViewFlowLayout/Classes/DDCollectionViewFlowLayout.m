//
//  DDCollectionViewFlowLayout.m
//  DDCollectionViewFlowLayout
//
//  Created by DeJohn Dong on 15-2-12.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "DDCollectionViewFlowLayout.h"

@interface DDCollectionViewFlowLayout()

@property (nonatomic, strong) NSMutableArray *sectionRects;
@property (nonatomic, strong) NSMutableArray *columnRectsInSection;
@property (nonatomic, strong) NSMutableArray *layoutItemAttributes;
@property (nonatomic, strong) NSDictionary *headerFooterItemAttributes;
@property (nonatomic, strong) NSMutableArray *sectionInsetses;
@property (nonatomic) UIEdgeInsets currentEdgeInsets;

@end

@implementation DDCollectionViewFlowLayout

#pragma mark - UISubclassingHooks Category Methods

- (CGSize)collectionViewContentSize {
    [super collectionViewContentSize];
    
    CGRect lastSectionRect = [[self.sectionRects lastObject] CGRectValue];
    CGSize lastSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetMaxY(lastSectionRect));
    return lastSize;
}

- (void)prepareLayout {
    
    NSUInteger numberOfSections = self.collectionView.numberOfSections;
    self.sectionRects = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    self.columnRectsInSection = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    self.layoutItemAttributes = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    self.sectionInsetses = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
    self.headerFooterItemAttributes = @{UICollectionElementKindSectionHeader:[NSMutableArray array], UICollectionElementKindSectionFooter:[NSMutableArray array]};
    
    for (NSUInteger section = 0; section < numberOfSections; ++section) {
        NSUInteger itemsInSection = [self.collectionView numberOfItemsInSection:section];
        [self.layoutItemAttributes addObject:[NSMutableArray array]];
        [self prepareSectionLayout:section withNumberOfItems:itemsInSection];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return self.headerFooterItemAttributes[kind][indexPath.section];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutItemAttributes[indexPath.section][indexPath.item];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self searchVisibleLayoutAttributesInRect:rect];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - Private Methods

- (void)prepareSectionLayout:(NSUInteger)section withNumberOfItems:(NSUInteger)numberOfItems {
    UICollectionView *cView = self.collectionView;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    
    //# hanlde the section header
    CGFloat headerHeight = 0.0f;
    
    CGRect previousSectionRect = [self rectForSectionAtIndex:indexPath.section - 1];
    CGRect sectionRect;
    sectionRect.origin.x = 0;
    sectionRect.origin.y = CGRectGetHeight(previousSectionRect) + CGRectGetMinY(previousSectionRect);
    sectionRect.size.width = cView.bounds.size.width;
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
        
        //# Define the rect of the header
        CGRect headerFrame;
        headerFrame.origin.x = 0.0f;
        headerFrame.origin.y = sectionRect.origin.y;

        CGSize headerSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
        headerFrame.size.height = headerSize.height;
        headerFrame.size.width = headerSize.width;
        
        UICollectionViewLayoutAttributes *headerAttributes =
        [UICollectionViewLayoutAttributes
         layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
         withIndexPath:indexPath];
        headerAttributes.frame = headerFrame;
        
        headerHeight = headerFrame.size.height;
        [self.headerFooterItemAttributes[UICollectionElementKindSectionHeader] addObject:headerAttributes];
    }

    //# get the insets of section
    UIEdgeInsets sectionInset = UIEdgeInsetsZero;
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInset = [self.delegate collectionView:cView layout:self insetForSectionAtIndex:section];
    }
    
    [self.sectionInsetses addObject:[NSValue valueWithUIEdgeInsets:sectionInset]];
    
    CGRect itemsContentRect;
    
    //# the the lineSpacing & interitemSpacing default values
    CGFloat lineSpacing = 0.0f;
    CGFloat interitemSpacing = 0.0f;

    if([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        interitemSpacing = [self.delegate collectionView:cView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        lineSpacing = [self.delegate collectionView:cView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    
    itemsContentRect.origin.x = sectionInset.left;
    itemsContentRect.origin.y = headerHeight + sectionInset.top;
    
    NSUInteger numberOfColumns = [self.delegate collectionView:cView layout:self numberOfColumnsInSection:section];
    itemsContentRect.size.width = CGRectGetWidth(cView.frame) - (sectionInset.left + sectionInset.right);
    
    CGFloat columnSpace = itemsContentRect.size.width - (interitemSpacing * (numberOfColumns - 1));
    CGFloat columnWidth = (columnSpace/numberOfColumns);
    
    // # store space for each column
    [self.columnRectsInSection addObject:[NSMutableArray arrayWithCapacity:numberOfColumns]];
    for (NSUInteger colIdx = 0; colIdx < numberOfColumns; ++colIdx)
        [self.columnRectsInSection[section] addObject:[NSMutableArray array]];
    
    // # Define the rect of the of each item
    for (NSInteger itemIdx = 0; itemIdx < numberOfItems; ++itemIdx) {
        NSIndexPath *itemPath = [NSIndexPath indexPathForItem:itemIdx inSection:section];
        CGSize itemSize = [self.delegate collectionView:cView layout:self sizeForItemAtIndexPath:itemPath];
        
        NSInteger destColumnIdx = [self preferredColumnIndexInSection:section];
        NSInteger destRowInColumn = [self numberOfItemsInColumn:destColumnIdx ofSection:section];
        CGFloat lastItemInColumnOffset = [self lastItemOffsetInColumn:destColumnIdx inSection:section];
        
        if(destRowInColumn == 0) {
            lastItemInColumnOffset += sectionRect.origin.y;
        }
        
        CGRect itemRect;
        itemRect.origin.x = itemsContentRect.origin.x + destColumnIdx * (interitemSpacing + columnWidth);
        itemRect.origin.y = lastItemInColumnOffset + (destRowInColumn > 0 ? lineSpacing: sectionInset.top);
        itemRect.size.width = columnWidth;
        itemRect.size.height = itemSize.height;
                
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemPath];
        itemAttributes.frame = itemRect;
        [self.layoutItemAttributes[section] addObject:itemAttributes];
        [self.columnRectsInSection[section][destColumnIdx] addObject:[NSValue valueWithCGRect:itemRect]];
    }
    
    itemsContentRect.size.height = [self heightOfItemsInSection:indexPath.section] + sectionInset.bottom;
    
    // # define the section footer
    CGFloat footerHeight = 0.0f;
    if([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        CGRect footerFrame;
        footerFrame.origin.x = 0;
        footerFrame.origin.y = itemsContentRect.size.height;
        
        CGSize footerSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath.section];
        footerFrame.size.height = footerSize.height;
        footerFrame.size.width = footerSize.width;
        
        UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes
                                                              layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withIndexPath:indexPath];
        footerAttributes.frame = footerFrame;
        
        footerHeight = footerFrame.size.height;
        
        [self.headerFooterItemAttributes[UICollectionElementKindSectionFooter] addObject:footerAttributes];
    }
    
    if(section > 0){
        itemsContentRect.size.height -= sectionRect.origin.y;
    }
    
    sectionRect.size.height = itemsContentRect.size.height + footerHeight;

    [self.sectionRects addObject:[NSValue valueWithCGRect:sectionRect]];
}

- (CGFloat)heightOfItemsInSection:(NSUInteger)sectionIdx {
    CGFloat maxHeightBetweenColumns = 0.0f;
    NSArray *columnsInSection = self.columnRectsInSection[sectionIdx];
    for (NSUInteger columnIdx = 0; columnIdx < columnsInSection.count; ++columnIdx) {
        CGFloat heightOfColumn = [self lastItemOffsetInColumn:columnIdx inSection:sectionIdx];
        maxHeightBetweenColumns = MAX(maxHeightBetweenColumns, heightOfColumn);
    }
    return maxHeightBetweenColumns;
}

- (NSInteger)numberOfItemsInColumn:(NSInteger)columnIdx ofSection:(NSInteger)sectionIdx {
    return [self.columnRectsInSection[sectionIdx][columnIdx] count];
}

- (CGFloat)lastItemOffsetInColumn:(NSInteger)columnIdx inSection:(NSInteger)sectionIdx {
    NSArray *itemsInColumn = self.columnRectsInSection[sectionIdx][columnIdx];
    if (itemsInColumn.count == 0) {
        if([self.headerFooterItemAttributes[UICollectionElementKindSectionHeader] count] > sectionIdx) {
            CGRect headerFrame = [self.headerFooterItemAttributes[UICollectionElementKindSectionHeader][sectionIdx] frame];
            return headerFrame.size.height;
        }
        return 0.0f;
    } else {
        CGRect lastItemRect = [[itemsInColumn lastObject] CGRectValue];
        return CGRectGetMaxY(lastItemRect);
    }
}

- (NSInteger)preferredColumnIndexInSection:(NSInteger)sectionIdx {
    NSUInteger shortestColumnIdx = 0;
    CGFloat heightOfShortestColumn = CGFLOAT_MAX;
    for (NSUInteger columnIdx = 0; columnIdx < [self.columnRectsInSection[sectionIdx] count]; ++columnIdx) {
        CGFloat columnHeight = [self lastItemOffsetInColumn:columnIdx inSection:sectionIdx];
        if (columnHeight < heightOfShortestColumn) {
            shortestColumnIdx = columnIdx;
            heightOfShortestColumn = columnHeight;
        }
    }
    return shortestColumnIdx;
}

- (CGRect)rectForSectionAtIndex:(NSInteger)sectionIdx {
    if (sectionIdx < 0 || sectionIdx >= self.sectionRects.count)
        return CGRectZero;
    return [self.sectionRects[sectionIdx] CGRectValue];
}

#pragma mark - Show Attributes Methods
- (NSArray *)searchVisibleLayoutAttributesInRect:(CGRect)rect {
    NSMutableArray *itemAttrs = [[NSMutableArray alloc] init];
    NSIndexSet *visibleSections = [self sectionIndexesInRect:rect];
    [visibleSections enumerateIndexesUsingBlock:^(NSUInteger sectionIdx, BOOL *stop) {
        
        //# items
        for (UICollectionViewLayoutAttributes *itemAttr in self.layoutItemAttributes[sectionIdx]) {
            CGRect itemRect = itemAttr.frame;
            itemAttr.zIndex = 1;
            BOOL isVisible = CGRectIntersectsRect(rect, itemRect);
            if (isVisible)
                [itemAttrs addObject:itemAttr];
        }
        
        //# footer
        if([self.headerFooterItemAttributes[UICollectionElementKindSectionFooter] count] > sectionIdx) {
            UICollectionViewLayoutAttributes *footerAttribute = self.headerFooterItemAttributes[UICollectionElementKindSectionFooter][sectionIdx];
            BOOL isVisible = CGRectIntersectsRect(rect, footerAttribute.frame);
            if (isVisible && footerAttribute)
                [itemAttrs addObject:footerAttribute];
            self.currentEdgeInsets = UIEdgeInsetsZero;
        } else {
            self.currentEdgeInsets = [self.sectionInsetses[sectionIdx] UIEdgeInsetsValue];
        }
        
        //# header
        if([self.headerFooterItemAttributes[UICollectionElementKindSectionHeader] count] > sectionIdx) {
            UICollectionViewLayoutAttributes *headerAttribute = self.headerFooterItemAttributes[UICollectionElementKindSectionHeader][sectionIdx];
            
            if(!self.enableStickyHeaders) {
                BOOL isVisibleHeader = CGRectIntersectsRect(rect, headerAttribute.frame);
                
                if (isVisibleHeader && headerAttribute)
                    [itemAttrs addObject:headerAttribute];
            } else {
                UICollectionViewLayoutAttributes *lastCell = [itemAttrs lastObject];
                
                if(headerAttribute)
                   [itemAttrs addObject:headerAttribute];
                
                [self updateHeaderAttributes:headerAttribute lastCellAttributes:lastCell];
            }
        }
    }];
    return itemAttrs;
}

- (NSIndexSet *)sectionIndexesInRect:(CGRect)rect {
    CGRect theRect = rect;
    NSMutableIndexSet *visibleIndexes = [[NSMutableIndexSet alloc] init];
    NSUInteger numberOfSections = self.collectionView.numberOfSections;
    for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx) {
        CGRect sectionRect = [self.sectionRects[sectionIdx] CGRectValue];
        BOOL isVisible = CGRectIntersectsRect(theRect, sectionRect);
        if (isVisible)
            [visibleIndexes addIndex:sectionIdx];
    }
    return visibleIndexes;
}

#pragma mark - Sticky Header implementation methods

- (void)updateHeaderAttributes:(UICollectionViewLayoutAttributes *)attributes
            lastCellAttributes:(UICollectionViewLayoutAttributes *)lastCellAttributes
{
    CGRect currentBounds = self.collectionView.bounds;
    attributes.zIndex = 1024;
    attributes.hidden = NO;
    
    CGPoint origin = attributes.frame.origin;
    
    CGFloat sectionMaxY = CGRectGetMaxY(lastCellAttributes.frame) - attributes.frame.size.height + self.currentEdgeInsets.bottom;
    
    CGFloat y = CGRectGetMaxY(currentBounds) - currentBounds.size.height + self.collectionView.contentInset.top;
    
    CGFloat maxY = MIN(MAX(y, attributes.frame.origin.y), sectionMaxY);
    
    origin.y = maxY;
    
    attributes.frame = (CGRect){
        origin,
        attributes.frame.size
    };
}

@end
