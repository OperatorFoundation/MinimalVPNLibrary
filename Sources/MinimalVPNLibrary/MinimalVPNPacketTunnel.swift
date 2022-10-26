//
//  File.swift
//  
//
//  Created by Joshua Clark on 10/11/22.
//

import Logging
import Network
import NetworkExtension

import SwiftTestUtils

open class MinimalVPNPacketTunnel: NEPacketTunnelProvider
{
    var logger: Logger
    var connection: NWTCPConnection! = nil
    var hostName = ""
    var port = "1234"

    public override init()
    {
        self.logger = Logger(label: "MinimalVPNPacketTunnelLog")
        self.logger.logLevel = .debug
        self.logger.debug("Initialized MinimalVPNPacketTunnel")

        super.init()
    }

    public override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void)
    {
        self.logger.debug("MinimalVPNPacketTunnel: startTunnel called")
        
        print("MinimalVPNPacketTunnel: creating a TCP connection to \(hostName):\(port)")
        
        self.connection = self.createTCPConnection(to: NWHostEndpoint(hostname: hostName, port: port), enableTLS: false, tlsParameters: nil, delegate: nil)
        
        self.logger.debug("MinimalVPNPacketTunnel: startTunnel created a connection. Connection state: \(connection.state)")
        
        guard let firstMessage = "hello".data(using: .utf8) else
        {
            completionHandler(NEVPNError(NEVPNError.configurationReadWriteFailed))
            return
        }
        
        self.connection.write(firstMessage)
        {
            maybeWriteError in

            if let writeError = maybeWriteError
            {
                self.logger.error("MinimalVPNPacketTunnel: startTunnel received an error trying to write to the connection: \(writeError)")
                completionHandler(writeError)
                return
            }
            else
            {
                self.logger.debug("MinimalVPNPacketTunnel: startTunnel wrote some data")
                completionHandler(nil)
            }
        }
//        connection.stateUpdateHandler =
//        {
//            (state: NWConnection.State) in
//
//            self.logger.debug("state: \(state)")
//            switch state
//            {
//                case .ready:
//                    self.logger.debug("ready!")
//                    completionHandler(nil)
//                case .cancelled:
//                    completionHandler(nil)
//                case .failed(_):
//                    completionHandler(nil)
//                default:
//                    return
//            }
//        }
        completionHandler(nil)
    }
        
    public override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        completionHandler()
    }
    
    public override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    public override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    public override func wake() {
        // Add code here to wake up.
    }
}

public enum PacketTunnelErrors: Error {
    case serverInfoNotFound
    case hostNotFound
    case portNotFound
}
