//
//  NSMutableAttributedString+LEE_SetAttributes.m
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import "NSMutableAttributedString+LEE_SetAttributes.h"
#import <CoreText/CoreText.h>

@implementation NSMutableAttributedString (LEE_SetAttributes)

- (void)lee_setTextColor:(UIColor*)color{
    [self lee_setTextColor:color range:NSMakeRange(0, self.length)];
}
- (void)lee_setTextColor:(UIColor*)color range:(NSRange)range{
    if (color.CGColor) {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
}

- (void)lee_setFont:(UIFont*)font{
    [self lee_setFont:font range:NSMakeRange(0, self.length)];
}
- (void)lee_setFont:(UIFont*)font range:(NSRange)range{
    if (font) {
        [self removeAttribute:(NSString*)kCTFontAttributeName range:range];
        
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (nil != fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

@end
