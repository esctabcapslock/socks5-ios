//
//  NetworkInterfaceViewModel.swift
//  sock5
//
//  Created on 25.06.25.
//

import Foundation
class NetworkInterfaceViewModel: ObservableObject {
    @Published var interfaces: [NetworkInterface] = []
    init(){
        loadInterface()
    }
    
    func loadInterface(){
        var results: [NetworkInterface] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                guard let interface = ptr?.pointee else { break }
                let name: String = String(cString: interface.ifa_name)
                
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST) == 0 {
                        let address: String = String(cString: hostname)
                        results.append(NetworkInterface(name: name, address: address))
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        DispatchQueue.main.async {
            self.interfaces = results
        }
        
    }
}
