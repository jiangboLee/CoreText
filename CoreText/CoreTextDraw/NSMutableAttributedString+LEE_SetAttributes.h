//
//  NSMutableAttributedString+LEE_SetAttributes.h
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (LEE_SetAttributes)

- (void)lee_setTextColor:(UIColor*)color;
- (void)lee_setTextColor:(UIColor*)color range:(NSRange)range;

- (void)lee_setFont:(UIFont*)font;
- (void)lee_setFont:(UIFont*)font range:(NSRange)range;


@end

NS_ASSUME_NONNULL_END
