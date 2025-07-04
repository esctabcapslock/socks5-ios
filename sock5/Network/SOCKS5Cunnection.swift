//
//  SOCKCunnection.swift
//  sock5
//
//  Created on 25.06.25.
//

import Network
import Foundation




// https://en.m.wikipedia.org/wiki/SOCKS 참조
class SOCKS5Cunnection {
    let connection: NWConnection
    
    init(connection: NWConnection) {
        self.connection = connection
        
        self.connection.stateUpdateHandler = { state in
                print("[self.connection.stateUpdateHandler=\(state)]")
        }
    }
    
    func start() {
        self.connection.start(queue: .global())
        receiveClientGreetings()
        
    }
    
    private func receiveClientGreetings(){
        self.connection.receive(minimumIncompleteLength: 2, maximumLength: 512) { data, _, _, error in
            guard let data = data, error == nil else { return }
            
            print("[receiveClientGreetings] 요청 수신 (\(data)) hex: \(data.map{String(format: "%02x", $0)})")
            let version = data[0]
//            let nAuth = data[1]
            guard version == 0x05 else {
                print("SOCK5 아님")
                self.connection.cancel()
                return
            }
            let methods = data.dropFirst(2) // 앞에 2개 드랍
            self.sendServerChoice(ok: methods.contains(0x00))
        }
    }
    
    private func sendServerChoice(ok: Bool){
        print("[sendServerChoice] ok:\(ok)")
        if ok{
            self.connection.send(content: Data([0x05, 0x00]), completion: .contentProcessed{error in
                if let error = error {
                    print("Error sending server choice: \(error)")
                } else {
                    print("no Error")
                    self.receiveClientConnectionRequest()
                }
            })
        } else {
            self.connection.send(content: Data([0x05, 0xFF]), completion: .contentProcessed{_ in
                self.connection.cancel()
            })
        }
    }
    
    private func receiveClientConnectionRequest(){
        print("[receiveClientConnectionRequest]")
        self.connection.receive(minimumIncompleteLength: 2, maximumLength: 512) {(data, _, _, error:NWError?) in
            guard let data = data, error == nil else { return }
            print("[receiveClientConnectionRequest] 요청 수신 (\(data)) hex: \(data.map{String(format: "%02x", $0)})")
            
            let version = data[0]
                
            let commandCode = SOCKS5Command(rawValue:data[1])
            let reserved = data[2]
            guard version == 0x05, reserved == 0x00 else {
                print("지원하지 않는 명령")
                self.connection.cancel()
                return
            }
            do {

                let address = try SOCKS5Address(data: Data(data[3..<data.count]))
                switch commandCode {
                case .connect:
                    self.connectToTargetHost(address: address)
                case .bind:
                    break
                case .udp:
                    break
                default:
                    fatalError("Unsupported address type: \(data[3])")
                }
   
            }catch{
                print("error: \(error)")
                return
            }
        }
    }
    
//
    private func connectToTargetHost(address: SOCKS5Address) {
        
        let targetConnection = NWConnection(host: address.hostAddress, port: address.dstPort, using: .tcp)
        targetConnection.start(queue: .global())
        
        targetConnection.stateUpdateHandler = { newState in
                print("newState: \(newState)")
            }

        
        print("[connectToTargetHost] targetConnection:\(targetConnection), address:\(address.hostAddress),\(address.hostAddressString), port:\(address.dstPort)")
        
        
        let responce: [UInt8] = [
            0x05, //버전
            0x00, // 성공
            0x00, // 예약
        ] + address.boundAddress
        
        self.connection.send(content: responce, completion: .contentProcessed{_ in
            Task{
               try await self.connectLoopTargetHost(targetConnection: targetConnection)
            }
            
        } )
    }
    
    
    private func connectLoopTargetHost(targetConnection:NWConnection) async throws {
        let maximumLength = 1024
        
        async let clientToRemote: Void = transferLoop(from: self.connection, to: targetConnection, maximumLength: maximumLength, direction: "c->r")
        async let remoteToClient: Void = transferLoop(from: targetConnection, to: self.connection, maximumLength: maximumLength, direction: "r->c")

        do {
            try await clientToRemote
            try await remoteToClient
        }catch{
            print("[connectLoopTargetHost] Error occurred: \(error)")
            targetConnection.cancel()
            self.connection.cancel()
            throw error
        }
        
//        try await withThrowingTaskGroup(of: Void.self) { group in
//            group.addTask {try await self.transferLoop(from: self.connection, to: targetConnection, maximumLength: maximumLength, direction: "c->r")}
//            group.addTask {try await self.transferLoop(from: targetConnection, to: self.connection, maximumLength: maximumLength, direction: "r->c")}
//            
//            do{
//                try await group.waitForAll()
//            }catch{
//                print("[connectLoopTargetHost] Error occurred: \(error)")
//                group.cancelAll()
//                targetConnection.cancel()
//                self.connection.cancel()
//                throw error
//            }
//            
//        }

        targetConnection.cancel()
        self.connection.cancel()
    }
    
    
    private func transferLoop(from:NWConnection, to:NWConnection, maximumLength:Int, direction: String) async throws{
        while true{
            print("[transferLoop] \(direction)----start")
            let (receivedData, _, isComplete) = try await from.receiveAsync(minimumIncompleteLength: 4, maximumLength: maximumLength)
            guard let data = receivedData else {
                print("[transferLoop] \(direction) break. \(isComplete), nil");
                continue
            }
            //print("[connectLoopTargetHost remote -> client] 요청 수신 \(isComplete) (\(data)) hex: \(data.map{String(format: "%02x", $0)})")
            print("[transferLoop] \(direction) 요청 수신 \(isComplete) (\(data))")
            
            guard !data.isEmpty else { continue }
            try await to.sendAsync(content: data, isComplete:isComplete)
            print("[transferLoop] \(direction)] 요청 발신")
            guard !isComplete, data.count==maximumLength else {
                print("[transferLoop] \(direction) break. \(isComplete), \(data.count)");
                continue
            }
            print("[transferLoop] \(direction)----fin")
        }

    }
    
//    private func receiveRequest(){
//        self.connection.receive(minimumIncompleteLength: 2, maximumLength: 512) { data, _, _, error in
//            guard let data = data, error == nil else { return }
//            
//            print("요청 수신 (\(data)) hex: \(data.map{String(format: "%02x", $0)})\n")
////            print("요청 수신 (\(data)) str: \(String(data:data, encoding: .utf8))\n")
//
//            self.connection.cancel()
//        }
//    }
}
