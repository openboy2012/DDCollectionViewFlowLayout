//
//  NSDate+DDKit.m
//  DDCategory
//
//  Created by DeJohn on 15/5/15.
//  Copyright (c) 2015年 DDKit. All rights reserved.
//

#import "NSDate+DDKit.h"

@implementation NSDate (DDKit)

- (BOOL)isSameToDate:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *compsSelf = [calendar components:unitFlags fromDate:self];
    NSDateComponents *compsOther = [calendar components:unitFlags fromDate:date];
    if(compsSelf.year == compsOther.year &&
       compsSelf.month == compsOther.month &&
       compsSelf.day == compsOther.day){
        return YES;
    }
    return NO;
}

- (BOOL)isSameToMonth:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *compsSelf = [calendar components:unitFlags fromDate:self];
    NSDateComponents *compsOther = [calendar components:unitFlags fromDate:date];
    if(compsSelf.year == compsOther.year &&
       compsSelf.month == compsOther.month){
        return YES;
    }
    return NO;
}

@end
