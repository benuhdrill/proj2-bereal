//
//  PostViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import PhotosUI
import ParseSwift
// TODO: Import Photos UI

// TODO: Import Parse Swift

class PostViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!

    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onPickedImageTapped(_ sender: UIBarButtonItem) {
        // TODO: Pt 1 - Present Image picker
      
        var config = PHPickerConfiguration()

        config.filter = .images

        config.preferredAssetRepresentationMode = .current

        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)

        picker.delegate = self

        // Present the picker
        present(picker, animated: true)

        
        func viewDidLoad() {
            super.viewDidLoad()

            // Set the title for the navigation bar
            self.title = "My Page"


            // Set the title text attributes to change color and font size
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
               
            ]
        }

    }

    @IBAction func onShareTapped(_ sender: Any) {

        // Dismiss Keyboard
        view.endEditing(true)

        guard let image = pickedImage,

                let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()

        post.imageFile = imageFile
        post.caption = captionTextField.text

        post.user = User.current

        post.save { [weak self] result in

            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")

                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }

    }

    @IBAction func onViewTapped(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated:true)
        
        guard let provider = results.first?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

           guard let image = object as? UIImage else {

             
              self?.showAlert()
              return
           }

           if let error = error {
               self?.showAlert(description: error.localizedDescription)
              return
           } else {

              DispatchQueue.main.async {

                 self?.previewImageView.image = image

                 self?.pickedImage = image
              }
           }
        }

    }
    

}
