//
//  ViewController.swift
//  BlackJack
//
//  Created by Machir on 2021/8/3.
//

import UIKit
import GameplayKit
import CoreAudio
import AVFAudio
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var playerCardsLabel: [UILabel]!
    @IBOutlet var cpuCardsLabel: [UILabel]!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var cpuScoreLabel: UILabel!
    @IBOutlet weak var totalBetAmountLabel: UILabel!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var betSegmentedControl: UISegmentedControl!
    @IBOutlet weak var betStepper: UIStepper!
    
    
    //設定bet及chip變數
    var bet = 0
    var chip = 500
    
    //設定CPU及Player紙牌點數
    var playerPoint = 0
    var cpuPoint = 0
    var playerSum = 0
    var cpuSum = 0
    
    //設定hit順序
    var index = 1
    
    //設定訊息資訊變數
    var controller = UIAlertController()
    var action = UIAlertAction()
    
    //洗牌
    let distribution = GKShuffledDistribution(lowestValue: 0, highestValue: cards.count - 1)
    
    //定義紙牌數字對應的Int
    func calculateRankNumber(card: String) -> Int {
        var score = 0
        if card.contains("A") {
            score = 1
        } else if card.contains("2") {
            score = 2
        } else if card.contains("3") {
            score = 3
        } else if card.contains("4") {
            score = 4
        } else if card.contains("5") {
            score = 5
        } else if card.contains("6") {
            score = 6
        } else if card.contains("7") {
            score = 7
        } else if card.contains("8") {
            score = 8
        } else if card.contains("9") {
            score = 9
        } else if card.contains("10") {
            score = 10
        } else if card.contains("J") {
            score = 10
        } else if card.contains("Q") {
            score = 10
        } else if card.contains("K") {
            score = 10
        }
        return score
    }
    
    //初始設定
    func gameInit() {
        index = 1
        
        for i in 0...4 {
            if i < 2 {
                playerCardsLabel[i].isHidden = false
                cpuCardsLabel[i].isHidden = false
                playerCardsLabel[i].text = cards[distribution.nextInt()]
                cpuCardsLabel[i].text = cards[distribution.nextInt()]
            } else {
                playerCardsLabel[i].isHidden = true
                cpuCardsLabel[i].isHidden = true
            }
        }
        
        
        
        playerSum = calculateRankNumber(card: playerCardsLabel[0].text!) + calculateRankNumber(card: playerCardsLabel[1].text!)
        playerScoreLabel.text = "\(playerSum)"
        
        cpuSum = calculateRankNumber(card: cpuCardsLabel[0].text!) + calculateRankNumber(card: cpuCardsLabel[1].text!)
        cpuScoreLabel.text = "\(cpuSum)"
        
        bet = 0
        betLabel.text = "$\(bet)"
        betSegmentedControl.selectedSegmentIndex = 0
        totalBetAmountLabel.text = "$\(chip)"
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameInit()
    }

    //下注金額
    @IBAction func betStepperChanged(_ sender: UIStepper) {
        if betSegmentedControl.selectedSegmentIndex == 0 {
            bet += 10 * Int(betStepper.value)
            if bet >= 0, bet <= chip {
                betLabel.text = "\(bet)"
                betStepper.value = 0
            } else if bet > chip {
                bet -= 10
                betLabel.text = "\(bet)"
                betStepper.value = 0
            } else {
                bet += 10
                betLabel.text = "\(bet)"
                betStepper.value = 0
            }
        } else if betSegmentedControl.selectedSegmentIndex == 1 {
            bet += 50 * Int(betStepper.value)
            if bet >= 0, bet <= chip {
                betLabel.text = "\(bet)"
                betStepper.value = 0
            } else if bet > chip {
                bet -= 50
                betLabel.text = "\(bet)"
                betStepper.value = 0
            } else {
                bet += 50
                betLabel.text = "\(bet)"
                betStepper.value = 0
            }
        } else {
            bet += 100 * Int(betStepper.value)
            if bet >= 0, bet <= chip {
                betLabel.text = "\(bet)"
                betStepper.value = 0
            } else if bet > chip {
                bet -= 100
                betLabel.text = "\(bet)"
                betStepper.value = 0
            } else {
                bet += 100
                betLabel.text = "\(bet)"
                betStepper.value = 0
            }
        }
    }
    
    
    
    
    //發牌
    @IBAction func getPlayerCard(_ sender: UIButton) {
        index = index + 1
        playerCardsLabel[index].isHidden = false
        playerCardsLabel[index].text = cards[distribution.nextInt()]
        
        playerPoint = calculateRankNumber(card: playerCardsLabel[index].text!)
        playerSum += playerPoint
        playerScoreLabel.text = "\(playerSum)"
        
        if playerSum > 21 {
            chip = chip - bet
            totalBetAmountLabel.text = "$\(chip)"
            
            if chip <= 0 {
                bet = 0
                
                controller = UIAlertController(title: "Game Over", message: "\(playerSum) Burst!\nOpps!\nYour bet amount is \(bet)!", preferredStyle: .alert)
                action = UIAlertAction(title: "Play Again", style: .default) { (_) in
                    self.gameInit()
                }
                chip = 500
                controller.addAction(action)
                present(controller, animated: true, completion: nil)
            } else {
                controller = UIAlertController(title: "Burst", message: "CHIP - \(bet)", preferredStyle: .alert)
                action = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.gameInit()
                }
                controller.addAction(action)
                present(controller, animated: true, completion: nil)
            }
            
        } else if playerSum == 21 {
            totalBetAmountLabel.text = "$\(chip)"
            chip = chip + bet
            
            controller = UIAlertController(title: "BlackJack", message: "GOOD!\nCHIP + \(bet)", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.gameInit()
            })
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
            
        } else if playerSum <= 21, index == 4 {
            totalBetAmountLabel.text = "$\(chip)"
            chip = chip + bet
            
            controller = UIAlertController(title: "Five Card Charlie", message: "GOOD!\nCHIP + \(bet)", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.gameInit()
            })
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func showCards(_ sender: UIButton) {
        if cpuSum <= 16 {
            for i in 2...4 {
                if cpuSum <= 17 {
                    cpuCardsLabel[i].isHidden = false
                    cpuCardsLabel[i].text = cards[distribution.nextInt()]
                    cpuPoint = calculateRankNumber(card: cpuCardsLabel[i].text!)
                    cpuSum = cpuSum + cpuPoint
                }
            }
        }
        cpuScoreLabel.text = "\(cpuSum)"
        
        if cpuSum > playerSum {
            if cpuSum > 21 {
                chip = chip + bet
                
                controller = UIAlertController(title: "You Win", message: "CPU: \(cpuSum) Busted\nCHIP + \(bet)", preferredStyle: .alert)
                action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.gameInit()
                })
                controller.addAction(action)
                present(controller, animated: true, completion: nil)
            } else if cpuSum == 21 {
                totalBetAmountLabel.text = "$\(chip)"
                chip = chip - bet
                
                if chip <= 0 {
                    totalBetAmountLabel.text = "$\(chip)"
                    bet = 0
                    betLabel.text = "$\(chip)"
                    
                    controller = UIAlertController(title: "Game Over", message: "CPU: BlackJack", preferredStyle: .alert)
                    action = UIAlertAction(title: "Play Again", style: .default, handler: { (_) in
                        self.gameInit()
                    })
                    controller.addAction(action)
                    present(controller, animated: true, completion: nil)
                    chip = 500
                } else {
                    controller = UIAlertController(title: "YOU LOSE!", message: "CPU: BlackJack!\nCHIP - \(bet)", preferredStyle: .alert)
                    action = UIAlertAction(title: "OK", style: .default) { (_) in
                        self.gameInit()
                    }
                    controller.addAction(action)
                    present(controller, animated: true, completion: nil)
                }
            } else if cpuSum <= 21, cpuCardsLabel[4].isHighlighted {
                totalBetAmountLabel.text = "\(bet)"
                chip = chip - bet
                
                if chip <= 0 {
                    print("1")
                    totalBetAmountLabel.text = "$\(chip)"
                    bet = 0
                    betLabel.text = "$\(bet)"
                    
                    controller = UIAlertController(title: "Game Over", message: "CPU: Five Card Charlie!\nYour bet amount is \(chip)!", preferredStyle: .alert)
                    action = UIAlertAction(title: "Play Again!", style: .default) { (_) in
                        self.gameInit()
                    }
                    controller.addAction(action)
                    present(controller, animated: true, completion: nil)
                    chip = 500
                } else {
                    print("2")
                    controller = UIAlertController(title: "YOU LOSE!", message: "CPU: Five Card Charlie!\nBetAmount - \(bet)", preferredStyle: .alert)
                    action = UIAlertAction(title: "OK", style: .default) { (_) in
                        self.gameInit()
                    }
                    controller.addAction(action)
                    present(controller, animated: true, completion: nil)
                }
            } else if cpuSum > playerSum {
                totalBetAmountLabel.text = "\(chip)"
                chip = chip - bet
                
                if chip <= 0 {
                    totalBetAmountLabel.text = "$\(chip)"
                    bet = 0
                    betLabel.text = "$\(bet)"
                    controller = UIAlertController(title: "Game Over!", message: "CPU: \(cpuSum)>\(playerSum)\nYour bet amount is \(chip)!", preferredStyle: .alert)
                    action = UIAlertAction(title: "Play Again!", style: .default) { (_) in
                        self.gameInit()
                    }
                    chip = 500
                    controller.addAction(action)
                    present(controller, animated: true, completion: nil)
            } else {
            controller = UIAlertController(title: "YOU LOSE!", message: "BetAmount - \(bet)", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default) { (_) in
                self.gameInit()
            }
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }
            }
        } else if cpuSum == playerSum {
            controller = UIAlertController(title: "TIE GAME!", message: "", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default) { (_) in
                self.gameInit()
            }
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
            totalBetAmountLabel.text = "$\(chip)"
        } else if cpuSum < playerSum {
            chip = chip + bet
            
            controller = UIAlertController(title: "YOU WIN!", message: "CPU: \(cpuSum) < \(playerSum)\nBetAmount + \(bet)", preferredStyle: .alert)
            action = UIAlertAction(title: "OK", style: .default) { (_) in
                self.gameInit()
            }
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
            totalBetAmountLabel.text = "$\(chip)"
    }
        }
}
