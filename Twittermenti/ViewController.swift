//
//  ViewController.swift
//  Twittermenti
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let swifter = Swifter(consumerKey: "dUqFwWUUf0V4F9J9hqf6bZY2L", consumerSecret: "Wv3mbEfFRIsYFzlfFeKuVuN3b8ot2DAYwGBg15BAT2v9KOydrW")
    let sentimentClassifier = TweetSentimentClassifier()
    let tweetCount = 100
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    
    func fetchTweets(){
        if let txt = textField.text{
            swifter.searchTweet(using: txt, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
                
            } failure: { (error) in
                print("There was a failure searching Tweet: \(error)")
            }
        }
    }
    
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]){
        do{
            let predictions =  try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for pred in predictions{
                let sentiment = pred.label
                if sentiment == "Pos"{
                    sentimentScore += 1
                }
                else if sentiment == "Neg"{
                    sentimentScore -= 1
                }
                updateUI(with: sentimentScore)
            }
        }
        catch{
            print("There was a failure making a prediction: \(error)")
        }
        
    }
    func updateUI(with sentimentScore: Int){
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
        print(sentimentScore)
        
    }
    
}

