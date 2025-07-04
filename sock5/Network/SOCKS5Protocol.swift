//
//  SOCKSProtocol.swift
//  sock5
//
//  Created on 25.06.25.
//

import Foundation
import Network



extension Data {
    func ipv6HexString() -> String {
        precondition(self.count % 2 == 0, "Data length must be even")
        
        // IPv6 주소는 8개의 16비트 그룹, 각 그룹은 4글자, 7개의 ':' 있음
        var result = String()
        result.reserveCapacity(self.count * 2 + 7) // 4*8 + 7 = 39 chars 예상
        
        for i in stride(from: 0, to: self.count, by: 2) {
            let highByte = UInt16(self[self.index(self.startIndex, offsetBy: i)]) << 8
            let lowByte = UInt16(self[self.index(self.startIndex, offsetBy: i + 1)])
            let segment = highByte | lowByte
            
            // 16비트 segment를 4자리 16진수로 변환 (앞자리 0 포함)

            for shift in stride(from: 12, through: 0, by: -4) {
                let nibble = Int((segment >> shift) & 0xF)
                let char: Character
                if nibble < 10 {
                    char = Character(UnicodeScalar(nibble + 48)!)  // '0' = 48
                } else {
                    char = Character(UnicodeScalar(nibble - 10 + 97)!)  // 'a' = 97
                }
                result.append(char)
            }
        
            
            // 마지막 그룹 아니면 ':' 추가
            if i < self.count - 2 {
                result.append(":")
            }
        }
        
        return result
    }
}



enum SOCKS5Command: UInt8 {
    case connect = 0x01
    case bind = 0x02
    case udp = 0x03
}

enum SOCKS5AddressType: UInt8 {
    case ipv4 = 0x01
    case domainName = 0x03
    case ipv6 = 0x04
}

enum sock5Error: Error {
    case protocolError
}


class SOCKS5Address {
    let addressType:SOCKS5AddressType
    var hostAddressString: String
    private(set) var hostAddress: NWEndpoint.Host
    private(set) var dstPort: NWEndpoint.Port
    private(set) var boundAddress: Data.SubSequence

    init(data:Data.SubSequence) throws {
        boundAddress = data
        if let addressType = SOCKS5AddressType(rawValue: data[0]) {
            self.addressType = addressType
        }else{
            throw sock5Error.protocolError
        }
        
        var idx = 1
        let addressLength: Int
        switch addressType {
        case .ipv4: addressLength = 4
        case .domainName:
            addressLength = Int(data[4])
            idx += 1
        case .ipv6: addressLength = 16
//        default:
//            throw sock5Error.protocolError
        }
                
        guard data.count >= idx + addressLength + 2 else {
            throw sock5Error.protocolError
        }

        
        switch addressType {
        case .ipv4:
            let octets = data[idx..<idx+addressLength]
            hostAddressString = octets.map { String($0) }.joined(separator: ".")
        case .domainName:
            hostAddressString = String(bytes: data[idx..<idx+addressLength], encoding: .utf8) ?? "InvalidDomain"
        case .ipv6:
            let segments = data[idx..<idx+addressLength]

//            hostAddressString = segments.map { String(format: "%02x", $0) }.joined(separator: ":")
            hostAddressString = segments.ipv6HexString()
//        default:
//            throw sock5Error.protocolError
        }

        hostAddress = NWEndpoint.Host(hostAddressString)
        idx += addressLength
        guard let dstPort = NWEndpoint.Port(rawValue: UInt16(data[idx]) << 8 | UInt16(data[idx+1])) else {
            throw sock5Error.protocolError
        }
        
        self.dstPort = dstPort
    }
}
