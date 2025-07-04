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
    @State private var showingCopyConfirmation = false
    var body: some View {
        VStack(spacing: 20){
            Text(viewModel.isRuning ? "SOCKS 서버 실행중" : "서버 꺼짐")
            Button(action: {
                viewModel.toggleServer()
            }){
                Text(viewModel.isRuning ? "서버 중지" : "서버 시작")
            }
            
            NavigationView{
                List(networkInterfaceViewModel.interfaces){iface in
                    VStack(alignment: .leading) {
                        Text("Name: \(iface.name)").font(.headline)
                        Text("Address: \(iface.address)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .onLongPressGesture {
                                UIPasteboard.general.string = iface.address
                                showingCopyConfirmation = true
                            }
                    }
                }
            }
            .navigationTitle("Network Interfaces")
            .alert("Address Copied", isPresented: $showingCopyConfirmation) {
                    Button("OK", role: .cancel) { }
            } message: {
                Text("The address has been copied to your clipboard.")
            }
        }.padding()
    }
}


#Preview {
    ContentView()
}
