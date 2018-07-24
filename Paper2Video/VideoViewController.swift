//
//  VideoViewController.swift
//  Paper2Video
//
//  Created by Joshua, Gregory on 7/23/18.
//  Copyright © 2018 NOCDIB, Inc. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
