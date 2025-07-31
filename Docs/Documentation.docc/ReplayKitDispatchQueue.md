#  ``ReplayKitDispatchQueue``

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

DispatchQueue를 쓴 핵심 이유는 AVAssetWriter와 그 입력(AVAssetWriterInput)에 대한 모든 작업을 “한 줄로” 순차적으로 보장해서, 다음 두 가지 문제를 모두 해결하기 위함입니다.

    1.    Race Condition 방지
        •    ReplayKit은 비디오 버퍼(.video)와 마이크 버퍼(.audioMic)를 서로 다른 스레드(콜백)에서 섞어서 보냅니다.
        •    만약 startWriting()/startSession(atSourceTime:) 호출과 append(sampleBuffer) 호출이 서로 다른 스레드에서 동시다발적으로 일어나면, 두 번째 세션 시작 시도가 첫 번째를 덮어쓰거나 append 직전 세션이 열리지 않는 타이밍이 생겨서 충돌(crash)이 발생할 수 있습니다.
        •    Serial Queue를 쓰면, 모든 쓰기 관련 로직(세션 시작, append, 마무리)이 큐에 차례차례 들어와 순서대로 실행돼 안전해집니다.

    2.    CMSampleBuffer 수명 보장 및 동기적 처리
        •    ReplayKit의 콜백 블록 이후에 sampleBuffer 메모리가 해제될 수 있는데, 비동기(.async)로 넘겨버리면 append 시점에 버퍼가 이미 날아가 버려 “빈 오디오”가 녹음되거나 심지어 크래시가 날 수도 있습니다.
        •    .sync 방식으로 큐에 넣으면, 핸들러 블록이 끝나기 전에 반드시 append가 완료되어, 버퍼가 안전하게 AVAssetWriter로 넘어갑니다.

정리하자면, writeQueue를 도입함으로써:
    •    동시성 이슈 없이 비디오·오디오 샘플을 순차적으로 처리
    •    CMSampleBuffer의 안전한 수명 관리
    •    AVAssetWriter에게 예측 가능한, 일관된 인터페이스 제공
