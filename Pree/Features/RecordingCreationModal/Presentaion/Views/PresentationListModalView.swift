//
//  PresentationListModalView.swift
//  Pree
//
//  Created by KimDogyung on 8/17/25.
//

import SwiftUI

struct PresentationListModalView: View {
    
    @EnvironmentObject var modalManager: ModalManager
    
    
    
    var body: some View {
        
        // 모달이 화면의 50% 차지하도록 GeometryReader 사용
        GeometryReader { geo in
            
            VStack {
                // VStack과 Spacer를 이용해서 모달이 화면 하단에 고정되도록 밀어냄
                // GeometryReader는 그 안에 있는 콘텐츠를 기본적으로 상단에 배치
                Spacer()
                
                VStack(spacing: 0) {
                    
                    dragBar
                        .padding(.top, 5)
                    
                    
                    modalToolbar
                        .padding(.top, 15)
                    
                    presentaionSection
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    PrimaryButton(title: "발표 영상 촬영하기", action: {}, isActive: false)
                }
                .appPadding()
                .safeAreaPadding(.bottom)
                .padding(.bottom, 21)
                .background(.white)
                .cornerRadius(20)
                .frame(height: geo.size.height * 0.5)
            }
        }
    } // View
    
    
    private var dragBar: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(hex: "#F0F1F2"))
            .frame(width: 36, height: 5)
    }
    
    private var modalToolbar: some View {
        HStack() {
            Button(
                action: {
                    modalManager.hideModal()
                },
                label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.black)
                        .frame(width: 24, height: 24)
                }
            )
            
            Spacer()
            
            Button(
                action: {
                    modalManager.showAddNewPresentationModal()
                },
                label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.primary)
                            .fontWeight(.semibold)
                            .frame(width: 16, height:16)
                        Text("새로 추가하기")
                            .foregroundStyle(Color.primary)
                            .font(.pretendardMedium(size: 14))
                    }
                }
            )
        }
    } // modalToolbar
    
    
    private var numberTag: some View {
        ZStack {
            
            Text("4개")
                .font(.pretendardMedium(size: 12))
                .foregroundStyle(Color.blue200)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.blue200,lineWidth: 1)
                .frame(width: 30, height: 18)
        }
    } // numberTag
    
    private var presentaionSection: some View {
        VStack(spacing: 2) {
            
            HStack(spacing: 4) {
                Text("프리 테스트")
                numberTag
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            Text("1일 전")
                .font(.pretendardMedium(size: 14))
                .foregroundStyle(Color.textGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 17)
    } // presentaionSection
    
    
} // PresentationListModalView


#Preview {
    PresentationListModalView()
        .environmentObject(ModalManager.shared)
}
