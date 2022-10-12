//
//  File.swift
//  
//
//  Created by Joshua Clark on 10/11/22.
//

import Foundation
import Network
import NetworkExtension

public class VPNManager
{
    public let manager = NETunnelProviderManager()
    let serverIP: String

    public init(serverIP: String)
    {
        self.serverIP = serverIP
        self.manager.isEnabled = false
    }

//    public func load()
//    {
//        print("Loading...")
//
//        self.manager.loadFromPreferences
//        {
//            maybeError in
//
//            print("Loaded.")
//        }
//    }

    public func enable()
    {
        self.manager.loadFromPreferences
        {
            maybeLoadError in

            print("VPNManager loadFromPreferences - 1")
            if let loadError = maybeLoadError
            {
                print("VPNManager encountered an error loading from preferences: \(loadError)")
                self.manager.isEnabled = false
                return
            }

            self.manager.saveToPreferences
            {
                maybeSaveError in

                print("VPNManager saveToPreferences - 1")

                self.manager.loadFromPreferences
                {
                    maybeNextLoadError in

                    print("VPNManager loadFromPreferences - 2")
                    
                    if let nextLoadError = maybeNextLoadError
                    {
                        print("VPNManager encountered an error on second load from preferences: \(nextLoadError)")
                        
                        self.manager.isEnabled = false
                        return
                    }

                    let protocolConfiguration = NETunnelProviderProtocol()
                    let appId = Bundle.main.bundleIdentifier!
                    protocolConfiguration.providerBundleIdentifier = "\(appId).MinimalVPNNetworkExtension"
                    protocolConfiguration.serverAddress = self.serverIP
                    protocolConfiguration.includeAllNetworks = true
                    self.manager.protocolConfiguration = protocolConfiguration
                    self.manager.localizedDescription = "MinimalVPNApp"
                    self.manager.isEnabled = true

                    print("***********\nVPNManager protocolConfiguration:\n\(protocolConfiguration)\n***********")

                    self.manager.saveToPreferences
                    {
                        _ in

                        print("VPNManager saveToPreferences - 2")

                        self.manager.loadFromPreferences
                        {
                            _ in

                            print("VPNManager loadFromPreferences - 3")
                            print("VPNManager enable() is done.")
                        }
                    }
                }
            }
        }
    }
}
