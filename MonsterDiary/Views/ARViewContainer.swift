import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var audioManager: AudioRecorderManager
    @StateObject private var arManager: ARModelManager = ARModelManager()

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let arModelDict = arManager.loadModels()
        for (index, day) in Week.allCases.enumerated() {
            guard let modelEntity = arModelDict[day] else { return arView}
            
            let anchor = AnchorEntity(plane: .horizontal)
            // 요일별로 다른 위치에 배치
            modelEntity.position = SIMD3(x: Float(index) * 0.1, y: 0, z: 0)
            modelEntity.generateCollisionShapes(recursive: true)
            anchor.addChild(modelEntity)
            arView.scene.anchors.append(anchor)
        }
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        arManager.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func animateModel(model: Entity, touchPosition: SIMD3<Float> = SIMD3<Float>(x: 0, y: 0, z: 0)){
        /// 실제 모델의 위치(0,0,0)와 model.postion의 위치가 달라서 움직이 제대로 적용 안됨
        let startPosition = model.position
        let endPosition = SIMD3(startPosition.x, startPosition.y + 0.1, startPosition.z)
        let controller = model.move(to: Transform(scale: model.scale, translation: endPosition), relativeTo: nil, duration: 0.5, timingFunction: .easeInOut)
    }
    
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
            
        }
        
        @objc func handleTap(gesture: UITapGestureRecognizer) {
            // 탭 이벤트 처리 로직
            let arView = gesture.view as! ARView
//            parent.togglePeopleOcclusion(arView: arView)
            let location = gesture.location(in: arView)
//            let results = arView.raycast(from: location,
//                                     allowing: .estimatedPlane,
//                                    alignment: .horizontal)
//
//            if let result = results.first {
//
//                print(result.worldTransform)    // contains values
//                let anchor = AnchorEntity(raycastResult: result)
//                print(anchor.position)          // why 0,0,0
//            }
            
            let results = arView.hitTest(location, query: .nearest)

            if let firstResult = results.first {
                parent.audioManager.fetchAllRecording()
                parent.arManager.togglePeopleOcclusion()
                playAnimation(entity: firstResult.entity)
//                parent.animateModel(model: firstResult.entity, startPosition: firstResult.position)

            }
        }
    
    
        func playAnimation(entity: Entity) {
            let scale = entity.scale
            let goUp = FromToByAnimation<Transform>(
                name: "goUp",
                from: .init(scale: scale, translation: entity.position),
                to: .init(scale: scale, translation: entity.position + .init(x: 0, y: 0.1, z: 0)),
                duration: 0.8,
                timing: .easeIn,
                bindTarget: .transform
//                ,repeatMode: .repeat
            )
            
            let pause = FromToByAnimation<Transform>(
                name: "pause",
                from: .init(scale: scale, translation: entity.position + .init(x: 0, y: 0.1, z: 0)),
                to: .init(scale: scale, translation: entity.position + .init(x: 0, y: 0.1, z: 0)),
                duration: 0.1,
                bindTarget: .transform
//                ,repeatMode: .repeat
            )
            
            let goDown = FromToByAnimation<Transform>(
                name: "goDown",
                from: .init(scale: scale, translation: entity.position + .init(x: 0, y: 0.1, z: 0)),
                to: .init(scale: scale, translation: entity.position),
                duration: 0.8,
                timing: .easeOut,
                bindTarget: .transform
//                ,repeatMode: .repeat
                
            )
            
            let goUpAnimation = try! AnimationResource
                .generate(with: goUp)
            
            let pauseAnimation = try! AnimationResource
                .generate(with: pause)
            
            let goDownAnimation = try! AnimationResource
                .generate(with: goDown)
            
            let animation = try! AnimationResource.sequence(with: [goUpAnimation, pauseAnimation, goDownAnimation])
            let animationResources = animation
            let playAnimation = animationResources.repeat(duration: .infinity)
            entity.playAnimation(playAnimation, transitionDuration: 0.5)
        }
        
        
    }
    
//    fileprivate func togglePeopleOcclusion(arView: ARView) {
//        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
//            fatalError("Unexpectedly failed to get the configuration.")
//        }
//        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
//            fatalError("People occlusion is not supported on this device.")
//        }
//        switch config.frameSemantics {
//        case [.personSegmentationWithDepth]:
//            config.frameSemantics.remove(.personSegmentationWithDepth)
//        default:
//            config.frameSemantics.insert(.personSegmentationWithDepth)
//        }
//        arView.session.run(config)
//    }
}
