//
//  DDCollectionViewFlowLayout.swift
//  DDCollectionViewFlowLayout_Swift
//
//  Created by DeJohn Dong on 15/9/30.
//  Copyright © 2015年 ddkit. All rights reserved.
//

import UIKit

@objc protocol DDCollectionViewDelegateFlowLayout : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DDCollectionViewFlowLayout, numberOfColumnInSection section: Int) -> NSInteger
    
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: DDCollectionViewFlowLayout, backgroundColorForSectionAtIndex index: Int) -> UIColor
}

class DDCollectionViewFlowLayout : UICollectionViewFlowLayout {
    fileprivate var sectionRects = NSMutableArray()
    fileprivate var columnRectsInSection = NSMutableArray()
    fileprivate var layoutItemAttributes = NSMutableArray()
    fileprivate var headerItemAttributes = NSMutableArray()
    fileprivate var footerItemAttributes = NSMutableArray()
    fileprivate var sectionInsetses = NSMutableArray()
    fileprivate var backgroundColorAttributes = NSMutableArray()
    fileprivate var currentEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    @IBOutlet weak var delegate : DDCollectionViewDelegateFlowLayout?
    @IBInspectable var enableStickyHeaders = false
    
    override var collectionViewContentSize : CGSize {
        var lastSize = super.collectionViewContentSize
        
        let lastSectionRect = (sectionRects.lastObject! as AnyObject).cgRectValue
        lastSize = CGSize(width: (self.collectionView?.bounds.width)!, height: (lastSectionRect?.maxY)!)
        return lastSize
    }
    
