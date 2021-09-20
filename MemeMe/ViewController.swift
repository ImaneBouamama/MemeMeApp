//
//  ViewController.swift
//  MemeMe
//
//  Created by Imane BOUAMAMA on 2021/09/14.
//

import UIKit

struct MemeModel {
    var image: UIImage!
    var topMeme: String!
    var bottomMeme: String!
    var memedImage: UIImage!
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var topTextField: UITextField!
    @IBOutlet var bottomTextField: UITextField!
    var memedImageToBeSaved: MemeModel!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -10
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpTextField( textField: topTextField, text: "Top" )
        self.setUpTextField( textField: bottomTextField, text: "Bottom" )
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable( .camera )
        imageView.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
        subscribeToKeyboardNotification()
        subscribeToKeyboardHidingNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated )
        unsubscribeFromKeyBoardNotification()
        unsubscribeFromKeyBoardHidingNotification()
    }

    func setUpTextField( textField: UITextField, text: String ) {
        textField.textAlignment = .center
        textField.delegate = self
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
    }
    
    func pickAnImageFrom ( sourceType : UIImagePickerController.SourceType ) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.present( pickerController, animated: true, completion: nil )
    }
    
    @IBAction func PickAnImage( _ sender: Any ) {
        pickAnImageFrom( sourceType: .photoLibrary )
    }
    
    @IBAction func PickACameraImage( _ sender: UIButton ) {
        pickAnImageFrom( sourceType: .camera )
    }
    
    @IBAction func shareButtonClicked( _ sender: UIButton ) {
        let screenShot = takeScreenshotOfTheView()
        memedImageToBeSaved = MemeModel(  )
        let shareImageController = UIActivityViewController( activityItems: [screenShot], applicationActivities: nil )
        shareImageController.completionWithItemsHandler = {
            ( acivity, completed, items, error ) in
            if completed{
                self.saveTheMemeImage( image: self.imageView.image!, topMeme: self.topTextField.text!, bottomMeme: self.bottomTextField.text!,  memedImage: screenShot )
            }
        }
        self.present( shareImageController, animated: true, completion: nil )
    }
    
    func saveTheMemeImage( image: UIImage, topMeme: String, bottomMeme: String, memedImage: UIImage) {
        memedImageToBeSaved = MemeModel( image: image,topMeme: topMeme, bottomMeme: bottomMeme, memedImage: memedImage )
    }
    
    //This function takes a screenshot of the current displayed view. It will be called to save the image with the user typed bottom and top memes
    func takeScreenshotOfTheView() -> UIImage {
        UIGraphicsBeginImageContextWithOptions( UIScreen.main.bounds.size, true, 0.0 )
        view.drawHierarchy( in: view.bounds, afterScreenUpdates: true )
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        image = cropImage( image: image )
        UIGraphicsEndImageContext()
        return image
    }
    
    func cropImage( image: UIImage ) -> UIImage {
      let refWidth = CGFloat( ( image.cgImage!.width ) )
      let refHeight = CGFloat( ( image.cgImage!.height ) )
      let refSize = refWidth > refHeight ? refWidth : refHeight
      let cropSize = 2 * refSize / 3
      let x = ( refWidth - cropSize ) / 2.0
      let refX = refWidth > refHeight ? 500 : 0
      let refY = refWidth > refHeight ? 20 : -200
      let cropRect = CGRect( x: x - CGFloat(refX),
                             y: self.view.center.y + CGFloat(refY),
                             width: refWidth,
                             height: refHeight - 350 )
      let imageRef = image.cgImage?.cropping( to: cropRect )
      return UIImage( cgImage: imageRef! )
    }
    
    func imagePickerController( _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any] ) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    imageView.image = image
            
                }
        
        dismiss( animated: true, completion: nil )
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func getKeyboardHeight( _ notification: Notification ) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow( _ notification: Notification ){
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = -getKeyboardHeight( notification )
        }
        
    }
    
    @objc func keyboardWillHide( _ notification: Notification ){
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = 0
        }
    }
    
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( keyboardWillShow ),
                                                name: UIResponder.keyboardWillShowNotification,
                                                object: nil )
    }
    
    func unsubscribeFromKeyBoardNotification() {
        NotificationCenter.default.removeObserver( self,
                                                   name: UIResponder.keyboardWillShowNotification,
                                                   object: nil )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField ) {
        textField.text = ""
            
        textField.textAlignment = .center
    }
    
    
    func subscribeToKeyboardHidingNotification() {
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( keyboardWillHide ),
                                                name: UIResponder.keyboardWillHideNotification,
                                                object: nil )
    }
    
    func unsubscribeFromKeyBoardHidingNotification() {
        NotificationCenter.default.removeObserver( self,
                                                   name: UIResponder.keyboardWillHideNotification,
                                                   object: nil )
    }
    
    @IBAction func cancel () {
        if ( self.imageView.animationDuration != nil ) {
            self.imageView.image = nil
        }
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
    }
}


