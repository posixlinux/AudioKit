//
//  AKSquareWaveOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKSquareWaveOscillatorAudioUnit_h
#define AKSquareWaveOscillatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKSquareWaveOscillatorAudioUnit : AUAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;
@property (nonatomic) float detuning;
@property (nonatomic) float pulseWidth;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKSquareWaveOscillatorAudioUnit_h */