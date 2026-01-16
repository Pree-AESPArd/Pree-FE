//
//  AddNewPresentationModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 8/22/25.
//

import SwiftUI
import FirebaseAuth

@MainActor
class AddNewPresentationModalViewModel: ObservableObject {
    //@Published var presentaion: Presentation
    
    @Published var titleText: String = ""
    @Published var minMinitue: String = "00"
    @Published var minSecond: String = "30"
    @Published var maxMinitue: String = "01"
    @Published var maxSecond: String = "00"
    @Published var showTimeOnScreen: Bool = false
    @Published var showMeOnScreen: Bool = false
    @Published var isDevMode: Bool = false
    
    @Published var textFieldError: String? = nil
    @Published var timeError: String? = nil
    @Published var isValid: Bool = false
    @Published var isLoading: Bool = false
    @Published var alert: AlertState? = nil
    
    private let createPresentationUsecase: CreatePresentationUseCase
    
    init(createPresentationUsecase: CreatePresentationUseCase) {
        self.createPresentationUsecase = createPresentationUsecase
    }
    
    
    func timeStringToInt() -> (minTime: Int, maxTime: Int)? {
        guard let minM = Int(minMinitue),
              let minS = Int(minSecond),
              let maxM = Int(maxMinitue),
              let maxS = Int(maxSecond) else {
            return nil // 하나라도 변환에 실패하면 nil 반환
        }
        
        let minTimeInt = (minM * 60) + minS
        let maxTimeInt = (maxM * 60) + maxS
        
        return (minTimeInt, maxTimeInt)
    }
    
    func validateTitleText() {
        textFieldError = nil
        
        // 비어있는지 먼저 확인
        guard !titleText.trimmingCharacters(in: .whitespaces).isEmpty else {
            textFieldError = "발표 제목을 입력해주세요."
            return
        }
        
        // 최대 글자 수를 확인
        if titleText.count > 15 {
            textFieldError = "최대 15자까지 입력할 수 있어요."
        }
    }
    
    func validateTimeText() {
        
        timeError = nil
        
        guard let (minTime, maxTime) = timeStringToInt() else {
            timeError = "유효한 숫자를 입력해주세요"
            return
        }
        
        if minTime >= maxTime {
            timeError = "최소시간은 최대시간을 넘을 수 없어요"
        }
        
        if minTime < 30 {
            timeError = "최소시간은 30초에요"
        }
        
        if maxTime > 60 {
            timeError = "최대 설정시간은 1분이에요"
        }
        
        
    }
    
    func validateForm() {
        validateTitleText()
        validateTimeText()
        
        isValid = textFieldError == nil && timeError == nil
    }
    
    func startRecording() async throws -> Presentation {
        
        validateForm()
        if let msg = textFieldError { throw AddPresentationError.invalidTitle(msg) }
        if let msg = timeError { throw AddPresentationError.invalidTime(msg) }
        
        guard let (minTime, maxTime) = timeStringToInt() else {
            throw AddPresentationError.invalidTime("유효한 숫자를 입력해주세요")
        }
        
        // 로그인 정보 가져오기
        guard let serverUUID = UserStorage.shared.getUUID() else {
            print("❌ 오류: 서버에서 발급받은 User UUID가 없습니다. (재로그인 필요)")
            textFieldError = "로그인 정보가 만료되었습니다. 앱을 재실행해주세요."
            throw AddPresentationError.createFailed("로그인 정보가 만료되었습니다. 앱을 재실행해주세요.")
        }
        
        print(isDevMode)
        // 발표 객체 생성
        let request: CreatePresentationRequest = .init(userId: serverUUID, name: titleText, idealMinTime: Double(minTime), idealMaxTime: Double(maxTime), showTimeOnScreen: showTimeOnScreen, showMeOnScreen: showMeOnScreen, isDevMode: isDevMode)
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let presentation = try await createPresentationUsecase.execute(request: request)
            print("응답 성공!!!!")
            print(presentation)
            return presentation
        } catch let error as AddPresentationError {
            alert = AlertState(
                title: "오류",
                message: error.localizedDescription
            )
            
            throw error
            
        } catch {
            alert = AlertState(
                title: "오류",
                message: "알 수 없는 오류가 발생했습니다."
            )
            throw AddPresentationError.createFailed("알 수 없는 오류가 발생했습니다.")
        }
        
    }
    
}


enum AddPresentationError: LocalizedError {
    case invalidTitle(String)
    case invalidTime(String)
    case createFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidTitle(let msg),
             .invalidTime(let msg),
             .createFailed(let msg):
            return msg
        }
    }
}
