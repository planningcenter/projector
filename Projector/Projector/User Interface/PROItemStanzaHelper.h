/*!
 * PROItemStanzaHelper.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/24/14
 */

#ifndef Projector_PROItemStanzaHelper_h
#define Projector_PROItemStanzaHelper_h

@import Foundation;

@interface PROItemStanzaHelper : NSObject

+ (void)addStanzaWithLabel:(NSString *)label toItem:(PCOItem *)item index:(NSInteger)index;

+ (PCOStanza *)stanzaAtIndex:(NSInteger)index item:(PCOItem *)item;

+ (void)removeStanzaAtIndex:(NSInteger)index item:(PCOItem *)item;

+ (void)clearCache;

@end

#endif
