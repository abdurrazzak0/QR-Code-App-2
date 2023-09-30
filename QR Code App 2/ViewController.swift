//
//  ViewController.swift
//  QR Code App 2
//
//  Created by Abdur Razzak on 27/9/23.
//

import UIKit
import AVFoundation
import CoreData
import PhotosUI

class ViewController: UIViewController {
    
    @IBOutlet weak var qrFileBarButton: UIBarButtonItem!
    @IBOutlet weak var qrimageView: UIImageView!
    @IBOutlet weak var getTextButton: UIButton!
    @IBOutlet weak var qrListTableView: UITableView!
    
    private let cellIdentifier: String = "qrCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var imageArray = UIImage()
    
    var getData = ""
    
    var items: [QRCode]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        qrListTableView.dataSource = self
        qrListTableView.delegate = self
        
        self.qrListTableView.register(UINib(nibName: "DataTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        
    }
    
    @IBAction func qrFileBarButtonAction(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        let pickerVC = PHPickerViewController(configuration: config)
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)
    }
    
    
    
    @IBAction func getTextButtonAction(_ sender: Any) {
        if let features = detectQRCode(imageArray), !features.isEmpty{
            for case let row as CIQRCodeFeature in features{
                getData = row.messageString ?? "nope"
                print(getData)
            }
            let actionController = UIAlertController(title: "Add New text", message : "Enter text Info...!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
                if actionController.textFields![0].text == "" {
                    print("Enter Name")
                } else {
                    print("OK")
                }
                if actionController.textFields![1].text == "" {
                    print("Enter text")
                } else {
                    let newText = QRCode(context: self.context)
                    newText.name = actionController.textFields![0].text
                    newText.descriptions = actionController.textFields![1].text
                    
                    
                    
                    do {
                        try self.context.save()
                    } catch {
                        
                    }
                }
                
            } )
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            actionController.addAction(okAction)
            actionController.addAction(cancelAction)
            
            
            actionController.addTextField { [weak self] textField -> Void in
                textField.text = self?.getData
            }
            
            actionController.addTextField { [weak self] textField -> Void in
                textField.text = self?.getData
            }
            
            self.present(actionController, animated: true, completion: nil)
        } else {
            let refreshAlert = UIAlertController(title: "NO QR Image", message: "No QR Code found! ", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
}


func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
    if let image = image, let ciImage = CIImage.init(image: image){
        var options: [String: Any]
        let context = CIContext()
        options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
            options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation: 1]
        }
        let features = qrDetector?.features(in: ciImage, options: options)
        return features
        
    }
    return nil
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as?
            DataTableViewCell {
            cell.configurateTheCell(items![indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let qrText = self.items![indexPath.row]
        
        let actionController = UIAlertController(title: "Edit QR Text", message : "Enter Text Info...!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            if actionController.textFields![0].text == "" {
                print("Enter Name")
            } else {
                print("OK")
            }
            if actionController.textFields![1].text == "" {
                print("Enter Descriptions")     // You refuse OK
            } else {
                
                qrText.name = actionController.textFields![0].text
                qrText.descriptions = actionController.textFields![1].text
                
                
                
                do {
                    try self.context.save()
                } catch {
                    
                }
                
                
            }
            
        } )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        actionController.addAction(okAction)
        actionController.addAction(cancelAction)
        
        actionController.addTextField { textField -> Void in
            textField.text = qrText.name
        }
        
        actionController.addTextField { textField -> Void in
            textField.text = qrText.descriptions
        }
        
        self.present(actionController, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let personTORemove = self.items![indexPath.row]
            
            
            self.context.delete(personTORemove)
            
            do {
                try self.context.save()
            } catch {
                
            }
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    self.imageArray = image
                }
                
                DispatchQueue.main.async { [self] in
                    self.qrimageView.image = imageArray
                }
            }
        }
    }
}




extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        imageArray = image
        DispatchQueue.main.async { [self] in
            self.qrimageView.image = image
        }
    }
    
}
