//
//  ViewController.swift
//  Remember the sequal
//
//  Created by Bastian Morath on 05/01/15.
//  Copyright (c) 2015 Bastian Morath. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    
    let BLUE_COLOR = UIColor(red: 16/255, green: 133/255, blue: 226/255, alpha: 1)
    let GREEN_COLOR = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
    
    let RED_COLOR = UIColor(red: 192/255, green: 20/255, blue: 21/255, alpha: 1)
    let LIGHT_RED_COLOR = UIColor(red: 223/255, green: 81/255, blue: 81/255, alpha: 1)
    let WHITE_COLOR = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    let GREY_COLOR = UIColor(red: 0.851, green: 0.867, blue: 0.859, alpha: 1)
    
    let highscoreKeyConstant = "highscore"
    
    //MARK:- Outlets
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    //MARK:- Variables
    //Speichert die Reihenfolge der Integer(Tags) [Random]
    var randomSequalArray: [Int] = []
    
    //Speichert die Reihenfolge, die der User drückt. Wird jedes Mal, wenn wieder ein neues Element hinzukommt, gelöscht
    var userSequalArray: [Int] = []
    
    //Level
    var currentLevel: Int = 0
    
    //
    var counter: Int = 0
    var isAnimating:Bool = false
    
    //Maximales bis jetzt erreichtes Level
    var highscore: Int {
        get{
          return Int(HighscoreStore.sharedInstance.getHighscore().highscore!)
        }
        set{
            HighscoreStore.sharedInstance.getHighscore().highscore! = NSNumber(value: newValue)
        }
    }
    
    
    //tagToDelete speichert den Tag, dessen entsprechender BUtton als nächster rot eingefärbt werden soll. Er wird immer um eins erhöht
    var tagToDelete: Int = 1 {
        didSet{
            if (oldValue % 2 == 0) {
                (self.view.viewWithTag(oldValue) as! UIButton).backgroundColor = LIGHT_RED_COLOR
            } else {
                (self.view.viewWithTag(oldValue) as! UIButton).backgroundColor = RED_COLOR
            }
        }
    }
    
    //MARK:- Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HighscoreStore.sharedInstance.createHighscore(score: 0);
        // Do any additional setup after loading the view, typically from a nib.
        self.highscoreLabel.text = "Highscore: \(self.highscore)"
        //Action-Target den Buttons hinzufügen
        for button in buttons{
            button.addTarget(self, action: #selector(buttonPressed), for: UIControlEvents.touchUpInside)
            button.layer.cornerRadius = 4.0
            button.clipsToBounds = true
        }
        
        self.colorWhiteAndGrey()
        self.enableUserInteractionForButtons(shouldEnable: false)
    }
    
    
    //MARK:- Button-Handling
    
    @IBAction func startGamePressed(sender: UIButton) {
        if !isAnimating {
            if randomSequalArray.count == 0 {
                self.enableUserInteractionForButtons(shouldEnable: false)
                //Start with random Button
                self.appendOneElementToSequal()
                colorWhiteAndGrey()
                self.currentLevel = 0
                self.levelLabel.text = "\(currentLevel)"
                
                Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(showSequal), userInfo: nil, repeats: false)
                
                //hide Button
                sender.setTitle("Reset", for: UIControlState.normal)
                //sender.hidden = false
                
            } else {
                self.endGame()
            }
            
        }
    }
    
    
    func buttonPressed(sender: UIButton!){
        // self.playASound()
        self.userSequalArray.append(sender.tag)
        if !userDidChooseTheRightButton() {
            //Game Finished
            sender.backgroundColor = RED_COLOR
            self.enableUserInteractionForButtons(shouldEnable: false)
            self.isAnimating = true
            self.endGame()
        } else  if userDidChooseTheRightButton() && randomSequalArray.count == userSequalArray.count {
            //Sequal is finished; Next Level
            self.highlightButton(button: sender, withColor: self.GREEN_COLOR)
            self.userSequalArray = []
            self.appendOneElementToSequal()
            self.currentLevel += 1
            self.levelLabel.text = "\(currentLevel)"
            self.showSequal()
        } else {
            self.highlightButton(button: sender, withColor: self.GREEN_COLOR)
        }
    }
    
    // Animation: Blauer topView soll runter animiert werden, inklusive Labels
    func endGame(){
        self.redTilesAnimation()
        self.randomSequalArray = []
        self.userSequalArray = []
        self.startButton.setTitle("Start Game", for: UIControlState.normal)
        
        //Wenn ein neuer Highscore gemacht wurde, zeige ein Label davon, sonst ein Label mit "Wrong Button"
        if self.currentLevel > self.highscore {
            self.highscore = self.currentLevel
            self.highscoreLabel.text = "Highscore: \(self.highscore)"
        }
    }
    
    //MARK:- Other functions
    
    func highlightButton(button: UIButton!, withColor color: UIColor!){
        let buttonColor = button.backgroundColor
        button.backgroundColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            button.backgroundColor = buttonColor
        }
