//
//  CardCreator.swift
//  Card Master
//
//  Created by Thomas Davey on 05/06/2020.
//  Copyright © 2020 Thomas Davey. All rights reserved.
//

import Foundation
import UIKit

class CardCreator {
    
    let players: [String]
    
    let fontSize = CGFloat(27)
    
    init(playersList: [String]) {
        self.players = playersList
        self.masterRemaining = playersList
        
        loadArrays()
        
        self.nhie = loadCSV(forResource: "nhie", forMinCount: nhieCount)!
        self.mostLikely = loadCSV(forResource: "mostLikely", forMinCount: mostLikelyCount)!
        self.categoriesActors = loadCSV(forResource: "categoriesActors", forMinCount: categoriesCount)!
        self.categoriesMusic = loadCSV(forResource: "categoriesMusic", forMinCount: categoriesCount)!
        self.categoriesTVFilm = loadCSV(forResource: "categoriesTVFilm", forMinCount: categoriesCount)!
        self.trivia = loadCSV(forResource: "trivia", forMinCount: triviaCount)!
        
        self.nhie.shuffle()
        self.mostLikely.shuffle()
        self.categoriesActors.shuffle()
        self.categoriesMusic.shuffle()
        self.categoriesTVFilm.shuffle()
        self.trivia.shuffle()
        
        
        
        
        print("\nUsed NHIE: \(usedNhie.count)")
        print("Remaining NHIE: \(nhie.count)")
        print("\nUsed mostLikely: \(usedMostLikely.count)")
        print("Remaining mostLikely: \(mostLikely.count)")
        print("\nUsed categoriesActors: \(usedCategoriesActors.count)")
        print("Remaining categoriesActors: \(categoriesActors.count)")
        print("\nUsed categoriesMusic: \(usedCategoriesMusic.count)")
        print("Remaining categoriesMusic: \(categoriesMusic.count)")
        print("\nUsed categoriesTVFilm: \(usedCategoriesTVFilm.count)")
        print("Remaining categoriesTVFilm: \(categoriesTVFilm.count)")
        print("\nUsed trivia: \(trivia.count)")
        print("Remaining trivia: \(usedTrivia.count)")
        print("")
        
        
    }
    
    // MARK: - File Required Cards
    
