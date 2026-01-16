//
//  PresentationListModalView.swift
//  Pree
//
//  Created by KimDogyung on 8/17/25.
//

import SwiftUI

struct PresentationListModalView: View {
    
    @EnvironmentObject var modalManager: ModalManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    // TODO: AppDI 로 인젝션
    @StateObject var vm: PresentationListModalViewModel = AppDI.shared.makePresentationListModalViewModel()
    
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            modalToolbar
                .padding(.top, 15)
                .appPadding()
            
            ScrollView() {
                
                ForEach(vm.presentations, id: \.id) { presentation in
                    
                    makePresentaionCard(presentation: presentation)
                        .padding(.top, 5)
                        .onTapGesture {
                            vm.selectedPresentaion = presentation
                            vm.validate()
                        }
                    
                }
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            PrimaryButton(
                title: "발표 영상 촬영하기",
                action: {
                    // modal 창 닫아주기
                    modalManager.hideModal()
                    
                    // 영상 촬영 화면으로 넘어감
//                    navigationManager.push(.camera())
                    // 모달이 완전히 닫힌 후 카메라를 띄우도록 약간의 딜레이
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            //TODO: 선택 된 발표 전달
                            if let selected = vm.selectedPresentaion {
                                navigationManager.push(.camera(presentation: selected))
                            }
                        }
                },
                isActive: vm.isValid
            )
            .appPadding()
            .safeAreaPadding(.bottom)
        }
        
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
            .appPadding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            Text("\(presentation.updatedAtText)일 전")
                .font(.pretendardMedium(size: 14))
                .foregroundStyle(Color.textGray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appPadding()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 17)
        .contentShape(Rectangle()) // 탭 가능한 영역을 사각형으로 명시적으로 정의
        .background(
            vm.selectedPresentaion?.id == presentation.id ? Color(hex:"#E6EDFF") : Color.clear
        )
        
    }
    
    
} // PresentationListModalView


//#Preview {
//    PresentationListModalView()
//        .environmentObject(ModalManager.shared)
//}
