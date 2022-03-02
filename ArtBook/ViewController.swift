//
//  ViewController.swift
//  ArtBook
//
//  Created by ferhatiltas on 2.03.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var nameList : [String] = [String]()
    var idList : [UUID] = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId : UUID?

    
    override func viewDidLoad() {// viewDidLoad sadece bir defa render edilir viewWillAppear ise her gidis geliste tetiklenir
        super.viewDidLoad()
        getData()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClick)) // added button inn app bar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //viewWillAppear  her gidis geliste tetiklenir
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue:"newData"), object: nil) // tetikleme islemi oldugunda getData calistir newData nin tanimlandigi yerden geldiginde
    }
    
   @objc func getData(){
       nameList.removeAll()
       idList.removeAll()
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
        fetchRequest.returnsDistinctResults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameList.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idList.append(id)
                    }
                    self.tableView.reloadData() // yeni veri eklendigi zaman tetikle

                }
            }
            print("SUCCESS")
        }catch{
            print("ERROR")

        }
    }
    
    @objc func addButtonClick(){
        selectedPainting = "" // eklemek icin gittigini bilsin ona gore kosulu saglasin
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameList[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
        if segue.identifier == "toDetailsVC"{ // verileri ilgili sinifa gonder
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameList[indexPath.row] // veri gonderip verileri gorsellestirmek icin
        selectedPaintingId = idList[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                       let context = appDelegate.persistentContainer.viewContext
                       let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
                       let idString = idList[indexPath.row].uuidString
                       fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
                       fetchRequest.returnsObjectsAsFaults = false
                       do {
                       let results = try context.fetch(fetchRequest)
                           if results.count > 0 {
                               for result in results as! [NSManagedObject] {
                                   if let id = result.value(forKey: "id") as? UUID {
                                       if id == idList[indexPath.row] {
                                           context.delete(result)
                                           nameList.remove(at: indexPath.row)
                                           idList.remove(at: indexPath.row)
                                           self.tableView.reloadData()
                                           do {
                                               try context.save()
                                           } catch {
                                               print("error")
                                           }
                                           break
                                       }
                                   }
                               }
                           }
                       } catch {
                           print("error")
                       }
                       
        }
    }
    
}

