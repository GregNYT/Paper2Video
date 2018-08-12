//
//  VideoViewController.swift
//  Paper2Video
//
//  Created by Joshua, Gregory on 7/23/18.
//  Copyright © 2018 NOCDIB, Inc. All rights reserved.
//

import UIKit
import AVKit

class VideoViewController: UIViewController {
    
    var videoId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        print("VideoViewController videoId = \(String(describing: videoId))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchJSON(String(videoId))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func fetchJSON(_ videoId:String) {
        /*
        let alert = UIAlertController(title: "Video To Load", message: videoId, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        */
        let videoPath = "https://vp.nyt.com/video/2018/07/18/77169_1_22police-violence-video_wg_1080p.mp4"
        let video = AVPlayer(url: URL(fileURLWithPath: videoPath))
        let videoPlayer = AVPlayerViewController()
        videoPlayer.player = video
        
        present(videoPlayer, animated: true, completion:
        {
            video.play()
        })
        
        dismiss(animated: true, completion:
        {
            video.pause()
        })
        /*let urlString = "http://api.letsbuildthatapp.com/jsondecodable/courses_snake_case"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get data from url:", err)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    // link in description for video on JSONDecoder
                    let decoder = JSONDecoder()
                    // Swift 4.1
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    self.courses = try decoder.decode([Course].self, from: data)
                    self.tableView.reloadData()
                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)
                }
            }
            }.resume()*/
    }

    @IBAction func backButton_TouchUpInside(_ sender: Any) {
        performSegue(withIdentifier: "VideoToCamera", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
