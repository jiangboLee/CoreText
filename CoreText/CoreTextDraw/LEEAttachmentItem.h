//
//  LEEAttachmentItem.h
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import "LEEBaseDataItem.h"

/**
 对其方式枚举
 
 - YTAttachmentAlignTypeBottom: 底部对其
 - YTAttachmentAlignTypeCenter: 居中对其
 - YTAttachmentAlignTypeTop: 顶部对其
 */
typedef NS_ENUM(NSUInteger, YTAttachmentAlignType) {
    YTAttachmentAlignTypeBottom,
    YTAttachmentAlignTypeCenter,
    YTAttachmentAlignTypeTop,
};

@interface LEEAttachmentItem : LEEBaseDataItem

@property (nonatomic, strong) id attachment;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) YTAttachmentAlignType align;///<对其方式
@property (nonatomic, assign) CGFloat ascent;///<文本内容的ascent，用于计算attachment内容的ascent
@property (nonatomic, assign) CGFloat descent;///<文本内容的descent，用于计算attachment内容的descent
@property (nonatomic, assign) CGSize size;///<attachment内容的大小

- (UIImage *)image;

@end

