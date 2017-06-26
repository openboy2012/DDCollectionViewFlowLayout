//
//  UICollectionViewLayoutAttributes+DDCollectionViewFlowLayout.m
//  DDCollectionViewFlowLayout
//
//  Created by DeJohn Dong on 2017/6/26.
//  Copyright © 2017年 DDKit. All rights reserved.
//

#import "UICollectionViewLayoutAttributes+DDCollectionViewFlowLayout.h"
#import <objc/runtime.h>

@implementation UICollectionViewLayoutAttributes (DDCollectionViewFlowLayout)

#pragma mark - runtime methods

- (void)setDd_backgroundColor:(UIColor *)dd_backgroundColor
{
    objc_setAssociatedObject(self, @selector(dd_backgroundColor), dd_backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)dd_backgroundColor
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
