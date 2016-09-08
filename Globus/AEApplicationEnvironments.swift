//
// AEApplicationEnvironments.swift
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

extension UIApplication {
    
    enum Environment: String {
        case Develop, Stage, Production, Unknown
    }
    
    enum Mode: String {
        case Debug, Release, Unknown
    }
    
    class var appConfiguration: String {
        return Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
    }
    
    class var buildConfiguration: (mode: Mode, environment: Environment) {
        let t: Mode, e: Environment
        
        // check configuration type
        if appConfiguration.lowercased().range(of: Mode.Debug.rawValue.lowercased()) != nil {
            t = .Debug
        } else if appConfiguration.lowercased().range(of: Mode.Release.rawValue.lowercased()) != nil {
            t = .Release
        } else {
            t = .Unknown
        }
        
        // check configuration environment
        if appConfiguration.lowercased().range(of: Environment.Develop.rawValue.lowercased()) != nil {
            e = .Develop
        } else if appConfiguration.lowercased().range(of: Environment.Stage.rawValue.lowercased()) != nil {
            e = .Stage
        } else if appConfiguration.lowercased().range(of: Environment.Production.rawValue.lowercased()) != nil {
            e = .Production
        } else {
            e = .Unknown
        }
        
        return (t, e)
    }
    
    class var isDebug: Bool {
        return buildConfiguration.mode == .Debug
    }
    
}
