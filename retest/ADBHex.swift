//
//  ADBHex.swift
//  retest
//
//  Created by Raphael Sacle on 3/29/18.
//  Copyright © 2018 Raphael Sacle. All rights reserved.
//

import Foundation

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}


class ADBHex {
    /*static func hexString(fromByteArray buffer: UnsafePointer<UInt8>, length: Int) -> String {
        var hexString = ""
        var _: Int = 0
        for i in 0..<length {
            if i == 0 {
                hexString = hexString + (String(format: "%02X", buffer[i]))
            }
            else {
                hexString = hexString + (String(format: " %02X", buffer[i]))
            }
        }
        return hexString
    }*/
    
    static func hexString(fromByteArray buffer: Data) -> String {
       
        return buffer.hexEncodedString(options: Data.HexEncodingOptions.upperCase)
        //return self.hexString(fromByteArray: nsData.bytes, length: buffer.count)
    }
    
    
    static func byteArray(fromHexString hexString: String) -> Data? {
        var data = Data(capacity: hexString.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: hexString, range: NSMakeRange(0, hexString.utf16.count)) { match, flags, stop in
            let byteString = (hexString as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
   
}