    override func prepare() -> Void {
        let numberOfSections = self.collectionView!.numberOfSections
        self.layoutItemAttributes.removeAllObjects()
        self.footerItemAttributes.removeAllObjects()
        self.headerItemAttributes.removeAllObjects()
        self.sectionRects.removeAllObjects()
        self.backgroundColorAttributes.removeAllObjects()
        self.columnRectsInSection.removeAllObjects()
        for i in 0 ..< numberOfSections {
            let itemsInSection = self.collectionView?.numberOfItems(inSection: i)
            self.layoutItemAttributes.add(NSMutableArray.init(capacity: 0))
            self.prepareLayoutInSection(i, numberOfItems: itemsInSection!)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return (layoutItemAttributes.object(at: indexPath.section) as AnyObject).object(at: indexPath.item) as? UICollectionViewLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader {
            return headerItemAttributes.object(at: indexPath.section) as? UICollectionViewLayoutAttributes
        } else {
            return footerItemAttributes.object(at: indexPath.section) as? UICollectionViewLayoutAttributes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.searchVisibleLayoutAttributesInRect(rect)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.enableStickyHeaders
    }
    
    fileprivate func prepareLayoutInSection(_ index: Int, numberOfItems items: Int) {
        let collectionView = self.collectionView
        
        let indexPath = IndexPath.init(item: 0, section: index)
        
        let previouseSectionRect = self.rectForSectionAtIndex(indexPath.section - 1)
        
        var sectionRect: CGRect = CGRect.zero
        sectionRect.origin.x = 0
        sectionRect.origin.y = previouseSectionRect.height + previouseSectionRect.minY
        sectionRect.size.width = (collectionView?.bounds.size.width)!
        
        var headerHeight: CGFloat = 0.0
        
        if ((self.delegate?.collectionView?(self.collectionView!, layout: self, referenceSizeForHeaderInSection: index)) != nil) {
            var headerFrame: CGRect = CGRect.zero
            headerFrame.origin.x = 0.0
            headerFrame.origin.y = sectionRect.origin.y
            
            let headerSize = self.delegate?.collectionView!(self.collectionView!, layout: self, referenceSizeForHeaderInSection: index)
            
            headerFrame.size.width = (headerSize?.width)!
            headerFrame.size.height = (headerSize?.height)!
            
            let headerAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
            
            headerAttributes.frame = headerFrame
            
            headerHeight = headerFrame.size.height
            
            self.headerItemAttributes.add(headerAttributes)
        }
        
        var sectionInsets = UIEdgeInsets.zero
        
        if ((self.delegate?.collectionView?(self.collectionView!, layout: self, insetForSectionAt: index)) != nil) {
            sectionInsets = (self.delegate?.collectionView!(self.collectionView!, layout: self, insetForSectionAt: index))!
        }
        
        self.sectionInsetses.add(NSValue.init(uiEdgeInsets: sectionInsets))
        
        var interitemSpacing: CGFloat = self.minimumInteritemSpacing
        var lineSpacing: CGFloat = self.minimumLineSpacing
        
        if ((self.delegate?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index)) != nil) {
            interitemSpacing = (self.delegate?.collectionView!(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: index))!
        }
        
        if ((self.delegate?.collectionView?(self.collectionView!, layout: self, minimumLineSpacingForSectionAt: index)) != nil) {
            lineSpacing = (self.delegate?.collectionView!(self.collectionView!, layout: self, minimumLineSpacingForSectionAt: index))!
        }
        
        var itemsContentRect: CGRect = CGRect.zero
        itemsContentRect.origin.x = sectionInsets.left
        itemsContentRect.origin.y = headerHeight + sectionInsets.top
        
        let numberOfColumns = self.delegate?.collectionView(self.collectionView!, layout: self, numberOfColumnInSection: index)
        itemsContentRect.size.width = (collectionView?.frame.size.width)! - (sectionInsets.left + sectionInsets.right)
        
        let columnSpace: CGFloat = itemsContentRect.size.width - (interitemSpacing * (CGFloat)(numberOfColumns! - 1))
        let columnWidth: CGFloat = columnSpace / CGFloat.init(integerLiteral:(numberOfColumns! == 0 ? 1 : numberOfColumns!))
        
        let columns = NSMutableArray.init(capacity: numberOfColumns!)
        for _ in 0 ..< numberOfColumns! {
            columns.add(NSMutableArray.init(capacity: 0))
        }
        
        self.columnRectsInSection.add(columns)

        
        for itemIndex in 0 ..< items {
            let itemIndexPath = IndexPath.init(item: itemIndex, section: index)
            let destinationColumnIndex = self.preferredColumnIndexInSection(index)
            let destinationRowInColumn = self.numberOfItemsForColumn(destinationColumnIndex, inSection: index)
            var lastItemInColumnOffsetY = self.lastItemOffsetYForColumn(destinationColumnIndex, inSection: index)
            
            if destinationRowInColumn == 0 {
                lastItemInColumnOffsetY += sectionRect.origin.y
            }
            
            var itemRect: CGRect = CGRect.zero
            itemRect.origin.x = itemsContentRect.origin.x + CGFloat.init(integerLiteral: destinationColumnIndex) * (interitemSpacing + columnWidth)
            itemRect.origin.y = lastItemInColumnOffsetY + (destinationRowInColumn > 0 ? lineSpacing : sectionInsets.top)
            itemRect.size.width = columnWidth
            itemRect.size.height = columnWidth
            
            if ((self.delegate?.collectionView?(self.collectionView!, layout: self, sizeForItemAt: itemIndexPath)) != nil) {
                let itemSize = self.delegate?.collectionView?(self.collectionView!, layout: self, sizeForItemAt: itemIndexPath)
                itemRect.size.height = itemSize!.height
            }
            
            let itemAttributes = UICollectionViewLayoutAttributes.init(forCellWith: itemIndexPath)
            itemAttributes.frame = itemRect
            (self.layoutItemAttributes.object(at: index) as AnyObject).add(itemAttributes)
            ((self.columnRectsInSection.object(at: index) as AnyObject).object(at: destinationColumnIndex) as AnyObject).add(NSValue.init(cgRect: itemRect))
        }
        
        itemsContentRect.size.height = self.heightOfItemsInSection(indexPath.section) + sectionInsets.bottom
        
        var footerHeight: CGFloat = 0.0
        if ((self.delegate?.collectionView?(self.collectionView!, layout: self, referenceSizeForFooterInSection: index)) != nil) {
            var footerFrame: CGRect = CGRect.zero
            footerFrame.origin.x = 0.0
            footerFrame.origin.y = sectionRect.origin.y
            
            let footerSize = self.delegate?.collectionView!(self.collectionView!, layout: self, referenceSizeForFooterInSection: index)
            
            footerFrame.size.width = (footerSize?.width)!
            footerFrame.size.height = (footerSize?.height)!
            
            let footerAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: indexPath)
            
            footerAttributes.frame = footerFrame
            
            footerHeight = footerFrame.size.height
            
            self.footerItemAttributes.add(footerAttributes)
        }
        
        if index > 0 {
            itemsContentRect.size.height -= sectionRect.origin.y
        }
        sectionRect.size.height = itemsContentRect.size.height + footerHeight
        
        self.sectionRects.add(NSValue.init(cgRect: sectionRect))
    }
    
