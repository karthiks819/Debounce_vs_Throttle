//
//  ViewController.swift
//  DebounceAndThrottleExample
//
//  Created by Karthik Solleti on 08/01/26.
//

import UIKit
import Combine


class ViewController: UIViewController {
    @IBOutlet weak var debounceTF: UITextField!
    @IBOutlet weak var throttleTF: UITextField!
    
    @IBOutlet weak var debounceLabel: UILabel!
    @IBOutlet weak var throttleLabel: UILabel!
    
    var subscriptions: Set<AnyCancellable> = []
    var debouncePublisher = PassthroughSubject<String, Never>()
    var throttlePublisher = PassthroughSubject<String, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        debouncePublisher
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .sink(receiveValue: {print("Debounce: \($0)")
                self.debounceLabel.text = "Debounce time interval is 1 second and received val is: \($0)"})
            .store(in: &subscriptions)
        
        throttlePublisher
            .throttle(for: .seconds(1.0), scheduler: RunLoop.main, latest: true)
            .sink(receiveValue: {print("throttle \($0)")
                self.throttleLabel.text = "Throttle val received:  \($0)"})
            .store(in: &subscriptions)
        
    }

    
    @IBAction func debounceTFAction(_ sender: UITextField) {
        if sender.tag == 0 {
            debouncePublisher.send(sender.text ?? "")
        }else {
            throttlePublisher.send(sender.text ?? "")
        }
    }
}



extension ViewController: UITextFieldDelegate {
    
}
