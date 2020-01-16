//
//  ViewController.swift
//  RGB Game
//
//  Created by Justin Matsnev on 1/14/20.
//  Copyright © 2020 Justin Matsnev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {

    @IBOutlet var currentScoreLbl : UILabel!
    @IBOutlet var highScoreLbl : UILabel!
    

    @IBOutlet var colorView : UIView! {
        didSet {
            colorView.layer.cornerRadius = 7.0
        }
    }
    
    @IBOutlet var greenButton : UIButton! {
        didSet {
            greenButton.layer.cornerRadius = 7.0
        }
    }
    
    @IBOutlet var blueButton : UIButton! {
        didSet {
            blueButton.layer.cornerRadius = 7.0
        }
    }
    
    @IBOutlet var orangeButton : UIButton! {
        didSet {
            orangeButton.layer.cornerRadius = 7.0
        }
    }
    
    @IBOutlet var redButton : UIButton! {
        didSet {
            redButton.layer.cornerRadius = 7.0
        }
    }
    var correctButton : UIButton!
    var bannerView: GADBannerView!
    let defaults = UserDefaults.standard
    var currentColor : UIColor!
    var currentColorStr : String!
    var gameMode = ""
    var currentScore = 0 {
        didSet {
            currentScoreLbl.text = "\(currentScore)"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.value(forKey: "high_score") != nil {
            highScoreLbl.text = "\(getHighScore())"
        }
        createBanner()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        requestGameMode()
        
    }
    
    func createBanner() {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //test
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //mine
        //bannerView.adUnitID = "ca-app-pub-3064270335088212/7053869411"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
     bannerView.translatesAutoresizingMaskIntoConstraints = false
     view.addSubview(bannerView)
     view.addConstraints(
       [NSLayoutConstraint(item: bannerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view.safeAreaLayoutGuide ,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0),
        NSLayoutConstraint(item: bannerView,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0)
       ])
    }
    
    func getHighScore() -> Int{
        return defaults.integer(forKey: "high_score")
    }
    
    func setHighScore() {
        defaults.set(currentScore, forKey: "high_score")
    }
    
    func showHighScoreAlert(score : Int) {
        let highScoreView = UIAlertController(title: "New Highscore!", message: "Woohoo! Congrats on the new highscore of \(score).", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Thanks! Play again", style: .default, handler: nil)
        let changeMode = UIAlertAction(title: "Change Game Mode", style: .default) { (action) in
            self.requestGameMode()
        }
        highScoreView.addAction(okAction)
        highScoreView.addAction(changeMode)
        self.present(highScoreView, animated: true, completion: nil)
    }
    
    func updateHighScore() {
        let score = defaults.value(forKey: "high_score")
        if score != nil {
            if getHighScore() < currentScore {
                showHighScoreAlert(score: currentScore)
                setHighScore()
                highScoreLbl.text = "\(getHighScore())"
            }
        } else {
            if currentScore != 0 {
                showHighScoreAlert(score: currentScore)
                setHighScore()
                highScoreLbl.text = "\(getHighScore())"
            }
        }
    }
    
    func gameOver() {
        updateHighScore()
        currentScoreLbl.text = "0"
        currentScore = 0
        self.beginGame()
    }
    
    
    @IBAction func answerSelected(sender : UIButton) {
        
        guard let color = sender.titleLabel?.text else {
            return
        }
        
        if color == currentColorStr {
            
            UIView.animate(withDuration: 0.2, animations: {
                sender.backgroundColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { (didComplete) in
                UIView.animate(withDuration: 0.2) {
                    sender.backgroundColor = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
                    sender.transform = CGAffineTransform.identity
                    
                    self.currentScore += 1
                    self.beginGame()
                }
            }
            
        } else {
            
            UIView.animate(withDuration: 0.6, animations: {
                sender.backgroundColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
                sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.correctButton.backgroundColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
                self.correctButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

            }) { (didComplete) in
                UIView.animate(withDuration: 0.2) {
                    sender.backgroundColor = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
                    sender.transform = CGAffineTransform.identity
                    self.correctButton.backgroundColor = UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0)
                    self.correctButton.transform = CGAffineTransform.identity
                    self.gameOver()
                }
            }
            
        }
    }
    
    @IBAction func changeMode(sender : UIButton) {
        requestGameMode()
    }
    
    func beginGame() {
        assignInitialColor()
        let answers = generateAnswers()
        let buttons = [greenButton, blueButton, orangeButton, redButton]
        for i in 0..<buttons.count {
            if answers[i] == currentColorStr {
                correctButton = buttons[i]
                buttons[i]?.setTitle(answers[i], for: .normal)
            } else {
                buttons[i]?.setTitle(answers[i], for: .normal)
            }
        }
        print(currentColorStr)
//        greenButton.setTitle(answers[0], for: .normal)
//        blueButton.setTitle(answers[1], for: .normal)
//        orangeButton.setTitle(answers[2], for: .normal)
//        redButton.setTitle(answers[3], for: .normal)
        
    }

    func generateAnswers() -> [String] {
        var answers : [String] = []
        
        for _ in 0..<3 {
            switch gameMode {
            case "Hex":
                answers.append("#\(UIColor.random.toHex()!)")
            case "Value":
                let color = UIColor.random.rgb()!
                answers.append("(\(color.red), \(color.green), \(color.blue))")
            default:
                break
            }
        }
        
        switch gameMode {
        case "Hex":
            currentColorStr = "#\(currentColor.toHex()!)"
            answers.append(currentColorStr)
        case "Value":
            let color = currentColor.rgb()!
            currentColorStr = "(\(color.red), \(color.green), \(color.blue))"
            answers.append(currentColorStr)
        default:
            break
        }
        
        return answers.shuffled()
    }
    
    func assignInitialColor() {
        currentColor = .random
        colorView.backgroundColor = currentColor
    }

    func requestGameMode() {
        let gameModeView =  UIAlertController(title: "GAME MODE", message: "Which mode would you like to play?", preferredStyle: .alert)
        
        let hexMode = UIAlertAction(title: "#Hex Mode", style: .default) { (action) in
            self.gameMode = "Hex"
            self.beginGame()
        }
        
        let valueMode = UIAlertAction(title: "R,G,B Mode", style: .default) { (action) in
            self.gameMode = "Value"
            self.beginGame()
        }
    
        
        gameModeView.addAction(hexMode)
        gameModeView.addAction(valueMode)
        
        self.present(gameModeView, animated: true, completion: nil)
    }

}

extension ViewController : GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
        addBannerViewToView(bannerView)

    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
