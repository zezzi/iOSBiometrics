//
//  ViewController.swift
//  BiometricsDemo
//
//  Created by Castillo, Ana on 8/16/21.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userView: UIImageView!
    @IBOutlet weak var faceIDLabel: UILabel!

    ///A Context is used at ViewController level for use during UI updates.
    var context = LAContext()

    enum AuthenticationState {
        case loggedin, loggedout
    }

    var state = AuthenticationState.loggedout {
        didSet {
            loginButton.isHighlighted = state == .loggedin
            showImage(authenthicated: state)
            faceIDLabel.isHidden = (state == .loggedin) || (context.biometryType != .faceID)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        state = .loggedout
    }


    @IBAction func tapButton(_ sender: UIButton) {
        if state == .loggedin {
            state = .loggedout
        } else {
            context = LAContext()
            context.localizedCancelTitle = "Enter Username/Password"
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "Log in to your account"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [unowned self] success, error in
                    if success {
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedin
                        }
                    } else {
                        self.showImage(authenthicated: .loggedout)
                        print(error?.localizedDescription ?? "Failed to authenticate")
                    }
                }
            } else {
                self.showImage(authenthicated: .loggedout)
                print(error?.localizedDescription ?? "Can't evaluate policy")
            }
        }
    }

    func showImage(authenthicated: AuthenticationState) {
        DispatchQueue.main.async { [unowned self] in
            let imageName = state == .loggedin ? "user" : "ninja"
            userView.image = UIImage(named: imageName)
        }
    }
}

