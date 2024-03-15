//
//  TinyBeansApp.swift
//  TinyBeans
//
//  Created by Jian Ma on 3/15/24.
//
import SwiftUI

@main
struct TinyBeans: App {
    var body: some Scene {
        WindowGroup {
//            Text("skja")
//            ContentView()
            
            NavigationStack {
                ContentView(
                    viewModel: ContentView.ViewModel(
//                        client: .mock
                        client: .live(apiKey: apiKey)
//                                    client: .live(apiKey: apiKey)
                    )
                )
                
            }
        }
    }
}
