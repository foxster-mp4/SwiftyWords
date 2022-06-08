//
//  ViewController.swift
//  SwiftyWords
//
//  Created by Huy Bui on 2022-06-06.
//

import UIKit

class ViewController: UIViewController {
    var cluesLabel: UILabel!, answerLetterCountsLabel: UILabel!, scoreLabel: UILabel!,
        textField: UITextField!, letterGroupButtons: [UIButton] = []
    var activatedButtons: [UIButton] = [], solutions: [String] = []
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        // Score label
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .gray
        view.addSubview(scoreLabel)
        
        // Clues label
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.text = "CLUES"
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.numberOfLines = 0 // 0 means as many lines as needed
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) // Lower priority for content hugging means it's more likely to get stretched by AutoLayout
        view.addSubview(cluesLabel)
        
        // Answer letter counts label
        answerLetterCountsLabel = UILabel()
        answerLetterCountsLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLetterCountsLabel.textAlignment = .right
        answerLetterCountsLabel.text = "ANSWERS"
        answerLetterCountsLabel.font = UIFont.systemFont(ofSize: 24)
        answerLetterCountsLabel.numberOfLines = 0
        answerLetterCountsLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answerLetterCountsLabel)
        
        // Text field
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .center
        textField.placeholder = "Tap a letter group to guess"
        textField.font = UIFont.systemFont(ofSize: 44)
        textField.isUserInteractionEnabled = false
        view.addSubview(textField)
        
        // Submit button
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("Submit", for: .normal)
        view.addSubview(submit)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        
        // Clear button
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("Clear", for: .normal)
        clear.tintColor = .systemRed
        view.addSubview(clear)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        
        for button in [submit, clear] {
            button.layer.cornerRadius = 5
            button.backgroundColor = .systemGray6
            button.titleLabel?.font = .systemFont(ofSize: 20)
        }
        
        // Letter groups' containter
        let letterGroupsContainer = UIView()
        letterGroupsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterGroupsContainer)
        
        // MARK: Constraints
        
        NSLayoutConstraint.activate([
            // Score label's constraints
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                
            // Clues label's constraints
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor), // Pinning the top of the clues label to the bottom of score label
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100), // Pinning leading edge of the clues label to the leading edge of the laout margins, adding 100 to shift the label to the right (spacing)
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.60, constant: -100), // Setting the clue label's width to be 60% of the layout, minus 100 for the extra space added above
            
            // Answer letter counts' constraints
            answerLetterCountsLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answerLetterCountsLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100), // -100 shifts the label to the left (for spacing)
            answerLetterCountsLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.40, constant: -100),
            answerLetterCountsLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor), // Setting the answer label's height to be the same as the clues label's
            
            // Text field's constraints
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.70), // Setting the text field's width to be 70% of the layout
            textField.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            // Submit button's constraints
            submit.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            submit.heightAnchor.constraint(equalToConstant: 44),
            submit.widthAnchor.constraint(equalToConstant: 100),
            
            // Clear button's constraints
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60),
            clear.heightAnchor.constraint(equalTo: submit.heightAnchor),
            clear.widthAnchor.constraint(equalToConstant: 100),
            
            // Letter groups' container constraints
            letterGroupsContainer.widthAnchor.constraint(equalToConstant: 750),
            letterGroupsContainer.heightAnchor.constraint(equalToConstant: 320),
            letterGroupsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            letterGroupsContainer.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            letterGroupsContainer.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
        
        let width = 150, height = 80
        
        for row in 0..<4 {
            for col in 0..<5 {
                let letterGroupButton = UIButton(type: .system)
                letterGroupButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterGroupButton.setTitle("ABC", for: .normal)
                
                // Calculate button frame
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterGroupButton.frame = frame
                
                letterGroupButton.addTarget(self, action: #selector(letterGroupTapped), for: .touchUpInside)
                
                letterGroupsContainer.addSubview(letterGroupButton)
                letterGroupButtons.append(letterGroupButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLevel()
    }
    
    func loadLevel() {
        var clue = "", solutionLetterCounts = "",
            letterGroupStrings: [String] = []
        
        if let levelFile = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFile) {
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    let line = line.components(separatedBy: ": "),
                        answer = line[0],
                        clueString = line[1]
                    
                    clue += "\(index + 1). \(clueString)\n"
                    
                    let word = answer.replacingOccurrences(of: "|", with: "")
                    solutionLetterCounts += "\(word.count) letters\n"
                    solutions.append(word)
                    
                    let letterGroup = answer.components(separatedBy: "|")
                    letterGroupStrings += letterGroup
                }
                
                cluesLabel.text = clue.trimmingCharacters(in: .whitespacesAndNewlines)
                answerLetterCountsLabel.text = solutionLetterCounts.trimmingCharacters(in: .whitespacesAndNewlines)
                
                letterGroupStrings.shuffle()
                
                if letterGroupStrings.count == letterGroupButtons.count {
                    for i in 0 ..< letterGroupButtons.count {
                        letterGroupButtons[i].setTitle(letterGroupStrings[i], for: .normal)
                    }
                }
            }
        }
    }
    
    @objc func letterGroupTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        textField.text = textField.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        disableButton(sender)
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let answer = textField.text else { return }
        
        // Correct answer submitted
        if let solutionPosition = solutions.firstIndex(of: answer) {
            activatedButtons.removeAll()
            
            // Spliting answer letter count label's text into an array to replace the letter count of the correct answer to the correct answer itself
            var answerLetterCounts = answerLetterCountsLabel.text?.components(separatedBy: "\n")
            answerLetterCounts?[solutionPosition] = answer.capitalized
            answerLetterCountsLabel.text = answerLetterCounts?.joined(separator: "\n")
            
            textField.text = ""
            score += 1
            
            if activatedButtons.count == 20 {
                let alertController = UIAlertController(title: "Level completed", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Next level", style: .default, handler: levelUp))
                present(alertController, animated: true)
            }
        } else { // Incorrect answer submitted
            let alertController = UIAlertController(title: "Incorrect answer", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Try again", style: .default))
            present(alertController, animated: true)
            
            if (score > 0) {
                score -= 1;
            }
        }
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        textField.text = ""
        for button in activatedButtons {
            enableButton(button)
        }
        activatedButtons.removeAll()
    }
    
    func disableButton(_ button: UIButton) {
        button.isUserInteractionEnabled = false
        button.setTitleColor(.gray, for: .normal)
    }
    
    func enableButton(_ button: UIButton) {
        button.isUserInteractionEnabled = true
        button.setTitleColor(.systemBlue, for: .normal)
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for button in letterGroupButtons {
            enableButton(button)
        }
    }


}

