//
//  PresentationListView.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct PresentationListView: View {
    @StateObject var vm: PresentationListViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject private var modalManager: ModalManager
    
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
                                VStack(alignment: .leading, spacing: 8){
                                    if vm.takes.isEmpty {
                                        // 데이터가 없을 때 표시할 뷰
                                        Text("아직 연습 기록이 없어요.")
                                            .font(.pretendardMedium(size: 14))
                                            .foregroundColor(.textGray)
                                            .padding(.top, 20)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        ForEach(vm.takes, id: \.id) { take in
                                            practiceList(take: take) // 데이터 전달
                                        }
                                    }
                                } // :VStack
                            }
                        } // : ForEach
                        
                    } // : VStack
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    
                } // :ScrollView
            } // : VStack
            .background(Color.mainBackground.ignoresSafeArea())
            
            // MARK: 구현 보류
            // eidtor 및 alert overlay
//            if let option = vm.option {
//                overlayClearBg
//            }
            
            // 모달은 RootTabView에서 관리됨
        } // :ZStack
        .navigationBarBackButtonHidden(true)
        .onChange(of: vm.option) { _, newOption in
            switch newOption {
            case .editName:
                modalManager.showEditAlert(
                    onCancel: {
                        vm.option = nil
                    },
                    onConfirm: { newText in
                        vm.option = nil
                        print("확인됨, 입력된 값: \(newText)")
                    }
                )
            case .deleteAll:
                modalManager.showDeleteAlert(
                    onCancel: {
                        vm.option = nil
                    },
                    onDelete: {
                        vm.option = nil
                        print("삭제됨")
                    }
                )
            case .defalut, .none:
                break
            }
        } // : onChange
        .task {
            // 화면 진입 시 그래프 데이터와 리스트 데이터 모두 호출
            await vm.fetchGraphData()
            await vm.fetchTakesList()
        }
    }
    
    //MARK: - view
    private var header: some View {
        HStack(spacing:0){
            Button(action:{
                navigationManager.pop()
            }){
                Image("back")
            }
            .frame(height: 48)
            
            Spacer()
            
            Text("\(vm.ptTitle)")
                .font(.pretendardMedium(size: 18))
                .foregroundStyle(Color.black)
            
            Spacer()
//
            // MARK: 구현 보류, UI 위치 유지위해 안보이게만 처리
            VStack {
                Button(action:{
//                    vm.option = .defalut
                }){
                    Image("more")
                }
                .frame(height: 48)
            }
            .opacity(0)
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
                                Text("최근 \(vm.takes.count)개 데이터의 결과에요!")
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
            // ⭐️ [수정 3] 실제 데이터 개수 반영
            Text("\(vm.takes.count)번의 연습 횟수가 있어요")
                .font(.pretendardSemiBold(size: 20))
                .foregroundStyle(Color.textTitle)
            
            // MARK: 구현 보류
//            Spacer()
//            
//            Button(action: {
//                vm.showDeleteMode.toggle()
//            }){
//                HStack(spacing: 4){
//                    Image(vm.showDeleteMode ? "trash_on": "trash_off")
//                    Text("삭제하기")
//                        .foregroundStyle(vm.showDeleteMode ? Color.preeRed : Color.textGray)
//                        .font(.pretendardMedium(size: 14))
//                }
//                .padding(.vertical, 8)
//            }
        }// : HStack
        .padding(.bottom, 16)
    }
    
    private func practiceList(take: Take) -> some View {
        HStack(spacing: 0) {
            if vm.showDeleteMode {
                Button(action: {
                    // TODO: 삭제 선택 로직
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
                        // 순번 표시 (단순 인덱스라면 뷰모델에서 index를 넘겨주거나 해야 함. 여기선 takeNumber 사용)
                        Text("\(take.takeNumber)")
                            .foregroundStyle(Color.white)
                            .font(.pretendardMedium(size: 12))
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 12)
            }
            
            // ⭐️ 회차 정보 바인딩
            Text("\(take.takeNumber)번째 테이크")
                .foregroundColor(Color.textBlack)
                .font(.pretendardMedium(size:16))
                .padding(.trailing,4)
            
            // 날짜 정보
            Text(take.dateText)
                .foregroundColor(Color.textGray)
                .font(.pretendardMedium(size:14))
            
            Spacer()
            
            // 점수 정보
            SmallCircularProgressBarRepresentable(value: Double(take.totalScore) / 100.0)
                .frame(width: 60, height: 60)
            
        } // : HStack
        .frame(height: 60)
        .background(Color.white)
        .cornerRadiusCustom(20, corners: [.topLeft, .bottomLeft])
        .cornerRadiusCustom(35, corners: [.topRight, .bottomRight])
        .applyShadowStyle()
        .onTapGesture {
            // 상세 화면으로 이동
            navigationManager.push(.practiceResult(takeId: take.id))
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
