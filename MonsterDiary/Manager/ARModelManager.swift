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

enum Week: String, CaseIterable {
    case mon, tue, wed, thr, fri, sat, sun
}

class ARModelManager: ObservableObject {
    var arView: ARView?
}
    

