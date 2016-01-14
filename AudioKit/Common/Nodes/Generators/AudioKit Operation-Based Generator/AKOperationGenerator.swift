//
//  AKOperationGenerator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is was built using the JC reverb implentation found in FAUST. According to
/// the source code, the specifications for this implementation were found on an old
/// SAIL DART backup tape.
/// This class is derived from the CLM JCRev function, which is based on the use of
/// networks of simple allpass and comb delay filters.  This class implements three
/// series allpass units, followed by four parallel comb filters, and two
/// decorrelation delay lines in parallel at the output.
///
public class AKOperationGenerator: AKNode, AKToggleable {

    // MARK: - Properties

    
    private var internalAU: AKOperationGeneratorAudioUnit?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    /// Parameters for changing internal operations
    public var parameters: [Double] = [] {
        didSet {
            internalAU?.setParameters(parameters)
        }
    }
    
    // MARK: - Initializers
    
    /// Initialize the generator with an operation and indicate whether it responds to a trigger
    ///
    /// - parameter operation: AKOperation stack to use
    /// - parameter triggered: Set to true if this operation requires a trigger (Default: false)
    ///
    public convenience init(operation: AKOperation, triggered: Bool = false) {
        var operationString = "\(operation) dup"
        if triggered {
            operationString = "\(operation) swap drop dup"
        }
        self.init(operationString, triggered: triggered)
    }
    
    /// Initialize the generator with a stereo operation and indicate whether it responds to a trigger
    ///
    /// - parameter stereoOperation: AKStereoOperation stack to use
    /// - parameter triggered: Set to true if this operation requires a trigger (Default: false)
    ///
    public convenience init(stereoOperation: AKStereoOperation, triggered: Bool = false) {
        var operationString = "\(stereoOperation) swap"
        if triggered {
            operationString = "drop \(stereoOperation) swap"
        }
        self.init(operationString, triggered: triggered)
    }
    
    /// Initialize the generator with a two mono operations for the left and right channel and indicate whether it responds to a trigger
    ///
    /// - parameter left: AKOperation to be heard from the left output
    /// - parameter right: AKOperation to be heard from the right output
    /// - parameter triggered: Set to true if this operation requires a trigger (Default: false)
    ///
    public convenience init(left: AKOperation, right: AKOperation, triggered: Bool = false) {
        var operationString = "\(left) \(right)"
        if triggered {
            operationString = "\(left) swap \(right)"
        }
        self.init(operationString, triggered: triggered)
    }
    
    /// Initialize this generator node with a generic sporth stack and a triggering flag
    ///
    /// - parameter sporth: String of valid Sporth code
    /// - parameter triggered: Set to true if this operation requires a trigger (Default: false)
    ///
    public init(_ sporth: String, triggered: Bool = false) {

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x63737467 /*'cstg'*/ 
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOperationGeneratorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKOperationGenerator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKOperationGeneratorAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            if triggered {
                self.internalAU?.setSporth("0 p 1 p\(sporth)")
            } else {
                self.internalAU?.setSporth(sporth)
            }
        }
    }
    
    /// Trigger the sound with an optional set of parameters
    /// - parameter parameters: An array of doubles to use as parameters
    ///
    public func trigger(parameters: [Double] = []) {
        self.internalAU!.trigger(parameters)
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}