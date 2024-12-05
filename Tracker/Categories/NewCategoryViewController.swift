
import UIKit

// экран добавления новой категории
final class NewCategoryViewController: UIViewController {
    
    private var categoryName: String = ""
    private var updateCategories: ((String) -> Void)
    
    init(updateCategories: @escaping (String) -> Void) {
        self.updateCategories = updateCategories
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.backgroundColor = .ypShedule
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let leftIndent = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftIndent
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var longNameWarningLabel: UILabel = {
        let label = UILabel()
        label.text = String(
            format: NSLocalizedString(
                "warningLabel",
                comment: "Limit charaters"
            ),
            24
        )
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .red
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButtonView: CustomButton = {
        let button = CustomButton(type: .create, title: NSLocalizedString("doneButtonTitle", comment: "Done button"))
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
       
        
        view.addSubview(nameTextField)
        view.addSubview(longNameWarningLabel)
        view.addSubview(doneButtonView)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            longNameWarningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            longNameWarningLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            longNameWarningLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            longNameWarningLabel.heightAnchor.constraint(equalToConstant: 60),
            
            doneButtonView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            doneButtonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            doneButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButtonView.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        setupNavigationBar(title: NSLocalizedString("newCategoryScreenTitle", comment: "Add category"))
        
    }
    
    private func updateDoneButtonState() {
        doneButtonView.isEnabled = !categoryName.isEmpty
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let length = textField.text?.count {
            longNameWarningLabel.isHidden = length <= 24
        }
        
        if longNameWarningLabel.isHidden {
            self.categoryName = textField.text ?? ""
        } else {
            self.categoryName = ""
        }
        
        self.updateDoneButtonState()
    }
    
    @objc func createButtonTapped() {
        updateCategories(categoryName)
        navigationController?.popViewController(animated: true)
    }
}
