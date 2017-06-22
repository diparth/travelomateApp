//
//  ViewController.swift
//  SpotifyTest
//
//  Created by Seth Rininger on 11/11/16.
//  Copyright © 2016 Seth Rininger. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
import Foundation
import MediaPlayer
import MarqueeLabel

class PlayerVC: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var trackTitle: MarqueeLabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var logoutPlayerButton: UIButton!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var coverView2: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var playbackSourceTitle: MarqueeLabel!
    @IBOutlet weak var artistTitle: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var currentDurationLabel: UILabel!
    @IBOutlet weak var endDurationLabel: UILabel!
    
    
    let volumeView = MPVolumeView()
    
    var myTrack: Track!
    var album: Album!
    var artist: Artist!
    var searchedUri: String!
    
    var isChangingProgress: Bool = false
    let audioSession = AVAudioSession.sharedInstance()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.volumeSlider = volumeView.subviews.first as? UISlider
        self.volumeSlider.value = self.audioSession.outputVolume
    
        self.trackTitle.text = "Nothing Playing"
        self.trackTitle.type = .leftRight
        self.artistTitle.text = ""
        self.logoutPlayerButton.isEnabled = false
        self.logoutPlayerButton.isHidden = true
        self.playPauseButton.setImage(UIImage.init(named: "pause"), for: .normal)
    
    }
    
    
    @IBAction func volumeSliderChanged(_ sender: Any) {
        if let view = volumeView.subviews.first as? UISlider {
            view.value = self.volumeSlider.value
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if isSongPlaying != nil {
            if isSongPlaying == false{
                //Show Player - from Dashboard will come here all the time with new song
                self.handleNewSession()
                isSongPlaying = true
            }
            //If song is playing but not coming through Show Player, then will come here
        }else {
            
            //If nothing is playing at all and coming through music button on Dashboard, will come here.
            self.disableAllOutlets()
        }
        
//        appDelegate?.player.delegate = self
//        appDelegate?.player.playbackDelegate = self
        self.updateUI()
        
        //print("session: \(appDelegate?.auth?.session.accessToken)")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate?.player.delegate = self
        appDelegate?.player.playbackDelegate = self
        self.volumeSlider.value = self.audioSession.outputVolume
        
    }
    
    
    @IBAction func cancelPlayerPressed(_ sender: Any) {
        isSongPlaying = nil
        _ = self.navigationController?.popToRootViewController(animated: true)
        do{
            try self.audioSession.setActive(false, with: .notifyOthersOnDeactivation)
        }catch let error {
            print("Cancel throws error: \(error)")
        }
        //self.deactivateAudioSession()
        
    }
    
    
    func disableAllOutlets() {
        self.progressSlider.isEnabled = false
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
        self.playPauseButton.isEnabled = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    
    
    @IBAction func rewind(_ sender: UIButton) {
        appDelegate?.player.skipPrevious(nil)
    }
    
    @IBAction func playPause(_ sender: UIButton) {
        appDelegate?.player.setIsPlaying(!(appDelegate?.player.playbackState.isPlaying)!, callback: nil)
        if (appDelegate?.player.playbackState.isPlaying)! {
            self.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
        }else {
            self.playPauseButton.setImage(UIImage.init(named: "pause"), for: .normal)
        }
    }
    
    @IBAction func fastForward(_ sender: UIButton) {
        appDelegate?.player.skipNext(nil)
    }

    @IBAction func seekValueChanged(_ sender: UISlider) {
        self.isChangingProgress = false
        let dest = (appDelegate?.player.metadata.currentTrack?.duration)! * Double(self.progressSlider.value)
        appDelegate?.player.seek(to: dest, callback: nil)
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        if (appDelegate?.player != nil) {
            appDelegate?.player.logout()
        }
        else {
            _ = self.navigationController!.popViewController(animated: true)
        }

    }
    
    @IBAction func proggressTouchDown(_ sender: UISlider) {
        self.isChangingProgress = true
    }
    
    func applyBlur(on imageToBlur: UIImage, withRadius blurRadius: CGFloat) -> UIImage {
        let originalImage = CIImage(cgImage: imageToBlur.cgImage!)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(originalImage, forKey: "inputImage")
        filter?.setValue(blurRadius, forKey: "inputRadius")
        let outputImage = filter?.outputImage
        let context = CIContext(options: nil)
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let ret = UIImage(cgImage: outImage!)
        return ret
    }
    
    
    func updateUI() {
        let auth = appDelegate?.auth
        if appDelegate?.player.metadata == nil || appDelegate?.player.metadata.currentTrack == nil {
            let img = UIImage.init(named: "music")
            self.coverView.image = img
            self.coverView2.image = img
            return
        }
        
        self.spinner.startAnimating()
        self.nextButton.isEnabled = appDelegate?.player.metadata.nextTrack != nil
        self.prevButton.isEnabled = appDelegate?.player.metadata.prevTrack != nil
        self.trackTitle.text = appDelegate?.player.metadata.currentTrack?.name
        self.artistTitle.text = appDelegate?.player.metadata.currentTrack?.artistName
        self.playbackSourceTitle.text = appDelegate?.player.metadata.currentTrack?.playbackSourceName
        print("Current Track Duration is: \(String(describing: appDelegate?.player.metadata.currentTrack?.duration))")

        SPTTrack.track(withURI: URL(string: SPTAudioStreamingController.sharedInstance().metadata.currentTrack!.uri)!, accessToken: auth!.session.accessToken, market: nil) { error, result in
            
            if let track = result as? SPTTrack {
                let imageURL = track.album.largestCover.imageURL
                if imageURL == nil {
                    print("Album \(track.album) doesn't have any images!")
                    self.coverView.image = nil
                    self.coverView2.image = nil
                    return
                }
                // Pop over to a background queue to load the image over the network.
                
                DispatchQueue.global().async {
                    do {
                        let imageData = try Data(contentsOf: imageURL!, options: [])
                        let image = UIImage(data: imageData)
                        // …and back to the main queue to display the image.
                        DispatchQueue.main.async {
                            self.spinner.stopAnimating()
                            self.coverView.image = image
                            self.coverView2.image = image
                            if image == nil {
                                print("Couldn't load cover image with error: \(String(describing: error))")
                                return
                            }
                        }
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
        
    }
    
    
    func handleNewSession() {
        
        if (appDelegate?.player.loggedIn)! {
            appDelegate?.player.delegate = self
            appDelegate?.player.playbackDelegate = self
            self.playAudioStreaming()
        }
        else {
            do {
                try appDelegate?.player.start(withClientId: appDelegate?.auth?.clientID, audioController: nil, allowCaching: false)
                appDelegate?.player.delegate = self
                appDelegate?.player.playbackDelegate = self
                appDelegate?.player.diskCache = SPTDiskCache() /* capacity: 1024 * 1024 * 64 */
                appDelegate?.player.login(withAccessToken: appDelegate?.auth?.session.accessToken)
            } catch let error {
                let alert = UIAlertController(title: "Error init", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (finished) in
                    self.closeSession()
                }))
                
                self.present(alert, animated: true, completion: { _ in })
            }
        }
    }
    
    func closeSession() {
//        do {
//            try SPTAudioStreamingController.sharedInstance().stop()
//            SPTAuth.defaultInstance().session = nil
//            _ = self.navigationController!.popViewController(animated: true)
//        } 
        do {
           try appDelegate?.player.stop()
            appDelegate?.auth?.session = nil
            _ = self.navigationController?.popViewController(animated: true)
        } catch let error {
            let alert = UIAlertController(title: "Error deinit", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: { _ in })
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: { _ in })
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing = \(isPlaying)")
        if isPlaying {
            self.activateAudioSession()
        }
        else {
            self.deactivateAudioSession()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        self.updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent, withName name: String) {
        print("didReceivePlaybackEvent: \(event) \(name)")
        //print("isPlaying=\(SPTAudioStreamingController.sharedInstance().playbackState.isPlaying) isRepeating=\(SPTAudioStreamingController.sharedInstance().playbackState.isRepeating) isShuffling=\(SPTAudioStreamingController.sharedInstance().playbackState.isShuffling) isActiveDevice=\(SPTAudioStreamingController.sharedInstance().playbackState.isActiveDevice) positionMs=\(SPTAudioStreamingController.sharedInstance().playbackState.position)")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("didReceiveError: \(error!.localizedDescription)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        if self.isChangingProgress {
            return
        }
        let positionDouble = Double(position)
        var durationDouble = 1.0
        if(appDelegate?.player.metadata.currentTrack != nil) {
            durationDouble = Double((appDelegate?.player.metadata.currentTrack?.duration)!)
        }
        self.progressSlider.value = Float(positionDouble / durationDouble)
        let (_, sm, ss) = self.secondsToHoursMinutesSeconds(seconds: Int(positionDouble))
        if(ss < 10) {
            self.currentDurationLabel.text = "\(sm):0\(ss)"
        }else {
            self.currentDurationLabel.text = "\(sm):\(ss)"
        }
        let (_, em, es) = self.secondsToHoursMinutesSeconds(seconds: Int(durationDouble-positionDouble))
        if(es < 10) {
            self.endDurationLabel.text = "-\(em):0\(es)"
        }else {
            self.endDurationLabel.text = "-\(em):\(es)"
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Starting \(trackUri)")
        print("Source \(String(describing: appDelegate?.player.metadata.currentTrack?.playbackSourceUri))")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = (appDelegate?.player.metadata.currentTrack?.playbackSourceUri.contains("spotify:track"))! && !(appDelegate?.player.metadata.currentTrack?.playbackSourceUri == trackUri)
        print("Relinked \(isRelinked)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        print("Finishing: \(trackUri)")
    }
    
    func playAudioStreaming() {
        self.updateUI()
        if self.album != nil {
            appDelegate?.player.playSpotifyURI(self.album.albumURI, startingWith: 0, startingWithPosition: 0) { error in
                
                if error != nil {
                    print("*** failed to play: \(String(describing: error))")
                    
                    return
                }
            }
        }else if self.artist != nil {
            appDelegate?.player.playSpotifyURI(self.artist.artistURI, startingWith: 0, startingWithPosition: 0) { error in
                
                if error != nil {
                    print("*** failed to play: \(String(describing: error))")
                    
                    return
                }
            }
        }else if self.myTrack != nil{
            appDelegate?.player.playSpotifyURI(self.myTrack.trackURI, startingWith: 0, startingWithPosition: 0) { error in
                
                if error != nil {
                    print("*** failed to play: \(String(describing: error))")
                    
                    return
                }
            }
        }else if self.searchedUri != nil {
            appDelegate?.player.playSpotifyURI(self.searchedUri!, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                if error != nil {
                    print("*** failed to play: \(String(describing: error))")
                    return
                }
            })
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        self.playAudioStreaming()
    }
    
    func activateAudioSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deactivateAudioSession() {
        do {
            //try AVAudioSession.sharedInstance().setActive(false)
            try audioSession.setActive(false)
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    
    
    
}
