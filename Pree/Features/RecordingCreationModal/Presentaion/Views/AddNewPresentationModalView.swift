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
    @EnvironmentObject var navigationManager: NavigationManager
    
    @StateObject var vm: AddNewPresentationModalViewModel = AppDI.shared.makeAddNewPresentationModalViewModel()
    
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
                .appPadding()
            
            ScrollView {
                
                ForEach(sections, id: \.self) { section in
                    switch section {
                    case .textField:
                        textFeild
                            .padding(.top, 16)
                            .appPadding()
                    case .timeRange:
                        timeRangeSection
                            .padding(.top, 15)
                    case .options:
                        optionSection
                            .padding(.top, 9)
                        
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            Spacer()
            
            PrimaryButton(
                title: vm.isLoading ? "발표 생성 중..." :"발표 영상 촬영하기",
                action: {
                    
                    Task {
                        
                        do {
                            let presentation = try await vm.startRecording()
                            modalManager.hideModal()
                            navigationManager.push(.camera(presentation: presentation))
                        } catch {
                            // VM에서 alert 띄우라고 신호 보냄
                        }
                    }
                    
                },
                isActive: vm.isValid && !vm.isLoading
            )
            .safeAreaPadding(.bottom)
            .appPadding()
        }
        .alert(item: $vm.alert) { (alert: AlertState) in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("확인"))
            )
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
        VStack(spacing: 6) {
            TextField(
                "",
                text: $vm.titleText,
                prompt: Text("발표이름을 입력해주세요")
                    .font(.pretendardBold(size: 28))
                    .foregroundStyle(Color.textGray)
            )
            .onChange(of: vm.titleText) { oldValue, newValue in
                //                if newValue.count > charLimit {
                //                    textInput = String(newValue.prefix(charLimit))
                //                }
                //vm.validateTitleText()
                vm.validateForm()
            }
            
            if let message = vm.textFieldError {
                Text(message)
                    .font(.pretendardMedium(size: 12))
                    .foregroundStyle(Color.preeRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        
    }
    
    enum TimeType {
        case from
        case to
    }
    
    private func timeRangeSelector(min: String, sec: String, type: TimeType) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundStyle(Color.primary)
                .frame(width: 16, height: 16)
            
            Text("\(min):\(sec)")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.primary)
            
            Text(type == .from ? "부터" : "까지")
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
    
    
    private func timeTextField(text: Binding<String>) -> some View {
        TextField(
            "",
            text: text,
        )
        .multilineTextAlignment(.center)
        .keyboardType(.numberPad)
        .frame(width: 44, height: 36)
        .background(Color(hex: "#F0F1F2"))
        .cornerRadius(4)
    }
    
    private var minTimeField: some View {
        HStack(spacing: 0) {
            
            timeTextField(text: $vm.minMinitue)
                .onChange(of: vm.minMinitue) {
                    vm.validateForm()
                }
            
            Spacer()
                .frame(width: 2)
            
            Text("분")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
            
            Spacer()
                .frame(width: 2)
            
            timeTextField(text: $vm.minSecond)
                .onChange(of: vm.minSecond) {
                    vm.validateForm()
                }
            
            Spacer()
                .frame(width: 2)
            
            Text("초 부터")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
        }
    }
    
    private var maxTimeField: some View {
        HStack(spacing: 0) {
            
            timeTextField(text: $vm.maxMinitue)
                .onChange(of: vm.maxMinitue) {
                    vm.validateForm()
                }
            
            Spacer()
                .frame(width: 2)
            
            Text("분")
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textGray)
            
            Spacer()
                .frame(width: 2)
            
            timeTextField(text: $vm.maxSecond)
                .onChange(of: vm.maxSecond) {
                    vm.validateForm()
                }
            
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
                                timeRangeSelector(min: vm.minMinitue, sec: vm.minSecond, type: .from)
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
                                timeRangeSelector(min: vm.maxMinitue, sec: vm.maxSecond, type: .to)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            
            if let errorMessage = vm.timeError {
                Text(errorMessage)
                    .font(.pretendardMedium(size: 12))
                    .foregroundStyle(Color.preeRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 9)
            }
        }
        .appPadding()
    }
    
    
    private func makeOption(title: String, isOn value: Binding<Bool>) -> some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.pretendardMedium(size: 16))
                .foregroundStyle(Color.textBlack)
            
            Spacer()
            
            Toggle("", isOn: value )
                .toggleStyle(SwitchToggleStyle(tint: Color.primary))
            
        }
    }
    
    private var optionSection: some View {
        VStack(spacing: 32.5) {
            makeOption(title: "촬영 시간 보이게 하기", isOn: $vm.showTimeOnScreen)
            makeOption(title: "촬영 화면 보이게 하기", isOn: $vm.showMeOnScreen)
            makeOption(title: "개발 모드", isOn: $vm.isDevMode)
        }
        .appPadding()
    }
    
    
} // AddNewPresentationModalView


//#Preview {
//    AddNewPresentationModalView(vm: AddNewPresentationModalViewModel())
//        .environmentObject(ModalManager.shared)
//}
