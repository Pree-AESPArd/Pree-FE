//
//  RootTabView.swift
//  Pree
//
//  Created by KimDogyung on 7/25/25.
//

import SwiftUI

enum Tab { case home, profile }

struct RootTabView: View {
    @State private var selection: Tab = .home
    
    var body: some View {
        TabView (selection: $selection) {
            
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(Tab.home)
            
        }
    }
}
