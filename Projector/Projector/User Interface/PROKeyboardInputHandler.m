//
//  PROKeyboardInputHandler.m
//  Projector
//
//  Created by Peter Fokos on 10/1/14.
//

#import "PROKeyboardInputHandler.h"

@implementation PROKeyboardInputHandler

- (UITextRange *)selectedTextRange {
    return [[UITextRange alloc] init];
}

- (UITextPosition *)endOfDocument {
    PCOLogDebug(@"Down");
    [self insertText:@"Port 3"];
    return nil;
}
- (UITextPosition *)beginningOfDocument {
    PCOLogDebug(@"Up");
    [self insertText:@"Port 1"];
    return nil;
}

- (NSArray *)keyCommands {
    UIKeyCommand *leftArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:0 action:@selector(leftArrow:)];
    UIKeyCommand *rightArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:0 action:@selector(rightArrow:)];
    return @[leftArrow, rightArrow];
}

- (void)leftArrow:(UIKeyCommand *)keyCommand {
    PCOLogDebug(@"Left");
    [self insertText:@"Left Arrow"];
}

- (void)rightArrow:(UIKeyCommand *)keyCommand {
    PCOLogDebug(@"Right");
    [self insertText:@"Right Arrow"];
}

//REQUIRED METHODS
- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition{ return nil; }
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset{ return nil; }
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {	return nil;}
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {return nil;}
- (NSString *)textInRange:(UITextRange *)range {return @"";}
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text {}
- (void)setSelectedTextRange:(UITextRange *)range {}
- (UITextRange *)markedTextRange {return nil;}
- (NSDictionary *)markedTextStyle {return nil;}
- (void)setMarkedTextStyle:(NSDictionary *)style {}
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {NSLog(@"Test position7");return nil;}
- (void) setInputDelegate:(id <UITextInputDelegate>) delegate {}
- (id <UITextInputDelegate>)inputDelegate {return nil;}
- (id <UITextInputTokenizer>)tokenizer {return nil;}
- (UITextRange *)characterRangeAtPoint:(CGPoint)point {return nil;}
- (UITextPosition *)closestPositionToPoint:(CGPoint)point {return nil;}
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {return nil;}
- (CGRect)caretRectForPosition:(UITextPosition *)position  {return CGRectZero;}
- (CGRect)firstRectForRange:(UITextRange *)range {return CGRectZero;}
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {}
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {return 0;}
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition {return 0;}
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other {return NSOrderedSame;}
- (void)unmarkText {}
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {}
- (NSArray *)selectionRectsForRange:(UITextRange *)range { return nil; }

@end
