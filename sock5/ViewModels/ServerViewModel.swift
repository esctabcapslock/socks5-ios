//
//  ServerViewModel.swift
//  sock5
//
//  Created on 25.06.25.
//

import Foundation
class ServerViewModel: ObservableObject {
    @Published var isRuning = false
    private var server: SOCKS5Server?
    
    func toggleServer() {
        if isRuning {
            server?.stop()
            isRuning = false

        } else {
            server = SOCKS5Server()
            server?.start()
            isRuning = true
            
        }
    }
}
