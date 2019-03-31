//
//  LEERichContentData.m
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import "LEERichContentData.h"
#import "LEETextItem.h"
#import "NSMutableAttributedString+LEE_SetAttributes.h"

@interface LEERichContentData ()

@property (nonatomic, strong) NSMutableAttributedString *attributeString;
@property (nonatomic, assign) CTFrameRef ctFrame;

/**
 截断标识字符串数据
 */
@property (nonatomic, strong) NSMutableArray<LEEBaseDataItem *> *truncations;

@end

@implementation LEERichContentData

- (instancetype)init {
    self = [super init];
    if (self) {
        _textColor = [UIColor blackColor];
        _font = [UIFont systemFontOfSize:14];
        _lineBreakMode = kCTLineBreakByTruncatingTail;
    }
    return self;
}

- (void)dealloc {
    if (_drawMode == LEEDrawModeLines) {
        for (LEECTLine *line in _linesToDraw) {
            if (line.ctLine != nil) {
                CFRelease(line.ctLine);
            }
        }
    } else {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
    }
}

// MARK: - Public

- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(ClickActionHandler)clickActionHandler {
    LEETextItem *textItem = [LEETextItem new];
    textItem.content = string;
    NSAttributedString *textAttributeString = [[NSAttributedString alloc] initWithString:textItem.content attributes:attributes];
    [self.attributeString appendAttributedString:textAttributeString];
}

- (void)setText:(NSString *)text {
    _text = text;
    [self.attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:_text attributes:nil]];
    [self.attributeString lee_setFont:_font];
    [self.attributeString lee_setTextColor:_textColor];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self.attributeString lee_setTextColor:_textColor];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self.attributeString lee_setFont:_font];
    [self updateAttachments];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha {
    _shadowAlpha = shadowAlpha;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    _paragraphSpacing = paragraphSpacing;
}

- (NSAttributedString *)attributeStringToDraw {
    [self setStyleToAttributeString:self.attributeString];
    return self.attributeString;
}

/**
 设置排版样式
 */
- (void)setStyleToAttributeString:(NSMutableAttributedString *)attributeString {
    CTParagraphStyleSetting settings[] =
    {
        {kCTParagraphStyleSpecifierAlignment, sizeof(self.textAlignment), &_textAlignment},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(self.lineSpacing), &_lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(self.lineSpacing), &_lineSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(self.paragraphSpacing), &_paragraphSpacing},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    [attributeString addAttribute:(id)kCTParagraphStyleAttributeName
                            value:(__bridge id)paragraphStyle
                            range:NSMakeRange(0, [attributeString length])];
    CFRelease(paragraphStyle);
}

- (CTFrameRef)frameToDraw {
    return self.ctFrame;
}

// MARK: - Helper

- (void)updateAttachment:(LEEAttachmentItem *)attachment withFont:(UIFont *)font {
    attachment.ascent = CTFontGetAscent((CTFontRef)font);
    attachment.descent = CTFontGetDescent((CTFontRef)font);
}

- (void)updateAttachments {
    for (LEEAttachmentItem *attachment in self.attachments) {
        [self updateAttachment:attachment withFont:self.font];
    }
}

- (void)composeDataToDrawWithBounds:(CGRect)bounds {
    _ctFrame = [self composeCTFrameWithAttributeString:self.attributeStringToDraw frame:bounds];
    [self calculateContentPositionWithBounds:bounds];
    [self calculateTruncatedLinesWithBounds:bounds];
}

- (LEEBaseDataItem *)itemAtPoint:(CGPoint)point {
    for (LEEBaseDataItem *item in self.truncations) {
        if ([item containsPoint:point]) {
            return item;
        }
    }
    for (LEEBaseDataItem *item in self.attachments) {
        if ([item containsPoint:point]) {
            return item;
        }
    }
    return nil;
}

- (CTFrameRef)composeCTFrameWithAttributeString:(NSAttributedString *)attributeString frame:(CGRect)frame {
    // 绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, (CGRect){{0, 0}, frame.size});
    
    // 使用NSMutableAttributedString创建CTFrame
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, attributeString.length), path, NULL);
    
    CFRelease(ctFramesetter);
    CFRelease(path);
    
    return ctFrame;
}

