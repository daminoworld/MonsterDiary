//
//  ARModelManager.swift
//  MonsterDiary
//
//  Created by Damin on 4/17/24.
//

import Foundation
import RealityKit
import ARKit
import UIKit

enum Week: CaseIterable {
    case mon, tue, wed, thr, fri, sat, sun
}

class ARModelManager: ObservableObject {
    var arView: ARView?
    var models: [Week: ModelEntity] = [:]
    // 모델 로드 함수
    func loadModels() -> [Week: ModelEntity] {
        for day in Week.allCases {
            if let model = try? ModelEntity.loadModel(named: "kittyGhost_purple") {
                var modelColor = UIColor.white
                switch day {
                case .mon:
                    modelColor = UIColor(hex: "#ff6666")
                case .tue:
                    modelColor =  UIColor(hex: "#ffbd55")
                case .wed:
                    modelColor =  UIColor(hex: "#ffff66")
                case .thr:
                    modelColor =  UIColor(hex: "#9de24f")
                case .fri:
                    modelColor =  UIColor(hex: "#87cefa")
                case .sat:
                    modelColor =  UIColor(hex: "#4b0082")
                case .sun:
                    modelColor =  UIColor(hex: "#ee82ee")
                }
                model.model?.materials = [SimpleMaterial(color: modelColor, isMetallic: false), SimpleMaterial(color: .black, isMetallic: false),SimpleMaterial(color: .black, isMetallic: false)]
                models[day] = model
            }
        }
        return models
    }
    
    func togglePeopleOcclusion() {
        guard let arView else { return }
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
            fatalError("Unexpectedly failed to get the configuration.")
        }
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        switch config.frameSemantics {
        case [.personSegmentationWithDepth]:
            config.frameSemantics.remove(.personSegmentationWithDepth)
        default:
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        arView.session.run(config)
    }
}
