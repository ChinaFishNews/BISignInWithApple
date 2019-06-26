/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Login view controller.
*/


/*
 ASAuthorizationAppleIDProvider ： 一种机制，用于根据用户的Apple ID生成对用户进行身份验证的请求
 ASAuthorizationController： 管理提供程序创建的授权请求的控制器
 ASAuthorizationAppleIDCredential：由成功的Apple ID身份验证产生的凭据
*/


import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProviderLoginView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
    }
    
    func setupProviderLoginView() {
        // Sign in with Apple按钮
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    /// 用户是否找到现有的iCloud密钥凭据或Apple ID凭据
    func performExistingAccountSetupFlows() {
        // 为苹果ID和密码提供者准备请求
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // 使用给定的请求创建授权控制器
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email // 只有第一次返回，之后返回nil
            
            // 在系统中创建一个帐户,将userIdentifier存储在keychain中
            do {
                try KeychainItem(service: "com.developer.baidu.juice", account: "userIdentifier").saveItem(userIdentifier)
            } catch {
                print("Unable to save userIdentifier to keychain.")
            }
            
            // 在ResultViewController中显示Apple ID凭据信息
            if let viewController = self.presentingViewController as? ResultViewController {
                DispatchQueue.main.async {
                    viewController.userIdentifierLabel.text = userIdentifier
                    if let givenName = fullName?.givenName {
                        viewController.givenNameLabel.text = givenName
                    }
                    if let familyName = fullName?.familyName {
                        viewController.familyNameLabel.text = familyName
                    }
                    if let email = email {
                        viewController.emailLabel.text = email
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // 使用现有的iCloud密钥凭据登录
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            DispatchQueue.main.async {
                let message = "应用程序已经从钥匙串接收到您选择的凭据 \n\n Username: \(username)\n Password: \(password)"
                let alertController = UIAlertController(title: "钥匙串凭证收到",
                                                        message: message,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error=\(error)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
