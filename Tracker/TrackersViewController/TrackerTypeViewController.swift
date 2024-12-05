
import UIKit


final class TrackerTypeViewController: UIViewController {
    
    weak var delegate: TrackerTypeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupNavigationBar(title: NSLocalizedString("addTrackerScreenTitle", comment: "Create tracker"))
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        let buttonHabbit = createButton(title: NSLocalizedString("regularTrackerButtonTitle", comment: "Habit button"), action: #selector(habitButtonTaped))
        stackView.addArrangedSubview(buttonHabbit)
        let buttonOneEvent = createButton(title: NSLocalizedString("irregularTrackerButtonTitle", comment: "Irregular button"), action: #selector(irregularEventButtonTaped))
        stackView.addArrangedSubview(buttonOneEvent)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 344),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    @objc private func habitButtonTaped() {
        let viewController = CreateHabbitViewController(isNew: true, isHabitOrRegular: true)
        viewController.createHabbitDelegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func irregularEventButtonTaped() {
        let viewController = CreateHabbitViewController(isNew: true, isHabitOrRegular: false)
        viewController.createHabbitDelegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = CustomButton(type: .create, title: title)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

extension TrackerTypeViewController: CreateHabbitDelegate {
    func didUpdateHabbit(id: UUID,name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        //
    }
    
    func didUpdateIrregularEvent(id: UUID,name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        //
    }
    
    
    func didCreateHabbit(name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        let newTracker = TrackerModel(
            id: UUID(),
            title: name,
            color: color,
            emoji: emoji,
            timeTable: days,
            type: .habit
        )
        delegate?.didSelectTrackerType(tracker: newTracker, category: category)
    }
    
    func didCreateIrregularEvent(name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        let newTracker = TrackerModel(
            id: UUID(),
            title: name,
            color: color,
            emoji: emoji,
            timeTable: days,
            type: .irregularEvent
        )
        
        delegate?.didSelectTrackerType(tracker: newTracker, category: category)
    }
}


