//
//  ViewController.swift
//  Word Scramble
//
//  Created by Nadya Postriganova on 24/3/19.
//  Copyright © 2019 Nadya Postriganova. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
  var allWords = [String]()
  var usedWords = [String]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptAnswer))
    if let startWordsListURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      if let startWords = try? String(contentsOf: startWordsListURL) {
        allWords = startWords.components(separatedBy: "\n")
      }
      
      navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "New word", style: .plain, target: self, action: #selector(startGame))
    }
    if allWords.isEmpty {
      allWords = ["silkworm"]
    }
    startGame()
  }
  @objc func startGame() {
    title = allWords.randomElement()
    usedWords.removeAll(keepingCapacity: true)
    tableView.reloadData()
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usedWords.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
    cell.textLabel?.text = usedWords[indexPath.row]
    return cell
  }
  @objc func promptAnswer() {
    let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
    ac.addTextField()
    let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
      guard let answer = ac?.textFields?[0].text else { return }
      self?.submit(answer.lowercased())
    }
    ac.addAction(submitAction)
    present(ac, animated: true)
  }
  
  func submit(_ answer: String) {
    
    if isPosible(word: answer) {
      if isOriginal(word: answer) {
        if isReal(word: answer) {
          usedWords.insert(answer, at: 0)
          
          let indexPath = IndexPath(row: 0, section: 0)
          tableView.insertRows(at: [indexPath], with: .automatic)
          return
        } else {
          showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
        }
      } else {
        showErrorMessage(title: "Word used already", message: "Be more original!")
      }
    } else {
      showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title!.lowercased())")
    }
    
  }
  
  func isPosible(word: String) -> Bool {
    guard var tempWord = title?.lowercased() else { return false }
    
    for letter in word {
      if let position = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: position)
      } else {
        return false
      }
    }
    return true
  }
  
  func isOriginal(word: String) -> Bool {
    return !usedWords.contains(word)
  }
  
  func isReal(word: String) -> Bool {
    if word.count < 3 || word == title {
      return false
    }
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    return misspelledRange.location == NSNotFound
  }
  
  func showErrorMessage(title: String, message: String) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Ok", style: .default))
    present(ac, animated: true)
  }
}

