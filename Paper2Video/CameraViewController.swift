//
//  CameraViewController.swift
//  Paper2Video
//
//  Created by Joshua, Gregory on 7/23/18.
//  Copyright © 2018 NOCDIB, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //camera stuff
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back {
                cameraDevice = device
            }
        }//for
        
    }
    
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
            
        }
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        // Convert image to bytes
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        // Send bytes to comparison API
        
        // If match is found then play video
        // UNCOMMENT THIS: performSegue(withIdentifier: "CameraToVideo", sender: self)
        
        // If match is not found then show alert
    }
    
    func matchImageToVideo(_ imageData: Data) {
        //let imageUrl = URL(string: "http://www.nocdib.com/trauma_black_blue.png")!
        //imageData = try! Data(contentsOf: imageUrl)
        
        let url = URL(string: "https://api.clarifai.com/v2/searches")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Key 1b8ad3caa84a476d89a670c5a160d174", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"query\": {\"ands\": [{\"output\": {\"input\": {\"data\": {\"image\": {\"base64\": \"\(imageData.base64EncodedString())\"}}}}}]}}".data(using: .utf8)!
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
                let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) {
                print(urlContent)
            } else {
                print("Error: \(error ?? "Error in matchImageToVideo() URLSession" as! Error)")
            }
            }.resume()
        
    }
    
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo:
        AVCapturePhoto, error: Error?){
        
        if let imageData = photo.fileDataRepresentation() {
            matchImageToVideo(imageData)
        }
    }
}
