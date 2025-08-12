//
//  CustomTabView.swift
//  Pree
//
//  Created by 이유현 on 8/3/25.
//

import SwiftUI

struct CustomTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack{
            HStack(alignment: .top) {
                Spacer()
                
                Ellipse()
                    .frame(width: 100, height: 90)
                    .foregroundColor(Color.white)
                    .offset(y:-29)
                    .applyShadowStyle()
                
                Spacer()
            } // :HStack
            .background(Color.white)
            .cornerRadiusCustom(30, corners: [.topLeft, .topRight])
            .offset(y:10)
            
            
            HStack(alignment: .top) {
                
                Spacer()
                
                Button(action:{
                    navigationManager.popToRoot()
                }){
                    Image((navigationManager.path.last == .home || navigationManager.path.isEmpty) ? "home_on": "home_off")
                        .padding(.top, 15.4)
                }
                
                Spacer()
                
                Circle()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.primary)
                    .overlay {
                        Image("plus")
                    }
                    .offset(y:-19)
                    .opacity(0)
                
                Spacer()
                
                Button(action:{
                    navigationManager.push(.profile)
                }){
                    Image(navigationManager.path.last == .profile ? "user_on" :"user_off")
                        .padding(.top, 15.4)
                }
                
                Spacer()
                
            } // :HStack
            .background(Color.white)
            .frame(height: 88)
            .cornerRadiusCustom(30, corners: [.topLeft, .topRight])
            .applyShadowStyle()
            
            HStack(alignment: .top) {
                Spacer()
                
                Ellipse()
                    .frame(width: 100, height: 90)
                    .foregroundColor(Color.white)
                    .offset(y:-29)
                    .applyShadowStyle()
                
                Spacer()
            } // :HStack
            
            Button(action:{
                navigationManager.push(.camera)
            }){
                Circle()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.primary)
                    .overlay {
                        Image("plus")
                    }
            }
            .offset(y:-19)
            .background{
                Rectangle()
                    .frame(width: 140)
                    .foregroundColor(.white)
            }
            
        } // :ZStack
//        edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    CustomTabView()
        .environmentObject(NavigationManager())
}
