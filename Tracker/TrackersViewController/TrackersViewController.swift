import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    let datePicker = UIDatePicker()
    let searchTextField = UISearchBar()
    let trackTitle = UILabel()
    var placeholderImageView = UIImageView()
    let placeholderLabel = UILabel()
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private func setupData() {
        trackerCategoryStore.fetchCategories { [weak self] categories in
            guard let self = self else { return }
            self.categories = categories
            trackerStore.fetchTrackers{
                [weak self] trackers in
                self?.trackers = trackers
            }
            trackerRecordStore.fetchRecords {
                [weak self] records in
                self?.completedTrackers = records
                print(records.count)
            }
            self.collectionView.reloadData()
            self.setupPlaceholder()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    private let dateLabel = UILabel()
    private var defaultCategory = TrackerCategoryModel(title: "Рутина", trackers: [])
    private var irregularCategory = TrackerCategoryModel(title: "Когда-то сделаю", trackers: [])
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
        setupUI()
        setupData()
        
    }
    
}

extension TrackersViewController {
    private func addTracker(to category: TrackerCategoryModel, tracker: TrackerModel) {
        
        trackerStore.addTracker(to: category, tracker: tracker){
            [weak self] completion in
            DispatchQueue.main .async {
                guard completion else {
                    print("Не удалось добавить трекер в базу данных.")
                    return
                }
                if let index = self?.categories.firstIndex(where: { $0.title == category.title }) {
                    
                    let updatedCategory = TrackerCategoryModel(
                        title: category.title,
                        trackers: (self?.categories[index].trackers)! + [tracker]
                    )
                    self?.categories[index] = updatedCategory
                } else {
                    
                    let newCategory = TrackerCategoryModel(title: category.title, trackers: [tracker])
                    self?.categories.append(newCategory)
                }
                self?.trackerCreationDates[tracker.id] = self?.datePicker.date
                self?.trackers.append(tracker)
                self?.collectionView.reloadData()
                self?.setupPlaceholder()
            }
        }
        
    }
    
    
    private func addTracker(tracker: TrackerModel) {
        addTracker(to: defaultCategory, tracker: tracker)
    }
    
    private func addIrregularEvent(tracker: TrackerModel) {
        addTracker(to: irregularCategory, tracker: tracker)
    }
    
    
    private func isIrregularEvent(trackerId: UUID) -> Bool {
        return categories.flatMap({ $0.trackers }).first(where: { $0.id == trackerId })?.type == .irregularEvent
    }
    
    private func isTracker(trackerId: UUID)->Bool {
        return categories.flatMap({$0.trackers}).first(where: {$0.id == trackerId})?.type == .habit
    }
    
    private func isFutureDate(_ date: Date)-> Bool {
        return date > Date()
    }
    
    func isTrackerCompletedToday(trackerId: UUID) -> Bool {
        return completedTrackers.contains { isSameTrackerRecord(trackerRecord: $0, id: trackerId) }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecordModel, id: UUID) -> Bool {
        return trackerRecord.id == id && Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
    }
}

