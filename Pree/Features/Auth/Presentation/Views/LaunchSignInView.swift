//
//  LaunchView.swift
//  Pree
//
//  Created by KimDogyung on 7/25/25.
//

import SwiftUI
import AuthenticationServices

struct LaunchSignInView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var navigationManager = NavigationManager()
    @State private var isAnimating = false  // 첫 시작 아이콘 애니메이션 플래그
    @State private var showText = false // 텍스트 애니메이션 플래그
    @State private var showSignIn = false
    
    
    // TODO: 세부 디자인 간격 맞추기
    
    var body: some View {
        ZStack(){
            
            // 배경 색상
            Color(Color.primary)
                .ignoresSafeArea()
            
            Image("pree_icon_top")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 46.46, height: 76.26)
            // shoText가 켜지면 로테이션을 해야하는데 각도를 틀면 위 아래 이미지 간격이 안맞아서 추가로 x 방향으로 움직여서 간격 맞춰줌
                .offset(x: isAnimating ? (showText ? -33 : -23.2) : 0 ,
                        // isAnimating이 켜지면 일단 튕겨 들어와서 -12에 위치하고,
                        // showText가 켜지면 추가로 위로 50pt 밀어 올립니다.
                        y: isAnimating ? (showText ? -62 : -12) : -UIScreen.main.bounds.height
                )
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8),
                    value: isAnimating // 시작 애니메이션
                )
                .rotationEffect(.degrees(showText ? 45 : 0), anchor: .top) // 각도 틀기
                .animation(.spring(response: 0.9, dampingFraction: 0.9),
                           value: showText) // 텍스트 애니메이션 시작할때, 위치를 위로 올릴때 애니메이션 추가
            
            Image("pree_icon_bottom")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 31.08, height: 89.64)
            // shoText가 켜지면 로테이션을 해야하는데 각도를 틀면 위 아래 이미지 간격이 안맞아서 추가로 x 방향으로 움직여서 간격 맞춰줌
                .offset(x: isAnimating ? (showText ? 18 : 23.2) : 0 ,
                        y: isAnimating ? (showText ? -38 : 12) : UIScreen.main.bounds.height
                )
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8),
                    value: isAnimating
                )
                .rotationEffect(.degrees(showText ? 45 : 0), anchor: .top)
                .animation(.spring(response: 0.9, dampingFraction: 0.9),
                           value: showText)
            
            Image("pree_launch_text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 106.74, height: 39.39)
                .offset(y: showText ? 50 : 60)
                .opacity(showText ? 1 : 0)
            // fade in과 위로 올라오는 애니메이션 두가지 동시에 구현
                .animation(
                    .spring(response: 0.9, dampingFraction: 0.9),
                    value: showText
                )
                .animation(
                    .easeIn(duration: 0.4),
                    value: showText
                )
            
            
            VStack {
                Spacer()
                
                if showSignIn {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        // 로그인 결과 처리
                        // TODO: 로그인 로직 구현
                        authVM.isSignedIn = true
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .transition(.opacity)
                    
                }
            }
            
        }
        .onAppear(){
            // 1) 바로 아이콘 튕겨오기
            isAnimating = true
            // 2) 0.7초 뒤에 텍스트도 페이드인 + 아이콘 추가 위치 보정
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showText = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showSignIn = true
                }
                
            }
            
        }
    }
}




#Preview {
    LaunchSignInView()
        .environmentObject(AuthViewModel())
}

