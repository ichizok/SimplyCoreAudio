//
//  AudioDevice+SubDevice.swift
//

import CoreAudio
import Foundation

// MARK: - SubDevice properties

public extension AudioDevice {
    var extraLatency: Float64? {
        get {
            guard let address = validAddress(selector: kAudioSubDevicePropertyExtraLatency) else { return nil }
            return getProperty(address: address)
        }
        set {
            guard let address = validAddress(selector: kAudioSubDevicePropertyExtraLatency) else { return }
            _ = setProperty(address: address, value: newValue)
        }
    }

    var driftCompensation: Bool? {
        get {
            guard let address = validAddress(selector: kAudioSubDevicePropertyDriftCompensation) else { return nil }
            return getProperty(address: address)
        }
        set {
            guard let address = validAddress(selector: kAudioSubDevicePropertyDriftCompensation) else { return }
            _ = setProperty(address: address, value: newValue)
        }
    }

    var driftCompensationQuality: UInt32? {
        get {
            guard let address = validAddress(selector: kAudioSubDevicePropertyDriftCompensationQuality) else { return nil }
            return getProperty(address: address)
        }
        set {
            guard let address = validAddress(selector: kAudioSubDevicePropertyDriftCompensationQuality) else { return }
            _ = setProperty(address: address, value: newValue)
        }
    }
}
