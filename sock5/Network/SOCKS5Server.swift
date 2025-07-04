//
//  SOCKSServer.swift
//  sock5
//
//  Created on 25.06.25.
//

import Network
class SOCKS5Server {
    private var listener: NWListener?
    func start () {
        do {
            listener = try NWListener(using: .tcp, on: 1080)
            
            listener?.newConnectionHandler = { connection in
                let handler = SOCKS5Cunnection(connection: connection)
                handler.start()
                
            }
            listener?.start(queue: .main)
            print("리스너 시작")
        } catch {
            print("리스너 시작 실패. \(error)")
        }
    }
    
    func stop() {
        listener?.cancel()
        listener = nil
        print("서버 종료")
    }
}
