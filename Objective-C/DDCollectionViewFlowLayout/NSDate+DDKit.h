//
//  NSDate+DDKit.h
//  DDCategory
//
//  Created by DeJohn on 15/5/15.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DDKit)

/**
 *  Compare the same date (not include the time)
 *
 *  @param date other date
 *
 *  @return true/false
 */
- (BOOL)isSameToDate:(NSDate *)date;

- (BOOL)isSameToMonth:(NSDate *)date;

@end
