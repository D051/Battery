//
//  protocol.swift
//  Battery
//
//  Created by Dominik Schweigler on 19.02.24.
//

import Foundation

// Mode Definitions
public let BatteryStateMaximum = 0;
public let BatteryStateLimited = 1;
public let BatteryStateError = 255;

// Battery Deamon Protocol
@objc protocol BatteryProtocol {
    
    // set battery mode to maximum charge
    func set_mode_maximum(withReply reply: @escaping (Int) -> Void)
    
    // set battery mode to limited charge
    func set_mode_limited(withReply reply: @escaping (Int) -> Void)
    
    // get current battery mode
    func get_mode(withReply reply: @escaping (Int) -> Void)
    
}
