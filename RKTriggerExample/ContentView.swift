//
//  ContentView.swift
//  RKTriggerExample
//
//  Created by Nien Lam on 4/2/20.
//  Copyright © 2020 Mobile Lab. All rights reserved.
//

import SwiftUI
import RealityKit
import Combine

class AppModel: ObservableObject {
    let flipTriggerSignal = PassthroughSubject<Void, Never>()
}

struct ContentView : View {
    @ObservedObject var model = AppModel()
    
    var body: some View {
        ZStack {
            // Underlying AR View.
            ARViewContainer(model: model).edgesIgnoringSafeArea(.all)
            
            // Overlay user interface.
            VStack {
                Spacer()
                
                Button(action: {
                    self.model.flipTriggerSignal.send()
                }) {
                    Text("FLIP ME")
                        .frame(width: 200, height: 60)
                        .background(Color.white)
                }
                .padding()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let model: AppModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        arView.scene.anchors.append(boxAnchor)
        
        // Use the flip trigger signal to send notification.
        model.flipTriggerSignal.sink {
            boxAnchor.notifications.tapFlip.post()
        }.store(in: &context.coordinator.subscriptions)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    class Coordinator: NSObject {
        var subscriptions = Set<AnyCancellable>()
    }
}
