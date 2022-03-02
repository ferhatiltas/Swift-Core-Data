//
//  DetailsVC.swift
//  ArtBook
//
//  Created by ferhatiltas on 2.03.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    override func viewDidLoad() { 
        super.viewDidLoad()
        
        if chosenPainting != ""{
            saveButton.isHidden = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                       let context = appDelegate.persistentContainer.viewContext
                       
                       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
                       let idString = chosenPaintingId?.uuidString
                       fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
                       fetchRequest.returnsObjectsAsFaults = false
                       
                       do {
                          let results = try context.fetch(fetchRequest)
                           
                           if results.count > 0 {
                               
                               for result in results as! [NSManagedObject] {
                                   
                                   if let name = result.value(forKey: "name") as? String {
                                       nameTextField.text = name
                                   }

                                   if let artist = result.value(forKey: "artist") as? String {
                                       artistTextField.text = artist
                                   }
                                   
                                   if let year = result.value(forKey: "year") as? Int {
                                       yearTextField.text = String(year)
                                   }
                                   
                                   if let imageData = result.value(forKey: "image") as? Data {
                                       let image = UIImage(data: imageData)
                                       imageView.image = image
                                   }
                                   
                               }
                           }

                       } catch{
                           print("error")
                       }
        }
        else{
            saveButton.isEnabled = false
        }
        
        
        // recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer) // for closed keyboard
        
        view.isUserInteractionEnabled = true // kullanici resim tiklayabilir
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        view.addGestureRecognizer(imageTapRecognizer)
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        // verileri core dataya kayit edecegiz
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // core data ya ulasabilmek icin
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        newPainting.setValue(artistTextField.text, forKey: "artist")
        newPainting.setValue(nameTextField.text, forKey: "name")
        newPainting.setValue(UUID(), forKey: "id")
        if let year = Int(yearTextField.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")

        do {//context.save throw oldugu icin hata firlatir do-try catch icine almak lazim
            try context.save()
            print("SUCCESS")
        }catch{
            print("ERROR")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)// geri dondugunde getData tetikle verileri cek
        self.navigationController?.popViewController(animated: true) // bir onceki sayfaya geri donmesini sagla
         
    }
    
    @objc func hideKeyboard(){// for closed keyboard
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        // kullanicinin resim secmesini saglayacagiz
         let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        saveButton.isEnabled = true
    }
    
}
