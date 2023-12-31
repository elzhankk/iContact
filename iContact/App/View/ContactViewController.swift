//
//  ContactViewController.swift
//  iContact
//
//  Created by elzhankk on 23.11.2023.
//

import UIKit
protocol ContactViewControllerDelegate {
    func contactWasDeleted()
}

class ContactViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var initialsLabel: UILabel!
    
    @IBOutlet weak var initialsContainerView: UIView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumberBtn: UIButton!
    
    @IBOutlet weak var undoDeleteButton: UIButton!
    
    @IBOutlet weak var deleteContactButton: UIButton!
    
    @IBOutlet weak var messageStackView: UIStackView!
    
    @IBOutlet weak var callStackView: UIStackView!
    
    @IBOutlet weak var videoStackView: UIStackView!
    
    @IBOutlet weak var mailStackView: UIStackView!
    
    @IBOutlet weak var phoneStackView: UIStackView!
    
    var contact: Contact!
    let contactManager = ContactManager()
    var timer: Timer?
    var countDown: Int = 0
    var countDownTotal: Int = 5
    
    var delegate: ContactViewControllerDelegate?
    var wasDeleted: ((Bool) ->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    setupContactContent()
    
    messageStackView.layer.cornerRadius = 5
    callStackView.layer.cornerRadius = 5
    videoStackView.layer.cornerRadius = 5
    mailStackView.layer.cornerRadius = 5
    phoneStackView.layer.cornerRadius = 5
    undoDeleteButton.layer.cornerRadius = 5
    deleteContactButton.layer.cornerRadius = 5
    
    // Добавляет кнопку в NavigationItem
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContact))
}

override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    initialsContainerView.layer.cornerRadius = initialsContainerView.frame.height / 2
}

func setupContactContent() {
    initialsLabel.text = "\(contact.firstName.first!)\(contact.lastName.first!)"
    fullNameLabel.text = "\(contact.firstName) \(contact.lastName)"
    phoneNumberBtn.setTitle(contact.phone, for: .normal)
}

@objc
func editContact() {
    let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
    alertController.addTextField { textField in
        textField.text = self.contact.firstName
    }
    alertController.addTextField { textField in
        textField.text = self.contact.lastName
    }
    alertController.addTextField { textField in
        textField.text = self.contact.phone
    }
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
        let firstName: String = alertController.textFields![0].text!
        let lastName: String = alertController.textFields![1].text!
        let phone: String = alertController.textFields![2].text!
        
        let editedContact = Contact(firstName: firstName, lastName: lastName, phone: phone)
        self.save(editedContact: editedContact)
    }
    alertController.addAction(saveAction)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true)
}

    @IBAction func callButtonTapped(_ sender: UIButton) {
        open(contactType: .call)
        }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        open(contactType: .message)
    }
    
    @IBAction func faceTimeButtonTapped(_ sender: UIButton) {
        open(contactType: .faceTime)
    }
    
    @IBAction func undoDeleteButtonTapped(_ sender: UIButton) {
        
        timer?.invalidate()
        
        progressView.progress = 1
        progressView.isHidden = true
        undoDeleteButton.isHidden = true
        deleteContactButton.isHidden = false
        
        contactManager.add(contact: contact)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteContact()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // Открывает приложения на iPhone/iPad с указанным ContactType
    func open(contactType: ContactType) {
        
        // Извлекается номер телефона
        let phone = contact.phone
        // Удаляются все символы '+' из сторки phone
        let phoneWithoutPlus = phone.replacingOccurrences(of: "+", with: "")
        // Удаляются все символы ' ' (пробелы) из сторки phoneWithoutPlus
        let phoneWithoutSpacing = phoneWithoutPlus.replacingOccurrences(of: " ", with: "")
        // Создается сторка которая указывает путь к приложению
        let urlString: String = "\(contactType.urlScheme)" + phoneWithoutSpacing
        
        // Проверяется на преображение сторки urlString в URL
        guard let url = URL(string: urlString) else {
            return
        }
        // Открывает приложение на iPhone/iPad с указанным путем. Например: "tel://77082968612" приложение контакты и позвонит на указанный номер
        UIApplication.shared.open(url)
    }
    
    func save(editedContact: Contact) {
        contactManager.edit(contactToEdit: contact, editedContact: editedContact)
        contact = editedContact
        setupContactContent()
    }
    
    func deleteContact() {
        contactManager.delete(contactToDelete: self.contact)
        
        deleteContactButton.isHidden = true
        undoDeleteButton.isHidden = false
        progressView.progress = 1
        progressView.isHidden = false
        
        scheduleTimer()
    }
    
    func scheduleTimer() {
        countDown = countDownTotal
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateProgressView() {
        
        countDown -= 1
        progressView.progress = Float(countDown)/Float(countDownTotal)
        
        if countDown == 0 {
            
            timer?.invalidate()
            navigationController?.popViewController(animated: true)
            delegate?.contactWasDeleted()
            wasDeleted?(true)
        }
    }
}


enum ContactType {
    case message
    case call
    case faceTime
    
    var urlScheme: String {
        switch self {
        case .message:
            return "sms://"
        case .call:
            return "tel://"
        case .faceTime:
            return "facetime://"
        }
    }
}
