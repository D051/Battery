//
//  service.swift
//  Service
//
//  Created by Dominik Schweigler on 19.02.24.
//

import Foundation

// BCLM Key definition
let BCLM_KEY = "CHWA"

// bclm value limited
let bclm_val_limited: SMCBytes = (
    UInt8(1), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)
)

// bclm value maximum
let bclm_val_maximum: SMCBytes = (
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
    UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0)
)

// Battery service Implementation for m series mac
@objc class BatteryService: NSObject, BatteryProtocol{
    
    // set battery mode to maximum charge
    func set_mode_maximum(withReply reply: @escaping (Int) -> Void) {
        do {
            try SMCKit.open()
            let key = SMCKit.getKey(BCLM_KEY, type: DataTypes.UInt8)
            try SMCKit.writeData(key, data: bclm_val_maximum)
            reply(BatteryStateMaximum)
        } catch {
            reply(BatteryStateError)
        }
    }
    
    // set battery mode to limited charge
    func set_mode_limited(withReply reply: @escaping (Int) -> Void) {
        do {
            try SMCKit.open()
            let key = SMCKit.getKey(BCLM_KEY, type: DataTypes.UInt8)
            try SMCKit.writeData(key, data: bclm_val_limited)
            reply(BatteryStateLimited)
        } catch {
            reply(BatteryStateError)
        }
    }
    
    // get current battery mode
    func get_mode(withReply reply: @escaping (Int) -> Void) {
        do {
            try SMCKit.open()
            let key = SMCKit.getKey(BCLM_KEY, type: DataTypes.UInt8)
            let status = try SMCKit.readData(key).0
            if status == 0 {
                reply(BatteryStateMaximum)
                return
            }
            if status == 1 {
                reply(BatteryStateLimited)
                return
            }
            reply(BatteryStateError)
        } catch {
            reply(BatteryStateError)
        }
    }

}
