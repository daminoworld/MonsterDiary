import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var audioManager: AudioRecorderManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 모델 로드 (usdz 파일 가정)
        if let modelEntity = try? ModelEntity.loadModel(named: "kittyGhost_purple") {
            let anchor = AnchorEntity(plane: .horizontal)
            modelEntity.generateCollisionShapes(recursive: true)
//            arView.installGestures([.all], for: modelEntity as! HasCollision)
            anchor.addChild(modelEntity)
            arView.scene.anchors.append(anchor)
            
            // 제스처 인식기 등록
            let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
            arView.addGestureRecognizer(tapGesture)
            //            modelEntity.model?.materials = [SimpleMaterial(color: .blue, isMetallic: false), SimpleMaterial(color: .black, isMetallic: false),SimpleMaterial(color: .yellow, isMetallic: false)]
            
           modelEntity.move(to: .init(scale: modelEntity.scale, translation: modelEntity.position + .init(x: 0, y: 0.1, z: 0)),
                                                  relativeTo: nil,
                                                  duration: 0.5)

        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func animateModel(model: ModelEntity) {
        // 초기 위치 설정
        let startPosition = model.position
        let endPosition = SIMD3(startPosition.x, startPosition.y + 0.2, startPosition.z)
        
        model.move(to: Transform(translation: .init(x: 0, y: 0, z: -0.5)),
           relativeTo: nil,
             duration: 0.5,
       timingFunction: .easeInOut)
    }

    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(gesture: UITapGestureRecognizer) {
            // 탭 이벤트 처리 로직
            let arView = gesture.view as! ARView
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
                print("Model tapped")
                
                parent.audioManager.fetchRecordings()
            
                playAnimation(entity: firstResult.entity)

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
            
            let animation = try! AnimationResource.sequence(with: [goUpAnimation, goDownAnimation])
            let animationResources = animation
            let playAnimation = animationResources.repeat(duration: .infinity)
            entity.playAnimation(playAnimation, transitionDuration: 0.5)
//            playAnimation(entity: entity)
        }
    }
}
