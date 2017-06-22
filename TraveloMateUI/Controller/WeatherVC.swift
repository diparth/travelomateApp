//
//  WeatherVC.swift
//  TraveloMateUI
//
//  Created by Diparth Patel on 4/14/17.
//  Copyright © 2017 Diparth Patel. All rights reserved.
//

import UIKit
import Foundation



class WeatherVC: UIViewController {

    
    //Outlets
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var weatherBoxView: UIView!
    
    
    
    
    //VAriables
    
    
    var weatherObj: Weather!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.weatherBoxView.layer.cornerRadius = 15

        self.updateUI()
        
        // Do any additional setup after loading the view.
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    func updateUI() {
        
        if weatherObj != nil {
            self.weatherImage.image = UIImage.init(named: self.weatherObj.condition)
            self.tempLabel.text = "\(self.weatherObj.temperature!)° C"
            self.tempMinLabel.text = "\(self.weatherObj.tempMin!)° C"
            self.tempMaxLabel.text = "\(self.weatherObj.tempMax!)° C"
            self.conditionLabel.text = self.weatherObj.condition
            self.descLabel.text = self.weatherObj.weatherType
            self.windSpeedLabel.text = "\(self.weatherObj.windSpeed!)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.timeStyle = .short
            
            let dateSunRise = Date.init(timeIntervalSince1970: self.weatherObj.sunriseTime)
            self.sunriseLabel.text = dateFormatter.string(from: dateSunRise)
            
            let dateSunset = Date.init(timeIntervalSince1970: self.weatherObj.sunsetTime)
            self.sunsetLabel.text = dateFormatter.string(from: dateSunset)
        }
        
        
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
