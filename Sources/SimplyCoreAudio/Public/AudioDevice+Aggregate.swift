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
        return validAddress(selector: kAudioAggregateDevicePropertyMainSubDevice) != nil
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

    /// All the subdevices of this aggregate device
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var allSubDevices: [AudioDevice]? {
        get {
            guard var address = validAddress(selector: kAudioAggregateDevicePropertyFullSubDeviceList) else { return nil }

            var size = UInt32(MemoryLayout<CFArray>.size)
            var value: CFArray? = nil

            let status = AudioObjectGetPropertyData(objectID, &address, UInt32(0), nil, &size, &value)
            guard noErr == status, let subDevices = ownedAggregateDevices else { return nil }

            let uids = (value! as NSArray) as! [String]
            return uids.compactMap { uid in
                subDevices.first(where: { $0.uid == uid })
            }
        }

        set {
            guard var address = validAddress(selector: kAudioAggregateDevicePropertyFullSubDeviceList) else { return }

            let size = UInt32(MemoryLayout<CFArray>.size)
            var value = (newValue?.compactMap { $0.uid }.unique() ?? []) as CFArray

            let _ = AudioObjectSetPropertyData(objectID, &address, UInt32(0), nil, size, &value)
        }
    }

    /// All the subdevices of this aggregate device that support input
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var allInputSubDevices: [AudioDevice]? {
        allSubDevices?.filter {
            guard let channels = $0.layoutChannels(scope: .input) else { return false }
            return channels > 0
        }
    }

    /// All the subdevices of this aggregate device that support output
    ///
    /// - Returns: An array of `AudioDevice` objects.
    var allOutputSubDevices: [AudioDevice]? {
        allSubDevices?.filter {
            guard let channels = $0.layoutChannels(scope: .output) else { return false }
            return channels > 0
        }
    }

    /// - Returns: *(optional)* A `String` with the audio device `UID`.
    var mainSubDevice: AudioDevice? {
        get {
            guard let address = validAddress(selector: kAudioAggregateDevicePropertyMainSubDevice),
                  let uid: String = getProperty(address: address) else { return nil }
            return AudioDevice.lookup(by: uid)
        }

        set {
            guard let address = validAddress(selector: kAudioAggregateDevicePropertyMainSubDevice),
                  let uid = newValue?.uid else { return }

            if allSubDevices == nil {
                allSubDevices = [newValue!]
            } else {
                allSubDevices!.insert(newValue!, at: 0)
            }
            let _ = setProperty(address: address, value: uid)
        }
    }

    @available(*, deprecated, renamed: "mainSubDevice")
    var masterSubDevice: AudioDevice? {
        mainSubDevice
    }

    /// - Returns: *(optional)* A `String` with the audio device `UID`.
    var clockDevice: AudioDevice? {
        get {
            guard let address = validAddress(selector: kAudioAggregateDevicePropertyClockDevice),
                  let uid: String = getProperty(address: address) else { return nil }
            return AudioDevice.lookup(by: uid)
        }

        set {
            guard let address = validAddress(selector: kAudioAggregateDevicePropertyClockDevice),
                  let uid = newValue?.uid else { return }

            if allSubDevices == nil {
                allSubDevices = [newValue!]
            } else {
                allSubDevices!.insert(newValue!, at: 0)
            }
            let _ = setProperty(address: address, value: uid)
        }
    }
}
