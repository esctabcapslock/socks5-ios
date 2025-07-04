//
//  NetworkInterface.swift
//  sock5
//
//  Created on 25.06.25.
//

import Foundation
struct NetworkInterface: Identifiable {
    let id = UUID()
    let name: String
    let address: String
}
