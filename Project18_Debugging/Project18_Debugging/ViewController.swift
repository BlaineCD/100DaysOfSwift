//
//  ViewController.swift
//  Project18_Debugging
//
//  Created by Blaine Dannheisser on 2/10/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        print("I'm inside the viewDidLoad() method.")
//        print(1, 2, 3, 4, 5)
//        print(5, 6, 7, 8, 9, separator: "-")
//        print("Some message", terminator: "")

//        assert(1 == 1, "Math failure!")
//        assert(1 == 2, "Math failure!")
//        assert(thisRandomMethod() == true, "The random method returned false!")

        for i in 1 ... 100 {
            print("Got number \(i)")
        }

    }


}