- (void)calculateContentPositionWithBounds:(CGRect)bounds {
    
    int imageIndex = 0;
    
    // CTFrameGetLines获取但CTFrame内容的行数
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    // CTFrameGetLineOrigins获取每一行的起始点，保存在lineOrigins数组中
    CGPoint lineOrigins[lines.count];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < lines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        for (int j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)(runs[j]);
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            if (!attributes) {
                continue;
            }
            
            // 从属性中获取到创建属性字符串使用CFAttributedStringSetAttribute设置的delegate值
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (!delegate) {
                continue;
            }
            // CTRunDelegateGetRefCon方法从delegate中获取使用CTRunDelegateCreate初始时候设置的元数据
            NSDictionary *metaData = (NSDictionary *)CTRunDelegateGetRefCon(delegate);
            if (!metaData) {
                continue;
            }
            
            // 找到代理则开始计算图片位置信息
            CGFloat ascent;
            CGFloat desent;
            // 可以直接从metaData获取到图片的宽度和高度信息
            CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, NULL);
            CGFloat height = ascent + desent;
            
            // CTLineGetOffsetForStringIndex获取CTRun的起始位置
            CGFloat xOffset = lineOrigins[i].x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            CGFloat yOffset = lineOrigins[i].y;
            
            // 更新ImageItem对象的位置
            if (imageIndex < self.attachments.count) {
                LEEAttachmentItem *imageItem = self.attachments[imageIndex];
                yOffset = yOffset - desent;
                imageItem.frame = CGRectMake(xOffset, yOffset, width, height);
                imageIndex ++;
            }
        }
    }
}

