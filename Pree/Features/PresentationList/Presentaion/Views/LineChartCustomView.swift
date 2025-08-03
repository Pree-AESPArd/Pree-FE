//
//  LineChartCustomView.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import DGCharts
import UIKit

class LineChartCustomView: UIView {
    
    private var myLineChart: LineChartView!
    
    var dayData: [String] = ["1번째", "2번째", "3번째", "4번째", "5번째"]
    var scoreData: [Double] = [] {
        didSet {
            if scoreData.count > 0 {
                dayData = (1...scoreData.count).map { "\($0)번째" }

                self.myLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayData)
                self.myLineChart.xAxis.setLabelCount(scoreData.count, force: true)
                self.myLineChart.xAxis.granularity = 1.0
                self.myLineChart.xAxis.avoidFirstLastClippingEnabled = true
                self.myLineChart.minOffset = 20 // 여백 줄임
                self.setLineData(lineChartView: self.myLineChart, lineChartDataEntries: self.entryData(values: self.scoreData))
                self.setNeedsLayout()
            } else {
                self.myLineChart.clear()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupChart()
    }
    
    private func setupChart() {
        // LineChartView 초기화
        myLineChart = LineChartView()
        myLineChart.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(myLineChart)
        
        // Auto Layout 설정 - 하단 여백 추가
        NSLayoutConstraint.activate([
            myLineChart.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            myLineChart.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            myLineChart.topAnchor.constraint(equalTo: self.topAnchor),
            myLineChart.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10) // 하단 여백 줄임
        ])
        
        // 기본 출력 텍스트
        self.myLineChart.noDataText = "출력 데이터가 없습니다."
        self.myLineChart.noDataFont = .systemFont(ofSize: 20)
        self.myLineChart.noDataTextColor = .white
        self.myLineChart.backgroundColor = .white
        
        // X축 설정 (라벨 아래로)
        self.myLineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayData)
        self.myLineChart.xAxis.setLabelCount(scoreData.count, force: true)
        self.myLineChart.xAxis.labelPosition = .bottom
        
        // x축 세로선 제거
        self.myLineChart.xAxis.drawGridLinesEnabled = false
        
        // X축 선 숨기기
        self.myLineChart.xAxis.drawAxisLineEnabled = false
        
        // x축 처음, 마지막 label text 잘리지 않게 수정
        self.myLineChart.xAxis.avoidFirstLastClippingEnabled = true
        
        // X축 라벨 색상 및 폰트 설정
        self.myLineChart.xAxis.labelTextColor = UIColor(.textDarkGray)
        self.myLineChart.xAxis.labelFont = UIFont(name: "Pretendard-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        self.myLineChart.xAxis.yOffset = 8
        
        // 차트 여백 설정
        self.myLineChart.minOffset = 20
        self.myLineChart.extraBottomOffset = 5 // 하단 여백 줄임
        self.myLineChart.extraTopOffset = 5
        
        // 범례 숨기기
        self.myLineChart.legend.enabled = false
        
        // 줌 및 드래그 비활성화
        self.myLineChart.setScaleEnabled(false)
        self.myLineChart.pinchZoomEnabled = false
        self.myLineChart.doubleTapToZoomEnabled = false
        self.myLineChart.dragEnabled = false
        
        // 클릭 시 강조 표시 비활성화
        self.myLineChart.highlightPerTapEnabled = false
        
        // Y축 라벨 제거
        self.myLineChart.rightAxis.enabled = false
        
        // Y축 설정
        let leftAxis = self.myLineChart.leftAxis
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 100
        leftAxis.granularity = 10
        leftAxis.setLabelCount(11, force: true)
        
        // Y축 간격 선 보이게 설정
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        leftAxis.gridLineWidth = 1
        leftAxis.gridLineDashLengths = [5, 3]
        
        // Y축 선은 보이게 설정
        self.myLineChart.leftAxis.drawAxisLineEnabled = false
        self.myLineChart.rightAxis.drawAxisLineEnabled = false
        
        // Y축 라벨 숨기기
        self.myLineChart.leftAxis.drawLabelsEnabled = false
        self.myLineChart.rightAxis.enabled = false
        
        // 데이터 설정
        self.setLineData(lineChartView: self.myLineChart, lineChartDataEntries: self.entryData(values: self.scoreData))
    }
    
