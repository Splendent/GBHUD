//
//  GBHUDView.m
//  GBHUD
//
//  Created by Luka Mirosevic on 21/11/2012.
//  Copyright (c) 2012 Goonbee. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#if !TARGET_OS_IPHONE
@interface NSTextField (Shrinking)

-(void)shrinkTextToFitWithTargetFont:(NSFont *)targetFont andMinSize:(CGFloat)minSize;

@end

@implementation NSTextField (Shrinking)

-(void)shrinkTextToFitWithTargetFont:(NSFont *)targetFont andMinSize:(CGFloat)minSize {
    CGFloat targetWidth = self.bounds.size.width;
    CGFloat targetHeight = self.bounds.size.height;
    
    CGFloat targetSize = [[[targetFont fontDescriptor] objectForKey:NSFontSizeAttribute] floatValue];
    NSString *fontName = [targetFont fontName];
    
    for (int i=targetSize; i>=minSize; i--) {
        NSSize potentialSize = [self.stringValue sizeWithAttributes:@{NSFontAttributeName: [NSFont fontWithName:fontName size:i]}];
        
        if (potentialSize.width <= targetWidth && potentialSize.height <= targetHeight) {
            [self setFont:[NSFont fontWithName:fontName size:i]];
            
            break;
        }
    }
}

@end
#endif


#import "GBHUDView.h"
#import "GBHUDBackgroundView.h"


static CGFloat const kLabelSidePadding = 6;
static CGFloat const kLabelHeight = 20;
static CGFloat const kLabelFontSizeMin = 8;


@interface GBHUDView ()

@property (strong, nonatomic) GBHUDBackgroundView   *backgroundView;

#if TARGET_OS_IPHONE
@property (strong, nonatomic) UILabel               *label;
#else
@property (strong, nonatomic) NSTextField           *label;
#endif

@end


@implementation GBHUDView

#pragma mark - custom accessors

-(void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    
    self.backgroundView.cornerRadius = cornerRadius;
}

-(void)setSymbolSize:(CGSize)symbolSize {
    _symbolSize = symbolSize;
    
    [self _resizeSymbol];
}

-(void)setSymbolTopOffset:(CGFloat)symbolTopOffset {
    _symbolTopOffset = symbolTopOffset;
    
    [self _resizeSymbol];
}

-(void)setLabelBottomOffset:(CGFloat)labelBottomOffset {
    _labelBottomOffset = labelBottomOffset;
    
    [self _resizeLabel];
}

-(void)setSymbolView:(GBView *)symbolView {
    [_symbolView removeFromSuperview];
    
    _symbolView = symbolView;

    [self _addSymbol];
}

-(void)setText:(NSString *)text {
    _text = text;
    
#if TARGET_OS_IPHONE
    self.label.text = text;
#else
    self.label.stringValue = text;
#endif
}

-(void)setFont:(GBFont *)font {
    _font = font;
    
    self.label.font = font;
}

-(void)setBackdropColor:(GBColor *)backdropColor {
    _backdropColor = backdropColor;
    
    self.backgroundView.color = backdropColor;
}

-(void)setTextColor:(GBColor *)textColor {
    _textColor = textColor;
    
    self.label.textColor = textColor;
}

#pragma mark - mem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //add and draw subviews
        [self _addBackground];
        [self _addSymbol];
        [self _addLabel];
    }
    return self;
}

-(void)dealloc {
    self.text = nil;
    self.font = nil;
    self.backdropColor = nil;
    self.textColor = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    [self.symbolView removeFromSuperview];
    self.symbolView = nil;
    [self.label removeFromSuperview];
    self.label = nil;
}

#pragma mark - private drawing

-(void)_addBackground {
    GBHUDBackgroundView *bgView = [[GBHUDBackgroundView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    
#if TARGET_OS_IPHONE
    bgView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
#else
    bgView.autoresizingMask = (NSViewHeightSizable | NSViewWidthSizable);
#endif
    bgView.color = self.backdropColor;
    bgView.cornerRadius = self.cornerRadius;
    [self addSubview:bgView];
    self.backgroundView = bgView;
}

-(void)_resizeBackground {
    if (self.backgroundView) {
        self.backgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
}

-(void)_addSymbol {
    if (self.symbolView) {
        //make sure its not a subview of anywhere else first
        [self.symbolView removeFromSuperview];
        
        //configure and add the view
#if TARGET_OS_IPHONE
        self.symbolView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
#else
        self.symbolView.autoresizingMask = (NSViewMinYMargin | NSViewMinXMargin | NSViewMaxXMargin);
#endif
        self.symbolView.frame = CGRectMake((self.bounds.size.width - self.symbolSize.width)/2.0, self.symbolTopOffset, self.symbolSize.width, self.symbolSize.height);
        [self addSubview:self.symbolView];
    }
}

-(void)_resizeSymbol {
    if (self.symbolView) {
        self.symbolView.frame = CGRectMake((self.bounds.size.width - self.symbolSize.width)/2.0, self.symbolTopOffset, self.symbolSize.width, self.symbolSize.height);
    }
}

-(void)_addLabel {
#if TARGET_OS_IPHONE
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kLabelSidePadding, self.bounds.size.height - kLabelHeight - self.labelBottomOffset, self.bounds.size.width - 2*kLabelSidePadding, kLabelHeight)];
    
    label.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
    label.textAlignment = UITextAlignmentCenter;
    label.minimumFontSize = kLabelFontSizeMin;
    label.adjustsFontSizeToFitWidth = YES;
    label.text = self.text;
    label.backgroundColor = [UIColor clearColor];
#else
    NSTextField *label = [[NSTextField alloc] initWithFrame:CGRectMake(kLabelSidePadding, self.bounds.size.height - kLabelHeight - self.labelBottomOffset, self.bounds.size.width - 2*kLabelSidePadding, kLabelHeight)];
    
    label.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin | NSViewMaxYMargin | NSViewWidthSizable;
    label.alignment = NSCenterTextAlignment;
    label.stringValue = self.text;
    [label shrinkTextToFitWithTargetFont:self.font andMinSize:kLabelFontSizeMin];
    
    //foo might need a clear bg color
#endif
    
    label.textColor = self.textColor;
    label.font = self.font;
    [self addSubview:label];
    self.label = label;
}

-(void)_resizeLabel {
    self.label.frame = CGRectMake(kLabelSidePadding, self.bounds.size.height - kLabelHeight - self.labelBottomOffset, self.bounds.size.width - 2*kLabelSidePadding, kLabelHeight);
}

@end
