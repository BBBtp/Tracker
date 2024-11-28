import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    var collectionView: UICollectionView!
    var currentDate: Date = Date()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        return picker
    }()
    private let searchTextField: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.layer.cornerRadius = 10
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    private let trackTitle: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    private var placeholderImageView = UIImageView(image: UIImage(named: "place"))
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var trackerStore: TrackerStore = {
        return TrackerStore(for: self.currentDate)
    }()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    private let dateLabel = UILabel()
    private var parameters: GeometricParameters
    private var trackers: [TrackerModel] = []
    private var completedTrackerAndIrregularIDs: Set<UUID> = []
    private var completedTrackers: [TrackerRecordModel] = []
    private var trackerCreationDates: [UUID: Date] = [:]
    private var categories: [TrackerCategoryModel] = []
    
    init() {
        self.parameters = GeometricParameters(cellCount: 2, leftInsets: 16, rightInsets: 16, cellSpacing: 9)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        trackerStore.updateDate(currentDate,"")
        setupPlaceholder()
        searchTextField.delegate = self
        setupUI()
    }
    
}
//MARK: Create Trackers
extension TrackersViewController {
    private func addTracker(to category: TrackerCategoryModel, tracker: TrackerModel) {
        trackerStore.addTracker(to: category, tracker: tracker)
    }
    
    private func addTracker(tracker: TrackerModel) {
        addTracker(to: Mocks.defaultCategory, tracker: tracker)
    }
    
    private func addIrregularEvent(tracker: TrackerModel) {
        addTracker(to: Mocks.irregularCategory, tracker: tracker)
    }
    
    private func isFutureDate(_ date: Date)-> Bool {
        return date > Date()
    }

}

extension TrackersViewController {
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        trackerStore.updateDate(currentDate,"")
        collectionView.reloadData()
        setupPlaceholder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    @objc func showTrackerType() {
        let trackerTypeVC = TrackerTypeViewController()
        trackerTypeVC.delegate = self
        trackerTypeVC.modalPresentationStyle = .pageSheet
        present(trackerTypeVC, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int
    ) -> Int {
        return trackerStore.numberOfItemsInSection(section)
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackersCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }

        let trackerCompletion = trackerStore.completionStatus(for: indexPath)
        cell.configure(
            with: trackerCompletion.tracker,
            isCompletedToday: trackerCompletion.isCompleted,
            completedDays: trackerCompletion.numberOfCompletions,
            indexPath: indexPath
        )
        cell.delegate = self
        return cell
    }
}

extension TrackersViewController {
    private func setupNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showTrackerType))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
    }
    private func setupTitle() {
        view.addSubview(trackTitle)
        trackTitle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            trackTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerXAnchor.constraint(equalTo: trackTitle.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackTitle.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor)
        ])
    }
    
    private func setupSearchTextField() {
        view.addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 125),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createPlaceholder() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor)
        ])
    }
    
    private func setupPlaceholder() {
        if trackerStore.isEmpty {
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        }
        else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.cellIdentifier)
        collectionView.register(TrackerCVHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCVHeader.headerIdentifier)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupUI () {
        setupTitle()
        setupNavBar()
        setupCollectionView()
        setupSearchTextField()
        createPlaceholder()
    }
}

extension TrackersViewController: CreateHabbitDelegate {
    func didCreateHabbit(name: String, days: [WeekDay], color: UIColor, emoji: String) {
        let newTracker = TrackerModel(
            id: UUID(),
            title: name,
            color: color,
            emoji: emoji,
            timeTable: days,
            type: .habit
        )
        addTracker(tracker: newTracker)
        collectionView.reloadData()
    }
    
    func didCreateIrregularEvent(name: String, days: [WeekDay], color: UIColor, emoji: String) {
        let newTracker = TrackerModel(
            id: UUID(),
            title: name,
            color: color,
            emoji: emoji,
            timeTable: days,
            type: .irregularEvent
        )
        addIrregularEvent(tracker: newTracker)
        collectionView.reloadData()
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let avaliableWidth = collectionView.bounds.width - parameters.paddingWidth
        let widthPerItem = avaliableWidth / CGFloat(parameters.cellCount)
        let heightPerItem = widthPerItem * (130 / 167)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return trackerStore.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 4, left: parameters.leftInsets, bottom: 16, right: parameters.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return parameters.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCVHeader.headerIdentifier,
            for: indexPath
        ) as? TrackerCVHeader else {
            fatalError("Failed to dequeue Trackers Header")
        }
        
        let categoryTitle = trackerStore.sectionName(for: indexPath.section)
        header.titleLabel.text = categoryTitle
        header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        
        return header
    }
}

extension TrackersViewController: TrackersCellDelegate {
    
    func completeOrUncompleteTracker(trackerId: UUID, indexPath: IndexPath) {
        if isFutureDate(currentDate){
            return
        }
        else{
            let trackerCompletion = trackerStore.completionStatus(for: indexPath)
            let newCompletionStatus = !trackerCompletion.isCompleted
            trackerStore.changeCompletion(for: indexPath, to: newCompletionStatus)
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        trackerStore.updateDate(currentDate, searchText)
        collectionView.reloadData()
        setupPlaceholder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension TrackersViewController: TrackerTypeDelegate {
    func showCreateHabit(isHabit: Bool) {
        dismiss(animated: false) { [weak self] in
            let createHabitVC = CreateHabbitViewController()
            createHabitVC.delegate = self
            createHabitVC.createHabbitDelegate = self
            createHabitVC.isHabitOrRegular = isHabit
            createHabitVC.modalPresentationStyle = .pageSheet
            self?.present(createHabitVC, animated: true)
        }
    }
    
    func showCreateIrregularEvent(isHabit: Bool) {
        dismiss(animated: false) { [weak self] in
            let createHabitVC = CreateHabbitViewController()
            createHabitVC.delegate = self
            createHabitVC.createHabbitDelegate = self
            createHabitVC.isHabitOrRegular = isHabit
            createHabitVC.modalPresentationStyle = .pageSheet
            self?.present(createHabitVC, animated: true)
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates({
            if !update.deletedSections.isEmpty {
                collectionView.deleteSections(IndexSet(update.deletedSections))
            }
            if !update.insertedSections.isEmpty {
                collectionView.insertSections(IndexSet(update.insertedSections))
            }
            collectionView.insertItems(at: update.insertedIndexes)
            collectionView.deleteItems(at: update.deletedIndexes)
            collectionView.reloadItems(at: update.updatedIndexes)
            for move in update.movedIndexes {
                collectionView.moveItem(at: move.from, to: move.to)
            }
        }, completion: nil)
        
    }
}
