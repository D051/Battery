//
//  ContentView.swift
//  Battery
//
//  Created by Dominik Schweigler on 19.02.24.
//

import SwiftUI
import ServiceManagement

struct ContentView: View {
    
    @State var hover: Bool = false
    
    @State var start_hover: Bool = false
    @State var close_hover: Bool = false
    
    @StateObject var bm = BatteryManager()

    
    var body: some View {
        
        ZStack {
            
            VStack(spacing: 16) {
                
                // Battery elements
                VStack(spacing: 16) {
                    
                    // Battery info element
                    VStack(spacing: 4) {
                        Image(systemName: bm.battery_limit_active ? "battery.75percent" : "battery.100percent")
                            .opacity(0.5)
                        Text(bm.battery_limit_active ? "Charges to 80%" : "Charges to 100%")
                            .opacity(0.5)
                    }
                    
                    // Battery ctrl element
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary.opacity(0.5))
                            .fill(.thinMaterial)
                            .shadow(radius: 4)
                        Toggle("Limit battery charge", isOn: $bm.battery_limit_toggle)
                            .toggleStyle(SwitchToggleStyle())
                    }
                    .frame(width: 200, height: 48)
                    
                }
                .opacity((start_hover || close_hover || bm.warning != nil) ? 0.5 : 1.0)
                .blur(radius: (start_hover || close_hover || bm.warning != nil) ? 12 : 0)
                
                // Battery menubar applications elements
                HStack(spacing: 16) {
                    
                    // Close button
                    Image(systemName: "xmark.circle.fill")
                        .opacity(close_hover ? 1.0 : 0.5)
                        .onHover { over in
                            withAnimation(.easeInOut(duration: 0.25)) { close_hover = over }
                        }
                        .onTapGesture {
                            NSApplication.shared.terminate(nil)
                        }
                    
                    // Start button
                    Image(systemName: bm.launch_at_login ? "play.circle.fill" : "play.circle")
                        .opacity(start_hover ? 1.0 : 0.5)
                        .onHover { over in
                            withAnimation(.easeInOut(duration: 0.25)) { start_hover = over }
                        }
                        .onTapGesture {
                            bm.launch_at_login.toggle()
                        }
                    
                }

            }
            
            // Launch on login info view
            VStack(spacing: 8) {
                Text("Launch Battery at login")
                    .fontWeight(.bold)
                Text(bm.launch_at_login ? "Enabled" : "Disabled")
                    .fontWeight(.bold)
                    .opacity(0.75)
            }
            .opacity(start_hover ? 1 : 0)

            
            // Quit battery info view
            VStack(spacing: 8) {
                Text("Quit Battery")
                    .fontWeight(.bold)
                Text("Click to quit battery")
                    .fontWeight(.bold)
                    .opacity(0.75)
            }
            .opacity(close_hover ? 1 : 0)
            
            // Warning display
            Text(bm.warning ?? "none")
                .fontWeight(.bold)
                .opacity(bm.warning == nil || start_hover || close_hover ? 0 : 1)
            
            
        }
        .padding()
    }
}

