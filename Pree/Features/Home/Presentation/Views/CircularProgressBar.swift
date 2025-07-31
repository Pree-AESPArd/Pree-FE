//
//  CircularProgressBar.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import UIKit

class CircularProgressBar: UIView {
    
    private var lineWidth: CGFloat = 10
    private var progressLayer: CAShapeLayer?
    private var backgroundLayer: CAShapeLayer?
    private var progressLabel: UILabel?
    
    var value: Double = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        setupLayers()
        setupLabel()
    }
    
    private func setupLayers() {
        // 배경 원형 레이어
        backgroundLayer = CAShapeLayer()
        backgroundLayer?.fillColor = UIColor.clear.cgColor
        backgroundLayer?.strokeColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1).cgColor
        backgroundLayer?.lineWidth = lineWidth
        backgroundLayer?.lineCap = .round
        
        // 프로그래스 레이어
        progressLayer = CAShapeLayer()
        progressLayer?.fillColor = UIColor.clear.cgColor
        progressLayer?.lineWidth = lineWidth
        progressLayer?.lineCap = .round
        
        if let backgroundLayer = backgroundLayer {
            layer.addSublayer(backgroundLayer)
        }
        if let progressLayer = progressLayer {
            layer.addSublayer(progressLayer)
        }
    }
    
    private func setupLabel() {
        progressLabel = UILabel()
        progressLabel?.textAlignment = .center
        progressLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        progressLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        if let progressLabel = progressLabel {
            addSubview(progressLabel)
            NSLayoutConstraint.activate([
                progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                progressLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    private func updateLayers() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        
        // 배경 원형 경로
        let backgroundPath = UIBezierPath(arcCenter: center,
                                         radius: radius,
                                         startAngle: -.pi / 2,
                                         endAngle: 3 * .pi / 2,
                                         clockwise: true)
        
        backgroundLayer?.path = backgroundPath.cgPath
        
        // 프로그래스 경로
        let progressPath = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: -.pi / 2,
                                       endAngle: (-.pi / 2) + (2 * .pi * value),
                                       clockwise: true)
        
        progressLayer?.path = progressPath.cgPath
    }
    
    private func updateProgress() {
        // 값 범위 제한 (0-1)
        let clampedValue = max(0, min(1, value))
        
        // 색상 설정
        let progressColor: UIColor
        let textColor: UIColor
        
        progressColor = colorForScore(clampedValue)
        textColor = colorForScore(clampedValue)
        
        progressLayer?.strokeColor = progressColor.cgColor
        
        // 레이블 업데이트
        if clampedValue == -1 {
            progressLabel?.text = "???"
            progressLabel?.textColor = UIColor(red: 0.94, green: 0.95, blue: 0.95, alpha: 1)
        } else {
            progressLabel?.text = "\(Int(clampedValue * 100))점"
            progressLabel?.textColor = textColor
        }
        
        // 애니메이션과 함께 레이어 업데이트
        updateLayers()
    }
}