- (void)calculateTruncatedLinesWithBounds:(CGRect)bounds {
    
    // 清除旧的数据
    [self.truncations removeAllObjects];
    [self.attachments removeAllObjects];
    
    // 获取最终需要绘制的文本行数
    CFIndex numberOfLinesToDraw = [self numberOfLinesToDrawWithCTFrame:self.ctFrame];
    if (numberOfLinesToDraw <= 0) {
        self.drawMode = LEEDrawModeFrame;
    } else {
        self.drawMode = LEEDrawModeLines;
        NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
        
        CGPoint lineOrigins[numberOfLinesToDraw];
        CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, numberOfLinesToDraw), lineOrigins);
        
        for (int lineIndex = 0; lineIndex < numberOfLinesToDraw; lineIndex ++) {
            
            CTLineRef line = (__bridge CTLineRef)(lines[lineIndex]);
            CFRange range = CTLineGetStringRange(line);
            // 判断最后一行是否需要显示【截断标识字符串(...)】
            if ( lineIndex == numberOfLinesToDraw - 1
                && range.location + range.length < [self attributeStringToDraw].length) {
                
                // 创建【截断标识字符串(...)】
                NSAttributedString *tokenString = nil;
                if (_truncationToken) {
                    tokenString = _truncationToken;
                } else {
                    NSUInteger truncationAttributePosition = range.location + range.length - 1;
                    
                    NSDictionary *attributes = [[self attributeStringToDraw] attributesAtIndex:truncationAttributePosition
                                                                                effectiveRange:NULL];
                    // 只要用到字体大小和颜色的属性，这里如果使用kCTParagraphStyleAttributeName属性在使用boundingRectWithSize方法计算大小的步骤会崩溃
                    NSDictionary *tokenAttributes =@{NSForegroundColorAttributeName: attributes[NSForegroundColorAttributeName]? attributes[NSForegroundColorAttributeName]: [UIColor blackColor],
                                                     NSFontAttributeName: attributes[NSFontAttributeName]? attributes[NSFontAttributeName]: [UIFont systemFontOfSize:14],
                                                     };
                    tokenString = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:tokenAttributes];
                }
                
                // 计算【截断标识字符串(...)】的长度
                CGSize tokenSize = [tokenString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
                CGFloat tokenWidth = tokenSize.width + 30;
                CTLineRef truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                
                // 根据【截断标识字符串(...)】的长度，计算【需要截断字符串】的最后一个字符的位置，把该位置之后的字符从【需要截断字符串】中移除，留出【截断标识字符串(...)】的位置
                CFIndex truncationEndIndex = CTLineGetStringIndexForPosition(line, CGPointMake(bounds.size.width - tokenWidth, 0));
                CGFloat length = range.location + range.length - truncationEndIndex;
                
                // 把【截断标识字符串(...)】添加到【需要截断字符串】后面
                NSMutableAttributedString *truncationString = [[[self attributeStringToDraw] attributedSubstringFromRange:NSMakeRange(range.location, range.length)] mutableCopy];
                if (length < truncationString.length) {
                    [truncationString deleteCharactersInRange:NSMakeRange(truncationString.length - length, length)];
                    [truncationString appendAttributedString:tokenString];
                }
                
                // 使用`CTLineCreateTruncatedLine`方法创建含有【截断标识字符串(...)】的`CTLine`对象
                CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CTLineRef lastLine = CTLineCreateTruncatedLine(truncationLine, bounds.size.width, truncationType, truncationTokenLine);
                
                // 添加truncation的位置信息
                NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
                if (runs.count > 0 && self.truncationActionHandler) {
                    CTRunRef run = (__bridge CTRunRef)runs.lastObject;
                    
                    CGFloat ascent;
                    CGFloat desent;
                    // 可以直接从metaData获取到图片的宽度和高度信息
                    CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, NULL);
                    CGFloat height = ascent + desent;
                    
                    LEEBaseDataItem* truncationItemImage = [LEEBaseDataItem new];
                    CGRect truncationimageFrame = CGRectMake(width - 18,
                                                             bounds.size.height - lineOrigins[lineIndex].y - height,
                                                             18,
                                                             18);
                    [truncationItemImage addFrame:truncationimageFrame];
                    truncationItemImage.clickActionHandler = self.truncationActionHandler;
                    [self.truncations addObject:truncationItemImage];
                    
                    LEEAttachmentItem *imageItem = [LEEAttachmentItem new];
                    imageItem.attachment = [UIImage imageNamed:@"tata_img_hottopicdefault"];
                    imageItem.size = CGSizeMake(18, 18);
                    [self.attachments addObject:imageItem];
                    imageItem.frame = CGRectMake(width - 18,
                                                 lineOrigins[lineIndex].y,
                                                 18,
                                                 18);;
                }
                
                LEECTLine *ytLine = [LEECTLine new];
                ytLine.ctLine = lastLine;
                ytLine.position = CGPointMake(lineOrigins[lineIndex].x, lineOrigins[lineIndex].y);
                [self.linesToDraw addObject:ytLine];
                
                CFRelease(truncationTokenLine);
                CFRelease(truncationLine);
                
            } else {
                LEECTLine *ytLine = [LEECTLine new];
                ytLine.ctLine = line;
                ytLine.position = CGPointMake(lineOrigins[lineIndex].x, lineOrigins[lineIndex].y);
                [self.linesToDraw addObject:ytLine];
            }
        }
    }
}

- (CFIndex)numberOfLinesToDrawWithCTFrame:(CTFrameRef)ctFrame {
    if (_numberOfLines <= 0) {
        return _numberOfLines;
    }
    return MIN(CFArrayGetCount(CTFrameGetLines(ctFrame)), _numberOfLines);
}


// MARK: - lazy load

- (NSMutableArray *)attachments {
    if (!_attachments) {
        _attachments = [NSMutableArray array];
    }
    return _attachments;
}

- (NSMutableArray<LEEBaseDataItem *> *)truncations {
    if (!_truncations) {
        _truncations = [NSMutableArray array];
    }
    return _truncations;
}

- (NSMutableArray<LEECTLine *> *)linesToDraw {
    if (!_linesToDraw) {
        _linesToDraw = [NSMutableArray array];
    }
    return _linesToDraw;
}

- (NSMutableAttributedString *)attributeString {
    if (!_attributeString) {
        _attributeString = [NSMutableAttributedString new];
    }
    return _attributeString;
}


@end
