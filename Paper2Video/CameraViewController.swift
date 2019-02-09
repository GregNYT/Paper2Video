//
//  CameraViewController.swift
//  Paper2Video
//
//  Created by Joshua, Gregory on 7/23/18.
//  Copyright © 2018 NOCDIB, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

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
        // Notify when the device orientation has changed
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        //camera stuff
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    // Every time the view appears start the camera button's animation
    override func viewDidAppear(_ animated: Bool) {
        cameraButton.pulsate()
    }
    
    // When the video player is closed set the camera view to default (portrait) position.
    // This prevents the camera screen from rotating to landscape when the video is closed in landscape.
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    // Called by the NotificationCenter in viewDidLoad() to rotate the camera button based on device orientation
    @objc func rotated() {
        var rotation_angle: CGFloat = 0
        switch UIDevice.current.orientation
        {
        case .landscapeLeft:
            rotation_angle = (CGFloat(Double.pi) / 2)
        case .landscapeRight:
            rotation_angle = (CGFloat(-Double.pi) / 2)
        case .portraitUpsideDown:
            rotation_angle = CGFloat(Double.pi)
        case .unknown, .portrait, .faceUp, .faceDown:
            rotation_angle = 0
        }
        UIView.animate(withDuration: 0.2, animations:
        {
            self.cameraButton.transform = CGAffineTransform(rotationAngle: rotation_angle);
        }, completion: nil)
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is VideoViewController
        {
            let vc = segue.destination as! VideoViewController
            guard let videoId = sender as? String else { return }
            vc.videoId = videoId
        }
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back {
                cameraDevice = device
            }
        }//for
        
    }
    
    func setupInputOutput() {
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
    
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    func startRunningCaptureSession() {
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
        cameraButton.alpha = 0
        // Get the Clarifai API key from Clarifai.plist file (not in git repo)
        var nsDictionary: NSDictionary?
        var api_key: String = ""
        if let path = Bundle.main.path(forResource: "Clarifai", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            api_key = (nsDictionary!["api_key"] as! String)
        }
        // Search Clarifai for the image
        let url = URL(string: "https://api.clarifai.com/v2/searches")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(api_key, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"query\": {\"ands\": [{\"output\": {\"input\": {\"data\": {\"image\": {\"base64\": \"\(imageData.base64EncodedString())\"}}}}}]}}".data(using: .utf8)!
        URLSession.shared.dataTask(with: request) { (data, response, error)  in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                activityIndicator.removeFromSuperview()
                // enable button
                self.cameraButton.isEnabled = true
                self.cameraButton.alpha = 1
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
        let minAllowableScore: Double = 0.65
        print("SCORE = \(score)")
        print("ID = \(videoId)")
        
        if(score < minAllowableScore){
            let alert = UIAlertController(title: "Video Not Found", message: "There is no video to match that image.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }else{
            guard let url = URL(string: "https://www.nytimes.com/svc/video/api/v3/video/\(videoId)") else { return }
            print("URL = \(url.absoluteString)")
            URLSession.shared.dataTask(with: url) { (data, _, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        print("Failed to get data from url:", err)
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        let searchResult = try JSONDecoder().decode(VideoResult.self, from: data)
                        let video1080p = searchResult.renditions.filter { $0.type == "video_1080p_mp4" }
                        self.playVideo(video1080p[0].url)
                    } catch let jsonErr {
                        let alert = UIAlertController(title: "Video Failed To Load", message: "Failed to decode JSON from the Video API.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alert, animated: true)
                        print("Failed in loadVideo():", jsonErr)
                    }
                }
            }.resume()
        }

    }
    
    func playVideo(_ videoPath: String) {
        DispatchQueue.main.async {
            //switch views and load video
            //performSegue(withIdentifier: "CameraToVideo", sender: videoId)
            let video = AVPlayer(url: URL(fileURLWithPath: videoPath))
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            self.present(videoPlayer, animated: true, completion:
                {
                    video.play()
            })
            
        }// DispatchQueue
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

extension UIButton {
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.9
        pulse.fromValue = 1.5
        pulse.toValue = 1.6
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }
}