    fileprivate func heightOfItemsInSection(_ index: Int) -> CGFloat {
        var maxHeightBetweenColumns : CGFloat = 0.0
        let columnsInSection = self.columnRectsInSection.object(at: index) as! NSArray
        for columnIndex in 0 ..< columnsInSection.count {
            let heightOfColumn = self.lastItemOffsetYForColumn(columnIndex, inSection: index)
            maxHeightBetweenColumns = max(maxHeightBetweenColumns, heightOfColumn)
        }
        return maxHeightBetweenColumns
    }
    
    fileprivate func numberOfItemsForColumn(_ columnIndex: Int, inSection sectionIndex: Int) -> Int {
        let sectionColumns = self.columnRectsInSection.object(at: sectionIndex) as! NSArray
        return (sectionColumns.object(at: columnIndex) as! NSArray).count
    }
    
    fileprivate func lastItemOffsetYForColumn(_ columnIndex: Int, inSection sectionIndex: Int) -> CGFloat {
        let columnsInSection = self.columnRectsInSection.object(at: sectionIndex) as! NSArray
        let itemsInColumn = columnsInSection.object(at: columnIndex)
        if (itemsInColumn as AnyObject).count == 0 {
            if self.headerItemAttributes.count > sectionIndex {
                let headerAttributes = self.headerItemAttributes.object(at: sectionIndex) as! UICollectionViewLayoutAttributes
                let headerFrame = headerAttributes.frame
                return headerFrame.size.height
            }
            return 0
        } else {
            let lastItemRectValue = (itemsInColumn as AnyObject).lastObject as! NSValue
            let lastItemRect = lastItemRectValue.cgRectValue
            return lastItemRect.maxY
        }
    }
    
    fileprivate func preferredColumnIndexInSection(_ index: Int) -> Int {
        var shortestColumnIndex = 0
        var heightOfShortestColumn = CGFloat.greatestFiniteMagnitude
        let columnRects = self.columnRectsInSection.object(at: index) as! NSArray
        for columnIndex in 0 ..< columnRects.count {
            let columnHeight = self.lastItemOffsetYForColumn(columnIndex, inSection: index)
            if columnHeight < heightOfShortestColumn {
                heightOfShortestColumn = columnHeight
                shortestColumnIndex = columnIndex
            }
        }
        return shortestColumnIndex
    }
    
    fileprivate func rectForSectionAtIndex(_ index: Int) -> CGRect {
        if index < 0 || index >= self.sectionRects.count {
            return CGRect.zero
        }
        
        let sectionRectValue = self.sectionRects.object(at: index) as! NSValue
        let sectionRect = sectionRectValue.cgRectValue
        return sectionRect
    }
    
