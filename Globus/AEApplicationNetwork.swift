//
// AEApplicationNetwork.swift
//
// Copyright (c) 2014 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import SystemConfiguration

var AENetworkActivityCount = 0
let AENetworkActivityQueue = DispatchQueue(label: "AENetworkActivity")

extension UIApplication {
    
    // MARK: - Network Connection
    
    class func hasNetworkConnection() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isWWAN = flags.contains(.isWWAN)
        let isReachable = flags == .reachable
        let offline = flags == .connectionRequired
        
        return (isReachable || isWWAN) && !offline
    }
    
    // MARK: - Network Activity Indicator
    
    public class func showNetworkActivityIndicator() {
        AENetworkActivityQueue.sync() {
            AENetworkActivityCount += 1
            UIApplication.updateNetworkActivityIndicator()
        }
    }
    
    public class func hideNetworkActivityIndicator() {
        AENetworkActivityQueue.sync() {
            // never go less then zero
            if AENetworkActivityCount > 0 {
                AENetworkActivityCount -= 1
            }
            UIApplication.updateNetworkActivityIndicator()
        }
    }
    
    private class func updateNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = (AENetworkActivityCount > 0)
    }
    
}
