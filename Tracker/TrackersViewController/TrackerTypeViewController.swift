
import UIKit


final class TrackerTypeViewController: UIViewController {
    weak var delegate: TrackerTypeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLabel()
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        let buttonHabbit = createButton(title: "Привычка", action: #selector(habitButtonTaped))
        stackView.addArrangedSubview(buttonHabbit)
        
        let buttonOneEvent = createButton(title: "Нерегулярное событие", action: #selector(irregularEventButtonTaped))
        stackView.addArrangedSubview(buttonOneEvent)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 344),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    @objc private func habitButtonTaped() {
        delegate?.showCreateHabit(isHabit: true)
        
    }
    
    @objc private func irregularEventButtonTaped() {
        delegate?.showCreateIrregularEvent(isHabit: false)
    }
    
    private func setLabel() {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }

    @objc private func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = .darkGray
    }

    @objc private func buttonReleased(_ sender: UIButton) {
        sender.backgroundColor = .black
    }
    
}


