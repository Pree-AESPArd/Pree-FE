//
//  ContentView.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var vm: HomeViewModel
    @State var showPresentationList: Bool = false
    
    
    enum HomeMenu {
        case avgScoreGraph
        case searchBarOff
        case filter
        case presentationList
    }
    
    private let menus: [HomeMenu] = [
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
                        case .searchBarOff:
                            searchBarOff
                        case .filter:
                            filter
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
            
            Image("search_off")
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
