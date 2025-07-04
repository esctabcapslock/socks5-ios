//
//  NWConnectionAsync.swift
//  sock5
//
//  Created on 04.07.25.
//
import Network
import Foundation

// NWConnection.receive async로 비동기처리
extension NWConnection{
    func receiveAsync(minimumIncompleteLength: Int, maximumLength: Int) async throws -> (Data?,  NWConnection.ContentContext?, Bool){
        return try await withCheckedThrowingContinuation {continuation in
            self.receive(minimumIncompleteLength: minimumIncompleteLength, maximumLength: maximumLength) { data, context, isComplete, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data, context, isComplete))
                }
            }
        }
    }
    
    func sendAsync(
        content: Data,
        contentContext: NWConnection.ContentContext = .defaultMessage,
        isComplete: Bool = true
    ) async throws {
        return try await withCheckedThrowingContinuation {continuation in
            print("sendAsync")
            self.send(content: content, contentContext: contentContext, isComplete:isComplete, completion: .contentProcessed {error in
                print("sendAsync in")
                if let error = error {
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(returning: ())
                }
            })
        }
    }
}
