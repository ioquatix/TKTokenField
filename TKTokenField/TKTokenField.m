//
//  TKTokenField.m
//  CustomTokenField
//
//  Created by Antoine Duchateau on 14/06/15.
//  Copyright (c) 2015 Taktik SA. All rights reserved.
//

#import "TKTokenField.h"
#import "TKTokenFieldCell.h"
#import "TKTokenTextView.h"
#import "TKTokenFieldAttachment.h"
#import "TKTokenFieldAttachmentCell.h"

@implementation TKTokenField

//
// Class methods
//
+ (void) initialize {
    if (self == [NSTokenField class]) {
        [self setVersion: 1];
        
        [self exposeBinding: NSEditableBinding];
        [self exposeBinding: NSTextColorBinding];
    }
}

- (id) initWithFrame: (NSRect)frame {
    if((self = [super initWithFrame: frame]) == nil) {
        return nil;
    }
    
    // initialize...
    [_cell setTokenStyle: NSDefaultTokenStyle];
    [_cell setCompletionDelay: [_cell defaultCompletionDelay]];
    [_cell setTokenizingCharacterSet: [_cell defaultTokenizingCharacterSet]];
    
    return self;
}

- (TKTokenFieldAttachment *)makeTokenFieldAttachment:(NSString*) tokenString range:(NSRange) range {
    TKTokenFieldAttachment *token = nil;
    if ([[self delegate] respondsToSelector:@selector(tokenField:makeAttachmentForString:inRange:)]) {
        token = [(id<TKTokenFieldDelegate>)[self delegate] tokenField:self makeAttachmentForString:tokenString inRange:range];
    }
    if (!token) {
        token = [TKTokenFieldAttachment new];
        
        if ([[self delegate] respondsToSelector:@selector(tokenField:representedObjectForEditingString:)]) {
            [token setContent:[(id<TKTokenFieldDelegate>)[self delegate] tokenField:(TKTokenField*)self representedObjectForEditingString:tokenString]];
        } else {
            [token setContent:tokenString];
        }
        [token setAttachmentCell:[[TKTokenFieldAttachmentCell alloc] initTextCell:tokenString]];
    }
    return token;
}

- (void) prepareInsertion:(TKTokenFieldAttachment *) att range:(NSRange) range rect:(NSRect) rect {
    if ([[self delegate] respondsToSelector:@selector(tokenField:attachment:willBeInsertedInRange:inRect:)]) {
        [(id<TKTokenFieldDelegate>)[self delegate] tokenField:self attachment:att willBeInsertedInRange:range inRect:rect];
    }
}

- (void) finishInsertion:(TKTokenFieldAttachment *) att range:(NSRange) range rect:(NSRect) rect {
    if ([[self delegate] respondsToSelector:@selector(tokenField:attachment:hasBeenInsertedInRange:inRect:)]) {
        [(id<TKTokenFieldDelegate>)[self delegate] tokenField:self attachment:att hasBeenInsertedInRange:range inRect:rect];
    }
}

- (void) setObjectValue:(id)objectValue {
    if (![objectValue isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableAttributedString * ms = [NSMutableAttributedString new];
    for (id obj in (NSArray *)objectValue) {
        NSString * desc = [(id<TKTokenFieldDelegate>)self.delegate tokenField:(TKTokenField*)self displayStringForRepresentedObject:obj]?:obj;
        
        TKTokenFieldAttachment * att = [self makeTokenFieldAttachment:desc range:NSMakeRange(ms.length, 0)];
        att.content = obj;
        [self prepareInsertion:att range:NSMakeRange(ms.length, 0) rect:NSZeroRect];
        [ms appendAttributedString:[NSAttributedString attributedStringWithAttachment:att]];
        [self finishInsertion:att range:NSMakeRange(ms.length, 0) rect:NSZeroRect];
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

/*
 * Setting the Cell class
 */
+ (Class) cellClass {
    return [TKTokenFieldCell class];
}

// Style...
- (NSTokenStyle)tokenStyle {
    return [_cell tokenStyle];
}

- (void)setTokenStyle:(NSTokenStyle)style {
    [_cell setTokenStyle: style];
}

// Completion delay...
+ (NSTimeInterval)defaultCompletionDelay {
    return [[TKTokenFieldCell class] defaultCompletionDelay];
}

- (NSTimeInterval)completionDelay {
    return [_cell completionDelay];
}

- (void)setCompletionDelay:(NSTimeInterval)delay {
    [_cell setCompletionDelay: delay];
}

// Character set...
+ (NSCharacterSet *)defaultTokenizingCharacterSet {
    return [[TKTokenFieldCell class] defaultTokenizingCharacterSet];
}

- (void)setTokenizingCharacterSet:(NSCharacterSet *)characterSet {
    [_cell setTokenizingCharacterSet: characterSet];
}

- (NSCharacterSet *)tokenizingCharacterSet {
    return [_cell tokenizingCharacterSet];
}

-(NSSize)intrinsicContentSize {
    NSSize intrinsicSize = [super intrinsicContentSize];
    
    TKTokenTextView *textView = [(TKTokenFieldCell*)self.cell tokenTextView];
    if (textView) {
        NSRect usedRect = [textView.textContainer.layoutManager usedRectForTextContainer:textView.textContainer];
        
        usedRect.size.height += 5.0; // magic number! (the field editor TextView is offset within the NSTextField. It’s easy to get the space above (it’s origin), but it’s difficult to get the default spacing for the bottom, as we may be changing the height
        
        intrinsicSize.height = usedRect.size.height;
    }
    if (intrinsicSize.height<self.superview.bounds.size.height) {
        intrinsicSize.height=self.superview.bounds.size.height;
    }
    
    if (textView && [self.window firstResponder] == textView) {
        [textView setFrame:NSMakeRect(textView.frame.origin.x, textView.frame.origin.y, textView.superview.frame.size.width, intrinsicSize.height - 5.0)];
        [textView.superview setFrame:NSMakeRect(textView.superview.frame.origin.x, textView.superview.frame.origin.y, textView.superview.frame.size.width, intrinsicSize.height - 2.0)];
    }
    
    return intrinsicSize;
}
@end