    fileprivate func getNeverHaveIEver() -> CardView {
        let newCard = CardView()
        let nhieString = nhie.popLast()
        usedNhie.append(nhieString!)
        
        let cardText = NSMutableAttributedString()
        if Int.random(in: 0...1) == 1 {
            cardText.append(NSAttributedString(string: "Drink \(generateDrinkSipsString()) if you've ever \(nhieString!.lowercased())", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        } else {
            cardText.append(NSAttributedString(string: "If you've ever \(nhieString!.lowercased()), drink \(generateDrinkSipsString())", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        }
        
        newCard.categoryLabel.text = "NEVER HAVE I EVER"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Never Have I Ever is a card where players should drink if they have done the prompt that appears on the card.\n\nPlayers that have done whatever the prompt asks, should drink the amount stated on the card.\n\nIf a player doesn't know or can't remember, feel free to drink anyway."
        newCard.backgroundColor = #colorLiteral(red: 0, green: 0.6588235294, blue: 0.5882352941, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getMostLikelyTo() -> CardView {
        let newCard = CardView()
        let mostLikelyString = mostLikely.popLast()
        usedMostLikely.append(mostLikelyString!)
        
        let cardText = NSMutableAttributedString(string: "Decide as a group who is the most likely to", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        cardText.append(NSAttributedString(string: "\n\n\(mostLikelyString!)\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        cardText.append(NSAttributedString(string: "The person chosen should drink \(generateDrinkSipsString())", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        
        newCard.categoryLabel.text = "MOST LIKELY TO"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Most likely to is a card where all players in the group should decide who is the most likely to do whatever prompt that appears on the card.\n\nWhen a majority vote has been reached, the person chosen should then drink the amount stated on the card.\n\nIf there is a tie, all tied players should drink.\n\nWe recommend voting by counting down from 3, followed by all players pointing to the player they have individually chosen."
        newCard.backgroundColor = #colorLiteral(red: 0.8431372549, green: 0.2549019608, blue: 0.6549019608, alpha: 1)
        
        return newCard
    }
    
    var categoriesRemaining = [0, 1, 2]
    
    fileprivate func getCategories() -> CardView {
        let newCard = CardView()
        categoriesRemaining.shuffle()
        let randomInt = categoriesRemaining.popLast()
        let categoryText: String
        if randomInt == 0 {
            categoryText = categoriesTVFilm.popLast()!
            usedCategoriesTVFilm.append(categoryText)
        } else if randomInt == 1 {
            categoryText = categoriesActors.popLast()!
            usedCategoriesActors.append(categoryText)
        } else {
            categoryText = categoriesMusic.popLast()!
            usedCategoriesMusic.append(categoryText)
        }
        
        let cardText = NSMutableAttributedString()
        if randomInt == 0 {
            cardText.append(NSMutableAttributedString(string: "Actors or characters that appear in", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        } else if randomInt == 1 {
            cardText.append(NSMutableAttributedString(string: "Movies or TV shows that feature", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        } else {
            cardText.append(NSMutableAttributedString(string: "Songs recorded by", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        }
        cardText.append(NSAttributedString(string: "\n\n\(categoryText)\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]))
        cardText.append(NSAttributedString(string: "\(players.randomElement()!) starts. The person who messes up should drink \(generateDrinkSipsString())", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        
        newCard.categoryLabel.text = "CATEGORIES"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Categories is a card where each player has to name something that fits within the category displayed on the card.\n\nThe player named on the card should start. The game should move clockwise around the group, each naming something that fits the category.\n\nThe player that messes up or can't think of an answer should drink the amount stated on the card."
        newCard.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.4, blue: 0.1411764706, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getTrivia() -> CardView {
        let newCard = CardView()
        var triviaText = trivia.popLast()!
        usedTrivia.append(triviaText)
        triviaText = triviaText.replacingOccurrences(of: "\"", with: "")
        
        let triviaTextSplit = triviaText.components(separatedBy: "?,")
        let cardText = NSMutableAttributedString(string: "\(players.randomElement()!)\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)])
        cardText.append(NSAttributedString(string: "\(triviaTextSplit[0])?\n\nShake the phone to reveal the answer", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        
        newCard.categoryLabel.text = "TRIVIA"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Trivia is a card that contains a general trivia question.\n\nThe player named on the card should attempt to answer the question. Shake the phone after they have done this to reveal the answer.\n\nIf the named player got the correct answer, they can give out the number of sips stated on the card. If they got it wrong, they should drink them instead."
//        print(triviaTextSplit)
        let sips = generateDrinkSipsString()
        newCard.shakeText = triviaTextSplit[1] + "\n\nIf you got the wrong answer, drink \(sips)\n\nIf you got the correct answer, choose someone else to drink \(sips)"
        newCard.backgroundColor = #colorLiteral(red: 0.1295120406, green: 0.5178374139, blue: 0.7767098126, alpha: 1)
        
        return newCard
    }
    
    // MARK: No File Required Cards
    
    fileprivate func getWaterfall() -> CardView {
        let newCard = CardView()
        let cardText = NSMutableAttributedString(string: "It's time to get the drinks flowing with a waterfall round\n\n\(players.randomElement()!) starts", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        
        newCard.categoryLabel.text = "WATERFALL"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Waterfall is a card that creates a \"Waterfall\" of players drinking around the group.\n\nThe game begins with everyone in the group drinking. The person named on the card can stop drinking whenever they want to. Once the named player has stopped, the player to their left can stop drinking whenever they want to. This process moves clockwise around the circle.\n\nNo player is allowed to stop drinking until the player to their right has stopped, except from the player named on the card. If a player finishes their drink, they can stop."
        newCard.backgroundColor = #colorLiteral(red: 0.08235294118, green: 0.6784313725, blue: 0.8784313725, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getPickAMate() -> CardView {
        let newCard = CardView()
        let cardText = NSMutableAttributedString(string: "\(players.randomElement()!)\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)])
        cardText.append(NSAttributedString(string: "Choose someone from the group. This person should drink every time that you drink for the rest of the round", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        
        newCard.categoryLabel.text = "PICK A MATE"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Pick a Mate is a card that creates drinking buddies within the group. It lasts until the end of the game.\n\nThe player named on the card should choose someone else from the group. This chosen player should drink whenever the player named on the card drinks, for the remainder of the game.\n\nThis only works one way, meaning the player named on the card does not have to drink whenever the person they choose has to drink."
        newCard.backgroundColor = #colorLiteral(red: 0.007843137255, green: 0.5019607843, blue: 0.5647058824, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getGender(isGuys: Bool) -> CardView {
        let newCard = CardView()
        let gender = isGuys ? "Guys" : "Girls"
        let opposite = isGuys ? "Girls" : "Guys"
        let cardText = NSMutableAttributedString(string: "All \(gender.lowercased()) should now drink \(generateDrinkSipsString()). Cheers, bottoms up!", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        
        newCard.categoryLabel.text = "\(gender.uppercased()) DRINK"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "\(gender) Drink is a card where all \(gender.lowercased()) in the group should drink the amount stated on the card.\n\nThere is one \(gender) Drink and one \(opposite) Drink card in every game. If you happen to be feeling extra masculine or feminine today, feel free to drink for either card."
        newCard.backgroundColor = #colorLiteral(red: 0.4470588235, green: 0.2039215686, blue: 0.6784313725, alpha: 1)
        
        return newCard
    }
    
    var masterRemaining: [String]!
    
    fileprivate func getThumbMaster() -> CardView {
        let newCard = CardView()
        masterRemaining.shuffle()
        let player = masterRemaining.popLast()!
        let cardText = NSMutableAttributedString(string: "\(player) is now the thumb master\n\nThe last player to follow \(player) in placing their thumb on the table should drink once", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        
        newCard.categoryLabel.text = "THUMB MASTER"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Thumb Master is a card that turns the player named on the card into the thumb master.\n\nThe thumb master can place their thumb on a surface at any point within the game. The last player to notice that the thumb master has done this and follow them in doing so, should drink once.\n\nPlayers can place their thumb on any surface, it doesn't have to be the same surface used by the thumb master. This can be repeated by the thumb master at any point throughout the game, an indefinite amount."
        newCard.backgroundColor = #colorLiteral(red: 0.5333333333, green: 0.2431372549, blue: 0.5568627451, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getQuestionMaster() -> CardView {
        let newCard = CardView()
        masterRemaining.shuffle()
        let cardText = NSMutableAttributedString(string: "\(masterRemaining.popLast()!) is now the question master\n\nPlayers that answer questions asked by the question master should drink once", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        
        newCard.categoryLabel.text = "QUESTION MASTER"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Question Master is a card that turns the player named on the card into the question master.\n\nPlayers should answer any question asked by the question master by saying \"screw you question master\" before their answer.\n\nIf a player forgets to say this before their answer, they should drink once.\n\nThe goal of the question master is to trick other players into answering their questions throughout the game."
        newCard.backgroundColor = #colorLiteral(red: 0.5568627451, green: 0.6509803922, blue: 0.01568627451, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getHeaven() -> CardView {
        let newCard = CardView()
        masterRemaining.shuffle()
        let player = masterRemaining.popLast()
        let cardText = NSMutableAttributedString(string: "\(player!) now has the power of the Gods!\n\nThe last player to follow \(player!) in pointing to the heavens should drink once", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        
        
        newCard.categoryLabel.text = "HEAVEN"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Heaven is a card that gives the player named on the card the power of the Gods.\n\nThe player named on the card can point to the sky at any point during the game. The last player to notice that the named player has done this and follow them in doing so, should drink once.\n\nThis can be repeated by the player named on the card at any point throughout the game, an indefinite amount."
        newCard.backgroundColor = #colorLiteral(red: 0.8431372549, green: 0.1490196078, blue: 0.2392156863, alpha: 1)
        
        return newCard
    }
    
    fileprivate func getDownIt() -> CardView {
        let newCard = CardView()
        let cardText = NSMutableAttributedString(string: "It's the end of the round. Let's finish the game with a bang!", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)])
        cardText.append(NSAttributedString(string: "\n\n\(players.randomElement()!)\n\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]))
        cardText.append(NSAttributedString(string: "Should now down their drink", attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]))
        
        newCard.categoryLabel.text = "DOWN IT"
        newCard.textLabel.attributedText = cardText
        newCard.helpText = "Down It is the last card found in every game of Card Master. The player named on the card should finish their drink.\n\nIf the player refuses to do so, they should face a forfeit decided upon by the other players.\n\nPlease drink responsibly."
        newCard.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return newCard
    }
    
    // MARK: - Building Deck
    
    let nhieCount = 8
    let mostLikelyCount = 3
    let categoriesCount = 2
    let triviaCount = 4

    func buildDeck() -> [CardView] {
        var deck: [CardView] = []
        var firstPart: [CardView] = []
        var middlePart: [CardView] = []
        var lastPart: [CardView] = []

        // 8x NHIE
        firstPart.append(getNeverHaveIEver())
        firstPart.append(getNeverHaveIEver())
        firstPart.append(getNeverHaveIEver())
        middlePart.append(getNeverHaveIEver())
        middlePart.append(getNeverHaveIEver())
        middlePart.append(getNeverHaveIEver())
        lastPart.append(getNeverHaveIEver())
        lastPart.append(getNeverHaveIEver())

        // 3x Most Likely To
        firstPart.append(getMostLikelyTo())
        middlePart.append(getMostLikelyTo())
        lastPart.append(getMostLikelyTo())

        // 2x Categories
        firstPart.append(getCategories())
        lastPart.append(getCategories())

        // 4x Trivia
        if Int.random(in: 0...1) == 1 {
            firstPart.append(getTrivia())
            firstPart.append(getTrivia())
            middlePart.append(getTrivia())
        } else {
            firstPart.append(getTrivia())
            middlePart.append(getTrivia())
            middlePart.append(getTrivia())
        }
        lastPart.append(getTrivia())

        if Int.random(in: 0...1) == 1 {
            firstPart.append(getGender(isGuys: true))
            lastPart.append(getGender(isGuys: false))
        } else {
            firstPart.append(getGender(isGuys: false))
            lastPart.append(getGender(isGuys: true))
        }

        if Int.random(in: 0...1) == 1 {
            firstPart.append(getWaterfall())
        } else {
            middlePart.append(getWaterfall())
        }

        if players.count > 2 {
            if Int.random(in: 0...10) < 7 {
                firstPart.append(getThumbMaster())
            } else {
                middlePart.append(getThumbMaster())
            }
        }

        if Int.random(in: 0...10) < 7 {
            firstPart.append(getQuestionMaster())
        } else {
            middlePart.append(getQuestionMaster())
        }

        if players.count > 2 {
            if Int.random(in: 0...10) < 7 {
                firstPart.append(getHeaven())
            } else {
                middlePart.append(getHeaven())
            }
        }

        for i in (0..<min(players.count-1, 4)) {
            if (i % 2) == 0 {
                firstPart.append(getPickAMate())
            } else {
                middlePart.append(getPickAMate())
            }
        }

        firstPart.shuffle()
        middlePart.shuffle()
        lastPart.shuffle()

        deck.append(getDownIt())
        deck.append(contentsOf: lastPart)
        deck.append(contentsOf: middlePart)
        deck.append(contentsOf: firstPart)

        print(deck.count)

        print("First: \(firstPart.count)")
        print("Last: \(middlePart.count)")
        print("End: \(lastPart.count)")
        
//        deck.append(getDownIt())
//        deck.append(getTrivia())
//        deck.append(getPickAMate())
//        deck.append(getHeaven())
//        deck.append(getWaterfall())
//        deck.append(getCategories())
//        deck.append(getThumbMaster())
//        deck.append(getMostLikelyTo())
//        deck.append(getGender(isGuys: true))
//        deck.append(getQuestionMaster())
//        deck.append(getNeverHaveIEver())
        
//        for _ in (0..<nhie.count) {
//            deck.append(getNeverHaveIEver())
//        }
        
        saveArrays()
        
        return deck
    }
    
    fileprivate func generateDrinkSipsString() -> String {
        let randomInt = Int.random(in: 0..<100)
        if randomInt > 85 {
            return "four times"
        } else if randomInt > 55 {
            return "three times"
        } else if randomInt > 10 {
            return "twice"
        } else {
            return "once"
        }
    }
    
    // MARK: - Loading and Saving
    
    var nhie: [String] = []
    var mostLikely: [String] = []
    var categoriesActors: [String] = []
    var categoriesMusic: [String] = []
    var categoriesTVFilm: [String] = []
    var trivia: [String] = []
    
    fileprivate func loadCSV(forResource resource: String, forMinCount count: Int) -> [String]? {
        if let list = csvLoader(resource) {
            if list.count < count {
                UserDefaults.standard.set(nil, forKey: "used" + resource.capitalizingFirstLetter())
                
                if resource == "nhie" {
                    usedNhie.removeAll()
                } else if resource == "mostLikely" {
                    usedMostLikely.removeAll()
                } else if resource == "categoriesActors" {
                    usedCategoriesActors.removeAll()
                } else if resource == "categoriesMusic" {
                    usedCategoriesMusic.removeAll()
                } else if resource == "categoriesTVFilm" {
                    usedCategoriesTVFilm.removeAll()
                } else if resource == "trivia" {
                    usedTrivia.removeAll()
                }
                
                return csvLoader(resource)
            } else {
                return list
            }
        } else {
            return nil
        }
    }
    
    fileprivate func csvLoader(_ resource: String) -> [String]? {
        let defaults = UserDefaults.standard
        let array = defaults.stringArray(forKey: "used" + resource.capitalizingFirstLetter())
        
        do {
            let file = try String(contentsOf: Bundle.main.url(forResource: resource, withExtension: "csv")!)
            var list: [String] = []
            for row in file.components(separatedBy: .newlines) {
                if row.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    if array == nil {
                        list.append(row)
                    } else {
                        if !array!.contains(row) {
                            list.append(row)
                        }
                    }
                }
            }
            return list
        } catch {
            print(error)
            return nil
        }
    }
    
    var usedNhie: [String] = []
    var usedMostLikely: [String] = []
    var usedCategoriesActors: [String] = []
    var usedCategoriesMusic: [String] = []
    var usedCategoriesTVFilm: [String] = []
    var usedTrivia: [String] = []
    
    fileprivate func loadArrays() {
        let defaults = UserDefaults.standard
        if let array = defaults.stringArray(forKey: "usedNhie") {
            usedNhie = array
        }
        if let array = defaults.stringArray(forKey: "usedMostLikely") {
            usedMostLikely = array
        }
        if let array = defaults.stringArray(forKey: "usedCategoriesActors") {
            usedCategoriesActors = array
        }
        if let array = defaults.stringArray(forKey: "usedCategoriesMusic") {
            usedCategoriesMusic = array
        }
        if let array = defaults.stringArray(forKey: "usedCategoriesTVFilm") {
            usedCategoriesTVFilm = array
        }
        if let array = defaults.stringArray(forKey: "usedTrivia") {
            usedTrivia = array
        }
        
    }
    
    fileprivate func saveArrays() {
        let defaults = UserDefaults.standard
        defaults.set(usedNhie, forKey: "usedNhie")
        defaults.set(usedMostLikely, forKey: "usedMostLikely")
        defaults.set(usedCategoriesActors, forKey: "usedCategoriesActors")
        defaults.set(usedCategoriesMusic, forKey: "usedCategoriesMusic")
        defaults.set(usedCategoriesTVFilm, forKey: "usedCategoriesTVFilm")
        defaults.set(usedTrivia, forKey: "usedTrivia")
        
//        defaults.set(nil, forKey: "usedNhie")
//        defaults.set(nil, forKey: "usedMostLikely")
//        defaults.set(nil, forKey: "usedCategoriesActors")
//        defaults.set(nil, forKey: "usedCategoriesMusic")
//        defaults.set(nil, forKey: "usedCategoriesTVFilm")
//        defaults.set(nil, forKey: "usedTrivia")
    }
}
