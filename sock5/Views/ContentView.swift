//
//  ContentView.swift
//  sock5
//
//  Created on 25.06.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ServerViewModel()
    @StateObject private var networkInterfaceViewModel = NetworkInterfaceViewModel()
    var body: some View {
        VStack(spacing: 20){
            Text(viewModel.isRuning ? "SOCKS 서버 실행중" : "서버 꺼짐")
            Button(action: {
                viewModel.toggleServer()
            }){
                Text(viewModel.isRuning ? "서버 중지" : "서버 시작")
            }
            
            NavigationView{
//                ##div:has(> div > :is(div, span) > a[href="#s-3"])
                List(networkInterfaceViewModel.interfaces){iface in
                    VStack(alignment: .leading) {
                        Text("Name: \(iface.name)").font(.headline)
                        Text("Address: \(iface.address)").font(.subheadline).foregroundColor(.secondary)
                    }
                }
            }
        }.padding()
    }
}


#Preview {
    ContentView()
}
