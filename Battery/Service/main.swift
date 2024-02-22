//
//  main.swift
//  Service
//
//  Created by Dominik Schweigler on 19.02.24.
//

import Foundation

// Battery Service Delegate
class BatteryServiceDelegate : NSObject, NSXPCListenerDelegate {
    // Battery Service Listener
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = BatteryService()
        newConnection.exportedInterface = NSXPCInterface(with: BatteryProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
    
}

// Battery Service Eventloop
let delegate = BatteryServiceDelegate()
let listener = NSXPCListener(machServiceName: "com.schweigler.Battery.Service")
listener.delegate = delegate;
listener.resume()
RunLoop.main.run()
