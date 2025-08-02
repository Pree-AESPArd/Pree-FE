//
//  PracticeResult.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct PracticeResultView: View {
    @StateObject var vm: PracticeResultViewModel
    @Binding var showPracticeResult: Bool
    @State var showModalView: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading,spacing:0){
                header
                    .padding(.horizontal, 16)
                
                videoPlayerView
                    .padding(.horizontal, 16)
                
                totalScore
                    .padding(.horizontal, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading,spacing:8){
                        
                        ForEach(Array(vm.itemNameList.enumerated()), id:\.offset){ index, item in
                            ExpandableReportItemView(
                                item: item,
                                progressScore: vm.progressScores[index],
                                index: index
                            )
                        } // :ForEach
                        
                        evaluationCriteria
                        
                    } // : VStack
                    .padding(.top, 20)
                    .padding(.bottom, 300)
                }// : ScrollView
            }// : VStack
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
            
            if showModalView {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                standardModalView(showModalView: $showModalView)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(1) // zIndex가 0인 경우 사라지는 애니메이션 적용이 안됨
            } // if
            
        }// : ZStack
    }
    
    //MARK: - view
    private var header: some View {
        HStack(spacing:0){
            Button(action:{
                showPracticeResult.toggle()
            }){
                Image("back")
            }
            .frame(height: 48)
            
            Spacer()
            
            Text("\(vm.practiceTitle)")
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
    } // : header
    
    private var videoPlayerView: some View {
        Rectangle()
            .frame(height: 225)
            .cornerRadius(20)
            .padding(.bottom, 25)
    }
    
    
    private var totalScore: some View {
        HStack(spacing:0){
            Text("총 점수")
                .foregroundColor(Color.textTitle)
                .font(.pretendardSemiBold(size: 20))
                .applyShadowStyle()
            
            Spacer()
            
            Text("\(Int(vm.totalscore))점")
                .foregroundColor(Color.white)
                .font(.pretendardBold(size: 24))
                .padding(.vertical, 5.5)
                .padding(.horizontal, 8)
                .background(Color(colorForScore(vm.totalscore/100)))
                .cornerRadius(20)
                .applyShadowStyle()
            
        } // : HStack
    }
    
    private var evaluationCriteria: some View {
        HStack(alignment: .top) {
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showModalView = true
                }
            }){
                Text("평가 기준 보러가기 >")
                    .foregroundColor(Color.primary)
                    .font(.pretendardMedium(size: 14))
            } // : Button
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        } // :HStack
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
    } // : overlayClearBg
    
}

#Preview {
    let vm = AppDI.shared.makePracticeResultViewModel()
    PracticeResultView(vm:vm, showPracticeResult: .constant(false))
}
