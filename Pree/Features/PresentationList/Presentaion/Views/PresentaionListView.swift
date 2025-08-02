//
//  PresentaionList.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct PresentaionListView: View {
    let vm2 = AppDI.shared.makePracticeResultViewModel()
    @StateObject var vm: PresentaionListViewModel
    
    @State var showPracticeResult: Bool = false
    @Binding var showPresentationList: Bool
    
    enum PtListMenu {
        case graph
        case deleteFilter
        case practiceList
    }
    
    private let menus: [PtListMenu] = [
        .graph,
        .deleteFilter,
        .practiceList
    ]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0){
                header
                    .padding(.horizontal, 16)
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 0){
                        
                        ForEach(menus, id:\.self){ menu in
                            switch menu {
                            case .graph:
                                graph
                            case .deleteFilter:
                                deleteFilter
                            case .practiceList:
                                ForEach(1...10, id:\.self){ _ in
                                    practiceList
                                }
                            }
                        } // : ForEach
                        
                    } // : VStack
                    .padding(.horizontal, 16)
                    .padding(.bottom, 300)
                    
                } // :ScrollView
            } // : VStack
            .background(Color.mainBackground.ignoresSafeArea())
            
            // eidtor 및 alert overlay
            if let option = vm.option {
                overlayClearBg
            }
            
            if let option = vm.option,
               option == .editName
            {
                EditAlertView(
                    onCancel: {
                        vm.option = nil
                    },
                    onConfirm: { newText in
                        vm.option = nil
                        print("확인됨, 입력된 값: \(newText)")
                    })
            }
            
            if let option = vm.option,
               option == .deleteAll
            {
                DeleteAlertView(
                    onCancel: {
                        vm.option = nil
                    },
                    onDelete: {
                        vm.option = nil
                        print("삭제됨")
                    },
                )
            }
        } // :ZStack
        .fullScreenCover(isPresented: $showPracticeResult) {
            PracticeResultView(vm: vm2, showPracticeResult: $showPracticeResult)
        }
    }
    
    //MARK: - view
    private var header: some View {
        HStack(spacing:0){
            Button(action:{
                showPresentationList.toggle()
            }){
                Image("back")
            }
            .frame(height: 48)
            
            Spacer()
            
            Text("\(vm.ptTitle)")
                .font(.pretendardMedium(size: 18))
                .foregroundStyle(Color.black)
            
            Spacer()
            
            VStack {
                Button(action:{
                    vm.option = .defalut
                }){
                    Image("more")
                }
                .frame(height: 48)
            }
            .background(Color.clear)
            .onTapGesture {
                // VStack 내부 클릭은 무시
            }
            
        } // : HStack
        .frame(height: 48)
        .padding(.bottom, 8)
    }
    
    private var graph: some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack(alignment: .top,spacing: 0){
                Text("나의 발표력 성장 곡선")
                    .lineLimit(1)
                    .font(.pretendardSemiBold(size: 20))
                    .foregroundStyle(Color.textTitle)
                
                Spacer()
                
                Rectangle()
                    .fill(Color.mainBackground)
                    .overlay {
                        Image("talk")
                            .offset(y:6)
                            .applyShadowStyle()
                            .overlay {
                                Text("최근 \(vm.practiceCount)개 데이터의 결과에요!")
                                    .font(.pretendardMedium(size: 12))
                                    .foregroundStyle(Color.primary)
                            }// : overlay
                    }// : overlay
                
            }// : HStack
            .padding(.bottom,16)
            
            LineChartRepresentable(scoreData: vm.scores)
                .frame(height: 224)
                .background(Color.white)
                .cornerRadius(20)
                .applyShadowStyle()
        } // : VStack
        .padding(.bottom, 40)
    }
    
    private var deleteFilter: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("\(vm.practiceCount)번의 연습 횟수가 있어요")
                .font(.pretendardSemiBold(size: 20))
                .foregroundStyle(Color.textTitle)
            
            Spacer()
            
            Button(action: {
                vm.showDeleteMode.toggle()
            }){
                HStack(spacing: 4){
                    Image(vm.showDeleteMode ? "trash_on": "trash_off")
                    Text("삭제하기")
                        .foregroundStyle(vm.showDeleteMode ? Color.preeRed : Color.textGray)
                        .font(.pretendardMedium(size: 14))
                }
                .padding(.vertical, 8)
            }
        }// : HStack
        .padding(.bottom, 16)
    }
    
    private var practiceList: some View {
        HStack(spacing: 0) {
            if vm.showDeleteMode {
                Button(action: {
                    
                }){
                    Image("select_off")
                        .padding(.leading, 16)
                        .padding(.trailing, 12)
                }
            } else {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Text("1")
                            .foregroundStyle(Color.white)
                            .font(.pretendardMedium(size: 12))
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
            }
            Text("1번째 테이크")
                .foregroundColor(Color.textBlack)
                .font(.pretendardMedium(size:16))
                .padding(.trailing,4)
            
            Text("2023. 12. 20")
                .foregroundColor(Color.textGray)
                .font(.pretendardMedium(size:14))
            
            Spacer()
            
            SmallCircularProgressBarRepresentable(value: 0.6)
                .frame(width: 60, height: 60)
            
        } // : HStack
        .frame(height: 60)
        .background(Color.white)
        .cornerRadiusCustom(20, corners: [.topLeft, .bottomLeft])
        .cornerRadiusCustom(35, corners: [.topRight, .bottomRight])
        .applyShadowStyle()
        .onTapGesture {
            showPracticeResult.toggle()
        }
    }
    
    // edit Mode
    private var overlayClearBg: some View {
        VStack(spacing:0){
            
            VStack(alignment: .leading, spacing:0){
                
                Button(action: {
                    //Todo: 이름 수정 기능 추가
                    vm.option = .editName
                }){
                    Text("이름 수정하기")
                        .foregroundColor(Color.black)
                        .font(.pretendardMedium(size: 17))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                }
                
                Divider()
                    .foregroundColor(Color.textGray)
                
                Button(action: {
                    //Todo: 연습파일 삭제 기능 추가
                    vm.option = .deleteAll
                }){
                    Text("연습 파일 삭제하기")
                        .foregroundColor(Color.black)
                        .font(.pretendardMedium(size: 17))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                }
                
            } // :VStack
            .background(Color.white)
            .frame(width: 260)
            .cornerRadius(15)
            .applyShadowStyle()
            .offset(x: 48, y:45)
            
            Spacer()
            
        } // :VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0))
        .contentShape(Rectangle()) // 터치 영역 감지
        .onTapGesture {
            vm.option = nil
        }
    }
    
}

#Preview {
    let vm = AppDI.shared.makePresnetationListViewModel()
    PresentaionListView(vm:vm, showPresentationList: .constant(false))
}
