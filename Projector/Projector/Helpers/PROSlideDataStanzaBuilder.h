/*!
 * PROSlideDataStanzaBuilder.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#ifndef Projector_PROSlideDataStanzaBuilder_h
#define Projector_PROSlideDataStanzaBuilder_h

@import Foundation;

@class PCOStanza;
@class PCOSlideBreak;

@interface PROSlideDataStanzaBuilder : NSObject

+ (NSArray *)createSlidesForStanza:(PCOStanza *)stanza slideClass:(Class)klass preferredNumberOfLines:(NSUInteger)lineCount;

+ (PCOSlideBreak *)slideBreakForStanza:(PCOStanza *)stanza preferredNumberOfLines:(NSUInteger)lineCount;

@end

#endif
