//
//  PracticeResult.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI
import AVKit

struct PracticeResultView: View {
    @StateObject var vm: PracticeResultViewModel
    @StateObject private var playerVM = VideoPlayerViewModel()
    @State var showModalView: Bool = false
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject private var modalManager: ModalManager
    
    var body: some View {
        mainContent
            .navigationBarBackButtonHidden(true)
            .onChange(of: showModalView) { newValue in
                if newValue {
                    modalManager.showStandardModal()
                }
            } // : onChange
            .onChange(of: vm.option) { newOption in
                handleOptionChange(newOption)
            } // : onChange
            .task {
                await vm.fetchResult()
            }
            .onChange(of: vm.videoURL) { _, newURL in
                if let url = newURL {
                    playerVM.playVideo(from: url)
                }
            }
            // 화면 나가면 재생 정지
            .onDisappear {
                playerVM.cleanup()
            }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, 16)
                
                videoPlayerSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                
                totalScore
                    .padding(.horizontal, 16)
                
                scrollContent
            } // : VStack
            .background(Color.mainBackground.ignoresSafeArea())
            
            // eidtor 및 alert overlay
//            if let option = vm.option {
//                overlayClearBg
//            }
            
        } // : ZStack
    }
    
    // MARK: - Scroll Content
    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(vm.itemNameList.enumerated()), id: \.offset) { index, item in
                    ExpandableReportItemView(
                        item: item,
                        progressScore: vm.progressScores[index],
                        index: index,
                        detailValue: vm.detailValues[item] ?? "-"
                    )
                } // :ForEach
                
                evaluationCriteria
                
            } // : VStack
            .padding(.top, 20)
            .padding(.bottom, 30)
        } // : ScrollView
    }
    
    // MARK: - Option Handler
    private func handleOptionChange(_ newOption: MoreOption?) {
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
    }
    
    //MARK: - view
    private var header: some View {
        HStack(spacing: 0) {
            Button(action: {
                navigationManager.pop()
            }) {
                Image("back")
            }
            .frame(height: 48)
            
            Spacer()
            
            Text("\(vm.practiceTitle)")
                .font(.pretendardMedium(size: 18))
                .foregroundStyle(Color.black)
            
            Spacer()
            
            // MARK: 구현 보류: 안보이게만 처리
            VStack {
                Button(action: {
//                    vm.option = .defalut
                }) {
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
    } // : header
    
    @ViewBuilder
    private var videoPlayerSection: some View {
        if vm.isVideoNotFound {
            // Case 1: 갤러리에 영상이 없을 때 (에러 화면)
            videoNotFoundView
        } else {
            // Case 2: 로딩 중이거나 재생 중일 때 -> VideoPlayerView 사용
            // playerVM을 전달하여 내부에서 상태에 따라 로딩/재생 처리
            VideoPlayerView(viewModel: playerVM)
        }
    }
    
    private var videoNotFoundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20) // VideoPlayerView와 radius 맞춤
                .fill(Color.gray.opacity(0.1))
            
            VStack(spacing: 8) {
                Image(systemName: "video.slash")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                Text("원본 영상을 갤러리에서 찾을 수 없습니다.")
                    .font(.pretendardMedium(size: 14))
                    .foregroundColor(.textGray)
            }
        }
        .frame(height: 225) // VideoPlayerView와 높이 맞춤
    }
    
    private var totalScore: some View {
        HStack(spacing: 0) {
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
                .background(Color(colorForScore(Double(vm.totalscore))))
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
            }) {
                Text("평가 기준 보러가기 >")
                    .foregroundColor(Color.primary)
                    .font(.pretendardMedium(size: 14))
            } // : Button
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        } // :HStack
        .padding(.bottom, 30)
    }
    
    // edit Mode
    private var overlayClearBg: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: 이름 수정 기능 보류
//                Button(action: {
//                    //Todo: 이름 수정 기능 추가
//                    vm.option = .editName
//                }){
//                    Text("이름 수정하기")
//                        .foregroundColor(Color.black)
//                        .font(.pretendardMedium(size: 17))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 13)
//                }
//
//                Divider()
//                    .foregroundColor(Color.textGray)
                
                Button(action: {
                    //Todo: 연습파일 삭제 기능 추가
                    vm.option = .deleteAll
                }) {
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
            .offset(x: 48, y: 45)
            
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

//#Preview {
//    let vm = AppDI.shared.makePracticeResultViewModel()
//    PracticeResultView(vm:vm)
//        .environmentObject(NavigationManager())
//}
