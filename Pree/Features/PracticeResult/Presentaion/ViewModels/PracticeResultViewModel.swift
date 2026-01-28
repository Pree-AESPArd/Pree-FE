//
//  PracticeResultViewModel.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import Foundation

@MainActor
final class PracticeResultViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var practiceTitle: String = "1번째 연습"
    @Published var option: MoreOption? = nil
    @Published var totalscore: Int = 88
    @Published var detailValues: [String: String] = [:]
    
    @Published var videoURL: URL? = nil       // 재생할 URL
    @Published var isVideoNotFound: Bool = false // "영상을 찾을 수 없음" 문구 표시용
    
    var itemNameList : [String] = ["발표 시간", "말의 빠르기", "목소리 크기", "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리"]
    var progressScores: [Int] = [0, 0, 0, 0, 0, 0]
    
    
    private let getTakeResultUseCase: GetTakeResultUseCaseProtocol
    private let takeId: String
    
    init(takeId: String, getTakeResultUseCase: GetTakeResultUseCaseProtocol) {
        self.takeId = takeId
        self.getTakeResultUseCase = getTakeResultUseCase
    }
    
    func fetchResult() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await getTakeResultUseCase.execute(takeId: takeId)
            
            // 데이터 바인딩
            self.practiceTitle = "\(result.takeInfo.takeNumber)번째 연습"
            self.totalscore = result.analysis.totalScore
            
            let myDuration = 120 // 예시: 실제 duration 값 필요
            let myWPM = String(result.analysis.wpm)
            let myDb = String(result.analysis.decibelAvg)
            let fillerCount = "\(result.analysis.fillerWordCount)회"
            let silenceCount = "0회" // 예시: silenceCount가 API에 있다면 사용
            let eyeRate = "\(result.analysis.eyeTrackingScore)%" // 시선 처리 비율 (점수와 동일하다면)
            
            // 각 항목별 점수 매핑 (순서 중요: itemNameList와 일치해야 함)
            // 1. 발표 시간 (durationScore)
            // 2. 말의 빠르기 (wpmScore)
            // 3. 목소리 크기 (dbScore)
            // 4. 발화 지연 (fillerScore)
            // 5. 공백 (silenceScore)
            // 6. 시선 처리 (eyeTrackingScore)
            self.progressScores = [
                result.analysis.durationScore,
                result.analysis.wpmScore,
                result.analysis.dbScore,
                result.analysis.fillerScore,
                result.analysis.silenceScore,
                result.analysis.eyeTrackingScore
            ]
            
            await loadGalleryVideo(videoKey: result.takeInfo.videoKey)
            
            
            
        } catch {
            print("❌ 결과 로드 실패: \(error)")
            // 에러 처리 (Alert 등)
        }
    }
    
    private func loadGalleryVideo(videoKey: String) async {
        do {
            // 서비스에게 요청
            let url = try await VideoResourceService.shared.fetchVideoURL(from: videoKey)
            self.videoURL = url
            self.isVideoNotFound = false
        } catch {
            // 에러 발생 시 (영상이 폰에 없음)
            self.videoURL = nil
            self.isVideoNotFound = true
        }
    }
}
