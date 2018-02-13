/*!
 * PROSlideStanzaProvider.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#ifndef Projector_PROSlideStanzaProvider_h
#define Projector_PROSlideStanzaProvider_h

@import Foundation;

@interface PROSlideStanzaProvider : NSObject

+ (instancetype)providerWithItem:(PCOItem *)item;

- (PCOStanza *)stanzaAtIndex:(NSUInteger)index;

@end

#endif
