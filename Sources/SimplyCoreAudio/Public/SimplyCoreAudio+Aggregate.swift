//
//  SimplyCoreAudio+Aggregate.swift
//  
//
//  Created by Ruben Nine on 4/4/21.
//

import CoreAudio
import Foundation
import os.log
@_implementationOnly import SimplyCoreAudioC

// MARK: - Create and Destroy Aggregate Devices

public extension SimplyCoreAudio {
    /// The composition of Addregate Device
    typealias AggregateOption = (isPrivate: Bool, isStacked: Bool)

    /// This routine creates a new aggregate audio device.
    ///
    /// - Parameter mainDevice: An audio device. This will also be the clock source.
    /// - Parameter subDevices: Audio devices.
    ///
    /// - Returns *(optional)* An aggregate `AudioDevice` if one can be created.
    func createAggregateDevice(mainDevice: AudioDevice?,
                               subDevices: [AudioDevice],
                               named name: String,
                               uid: String,
                               option: AggregateOption? = nil) -> AudioDevice?
    {
        // Don't accept the case that subDevices are given but mainDevice is not
        if mainDevice == nil && !subDevices.isEmpty {
            return nil
        }

        var desc: [String: Any] = [
            kAudioAggregateDeviceNameKey: name,
            kAudioAggregateDeviceUIDKey: uid,
            kAudioAggregateDeviceIsPrivateKey: option?.isPrivate ?? false,
            kAudioAggregateDeviceIsStackedKey: option?.isStacked ?? false,
        ]

        if let mainDeviceUID = mainDevice?.uid {
            // Dedup given devices
            let deviceUIDs = ([mainDeviceUID] + subDevices.compactMap { $0.uid }).unique()
            let deviceList: [[String: Any]] = deviceUIDs.map {
                [
                    kAudioSubDeviceUIDKey: $0,
                    kAudioSubDeviceDriftCompensationKey: $0 == mainDeviceUID ? 0 : 1,
                ]
            }
            desc[kAudioAggregateDeviceSubDeviceListKey] = deviceList
            desc[kAudioAggregateDeviceMainSubDeviceKey] = mainDeviceUID
        }

        var deviceID: AudioDeviceID = 0
        let error = AudioHardwareCreateAggregateDevice(desc as CFDictionary, &deviceID)

        guard error == noErr else {
            os_log("Failed creating aggregate device with error: %d.", log: .default, type: .debug, error)
            return nil
        }

        return AudioDevice.lookup(by: deviceID)
    }
    
    func createAggregateDevice(mainDevice: AudioDevice,
                               secondDevice: AudioDevice?,
                               named name: String,
                               uid: String) -> AudioDevice?
    {
        var subDevices: [AudioDevice] = []
        if let secondDevice = secondDevice {
            subDevices.append(secondDevice)
        }
        return createAggregateDevice(mainDevice: mainDevice, subDevices: subDevices, named: name, uid: uid)
    }
    
    @available(*, deprecated, message: "mainDevice: is preferred spelling for first argument")
    func createAggregateDevice(masterDevice: AudioDevice,
                               secondDevice: AudioDevice?,
                               named name: String,
                               uid: String) -> AudioDevice?
    {
        return createAggregateDevice(mainDevice: masterDevice, secondDevice: secondDevice, named: name, uid: uid)
    }

    func createMultiOutputDevice(mainDevice: AudioDevice?,
                                 subDevices: [AudioDevice],
                                 named name: String,
                                 uid: String) -> AudioDevice? {
        return createAggregateDevice(mainDevice: mainDevice, subDevices: subDevices, named: name, uid: uid, option: AggregateOption(isPrivate: false, isStacked: true))
    }

    /// Destroy the given audio aggregate device.
    ///
    /// The actual destruction of the device is asynchronous and may take place after
    /// the call to this routine has returned.
    ///
    /// - Parameter id: The `AudioObjectID` of the audio aggregate device to destroy.
    /// - Returns An `OSStatus` indicating success or failure.
    func removeAggregateDevice(id deviceID: AudioObjectID) -> OSStatus {
        AudioHardwareDestroyAggregateDevice(deviceID)
    }
}
