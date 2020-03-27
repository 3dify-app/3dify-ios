//
//  CameraViewController.swift
//  3Dify
//
//  Created by It's free real estate on 21.03.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation
import SpriteKit
import Accelerate


final class CameraViewController: UIViewController {
    let cameraCoordinator: CameraCoordinator
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let previewView = UIView()
    let button = UIButton()
    
    private let onCapture: ((DepthImage) -> ())
    
    init(cameraCoordinator: CameraCoordinator, onCapture: @escaping ((DepthImage) -> ())) {
        self.cameraCoordinator = cameraCoordinator
        self.onCapture = onCapture
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.frame = .init(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        previewView.backgroundColor = .black
        previewView.contentMode = .scaleAspectFit
        view.addSubview(previewView)
        
        loadingIndicator.frame = self.view.bounds
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        cameraCoordinator.captureDelegate = self
        cameraCoordinator.prepare() {
            self.cameraCoordinator.displayPreview(on: self.previewView) {
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        
        guard
            error == nil,
            let colorImageData = photo.fileDataRepresentation(),
            let image = UIImage(data: colorImageData),
            let depthData = photo.depthData
        else {return}
        
        let convertedDepthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        let depthMap = convertedDepthData.depthDataMap
        depthMap.normalize()
        
        guard
            let depthMapImage = UIImage(pixelBuffer: depthMap),
            let depthCGImage = depthMapImage.cgImage,
            let rotatedDepthImage = UIImage(cgImage: depthCGImage, scale: 1.0, orientation: image.imageOrientation)
                .rotate(radians: 0),
            let rotatedImage = image.rotate(radians: 0),
            let depthImage = DepthImage(diffuse: rotatedImage, trueDepth: rotatedDepthImage)
        else {return}
        
        onCapture(depthImage)
    }
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    public typealias UIViewControllerType = CameraViewController
    
    let cameraCoordinator: CameraCoordinator
    let onCapture: ((DepthImage) -> ())
    
    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<CameraViewControllerRepresentable>
    ) -> CameraViewController {
        return CameraViewController(cameraCoordinator: cameraCoordinator, onCapture: onCapture)
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewControllerRepresentable>) {
        // Do nothing
    }
}