//        let dispatchTime: dispatch_time_t = DispatchTime.now(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.2 * Double(NSEC_PER_SEC)))
//        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
//            button.backgroundColor = buttonColor
//        })
    }
    
    func showSequal(){
        self.enableUserInteractionForButtons(shouldEnable: false)
        if let tag = self.randomSequalArray.first {
            if let firstButton = self.view.viewWithTag(tag){
                Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(highlightOddButtonScheduled), userInfo: firstButton, repeats: false)
            }
        }
    }
    
    //indexCounter zählt die Indizes durch den randomSequalArray durch
    var indexCounter = 0
    
    // Highlight Odd Buttons
    func highlightOddButtonScheduled(timer: Timer!){
        if !isAnimating{
            
            self.highlightButton(button: timer.userInfo as! UIButton, withColor: GREEN_COLOR)
            indexCounter += 1
            
            if (indexCounter<self.randomSequalArray.count){
                let nextButton = self.buttonWithTag(tag: self.randomSequalArray[indexCounter])
                Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(highlightEvenButtonScheduled), userInfo: nextButton, repeats: false)
            } else {
                self.enableUserInteractionForButtons(shouldEnable: true)
                indexCounter = 0
                
                return
            }
        }
    }
    
    //Highlight Even Buttons
    func highlightEvenButtonScheduled(timer: Timer!){
        if !isAnimating{
            self.highlightButton(button: timer.userInfo as! UIButton, withColor: GREEN_COLOR)
            indexCounter += 1
            
            if indexCounter<self.randomSequalArray.count{
                let nextButton = self.buttonWithTag(tag: self.randomSequalArray[indexCounter])
                Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(highlightOddButtonScheduled), userInfo: nextButton, repeats: false)
            } else {
                self.enableUserInteractionForButtons(shouldEnable: true)
                indexCounter = 0
                return
            }
            
        }
    }
    
    func appendOneElementToSequal(){
        var randomNumber = Int(arc4random_uniform(10)+1)
        while randomNumber == randomSequalArray.last {
            randomNumber = Int(arc4random_uniform(10)+1)
        }
        randomSequalArray.append(randomNumber)
    }
    
    //Immer, wenn der User einen nächsten Button gedrückt hat, wird der Tag des Buttons im 'userSequalArray' hinzugefügt und in der folgenden Methode mit dem 'randomSequalArray' verglichen.
    func userDidChooseTheRightButton() -> Bool {
        for (index, element) in userSequalArray.enumerated(){
            if index < randomSequalArray.count {
                if randomSequalArray[index] == element {
                    continue
                } else {
                    return false
                }
                
            }
        }
        return true
    }
    
    func colorWhiteAndGrey(){
        for button in buttons {
            if button.tag % 2 == 0 {
                
                button.backgroundColor = WHITE_COLOR
            } else {
                button.backgroundColor = GREY_COLOR
            }
            
        }
    }
    
    
    // MARK:- Helper functions
    
    func enableUserInteractionForButtons(shouldEnable :Bool!){
        for button in buttons {
            button.isUserInteractionEnabled = shouldEnable
        }
        
    }
    
    func buttonWithTag(tag: Int!) -> UIButton! {
        return self.view.viewWithTag(tag) as! UIButton
    }
    
    
    //Changing Status Bar
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//
//        //LightContent
//        return UIStatusBarStyle.lightContent
//    }
    
    func redTilesAnimation() {
        buttons[counter].backgroundColor = RED_COLOR
        counter += 1
        
        let timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(littleBreak2), userInfo: nil, repeats: false)
        if counter == 12 {
            timer.invalidate()
            counter = 0
            isAnimating = false
        }
    }
    
    func littleBreak2() {
        buttons[counter].backgroundColor = RED_COLOR
        counter += 1
        let timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(redTilesAnimation), userInfo: nil, repeats: false)
        if counter == 12 {
            timer.invalidate()
            counter = 0
            isAnimating = false
        }
    }
    
    
}