    // 데이터 적용하기
    private func setLineData(lineChartView: LineChartView, lineChartDataEntries: [ChartDataEntry]) {
        let lineChartdataSet = LineChartDataSet(entries: lineChartDataEntries, label: "")
        
        // 점 상단 value label 제거
        lineChartdataSet.drawValuesEnabled = false
        
        // 라인 스타일 설정 (점선)
        lineChartdataSet.lineDashLengths = [5, 3]
        lineChartdataSet.lineWidth = 3.0
        lineChartdataSet.colors = [UIColor(red: 0.82, green: 0.83, blue: 0.84, alpha: 1)]
        lineChartdataSet.circleRadius = 1
        lineChartdataSet.circleColors = [.white]
        
        // DataSet을 차트 데이터로 넣기
        let lineChartData = LineChartData(dataSet: lineChartdataSet)
        
        // 데이터 출력
        lineChartView.data = lineChartData
    }
    
    // entry 만들기
    private func entryData(values: [Double]) -> [ChartDataEntry] {
        var lineDataEntries: [ChartDataEntry] = []
        for i in 0 ..< values.count {
            let lineDataEntry = ChartDataEntry(x: Double(i), y: values[i])
            lineDataEntries.append(lineDataEntry)
        }
        return lineDataEntries
    }
    
    // 데이터 포인트에 원 추가하기
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 기존 원 제거
        removeExistingCircles()
        
        // 데이터 포인트에 원 추가
        self.addCirclesToChart()
    }
    
    // 그림 그리기
    private func addCirclesToChart() {
        for i in 0..<scoreData.count {
            // 차트에서 데이터 포인트의 위치를 계산
            let transformer = myLineChart.getTransformer(forAxis: .left) // 왼쪽 Y축에 대한 변환기 가져오기
            let point = transformer.pixelForValues(x: Double(i), y: scoreData[i]) // 데이터 포인트의 픽셀 좌표 계산
            
            // 원 위치
            let circle = UIView(frame: CGRect(x: point.x - 18, y: point.y - 15, width: 41, height: 30))
            circle.backgroundColor = .white
            circle.layer.cornerRadius = 15
            
            let score = scoreData[i]
            // 점수를 0-1 범위로 변환 (0-100 -> 0-1)
            let normalizedScore = score / 100.0
            circle.layer.borderColor = colorForScore(normalizedScore).cgColor
            
            circle.layer.borderWidth = 1
            
            circle.layer.masksToBounds = false
            circle.layer.shadowColor = UIColor(red: 0, green: 0.271, blue: 0.91, alpha: 0.1).cgColor
            circle.layer.shadowOpacity = 1
            circle.layer.shadowRadius = 15
            circle.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            // 태그 추가하여 식별 가능하게 설정
            circle.tag = 999
            myLineChart.addSubview(circle)
            
            
            let scoreLabel = UILabel()
            scoreLabel.text = "\(Int(scoreData[i]))점"
            scoreLabel.font = UIFont(name: "Pretendard-Medium", size: 14)
            scoreLabel.textColor = colorForScore(normalizedScore)
            
            scoreLabel.textAlignment = .center
            scoreLabel.frame = circle.bounds
            scoreLabel.center = CGPoint(x: circle.bounds.midX, y: circle.bounds.midY)
            
            // 원에 라벨 추가
            circle.addSubview(scoreLabel)
        }
    }
    
    // 기존 원 제거
    private func removeExistingCircles() {
        // 특정 태그를 가진 서브뷰를 제거
        myLineChart.subviews.forEach { subview in
            if subview.tag == 999 { // 원에 부여한 태그
                subview.removeFromSuperview()
            }
        }
    }
}
