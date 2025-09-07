//
//  PresentationListModalView.swift
//  Pree
//
//  Created by KimDogyung on 8/17/25.
//

import SwiftUI

struct PresentationListModalView: View {
    
    @EnvironmentObject var modalManager: ModalManager
    let presentations: [Presentation]
    
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            modalToolbar
                .padding(.top, 15)
            
            ScrollView() {
                
                ForEach(presentations, id: \.presentationId) { presentation in
                    makePresentaionCard(presentation: presentation)
                        .padding(.top, 5)
                }
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            PrimaryButton(title: "발표 영상 촬영하기", action: {}, isActive: false)
                .safeAreaPadding(.bottom)
        }
        .appPadding()
    } // View
    
    
    
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
    
    
    
    private func makePresentaionCard(presentation: Presentation) -> some View {
        VStack(spacing: 2) {
            
            HStack(spacing: 4) {
                Text(presentation.presentationName)
            
                // number tag
                ZStack {
                    
                    Text("\(presentation.totalPractices) 개")
                        .font(.pretendardMedium(size: 12))
                        .foregroundStyle(Color.blue200)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue200,lineWidth: 1)
                        .frame(width: 30, height: 18)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            Text("\(presentation.updatedAtText)일 전")
                .font(.pretendardMedium(size: 14))
                .foregroundStyle(Color.textGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 17)
    }
    
    
} // PresentationListModalView


//#Preview {
//    PresentationListModalView()
//        .environmentObject(ModalManager.shared)
//}