    fileprivate func searchVisibleLayoutAttributesInRect(_ rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let itemAttrs = NSMutableArray()
        let visibleSection = self.sectionIndexesInRect(rect)
        (visibleSection as NSIndexSet).enumerate({ (sectionIndex: Int, pointer: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            let sectionLayoutItemAttributes = self.layoutItemAttributes.object(at: sectionIndex)
            for i in 0 ..< (sectionLayoutItemAttributes as AnyObject).count {
                let layoutItemAttributes = (sectionLayoutItemAttributes as AnyObject).object(at: i) as! UICollectionViewLayoutAttributes
                layoutItemAttributes.zIndex = 1
                let itemRect = layoutItemAttributes.frame
                let isVisible = rect.intersects(itemRect)
                if isVisible {
                    itemAttrs.add(layoutItemAttributes)
                }
            }
            
            if self.footerItemAttributes.count > sectionIndex {
                let footerLayoutAttributes = self.footerItemAttributes.object(at: sectionIndex) as! UICollectionViewLayoutAttributes
                let isVisible = rect.intersects(footerLayoutAttributes.frame)
                if isVisible {
                    itemAttrs.add(footerLayoutAttributes)
                }
                self.currentEdgeInsets = UIEdgeInsets.zero
            } else {
                let insetsValue = self.sectionInsetses.object(at: sectionIndex) as! NSValue
                self.currentEdgeInsets = insetsValue.uiEdgeInsetsValue
            }
            
            if self.headerItemAttributes.count > sectionIndex {
                let headerLayoutAttributes = self.headerItemAttributes.object(at: sectionIndex) as! UICollectionViewLayoutAttributes
                if self.enableStickyHeaders {
                    let lastItemAttributes = itemAttrs.lastObject as! UICollectionViewLayoutAttributes
                    
                    itemAttrs.add(headerLayoutAttributes)
                    
                    if lastItemAttributes.representedElementKind != UICollectionElementKindSectionHeader {
                        self.updateTheHeaderLayoutAttributes(headerLayoutAttributes, lastItemAttributes: lastItemAttributes)
                    }
                    
                } else {
                    let isVisible = rect.intersects(headerLayoutAttributes.frame)
                    if isVisible {
                        itemAttrs.add(headerLayoutAttributes)
                    }
                }
            }
        })
        return NSArray(array: itemAttrs) as? [UICollectionViewLayoutAttributes]
    }
    
    fileprivate func sectionIndexesInRect(_ rect: CGRect) -> IndexSet {
        let visibleIndexes = NSMutableIndexSet()
        let numberOfSections = self.collectionView?.numberOfSections
        for index in 0 ..< numberOfSections! {
            let sectionRectValue = self.sectionRects.object(at: index) as! NSValue
            let sectionRect = sectionRectValue.cgRectValue
            let isVisible = rect.intersects(sectionRect)
            if isVisible {
                visibleIndexes.add(index)
            }
        }
        return visibleIndexes as IndexSet
    }
    
    fileprivate func updateTheHeaderLayoutAttributes(_ headerAttributes: UICollectionViewLayoutAttributes, lastItemAttributes: UICollectionViewLayoutAttributes) -> Void {
        let currentBounds = self.collectionView?.bounds
        headerAttributes.zIndex = 1024
        headerAttributes.isHidden = false
        
        var origin = headerAttributes.frame.origin
        let sectionMaxY = lastItemAttributes.frame.maxY - lastItemAttributes.frame.size.height + self.currentEdgeInsets.bottom
        let y = (currentBounds?.maxY)! - (currentBounds?.size.height)! + (self.collectionView?.contentInset.top)!
        
        let maxY = min(max(y, headerAttributes.frame.origin.y), sectionMaxY)
        
        origin.y = maxY
        
        headerAttributes.frame = CGRect(x: origin.x, y: origin.y, width: headerAttributes.frame.size.width, height: headerAttributes.frame.size.height)
        
    }
}


