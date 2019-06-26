/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main application view controller.
*/

import UIKit
import AuthenticationServices

class ResultViewController: UIViewController {
    
    @IBOutlet weak var userIdentifierLabel: UILabel!
    @IBOutlet weak var givenNameLabel: UILabel!
    @IBOutlet weak var familyNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdentifierLabel.text = KeychainItem.currentUserIdentifier
    }
    
    @IBAction func signOutButtonPressed() {
        // 删除之前存储在钥匙串中的用户标识符
        KeychainItem.deleteUserIdentifierFromKeychain()
        
        userIdentifierLabel.text = ""
        givenNameLabel.text = ""
        familyNameLabel.text = ""
        emailLabel.text = ""
        
        // 显示登陆控制器
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController
                else { return }
            viewController.modalPresentationStyle = .formSheet
            viewController.isModalInPresentation = true
            self.present(viewController, animated: true, completion: nil)
        }
    }
}
