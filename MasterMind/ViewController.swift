//
//  ViewController.swift
//  MasterMind
//
//  Created by Tomas Gallucci on 3/28/19.
//  Copyright © 2019 Tomas Gallucci. All rights reserved.
//

import Cocoa
import GameplayKit

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var answer = ""
    var guesses = [String]()
    
    var tableCellAnimations = [
        NSTableView.AnimationOptions.slideLeft,
        NSTableView.AnimationOptions.slideRight,
    ]
    var animationIndex = 0

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var guess: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startGame()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return guesses.count
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func submitGuess(_ sender: Any) {
        // first check for 4 unique characters
        let guessString = guess.stringValue
        guard Set(guessString).count == 4 else {return}
        
        // second, ensure there are no non-digit characters
        let badCharacters = CharacterSet(charactersIn: "0123456789").inverted
        guard guessString.rangeOfCharacter(from: badCharacters) == nil else {return}
        
        guesses.insert(guessString, at: 0)
        
        tableView.insertRows(at: IndexSet(integer: 0), withAnimation: getNextAnimationOption())
        
        // did the player win?
        let resultString = result(for: guessString)
        
        if resultString.contains("4b") {
            let alert = NSAlert()
            alert.messageText = "You win!"
            alert.informativeText = "Congratulations! Click OK to play again."
            
            alert.runModal()
            
            startGame()
        }
        
    }
    
    func getNextAnimationOption() -> NSTableView.AnimationOptions {
        animationIndex += 1
        
        if ( (animationIndex % tableCellAnimations.count) == 0) {
            animationIndex = 0
        }
        
//        print("animationIndex: \(animationIndex)")
        return tableCellAnimations[animationIndex]
    }
    
    func result(for guess: String) -> String {
        var bulls = 0
        var cows = 0
        
        let guessLetters = Array(guess)
        let answerLetters = Array(answer)
        
        for(index, letter) in guessLetters.enumerated() {
            if letter == answerLetters[index] {
                bulls += 1
            } else if answerLetters.contains(letter) {
                cows += 1
            }
        }
        
        return "\(bulls)b \(cows)c"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {return nil}
        
        if tableColumn?.title == "Guess" {
            vw.textField?.stringValue = guesses[row]
        } else {
            vw.textField?.stringValue = result(for: guesses[row])
        }
        
        return vw
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func startGame() {
        guess.stringValue = ""
        guesses.removeAll()
        
        var numbers = Array(0...9)
        numbers = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: numbers) as! [Int]
        
        for _ in 0 ..< 4 {
            answer.append(String(numbers.removeLast()))
        }
        
        tableView.reloadData()
        
        print("answer: \(answer)")
    }
    
}

