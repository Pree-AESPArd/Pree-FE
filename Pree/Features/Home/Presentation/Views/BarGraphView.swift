//
//  BarGraphView.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation
import UIKit

class BarGraphView: UIView {
    // 막대그래프 데이터
    var percentages: [CGFloat] = [] {
        didSet {
            setupBars()
        }
    }
    
    // 그래프 이름 데이터
    let grapNamehData: [String] = ["발표 시간", "말 빠르기", "음성 크기", "발화 지연", "공백 횟수", "시선 처리"]
    
    var maxHeight: CGFloat = 127.0 // 최대 높이
    var barWidth: CGFloat = 25.0 // 막대 가로 길이
    var spacing: CGFloat = 30.0 // 막대 사이 간격
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBars()
    }
    
    // 막대 설정
    private func setupBars() {
        // 기존 서브뷰 제거
        subviews.forEach { $0.removeFromSuperview() }
        
        // 막대 추가
        for (index, percentage) in percentages.enumerated() {
            var barHeight: CGFloat
            if(percentage != 0){
                barHeight = maxHeight * (percentage / 100)
            }
            else{
                barHeight = 5 // 퍼센티지가 0일 때 고정된 최소 높이
            }
            let barView = UIView()
            barView.backgroundColor = .white
            barView.frame = CGRect(
                x: CGFloat(index) * (barWidth + spacing),
                y: maxHeight - barHeight,
                width: barWidth,
                height: barHeight
            )
            
            // 상단 모서리만 둥글게 설정
            let path = UIBezierPath(
                roundedRect: barView.bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 8, height: 8)
            )
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            barView.layer.mask = shapeLayer
            
            // 세로 그라데이션 추가
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    UIColor(red: 0.2, green: 0.44, blue: 1, alpha: 1).cgColor,  // 위쪽 색
                    UIColor(red: 0.54, green: 0.68, blue: 1, alpha: 1).cgColor   // 아래쪽 색
                ]
                gradientLayer.locations = [0, 1]  // 그라데이션의 시작과 끝 위치
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)  // 세로 방향 (위에서 아래로)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
                
                gradientLayer.bounds = barView.bounds
                gradientLayer.position =  CGPoint(x: 12.5, y: barHeight/2)
                
                barView.layer.addSublayer(gradientLayer)
            
            addSubview(barView)
            
            
            // 막대 상단에 퍼센트 값 표시 라벨 추가
            let percentageLabel = UILabel()
            percentageLabel.translatesAutoresizingMaskIntoConstraints = false
            percentageLabel.text = "\(Int(percentage))"  // 퍼센트 값을 표시
            percentageLabel.font = UIFont(name: "Pretendard-Medium", size: 12)
            percentageLabel.textAlignment = .center
            percentageLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            
            addSubview(percentageLabel)
            
            // 퍼센트 라벨을 막대 상단에 배치
            NSLayoutConstraint.activate([
                percentageLabel.topAnchor.constraint(equalTo: barView.topAnchor, constant: 4),
                percentageLabel.centerXAnchor.constraint(equalTo: barView.centerXAnchor)
            ])
            
            // 라벨 추가 (막대 아래에 위치)
            if index < grapNamehData.count {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = grapNamehData[index]
                label.font = UIFont(name: "Pretendard-Medium", size: 12)
                label.textAlignment = .center
                label.textColor = UIColor(red: 0.427, green: 0.439, blue: 0.471, alpha: 1)
                
                addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 8),
                    label.centerXAnchor.constraint(equalTo: barView.centerXAnchor)
                ])
            }
        }
    }
    
    // 커스텀 뷰의 크기 조정
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
