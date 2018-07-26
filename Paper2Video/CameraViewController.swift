//
//  CameraViewController.swift
//  Paper2Video
//
//  Created by Joshua, Gregory on 7/23/18.
//  Copyright © 2018 NOCDIB, Inc. All rights reserved.
//

import UIKit
import AVFoundation

struct Status: Codable {
    let code: Int
    let description: String
}

struct Hit: Codable {
    let score: Double
    struct Input: Codable {
        let id: String
        struct data: Codable {
            struct image: Codable {
                let url: String
            }
        }
    let created_at: String
    let modified_at: String
    let status: Status
    }
    let input: Input
}

struct ImageSearchResult: Codable {
    let status: Status
    let id: String
    let hits: [Hit]
}

struct VideoResult: Codable {
    struct Rendition: Codable {
        let type: String
        let url: String
        let width: Int
        let height: Int
        let duration: Int
        let bitrate: Int
        let file_size: Int
        let videoencoding: String
        let live: Bool
    }
    let renditions: [Rendition]
}



class CameraViewController: UIViewController {
    
    
    @IBOutlet weak var cameraButton: UIButton!
    var captureSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add the activity indicator to the view
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
        print("Camera button clicked")

        // Convert image to bytes
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        // Send bytes to comparison API
        
        // If match is found then play video
        // UNCOMMENT THIS: performSegue(withIdentifier: "CameraToVideo", sender: self)
        
        // If match is not found then show alert
    }
    
    func matchImageToVideo(_ imageData: Data) {
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        self.view.addSubview(activityIndicator)
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        // disable button
        cameraButton.isEnabled = false
        
        let url = URL(string: "https://api.clarifai.com/v2/searches")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Key 1b8ad3caa84a476d89a670c5a160d174", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"query\": {\"ands\": [{\"output\": {\"input\": {\"data\": {\"image\": {\"base64\": \"\(imageData.base64EncodedString())\"}}}}}]}}".data(using: .utf8)!
        URLSession.shared.dataTask(with: request) { (data, response, error)  in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                // enable button
                self.cameraButton.isEnabled = true
            }
            
            

            // ***** UNCOMMENT TO PRINT THE JSON AS A STRING ***** //
            //let urlContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue)
            //print(urlContent!)
            //print("------------------")
            
            do {
                let searchResult = try JSONDecoder().decode(ImageSearchResult.self, from: data)
                let score = searchResult.hits[0].score
                let videoId = searchResult.hits[0].input.id.split(separator: "_")[0]
                
                self.loadVideo(score, String(videoId))
            } catch let err as NSError {
                print("Error trying to decode image search result JSON")
                print(err)
            }
                
        }.resume()
        
    } // func matchImageToVideo

    func loadVideo (_ score: Double, _ videoId: String) {
        let minAllowableScore: Double = 0.50
        print("SCORE = \(score)")
        print("ID = \(videoId)")
        
        if(score < minAllowableScore){
            let alert = UIAlertController(title: "Video Not Found", message: "There is no video to match that image.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }else{
            //switch views and load video
        }


    }
    
} // class CameraViewController

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo:
        AVCapturePhoto, error: Error?){
        
        if let imageData = photo.fileDataRepresentation() {
            matchImageToVideo(imageData)
        }
    }
}

//extension UIViewController {
//    class func displaySpinner(onView : UIView) -> UIView {
//        let spinnerView = UIView.init(frame: onView.bounds)
//        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
//        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
//        ai.startAnimating()
//        ai.center = spinnerView.center
//
//        DispatchQueue.main.async {
//            spinnerView.addSubview(ai)
//            onView.addSubview(spinnerView)
//        }
//
//        return spinnerView
//    }
//
//    class func removeSpinner(spinner :UIView) {
//        DispatchQueue.main.async {
//            spinner.removeFromSuperview()
//        }
//    }
//}

