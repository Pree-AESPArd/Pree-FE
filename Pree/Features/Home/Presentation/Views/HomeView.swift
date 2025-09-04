//
//  ContentView.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI

enum HomeMenu: Hashable, Identifiable {
    case avgScoreGraph
    case searchBarOff
    case filter
    case presentationList
    case searchBarOn
    
    var id: String {
        String(describing: self)
    }
}

struct HomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var modalManager: ModalManager
    @StateObject var vm: HomeViewModel
    @State var showPresentationList: Bool = false
    
    @State private var isSearchBarExpanded = false
    @State private var searchText = ""
    
    @State private var menus: [HomeMenu] = [
        .avgScoreGraph,
        .searchBarOff,
        .filter,
        .presentationList
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            header
                .padding(.horizontal, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    ForEach(menus, id:\.self){ menu in
                        switch menu {
                        case .avgScoreGraph:
                            avgScoreGraph
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                            
                        case .searchBarOff:
                            searchBarOff
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                            
                        case .searchBarOn:
                            SearchBarView(
                                searchText: $searchText,
                                isExpanded: $isSearchBarExpanded)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                            
                        case .filter:
                            filter
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        case .presentationList:
                            VStack(alignment: .leading, spacing: 8){
                                ForEach(1...10, id:\.self){ _ in
                                    presentationList
                                }
                            } // :VStack
                        }
                    } // ForEach
                    
                    Spacer()
                } // : VStack
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            } // : ScrollView
        }// : VStack
        .background(Color.mainBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onChange(of: isSearchBarExpanded) { newValue in
            if !newValue {
                // 검색바가 닫힐 때 메뉴 상태 복원
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        menus.removeAll { $0 == .searchBarOn }
                        menus.insert(.avgScoreGraph, at: 0)
                        menus.insert(.searchBarOff, at: 1)
                        menus.insert(.filter, at: 2)
                    }
                }
            }
        }
        .sheet(isPresented: $modalManager.isShowingModal){
            if case .recordingCreationModal = modalManager.currentModal {
                PresentationListModalView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        
    }
    
    //MARK: - view
    
    private var header: some View {
        HStack(spacing: 0){
            Image("LOGO")
                .padding(.vertical, 12.62)
            
            Spacer()
        }
    }
    
    private var avgScoreGraph: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("\(vm.userName)님, 오늘도 \n프리와 함께 발표준비해요!")
                .foregroundStyle(Color.textTitle)
                .font(.pretendardBold(size: 28))
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            VStack(alignment: .leading,spacing:0){
                Text("최근 \(vm.presentationListCount)개 발표의 평균 점수 그래프")
                    .foregroundStyle(Color.black)
                    .font(.pretendardMedium(size: 16))
                    .padding(.top, 16)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0){
                    Spacer()
                    
                    BarGraphViewRepresentable(percentages: vm.percentagesZero)
                        .padding(.bottom, 12)
                    
                    Spacer()
                } // : HStack
            } // : VStack
            .frame(height: 224)
            .padding(.horizontal, 22)
            .background(Color.sectionBackground)
            .cornerRadius(20)
            .applyShadowStyle()
            .padding(.bottom, 40)
        }
    }
    
    private var searchBarOff: some View {
        HStack(spacing: 0){
            Text("\(vm.presentationListCount)개의 발표 연습 목록이 있어요")
                .foregroundStyle(Color.textTitle)
                .font(.pretendardSemiBold(size: 20))
            
            Spacer()
            
            Button(action:{
                withAnimation(.easeInOut(duration: 0.3)) {
                    menus.removeAll { $0 == .avgScoreGraph || $0 == .filter || $0 == .searchBarOff }
                    menus.insert(.searchBarOn, at: 0)
                }
                
                // 검색바가 완전히 나타난 후에 확장 상태 활성화
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isSearchBarExpanded = true
                    }
                }
            }){
                Image("search_off")
            }
        }
        .padding(.bottom, 16)
    }
    
    private var filter: some View {
        HStack(spacing:0){
            Button(action: {
                vm.showDeleteMode = false
                vm.filterMode = .recentMode
            }){
                HStack(spacing: 4){
                    Image(vm.filterMode == FilterMode.recentMode ? "recent_on" : "recent_off")
                    Text("최신순")
                        .foregroundStyle(vm.filterMode == FilterMode.recentMode ? Color.primary : Color.textGray)
                        .font(.pretendardMedium(size: 12))
                }
                .padding(8)
                .background(Color.sectionBackground)
                .cornerRadius(20)
                .applyShadowStyle()
            }
            .padding(.trailing, 4)
            
            
            Button(action: {
                vm.showDeleteMode = false
                vm.filterMode = .bookmarkMode
            }){
                HStack(spacing: 4){
                    Image(vm.filterMode == FilterMode.bookmarkMode ? "star_blue_on" : "star_blue_off")
                    Text("즐겨찾기")
                        .foregroundStyle(vm.filterMode == FilterMode.bookmarkMode ? Color.primary : Color.textGray)
                        .font(.pretendardMedium(size: 12))
                }
                .padding(8)
                .background(Color.sectionBackground)
                .cornerRadius(20)
                .applyShadowStyle()
            }
            
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
            
        } // : HStack
        .padding(.bottom, 12)
    }
    
    private var presentationList: some View {
        ZStack(alignment: .trailing){
            HStack(alignment: .top,spacing:0){
                
                if vm.showDeleteMode {
                    Button(action: {
                        
                    }){
                        Image("select_off")
                            .padding(.vertical, 30)
                            .padding(.horizontal, 12)
                    }
                    .padding(.leading, 4)
                } else {
                    Button(action: {
                        
                    }){
                        Image("star_yello_off")
                            .padding(.vertical, 30)
                            .padding(.horizontal, 12)
                    }
                    .padding(.leading, 4)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        
                        Text("협업체험학습 발표")
                            .foregroundStyle(Color.black)
                            .font(.pretendardMedium(size: 16))
                        
                        VStack(spacing:0){
                            Text("4개")
                                .font(.pretendardMedium(size: 12))
                                .foregroundStyle(Color.blue200)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue200, lineWidth: 1)
                                )
                        }
                    } // : HStack
                    .padding(.top, 21.5)
                    .padding(.bottom, 2)
                    
                    Text("1일 전")
                        .font(.pretendardMedium(size: 14))
                        .foregroundStyle(Color.textGray)
                } // : VStack
                
                Spacer()
            }// : HStack
            .background(Color.sectionBackground)
            .cornerRadiusCustom(20, corners: [.topLeft, .bottomLeft])
            .cornerRadiusCustom(35, corners: [.topRight, .bottomRight])
            .applyShadowStyle()
            
            
            CircularProgressBarView(value: vm.score)
                .frame(width: 80, height: 80)
        } // : ZStack
        .onTapGesture {
            navigationManager.push(.presentationList)
        }
    }
}

#Preview {
    let vm = AppDI.shared.makeHomeViewModel()
    HomeView(vm:vm)
        .environmentObject(NavigationManager())
}