extension TrackersViewController {
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        
        collectionView.reloadData()
        setupPlaceholder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        _ = dateFormatter.string(from: selectedDate)
    }
    
    @objc func showTrackerType() {
        let trackerTypeVC = TrackerTypeViewController()
        trackerTypeVC.delegate = self
        trackerTypeVC.modalPresentationStyle = .pageSheet
        present(trackerTypeVC, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func selectedWeekDay(selectedDate: Date) -> Int {
        var selectedWeekday = Calendar.current.component(.weekday, from: selectedDate)
        selectedWeekday = (selectedWeekday == 1) ? 7 : (selectedWeekday - 1)
        return selectedWeekday
    }
    
    func visibleTrackers(selectedWeekday: Int, selectedDate: Date, searchText: String) -> [TrackerModel] {
        let visibleTrackers = trackers.filter { tracker in
            switch tracker.type {
            case .habit:
                // Показываем привычки, если они должны быть на текущий день
                let isVisible = tracker.timeTable.contains(WeekDay(rawValue: selectedWeekday)!) ||
                                tracker.title.lowercased().contains(searchText)
                return isVisible
                
            case .irregularEvent:
                if let creationDate = trackerCreationDates[tracker.id] {
                    // Показываем нерегулярное событие всегда, если оно не выполнено
                    let isVisible = !completedTrackers.contains(where: { $0.id == tracker.id }) ||
                                    tracker.title.lowercased().contains(searchText)
                    
                    // Если событие выполнено, показываем только в день выполнения
                    if completedTrackers.contains(where: { $0.id == tracker.id }) {
                        return Calendar.current.isDate(creationDate, inSameDayAs: selectedDate) || isVisible
                    }
                    
                    return isVisible
                } else {
                    // Если дата создания не установлена, показываем только если не выполнено
                    return !completedTrackers.contains(where: { $0.id == tracker.id }) ||
                           tracker.title.lowercased().contains(searchText)
                }
            }
        }
        
        return visibleTrackers
    }

    
    func filterTrackers(for categories: [TrackerCategoryModel], selectedDate: Date, searchText: String) -> [TrackerCategoryModel] {
        let selectedWeekDay = selectedWeekDay(selectedDate: selectedDate)
        return categories.map { category in
            
            let filteredTrackers = category.trackers.filter { tracker in
                switch tracker.type {
                case .habit:
                    
                    return tracker.timeTable.contains(WeekDay(rawValue: selectedWeekDay)!) ||
                    tracker.title.lowercased().contains(searchText)
                    
                case .irregularEvent:
                    
                    if let creationDate = trackerCreationDates[tracker.id] {
                        
                        if Calendar.current.isDate(creationDate, inSameDayAs: selectedDate) {
                            return true
                        } else {
                            return !completedTrackers.contains(where: { $0.id == tracker.id })
                        }
                    } else {
                        return !completedTrackers.contains(where: { $0.id == tracker.id })
                    }
                }
            }
            return TrackerCategoryModel(title: category.title, trackers: filteredTrackers)
        }.filter { category in
            !category.trackers.isEmpty
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let searchText = searchTextField.text?.lowercased() ?? ""
        let selectedDate = datePicker.date
        
        let visibleCategories = filterTrackers(for: categories, selectedDate: selectedDate, searchText: searchText)
        
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let searchText = searchTextField.text?.lowercased() ?? ""
        let selectedDate = datePicker.date
        
        let visibleCategories = filterTrackers(for: categories, selectedDate: selectedDate, searchText: searchText)
        let category = visibleCategories[section]
        
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let searchText = searchTextField.text?.lowercased() ?? ""
        let selectedDate = datePicker.date
        
        let visibleCategories = filterTrackers(for: categories, selectedDate: selectedDate, searchText: searchText)
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.cellIdentifier, for: indexPath) as! TrackersCollectionViewCell
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        let isCompletedToday = isTrackerCompletedToday(trackerId: tracker.id)
        
        cell.configure(with: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
}

extension TrackersViewController {
    func setupNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showTrackerType))
        addButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = addButton
        
        
        print("Navigation bar setup completed")
    }
    
    func setupTitle() {
        trackTitle.text = "Трекеры"
        trackTitle.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        view.addSubview(trackTitle)
        trackTitle.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            trackTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerXAnchor.constraint(equalTo: trackTitle.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackTitle.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor)
        ])
    }
    
    func setupSearchTextField() {
        searchTextField.placeholder = "Поиск"
        searchTextField.layer.cornerRadius = 10
        searchTextField.backgroundImage = UIImage()
        searchTextField.delegate = self
        view.addSubview(searchTextField)
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 125),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
    }
    func createPlaceholder(){
        placeholderImageView = UIImageView(image: UIImage(named: "place"))
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
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
        let searchText = searchTextField.text?.lowercased() ?? ""
        let selectedDate = datePicker.date
        let selectedWeekday = selectedWeekDay(selectedDate: selectedDate)
        
        let visible = visibleTrackers(selectedWeekday: selectedWeekday, selectedDate: selectedDate, searchText: searchText)
        placeholderImageView.isHidden = !visible.isEmpty
        placeholderLabel.isHidden = !visible.isEmpty
        print("Visible Trackers Count: \(visible.count)")
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackersCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackersCollectionViewCell.cellIdentifier
        )
        collectionView.register(
            TrackerCVHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCVHeader.headerIdentifier
        )
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
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
        print("Трекер добавлен: \(newTracker.title)")
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
        print("Событие добавлен: \(newTracker.title)")
        collectionView.reloadData()
    }
    
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let avaliableWidth = collectionView.bounds.width - parameters.paddingWidth
        let widthPerItem = avaliableWidth / CGFloat(parameters.cellCount)
        let heightPerItem = widthPerItem * (148 / 167)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return categories[section].trackers.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: parameters.leftInsets, bottom: 16, right: parameters.rightInsets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return parameters.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCVHeader.headerIdentifier, for: indexPath) as? TrackerCVHeader else {
            fatalError("Failed to dequeue Trackers Header")
        }
        
        let category = categories[indexPath.section]
        header.titleLabel.text = category.title
        header.titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        
        return header
    }
}

extension TrackersViewController: TrackersCellDelegate {
    
    func completeOrUncompleteTracker(trackerId: UUID, indexPath: IndexPath) {
        let date = datePicker.date
        guard !isFutureDate(date) else { return }

        let trackerRecordStore = TrackerRecordStore()

        trackerRecordStore.fetchRecords { [weak self] records in
            guard let self = self else { return }

            if records.first(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date) }) != nil {
                // Удаляем запись, если она существует
                trackerRecordStore.removeRecord(for: trackerId, date: date) { success in
                    if success {
                        self.completedTrackers.removeAll { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date) }
                        self.completedTrackerAndIrregularIDs.remove(trackerId)
                        self.collectionView.reloadItems(at: [indexPath])
                    } else {
                        print("Ошибка при удалении записи")
                    }
                }
            } else {
                // Добавляем событие, если оно ещё не выполнено
                trackerRecordStore.addRecord(for: trackerId, date: date) { success in
                    if success {
                        let newRecord = TrackerRecordModel(id: trackerId, date: date)
                        self.completedTrackers.append(newRecord)
                        self.completedTrackerAndIrregularIDs.insert(trackerId)
                        self.collectionView.reloadItems(at: [indexPath])
                    } else {
                        print("Ошибка при добавлении записи")
                    }
                }
            }
        }
        
    }

    
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        collectionView.reloadData()
        setupPlaceholder()
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
