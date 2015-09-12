//
//  AKDelay.swift
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka on 9/11/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

/** Simple audio delay

Add a delay to an incoming signal with optional feedback.
*/
@objc class AKDelay : AKParameter {

    // MARK: - Properties

    private var delay = UnsafeMutablePointer<sp_delay>.alloc(1)

    private var input = AKParameter()

    /** Delay time, in seconds. [Default Value: 1.0] */
    private var delayTime: Float = 0


    /** Feedback amount. Should be a value between 0-1. [Default Value: 0.0] */
    var feedback: AKParameter = akp(0.0) {
        didSet { feedback.bind(&delay.memory.feedback) }
    }


    // MARK: - Initializers

    /** Instantiates the delay with default values */
    init(input sourceInput: AKParameter)
    {
        super.init()
        input = sourceInput
        setup()
        bindAll()
    }

    /**
    Instantiates delay with constants

    - parameter delayTime: Delay time, in seconds. [Default Value: 1.0]
 */
    init (input sourceInput: AKParameter, delayTime timeInput: Float) {
        super.init()
        input = sourceInput
        setup(timeInput)
        bindAll()
    }

    /**
    Instantiates the delay with all values

    - parameter input: Input audio signal. 
    - parameter feedback: Feedback amount. Should be a value between 0-1. [Default Value: 0.0]
    - parameter delayTime: Delay time, in seconds. [Default Value: 1.0]
    */
    convenience init(
        input     sourceInput:   AKParameter,
        feedback  feedbackInput: AKParameter,
        delayTime timeInput:     Float)
    {
        self.init(input: sourceInput, delayTime: timeInput)
        feedback  = feedbackInput

        bindAll()
    }

    // MARK: - Internals

    /** Bind every property to the internal delay */
    internal func bindAll() {
        feedback .bind(&delay.memory.feedback)
    }

    /** Internal set up function */
    internal func setup(delayTime: Float = 1.0)
 {
        sp_delay_create(&delay)
        sp_delay_init(AKManager.sharedManager.data, delay, delayTime)
    }

    /** Computation of the next value */
    override func compute() {
        sp_delay_compute(AKManager.sharedManager.data, delay, &(input.leftOutput), &leftOutput);
        rightOutput = leftOutput
    }

    /** Release of memory */
    override func teardown() {
        sp_delay_destroy(&delay)
    }
}
