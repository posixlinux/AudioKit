//
//  AKSquareWaveOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is a bandlimited square oscillator ported from the "square" function
/// from the Faust programming language.
///
/// - parameter frequency: In cycles per second, or Hz.
/// - parameter amplitude: Output amplitude
/// - parameter detuning: Frequency offset in Hz.
/// - parameter pulseWidth: Duty cycle width (range 0-1).
///
public class AKSquareWaveOscillator: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKSquareWaveOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?


    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var detuningParameter: AUParameter?
    private var pulseWidthParameter: AUParameter?

    /// In cycles per second, or Hz.
    public var frequency: Double = 440 {
        didSet {
            internalAU?.frequency = Float(frequency)
        }
    }

    /// Ramp to frequency over 20 ms
    ///
    /// - parameter frequency: Target In cycles per second, or Hz.
    ///
    public func ramp(frequency frequency: Double) {
        frequencyParameter?.setValue(Float(frequency), originator: token!)
    }

    /// Output amplitude
    public var amplitude: Double = 1.0 {
        didSet {
            internalAU?.amplitude = Float(amplitude)
        }
    }

    /// Ramp to amplitude over 20 ms
    ///
    /// - parameter amplitude: Target Output amplitude
    ///
    public func ramp(amplitude amplitude: Double) {
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Frequency offset in Hz.
    public var detuning: Double = 0 {
        didSet {
            internalAU?.detuning = Float(detuning)
        }
    }

    /// Ramp to detuning over 20 ms
    ///
    /// - parameter detuning: Target Frequency offset in Hz.
    ///
    public func ramp(detuning detuning: Double) {
        detuningParameter?.setValue(Float(detuning), originator: token!)
    }

    /// Duty cycle width (range 0-1).
    public var pulseWidth: Double = 0.5 {
        didSet {
            internalAU?.pulseWidth = Float(pulseWidth)
        }
    }

    /// Ramp to pulseWidth over 20 ms
    ///
    /// - parameter pulseWidth: Target Duty cycle width (range 0-1).
    ///
    public func ramp(pulseWidth pulseWidth: Double) {
        pulseWidthParameter?.setValue(Float(pulseWidth), originator: token!)
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - parameter frequency: In cycles per second, or Hz.
    /// - parameter amplitude: Output amplitude
    /// - parameter detuning: Frequency offset in Hz.
    /// - parameter pulseWidth: Duty cycle width (range 0-1).
    ///
    public init(
        frequency: Double = 440,
        amplitude: Double = 1.0,
        detuning: Double = 0,
        pulseWidth: Double = 0.5) {


        self.frequency = frequency
        self.amplitude = amplitude
        self.detuning = detuning
        self.pulseWidth = pulseWidth

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x7371726f /*'sqro'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKSquareWaveOscillatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKSquareWaveOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKSquareWaveOscillatorAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter  = tree.valueForKey("frequency")  as? AUParameter
        amplitudeParameter  = tree.valueForKey("amplitude")  as? AUParameter
        detuningParameter   = tree.valueForKey("detuning")   as? AUParameter
        pulseWidthParameter = tree.valueForKey("pulseWidth") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                } else if address == self.detuningParameter!.address {
                    self.detuning = Double(value)
                } else if address == self.pulseWidthParameter!.address {
                    self.pulseWidth = Double(value)
                }
            }
        }
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.detuning = Float(detuning)
        internalAU?.pulseWidth = Float(pulseWidth)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func copy() -> AKVoice {
        let copy = AKSquareWaveOscillator(frequency: self.frequency, amplitude: self.amplitude, detuning: self.detuning, pulseWidth: self.pulseWidth)
        return copy
    }

    /// Function to start, play, or activate the node, all do the same thing
    public override func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public override func stop() {
        self.internalAU!.stop()
    }
}