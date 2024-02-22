//
//  Manager.swift
//  Battery
//
//  Created by Dominik Schweigler on 19.02.24.
//

import Foundation
import ServiceManagement


class BatteryManager: ObservableObject {
    
    @Published var warning: String? = "loading"
    
    @Published var launch_at_login: Bool = false {
        didSet {
            Task {
                if launch_at_login {
                    do {
                        try SMAppService.mainApp.register()
                    } catch {
                        DispatchQueue.main.async {
                            self.warning = "Failed to enable launch at login"
                            self.launch_at_login = false
                        }
                    }
                } else {
                    do {
                        try SMAppService.mainApp.unregister()
                    } catch {
                        DispatchQueue.main.async {
                            self.warning = "Failed to disable launch at login"
                            self.launch_at_login = true
                        }
                    }
                }
            }
        }
    }
    
    @Published var battery_limit_toggle: Bool = false {
        @MainActor
        didSet {
            if battery_limit_toggle != battery_limit_active {
                if battery_limit_toggle == false {
                    set_mode_maximum()
                } else {
                    set_mode_limited()
                }
            }
        }
    }
    
    @Published var battery_limit_active: Bool = false {
        @MainActor
        didSet {
            if battery_limit_toggle != battery_limit_active {
                battery_limit_toggle = battery_limit_active
            }
        }
    }
    
    private var connection: NSXPCConnection?
    
    init() {
        
        // get launch at login status
        switch SMAppService.mainApp.status {
        case .enabled:
            self.launch_at_login = true
        default:
            self.launch_at_login = false
        }
        
        // check service
        let service = SMAppService.daemon(plistName: "com.schweigler.Battery.Service.plist")
        
        // handle missing installation
        if service.status == .notRegistered || service.status == .notFound {
            self.install(service: service)
            return
        }
        
        // Display message if approval is required
        if service.status == .requiresApproval {
            self.warning = "Allow Battery in Settings"
            return
        }
        
        // Connect if service is enabled
        if service.status == .enabled {
            self.connect()
            return
        }
        
    }
    
    // Install daemon service
    func install(service: SMAppService) {
        Task {
            do {
                try service.register()
            } catch {
                if (error as NSError).code != 1 {
                    DispatchQueue.main.async {
                        self.warning = "Installation failed: \(error)"
                    }
                }
            }
            if service.status == .requiresApproval {
                DispatchQueue.main.async {
                    self.warning = "Allow Battery in Settings"
                }
            } else {
                DispatchQueue.main.async {
                    self.warning = "Failed to install daemon"
                }
            }
        }
    }
    
    // Connect daemon service
    func connect() {
        // init daemon connection
        self.connection = NSXPCConnection(machServiceName: "com.schweigler.Battery.Service")
        self.connection!.remoteObjectInterface = NSXPCInterface(with: BatteryProtocol.self)
        self.connection!.resume()
        // create proxy
        let proxy = self.connection!.remoteObjectProxyWithErrorHandler { error in
            DispatchQueue.main.async {
                self.warning = "Battery service proxy failed"
            }
        } as? BatteryProtocol
        // try to fetch current battery mode
        if let p = proxy {
            p.get_mode() { mode in
                DispatchQueue.main.async {
                    switch mode {
                    case BatteryStateLimited:
                        self.battery_limit_active = true
                    case BatteryStateMaximum:
                        self.battery_limit_active = false
                    default:
                        self.warning = "Unknown battery state"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.warning = "Battery service proxy failed"
            }
        }
        self.warning = nil
    }
    
    // Set battery mode to maximum charge
    func set_mode_maximum() {
        // connecto to daemon service
        let service = self.connection!.remoteObjectProxyWithErrorHandler { error in
            DispatchQueue.main.async {
                self.warning = "Failed to connect to bettery service"
            }
        } as? BatteryProtocol
        // handle connection error
        if let s = service {
            // set battery mode to limited via daemon
            s.set_mode_maximum() { mode in
                if mode == BatteryStateMaximum {
                    DispatchQueue.main.async {
                        self.battery_limit_active = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.warning = "failed to set battery mode"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.warning = "Failed to connect to bettery service"
            }
        }
    }
    
    // Set battery mode to limited charge
    func set_mode_limited() {
        // connecto to daemon service
        let service = self.connection!.remoteObjectProxyWithErrorHandler { error in
            DispatchQueue.main.async {
                self.warning = "Failed to connect to bettery service"
            }
        } as? BatteryProtocol
        // handle connection error
        if let s = service {
            // set battery mode to limited via daemon
            s.set_mode_limited() { mode in
                if mode == BatteryStateLimited {
                    DispatchQueue.main.async {
                        self.battery_limit_active = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.warning = "failed to set battery mode"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.warning = "Failed to connect to bettery service"
            }
        }
    }
    
}
