//
//  TKTokenFieldCell.h
//  CustomTokenField
//
//  Created by Antoine Duchateau on 14/06/15.
//  Copyright (c) 2015 Taktik SA. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TKTokenTextView, TKTokenFieldAttachment;

@interface TKTokenFieldCell : NSTextFieldCell

@property (assign,readwrite) NSTokenStyle tokenStyle;
@property (assign,readwrite) NSTimeInterval completionDelay;
@property (strong,readwrite) NSCharacterSet *tokenizingCharacterSet;

@property (strong,readwrite,nonatomic) TKTokenTextView * tokenTextView;

// Completion delay...
+ (NSTimeInterval)defaultCompletionDelay;
// Character set...
+ (NSCharacterSet *)defaultTokenizingCharacterSet;

- (TKTokenFieldAttachment *)makeTokenFieldAttachment:(NSString*) tokenString range:(NSRange) range;
- (void) prepareInsertion:(TKTokenFieldAttachment *) att range:(NSRange) range rect:(NSRect) rect;
- (void) finishInsertion:(TKTokenFieldAttachment *) att range:(NSRange) range rect:(NSRect) rect;

@end
