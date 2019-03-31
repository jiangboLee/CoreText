//
//  CoreTextSimple.m
//  CoreText
//
//  Created by Lee on 2019/3/29.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "CoreTextSimple.h"
#import <CoreText/CoreText.h>
#import "LEERichContentData.h"
#import "LEEBaseDataItem.h"
#import "LEEAttachmentItem.h"

@interface CoreTextSimple ()

@property (nonatomic, strong) LEERichContentData *data;
@property (nonatomic, strong) LEEBaseDataItem *clickedItem;

@end

@implementation CoreTextSimple

@dynamic truncationToken, truncationActionHandler, text, textColor, font, shadowColor, shadowOffset, shadowAlpha, lineSpacing, paragraphSpacing, textAlignment;

// MARK: - Public

- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(ClickActionHandler)clickActionHandler {
    [self.data addString:string attributes:attributes clickActionHandler:clickActionHandler];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    self.data.numberOfLines = numberOfLines;
    [self setNeedsDisplay];
}


// MARK: - Override
- (CGSize)sizeThatFits:(CGSize)size {
    NSAttributedString *drawString = self.data.attributeStringToDraw;
    if (drawString == nil) {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter) {
        CFRelease(framesetter);
    }
    
    return newSize;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)];
}

// truncationToken, truncationActionHandler, text, textColor, font, shadowColor, shadowOffset, shadowAlpha, lineSpacing, paragraphSpacing, textAlignment 这些属性走转发流程
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.data;
}

// MARK: - Draw

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // 处理数据
    [self.data composeDataToDrawWithBounds:self.bounds];
    
    // 绘制阴影
    [self drawShadowInContext:context];
    
    // 绘制文字
    [self drawTextInContext:context];
    
    // 绘制图片
    [self drawAttachmentsInContext:context];
}


/**
 绘制文字
 */
- (void)drawTextInContext:(CGContextRef)context {
    if (self.data.drawMode == LEEDrawModeFrame) {
        CTFrameDraw(self.data.frameToDraw, context);
    } else if (self.data.drawMode == LEEDrawModeLines) {
        for (LEECTLine *line in self.data.linesToDraw) {
            // 设置Line绘制的位置
            CGContextSetTextPosition(context, line.position.x, line.position.y);
            CTLineDraw(line.ctLine, context);
        }
    }
}

/**
 绘制图片
 */
- (void)drawAttachmentsInContext:(CGContextRef)context {
    // 在CGContextRef上下文上绘制图片
    for (int i = 0; i < self.data.attachments.count; i++) {
        LEEAttachmentItem *attachmentItem = self.data.attachments[i];
        if (attachmentItem.image) {
            CGContextDrawImage(context, attachmentItem.frame, attachmentItem.image.CGImage);
        }
    }
}

/**
 绘制阴影
 */
- (void)drawShadowInContext:(CGContextRef)context {
    if (self.data.shadowColor == nil
        || CGSizeEqualToSize(self.data.shadowOffset, CGSizeZero)) {
        return;
    }
    CGContextSetShadowWithColor(context, self.data.shadowOffset, self.data.shadowAlpha, self.data.shadowColor.CGColor);
}

// MARK: - Gesture

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    if (touch.view == self) {
        CGPoint point = [touch locationInView:touch.view];
        LEEBaseDataItem *clickedItem = [self.data itemAtPoint:point];
        self.clickedItem = clickedItem;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    !self.clickedItem.clickActionHandler ?: self.clickedItem.clickActionHandler(_clickedItem);
    self.clickedItem = nil;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.clickedItem = nil;
    [self touchesEnded:touches withEvent:event];
}


// MARK: - Lazy load

- (LEERichContentData *)data {
    if (!_data) {
        _data = [LEERichContentData new];
    }
    return _data;
}


@end
