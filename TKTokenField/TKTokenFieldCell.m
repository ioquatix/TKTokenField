//
//  TKTokenFieldCell.m
//  CustomTokenField
//
//  Created by Antoine Duchateau on 14/06/15.
//  Copyright (c) 2015 Taktik SA. All rights reserved.
//

#import "TKTokenFieldCell.h"
#import "TKTokenTextView.h"
#import "TKTokenField.h"

@implementation TKTokenFieldCell

+ (NSTimeInterval)defaultCompletionDelay {
    return 0;
}

+ (NSCharacterSet *)defaultTokenizingCharacterSet{
    return [NSCharacterSet newlineCharacterSet];
}

- (NSTextView *) fieldEditorForView:(NSView *) view {
    if (!self.tokenTextView) {
        self.tokenTextView = [[TKTokenTextView alloc] initWithFrame:view.bounds];
        
        self.tokenTextView.tokenizingCharacterSet = self.tokenizingCharacterSet ?: [[self class] defaultTokenizingCharacterSet];
        self.tokenTextView.completionDelay = self.completionDelay ?: [[self class] defaultCompletionDelay];
        self.tokenTextView.tokenStyle = self.tokenStyle;
        
        // self.tokenTextView.font = ((NSTextField*)view).font;
		self.tokenTextView.font = [NSFont systemFontOfSize:12.0];
    }
	
    return self.tokenTextView;
}

- (TKTokenFieldAttachment *)makeTokenFieldAttachment:(NSString*) tokenString range:(NSRange) range {
    TKTokenFieldAttachment *token = nil;
    //if ([[self delegate] respondsToSelector:@selector(tokenField:makeAttachmentForString:inRange:)]) {
    //    token = [(id<TKTokenFieldDelegate>)[self delegate] tokenField:self makeAttachmentForString:tokenString inRange:range];
    //}
    if (!token) {
        token = [TKTokenFieldAttachment new];
        
        //if ([[self delegate] respondsToSelector:@selector(tokenField:representedObjectForEditingString:)]) {
        //    [token setContent:[(id<TKTokenFieldDelegate>)[self delegate] tokenField:(TKTokenField*)self representedObjectForEditingString:tokenString]];
        //} else {
            [token setContent:tokenString];
        //}
        [token setAttachmentCell:[[TKTokenFieldAttachmentCell alloc] initTextCell:tokenString]];
    }
    return token;
}

- (void) prepareInsertion:(TKTokenFieldAttachment *) att range:(NSRange) range rect:(NSRect) rect {
    //if ([[self delegate] respondsToSelector:@selector(tokenField:attachment:willBeInsertedInRange:inRect:)]) {
    //    [(id<TKTokenFieldDelegate>)[self delegate] tokenField:self attachment:att willBeInsertedInRange:range inRect:rect];
    //}
}

- (void) finishInsertion:(TKTokenFieldAttachment *) att range:(NSRange) range rect:(NSRect) rect {
    //if ([[self delegate] respondsToSelector:@selector(tokenField:attachment:hasBeenInsertedInRange:inRect:)]) {
    //    [(id<TKTokenFieldDelegate>)[self delegate] tokenField:self attachment:att hasBeenInsertedInRange:range inRect:rect];
    //}
}

- (void) setObjectValue:(id)objectValue {
    if (![objectValue isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableAttributedString * ms = [NSMutableAttributedString new];
    for (id obj in (NSArray *)objectValue) {
        NSRange effectiveRange = NSMakeRange(ms.length, 0);
        TKTokenFieldAttachment * att = [self makeTokenFieldAttachment:obj editingString:nil range:effectiveRange];
        TKTokenTextView *textView = [(TKTokenFieldCell*)self.cell tokenTextView];
        
        NSRect rect = textView ? [textView firstRectForCharacterRange:effectiveRange actualRange:nil]:NSZeroRect; //screen coordinates
        rect = [self.window convertRectFromScreen:rect];
        rect.origin = [self convertPoint:rect.origin fromView:nil];
        
        [self prepareInsertion:att range:effectiveRange rect:rect];
        [ms appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
        //
    }
    
    [super setObjectValue:ms];
    
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (id) objectValue {
    NSAttributedString * as = self.attributedStringValue;
    NSUInteger length = as.length;
    NSRange effectiveRange = NSMakeRange(0, 0);
    
    NSMutableArray * result = [NSMutableArray new];
    
    TKTokenFieldAttachment * attachment;
    while (NSMaxRange(effectiveRange) < length) {
        attachment = [as attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if ([attachment isKindOfClass:[TKTokenFieldAttachment class]]) {
            [result addObject:attachment.content];
        }
    }
    return result;
}

- (TKTokenFieldAttachment *) attachmentForRepresentedObject:(id) object {
    NSAttributedString * as = self.attributedStringValue;
    NSUInteger length = as.length;
    NSRange effectiveRange = NSMakeRange(0, 0);

    TKTokenFieldAttachment * attachment;
    while (NSMaxRange(effectiveRange) < length) {
        attachment = [as attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
        if ([attachment isKindOfClass:[TKTokenFieldAttachment class]] && [attachment.content isEqualTo:object]) {
            return attachment;
        }
    }
    return nil;
}

@end
