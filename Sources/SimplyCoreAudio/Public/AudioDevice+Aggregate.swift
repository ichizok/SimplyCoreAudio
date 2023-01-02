//
//  AudioDevice+Aggregate.swift
//
//  Created by Ryan Francesconi on 2/24/21.
//

import CoreAudio
import Foundation

// MARK: - Aggregate Device Functions

public extension AudioDevice {
    /// - Returns: `true` if this device is an aggregate one, `false` otherwise.
    var isAggregateDevice: Bool {
        guard let aggregateDevices = ownedAggregateDevices else { return false }
        return !aggregateDevices.isEmpty
    }

    /// All the subdevices of this aggregate device
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var ownedAggregateDevices: [AudioDevice]? {
        guard let ownedObjectIDs = ownedObjectIDs else { return nil }
        return ownedObjectIDs.compactMap { AudioDevice.lookup(by: $0) }
    }

    /// All the subdevices of this aggregate device that support input
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var ownedAggregateInputDevices: [AudioDevice]? {
        ownedAggregateDevices?.filter {
            guard let channels = $0.layoutChannels(scope: .input) else { return false }
            return channels > 0
        }
    }

    /// All the subdevices of this aggregate device that support output
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var ownedAggregateOutputDevices: [AudioDevice]? {
        ownedAggregateDevices?.filter {
            guard let channels = $0.layoutChannels(scope: .output) else { return false }
            return channels > 0
        }
    }

    /// - Returns: *(optional)* A `String` with the audio device `UID`.
    var mainSubDevice: AudioDevice? {
        guard let address = validAddress(selector: kAudioAggregateDevicePropertyMainSubDevice) else { return nil }
        guard let uid: String = getProperty(address: address) else { return nil }
        return AudioDevice.lookup(by: uid)
    }

    @available(*, deprecated, renamed: "mainSubDevice")
    var masterSubDevice: AudioDevice? {
        mainSubDevice
    }

    /// - Returns: *(optional)* A `String` with the audio device `UID`.
    var clockDevice: AudioDevice? {
        guard let address = validAddress(selector: kAudioAggregateDevicePropertyClockDevice) else { return nil }
        guard let uid: String = getProperty(address: address) else { return nil }
        return AudioDevice.lookup(by: uid)
    }
}
