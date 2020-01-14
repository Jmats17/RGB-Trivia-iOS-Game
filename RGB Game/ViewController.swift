//
//  ViewController.swift
//  RGB Game
//
//  Created by Justin Matsnev on 1/14/20.
//  Copyright © 2020 Justin Matsnev. All rights reserved.
//

import UIKit

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
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        requestGameMode()
        
    }
    
    func getHighScore() -> Int{
        return defaults.integer(forKey: "high_score")
    }
    
    func setHighScore() {
        defaults.set(currentScore, forKey: "high_score")
    }
    
    private func updateHighScore() {
        let score = defaults.value(forKey: "high_score")
        if score != nil {
            if getHighScore() < currentScore {
                setHighScore()
                highScoreLbl.text = "\(getHighScore())"
            }
        } else {
            setHighScore()
            highScoreLbl.text = "\(getHighScore())"
        }
    }
    
    private func gameOver() {
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
            currentScore += 1
            self.beginGame()
        } else {
            gameOver()
        }
        
    }
    
    
    private func beginGame() {
        assignInitialColor()
        let answers = generateAnswers()
        greenButton.setTitle(answers[0], for: .normal)
        blueButton.setTitle(answers[1], for: .normal)
        orangeButton.setTitle(answers[2], for: .normal)
        redButton.setTitle(answers[3], for: .normal)
    }
    
    private func generateAnswers() -> [String] {
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
    
    private func assignInitialColor() {
        currentColor = .random
        colorView.backgroundColor = currentColor
    }

    private func requestGameMode() {
        let gameModeView =  UIAlertController(title: "GAME MODE", message: "Which mode would you like to play?", preferredStyle: .alert)
        
        let hexMode = UIAlertAction(title: "#Hex Mode", style: .default) { (action) in
            self.gameMode = "Hex"
            self.beginGame()
        }
        
        let valueMode = UIAlertAction(title: "R,G,B Mode", style: .default) { (action) in
            self.gameMode = "Value"
            self.beginGame()
        }
        
        let mixedMode = UIAlertAction(title: "Mix'n'Match Mode", style: .default) { (action) in
            self.gameMode = "Mixed"
            self.beginGame()
        }
        
        gameModeView.addAction(hexMode)
        gameModeView.addAction(valueMode)
        gameModeView.addAction(mixedMode)
        
        self.present(gameModeView, animated: true, completion: nil)
    }

}


