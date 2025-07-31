//
//  ContentView.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                //MARK: - header
                HStack(spacing: 0){
                    Image("LOGO")
                        .padding(.vertical, 12.62)
                    
                    Spacer()
                }
                
                //MARK: - summary graph - if 가로모드 지원, 수정 필요
                Text("\(vm.userName)님, 오늘도 \n프리와 함께 발표준비해요!")
                    .foregroundStyle(Color.textTitle)
                    .font(.pretendardBold(size: 28))
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                
                VStack(alignment: .leading,spacing:0){
                    Text("최근 \(vm.prarticeListCount)개 발표의 평균 점수 그래프")
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
                
                //MARK: - searchBar
                HStack(spacing: 0){
                    Text("\(vm.prarticeListCount)개의 발표 연습 목록이 있어요")
                        .foregroundStyle(Color.textTitle)
                        .font(.pretendardSemiBold(size: 20))
                    
                    Spacer()
                    
                    Image("search_off")
                }
                .padding(.bottom, 16)
                
                //MARK: - practice List filter
                HStack(spacing:0){
                    Button(action: {}){
                        HStack(spacing: 4){
                            Image("recent_off")
                            Text("최신순")
                                .foregroundStyle(Color.primary)
                                .font(.pretendardMedium(size: 12))
                        }
                        .padding(8)
                        .background(Color.sectionBackground)
                        .cornerRadius(20)
                        .applyShadowStyle()
                    }
                    .padding(.trailing, 4)
                    
                    
                    Button(action: {}){
                        HStack(spacing: 4){
                            Image("star_blue_off")
                            Text("즐겨찾기")
                                .foregroundStyle(Color.primary)
                                .font(.pretendardMedium(size: 12))
                        }
                        .padding(8)
                        .background(Color.sectionBackground)
                        .cornerRadius(20)
                        .applyShadowStyle()
                    }
                    
                    Spacer()
                    
                    Button(action: {}){
                        HStack(spacing: 4){
                            Image("trash_off")
                            Text("삭제하기")
                                .foregroundStyle(Color.textGray)
                                .font(.pretendardMedium(size: 14))
                        }
                        .padding(.vertical, 8)
                    }
                    
                } // : HStack
                .padding(.bottom, 12)
                
                //MARK: - practice List
                ZStack(alignment: .trailing){
                    HStack(alignment: .top,spacing:0){
                        
                        Button(action: {}){
                            Image("star_yello_off")
                                .padding(.vertical, 32)
                                .padding(.horizontal, 12)
                        }
                        .padding(.leading, 4)
                        
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
                    .cornerRadius(20, corners: [.topLeft, .bottomLeft])
                    .cornerRadius(35, corners: [.topRight, .bottomRight]) 
                    .applyShadowStyle()
                    
                    
                    CircularProgressBarView(value: vm.score)
                        .frame(width: 80, height: 80)
                } // : ZStack
                
                Spacer()
            } // : VStack
            .padding(.horizontal, 16)
        } // : ScrollView
        .background(Color.mainBackground.ignoresSafeArea())
    }
}

#Preview {
    let vm = AppDI.shared.makeHomewViewModel()
    HomeView(vm:vm)
}
