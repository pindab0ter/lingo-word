//
//  LingoWordSolver.swift
//  LingoWord
//
//  Created by Hans van Luttikhuizen-Ross on 09/01/2021.
//

import Foundation

struct LingoWordSolver {
    let minimumWordLength = 5
    let maximumWordLength = 14
    
    // TODO: Load each word length in separate array/map entry
    private let candidateLists: [Int: [String]]
    
    init() {
        let fileName = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let contents = try! String(contentsOfFile: fileName!, encoding: String.Encoding.utf8)
        let lines = contents.components(separatedBy: "\n")
        candidateLists = Dictionary(uniqueKeysWithValues: (minimumWordLength...maximumWordLength).map { index in
            (index, lines.filter { line in
                line.count == index
            })
        })
    }
    
    func solve(_ word: Word) -> [String] {
        if let candidates = candidateLists[word.count] {
            return candidates.filter { candidate in
                // TODO: Prevent reusing letters
                candidate.count == word.count
                    && word.incorrectLetters.allSatisfy { incorrectLetter in !candidate.contains(incorrectLetter) }
                    && word.unplacedLetters.allSatisfy { unplacedLetter in candidate.contains(unplacedLetter) }
                    && word.placedLetters.allSatisfy { (letter, index) in
                        candidate[candidate.index(candidate.startIndex, offsetBy: index)] == letter
                    }
            }
        } else {
            return []
        }
    }
}

enum Letter: Identifiable {
    case placed(Int, Character, Int)
    case unplaced(Int, Character)
    case incorrect(Int, Character)
    case unknown(Int)
    
    var id: Int {
        switch self {
        case .placed(let id, _, _):
            return id
        case .unplaced(let id, _):
            return id
        case .incorrect(let id, _):
            return id
        case .unknown(let id):
            return id
        }
    }
}

typealias Word = [Letter]
typealias PlacedLetter = (Character, Int)

extension Word {
    var placedLetters: [PlacedLetter] {
        return compactMap { letter in
            switch letter {
            case .placed(_, let character, let index):
                return (character, index)
            default:
                return nil
            }
        }
    }
    var unplacedLetters: [Character] {
        return compactMap { letter in
            switch letter {
            case .unplaced(_, let character):
                return character
            default:
                return nil
            }
        }
    }
    var incorrectLetters: [Character] {
        return compactMap { letter in
            switch letter {
            case .incorrect(_, let character):
                return character
            default:
                return nil
            }
        }
    }
}
