//
//  ViewController.swift
//  CoreDataTodo
//
//  Created by Aman Verma on 10/02/23.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models=[TodoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title="ToDo App"
        getAllItem()
        view.addSubview(tableView)
        tableView.delegate=self
        tableView.dataSource=self
        tableView.frame=view.bounds
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd(){
        let alert=UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .default,handler: { [weak self] _ in
            guard let field = alert.textFields?.first,let text=field.text, !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
        }))
        present(alert,animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model=models[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text=model.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Actions", message: "Actions", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style:.cancel ))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default,handler: { [weak self] _ in
            let oldItem=item
            let alert=UIAlertController(title: "Edit", message: "Edit Item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text=oldItem.name
            alert.addAction(UIAlertAction(title: "Update", style: .default,handler: { [weak self] _ in
                guard let field = alert.textFields?.first,let newName=field.text, !newName.isEmpty else {
                    return
                }
                self?.updateItem(oldItem: oldItem,name:newName)
            }))
            self!.present(alert,animated: true)
        }))
        sheet.addAction(UIAlertAction(title:"Delete",style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
            
        }))
        present(sheet,animated: true)
        
    }
    


}

extension ViewController{
    
    func getAllItem(){
        do{
            models = try context.fetch(TodoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            //error
        }
    }
    
    func createItem(name:String){
        let newItem = TodoListItem(context: context)
        newItem.name = name
        newItem.createdAt=Date()
        
        do{
            try context.save()
            getAllItem()
        }catch{
            
        }
    }
    
    func deleteItem(item:TodoListItem){
        context.delete(item)
        getAllItem()
    }
    func updateItem(oldItem:TodoListItem,name:String){
        oldItem.name=name
        do{
            try context.save()
            getAllItem()
        }catch{
            
        }
    }
}

