//
//  AddNewPresentationModalView.swift
//  Pree
//
//  Created by KimDogyung on 8/17/25.
//

import SwiftUI
import Combine

struct AddNewPresentationModalView: View {
    @EnvironmentObject var modalManager: ModalManager
    @StateObject var vm: AddNewPresentationModalViewModel = AddNewPresentationModalViewModel()
    
    @State private var isMinTimeFieldPressed: Bool = false
    @State private var isMaxTimeFieldPressed: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    
    private enum Section {
        case textField
        case timeRange
        case options
    }
    
    private let sections: [Section] = [
        .textField,
        .timeRange,
        .options,
    ]
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            
            modalToolbar
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
            
            ForEach(sections, id: \.self) { section in
                switch section {
                case .textField:
                    textFeild
                        .padding(.top, 16)
                case .timeRange:
                    timeRangeSection
                        .padding(.top, 15)
                case .options:
                    optionSection
                        .padding(.top, 32.5)
                }
            }
            
            Spacer()
            
            PrimaryButton(title: "발표 영상 촬영하기", action: {}, isActive: false)
                .padding(.top, 32.5)
        }
        .appPadding()
        .padding(.bottom, keyboardHeight)
        // 키보드 높이가 변할 때마다 keyboardHeight 상태를 업데이트
        .onReceive(Publishers.keyboardHeight) { height in
            // 애니메이션과 함께 부드럽게 올라가도록 설정
            withAnimation {
                self.keyboardHeight = height
            }
        }
    } // View
    
    
    private var modalToolbar: some View {
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
    } // modalToolbar
    
    private var textFeild: some View {
        TextField(
            "",
            text: $vm.titleText,
            prompt: Text("발표이름을 입력해주세요")
                .font(.pretendardBold(size: 28))
                .foregroundStyle(Color.textGray)
        )
        
    }
    
    private var timeRangeSelector: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundStyle(Color.primary)
                .frame(width: 16, height: 16)
            
            Text("05:00")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.primary)
            
            Text("부터")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(
                    color: Color(hex: "#38508B").opacity(0.19),
                    radius: 15,
                    x: 0,
                    y: 0
                )
        )
    }
    
    private var minTimeField: some View {
        HStack(spacing: 0) {
            TextField(
                "",
                text: .constant(""),
            )
            .frame(width: 44, height: 36)
            .background(Color(hex: "#F0F1F2"))
            .cornerRadius(4)
            
            Spacer()
                .frame(width: 2)
            
            Text("분")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
            
            Spacer()
                .frame(width: 2)
            
            TextField(
                "",
                text: .constant(""),
            )
            .frame(width: 44, height: 36)
            .background(Color(hex: "#F0F1F2"))
            .cornerRadius(4)
            
            Spacer()
                .frame(width: 2)
            
            Text("초 부터")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
        }
    }
    
    private var maxTimeField: some View {
        HStack(spacing: 0) {
            TextField(
                "",
                text: .constant(""),
            )
            .frame(width: 44, height: 36)
            .background(Color(hex: "#F0F1F2"))
            .cornerRadius(4)
            
            Spacer()
                .frame(width: 2)
            
            Text("분")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
            
            Spacer()
                .frame(width: 2)
            
            TextField(
                "",
                text: .constant(""),
            )
            .frame(width: 44, height: 36)
            .background(Color(hex: "#F0F1F2"))
            .cornerRadius(4)
            
            Spacer()
                .frame(width: 2)
            
            Text("초 까지")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
        }
    }
    
    private var timeRangeSection: some View {
        VStack(spacing: 0) {
            Text("발표시간")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            HStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    Text("최소시간")
                        .font(.pretendardMedium(size: 14))
                        .foregroundStyle(Color.textGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    if isMinTimeFieldPressed {
                        minTimeField
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Button(
                            action: {
                                isMinTimeFieldPressed = true
                            },
                            label: {
                                timeRangeSelector
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                    }
                }
                
                
                
                
                VStack(spacing: 0) {
                    Text("최대시간")
                        .font(.pretendardMedium(size: 14))
                        .foregroundStyle(Color.textGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    if isMaxTimeFieldPressed {
                        maxTimeField
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Button(
                            action: {
                                isMaxTimeFieldPressed = true
                            },
                            label: {
                                timeRangeSelector
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            
            
        }
    }
    
    @State private var isOn = true
    private func makeOption(title: String) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textBlack)
            
            Spacer()
            
            Toggle("", isOn: $isOn )
                .toggleStyle(SwitchToggleStyle(tint: Color.primary))
            
        }
    }
    
    private var optionSection: some View {
        VStack(spacing: 32.5) {
            makeOption(title: "촬영 시간 보이게 하기")
            makeOption(title: "촬영 화면 보이게 하기")
            makeOption(title: "개발 모드")
        }
    }
    
    
} // AddNewPresentationModalView


#Preview {
    AddNewPresentationModalView(vm: AddNewPresentationModalViewModel())
        .environmentObject(ModalManager.shared)
}
