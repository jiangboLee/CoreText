//
//  LEERichContentData.h
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "LEEBaseDataItem.h"
#import "LEEAttachmentItem.h"
#import "LEECTLine.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    LEEDrawModeLines,
    LEEDrawModeFrame,
} LEEDrawMode;

@interface LEERichContentData : NSObject

/**
 图片数据
 */
@property (nonatomic, strong) NSMutableArray<LEEAttachmentItem *> *attachments;

/**
 绘制的CTline数据
 */
@property (nonatomic, strong) NSMutableArray<LEECTLine *> *linesToDraw;
@property (nonatomic, assign) CTFrameRef frameToDraw;

/**
 绘制模式，使用CTFrame或者CTLine
 */
@property (nonatomic, assign) LEEDrawMode drawMode;

@property (nonatomic, assign) NSInteger numberOfLines; ///<行数
@property (nonatomic, strong) NSMutableAttributedString *truncationToken;///<截断的标识字符串，默认是"..."
@property (nonatomic, copy) ClickActionHandler truncationActionHandler;///<截断的标识字符串点击事件
@property (nonatomic, strong) NSString *text;///<文本内容
@property (nonatomic, strong) UIColor *textColor;///<字体颜色
@property (nonatomic, strong) UIFont *font;///<字体
@property (nonatomic, strong) UIColor *shadowColor;///<阴影颜色
@property (nonatomic, assign) CGSize shadowOffset;///<阴影偏移位置
@property (nonatomic, assign) CGFloat shadowAlpha;///<阴影透明度
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;///<LineBreakMode
@property (nonatomic, assign) CGFloat lineSpacing;///<行间距
@property (nonatomic, assign) CGFloat paragraphSpacing;///<段落间距
@property (nonatomic, assign) CTTextAlignment textAlignment;///<文字排版样式

// MARK: - Public
- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(ClickActionHandler)clickActionHandler;

/**
 生成View绘制需要使用的数据
 
 @param bounds 绘制的区域，View的Bounds
 */
- (void)composeDataToDrawWithBounds:(CGRect)bounds;

/**
 获取View点击位置的数据
 
 @param point 点击的点
 @return 如果点击位置是可点击的元素，返回对应的数据，否则返回nil
 */
- (LEEBaseDataItem *)itemAtPoint:(CGPoint)point;


/**
 获取CTFrame对应的NSAttributedString数据
 */
- (NSAttributedString *)attributeStringToDraw;

@end

NS_ASSUME_NONNULL_END
