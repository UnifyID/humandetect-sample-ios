// Copyright © 2020 UnifyID, Inc. All rights reserved.
// Unauthorized copying or excerpting via any medium is strictly prohibited.
// Proprietary and confidential.

import UIKit
import HumanDetect

let flaskURL = "http://humandetect-example-flask.herokuapp.com/"
let humanDetect = unify.humanDetect
var vSpinner : UIView?

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var imagePicker: UIImagePickerController!
    @IBOutlet weak var imageView: UIImageView!
    
    /*
     Begins HumanDetect data capture once the main view loads
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        humanDetect.startPassiveCapture()
    }

    /*
     Uses UIImagePickerController to take a picture
     */
    @IBAction func takePhoto(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    /*
     Displays a spinner that blocks the view
     Used after an image is taken while waiting for the POST request to finish
     */
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    /*
     Removes the spinner
     Used after the POST request is completed
     */
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
    
    /*
     Creates an alert popup
     Used to display the response from the POST request
     */
    func showAlert(ttl: String, msg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: ttl, message: msg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Updating imageView and displaying spinner
        imagePicker.dismiss(animated: true, completion: nil)
        self.showSpinner(onView: self.view)
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        
        // HumanDetect token generation
        switch humanDetect.getPassive() {
            case .success(let humanDetectToken):
                
                // Creating POST request
                let fieldName = "token"
                let fieldValue = humanDetectToken.token
                let filename = "image.png"
                let boundary = UUID().uuidString
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                var urlRequest = URLRequest(url: URL(string: flaskURL)!)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                var data = Data()
                
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(fieldValue)".data(using: .utf8)!)
                
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                data.append(image.pngData()!)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                // POST request to Flask server
                session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
                    if(error != nil){
                        self.removeSpinner()
                        self.showAlert(ttl: "Error", msg: "\(error!.localizedDescription)")
                    }
                    
                    guard let responseData = responseData else {
                        self.removeSpinner()
                        self.showAlert(ttl: "Error", msg: "No response data")
                        return
                    }
                    
                    if let responseString = String(data: responseData, encoding: .utf8) {
                        self.removeSpinner()
                        self.showAlert(ttl: "Success", msg: responseString)
                    }
                }).resume()
            
            case .failure(let error):
              self.removeSpinner()
              self.showAlert(ttl: "Error", msg: "Could not generate HumanDetect token: \(error)")
        }
    }
}

