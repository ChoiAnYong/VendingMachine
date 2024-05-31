//
//  VendingMachineTestView.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//

import SwiftUI

struct VendingMachineTestView: View {
    @ObservedObject var client = TcpSocket()
    @State private var selectedDrink = "물"
    @State private var quantity = "1"
    @State private var oldName = ""
    @State private var newName = ""
    
    var body: some View {
        VStack {
            Text("Vending Machine Client")
                .font(.largeTitle)
            
            HStack {
                TextField("Drink Name", text: $selectedDrink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Quantity", text: $quantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Buy") {
                    let message = "BUY:\(selectedDrink):\(quantity)\n"
                    client.send(message: message)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            
            HStack {
                TextField("Old Name", text: $oldName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("New Name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Change Name") {
                    let message = "CHANGE_NAME:\(oldName):\(newName)\n"
                    client.send(message: message)
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            
            Button("Check Stock") {
                client.send(message: "STOCK\n")
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            List(client.messages, id: \.self) { message in
                Text(message)
            }
            .padding()
        }
        .onAppear {
            client.connect(host: "127.0.0.1", port: 9000)
        }
        .onDisappear {
            client.disconnect()
        }
    }
}

#Preview {
    VendingMachineTestView()
}
