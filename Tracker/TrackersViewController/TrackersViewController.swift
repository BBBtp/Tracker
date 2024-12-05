import Foundation
import UIKit

final class TrackersViewController: UIViewController {
    var collectionView: UICollectionView!
    var currentDate: Date = Date()
    private var currentFilter: FilterOptions = .all
    var category: String = ""
    private let yandexMetricaService = YandexMetricaService()
    private var searchText: String?
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = .ypLightGray
        picker.overrideUserInterfaceStyle = .light
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.clearButtonMode = .never
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("searchBarPlaceholder", comment: "Placeholder text for search bar"),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypWhiteGray]
        )
        
        if let glassIconView = searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .ypWhiteGray
        }
        return searchController
    }()
    
    private lazy var filterButton: UIButton = {
        let button = FilterButton(title: NSLocalizedString("filterScreenTitle", comment: "Filter button title"))
        button.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        return button
    }()
    private let trackTitle: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackersTabBarTitle", comment: "Trackers title")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    private var placeholderImageView = UIImageView(image: UIImage(named: "place"))
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyStateNoTrackersCaption", comment: "Trackers empty state")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var trackerStore: TrackerStore = {
        return TrackerStore(for: self.currentDate,with: currentFilter)
    }()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private lazy var placeholderView: PlaceholderEmptyView = {
        let placeholder = PlaceholderEmptyView(frame: .zero)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        return placeholder
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
        view.backgroundColor = .ypWhite
        setupUI()
        configureViewState()
        applyFilterAndUpdateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        yandexMetricaService.report(event: "open", params: ["screen" : "main"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        yandexMetricaService.report(event: "close", params: ["screen" : "main"])
    }
    
}
//MARK: Create Trackers
extension TrackersViewController {
    private func addTracker(to category: String, tracker: TrackerModel) {
        trackerStore.addTracker(category: category, tracker: tracker)
        collectionView.reloadData()
        configureViewState()
    }
    private func addTracker(tracker: TrackerModel) {
        addTracker(to: self.category , tracker: tracker)
        configureViewState()
    }
    
    private func updateTracker(tracker: TrackerModel) {
        updateTracker(to: self.category, tracker: tracker)
    }
    
    private func updateTracker(to category: String, tracker: TrackerModel) {
        trackerStore.updateTracker(in: category, updatedTracker: tracker)
    }
    
    private func isFutureDate(_ date: Date)-> Bool {
        return date > Date()
    }
}

extension TrackersViewController {
    func applyFilterAndUpdateView() {
        trackerStore.applyFilter(currentFilter, on: currentDate, with: searchText)
        collectionView.reloadData()
        configureViewState()
    }
    @objc private func filterButtonDidTap() {
        yandexMetricaService.report(event: "click", params: ["screen" : "main", "item": "filter"])
        let viewController = FilterViewController()
        viewController.currentFilter = currentFilter
        viewController.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            
            self.currentFilter = filter
            
            if filter == .today {
                self.currentDate = Date()
                datePicker.date = Date()
            }
            
            
            self.applyFilterAndUpdateView()
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        print(currentDate)
        if currentFilter == .today && currentDate != Date() {
            currentFilter = .all
        }
        applyFilterAndUpdateView()
        
        configureViewState()
        
    }
    
    @objc func showTrackerType() {
        yandexMetricaService.report(event: "click", params: ["screen" : "main", "item": "add_track"])
        let trackerTypeVC = TrackerTypeViewController()
        trackerTypeVC.delegate = self
        let navigationController = UINavigationController(rootViewController: trackerTypeVC)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
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
            indexPath: indexPath,
            isPinned: trackerCompletion.isPinned
        )
        cell.delegate = self
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell,
              cell.coloredRectangleView.frame.contains(cell.convert(point, from: collectionView)) else { return nil }
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider: { [weak self] actions in
            
            var menuItems: [UIAction] = []
            menuItems.append((self?.createPinAction(for: indexPath, isPinned: cell.isPinned))!)
            menuItems.append((self?.createEditAction(for: indexPath))!)
            menuItems.append((self?.createDeleteAction(for: indexPath))!)
            
            return UIMenu(children: menuItems)
        })
    }
}

extension TrackersViewController {
    private func setupNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showTrackerType))
        addButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("trackersTabBarTitle", comment: "Title for the Trackers tab")
        searchController.searchBar.searchTextField.textColor = .ypBlack
    }
    
    private func setupSearchTextField() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    private func  createPlaceholder(){
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureViewState() {
        let isFilteredEmpty = trackerStore.isFilteredEmpty
        let isDateEmpty = isFilteredEmpty ? trackerStore.isDateEmpty : false
        
        collectionView.isHidden = isFilteredEmpty
        placeholderView.isHidden = !isFilteredEmpty
        filterButton.isHidden = isDateEmpty
        
        if isDateEmpty {
            placeholderView.config(with: NSLocalizedString("emptyStateNoResultsCaption", comment: "Trackers empty"), image: UIImage(named: "emoji2"))
        } else if isFilteredEmpty {
            placeholderView.config(with: NSLocalizedString("emptyStateNoTrackersCaption", comment: "Trackers empty"), image: UIImage(named: "place"))
        }
        
        let filterTitleColor: UIColor = (currentFilter == .all || currentFilter == .today) ? .white : .ypColor1
        filterButton.setTitleColor(filterTitleColor, for: .normal)
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
        collectionView.backgroundColor = .ypWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func setupUI () {
        setupNavBar()
        setupCollectionView()
        setupSearchTextField()
        createPlaceholder()
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
            yandexMetricaService.report(event: "click", params: ["screen" : "main", "item": "track"])
            NotificationCenter.default.post(name: .trackerCompletionUpdated, object: nil)
            collectionView.reloadItems(at: [indexPath])
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

extension TrackersViewController: TrackerTypeDelegate {
    func didSelectTrackerType(tracker: TrackerModel, category: String) {
        self.category = category
        addTracker(tracker: tracker)
        collectionView.reloadData()
    }
    
}

extension TrackersViewController {
    private func createEditAction(for indexPath: IndexPath) -> UIAction {
        let title = NSLocalizedString("contextMenuEditOption", comment: "Edit item")
        return UIAction(title: title) { [weak self] _ in
            guard let self = self else { return }
            self.yandexMetricaService.report(event: "click", params: ["screen" : "main", "item": "edit"])
            let viewController = CreateHabbitViewController(isNew: false, isHabitOrRegular: trackerStore.trackerType(at: indexPath))
            
            let completion = self.trackerStore.completionStatus(for: indexPath)
            viewController.trackerName = completion.tracker.title
            viewController.numberOfCompletions = completion.numberOfCompletions
            viewController.trackerColor = completion.tracker.color
            viewController.trackerEmoji = completion.tracker.emoji
            viewController.id = completion.tracker.id
            viewController.selectedWeekDays = completion.tracker.timeTable
            viewController.category = self.trackerStore.categoryName(for: indexPath)
            viewController.createHabbitDelegate = self
            let navigationController = UINavigationController(rootViewController: viewController)
            
            navigationController.modalPresentationStyle = .formSheet
            self.present(navigationController, animated: true)
        }
    }
    
    private func createDeleteAction(for indexPath: IndexPath) -> UIAction {
        let title = NSLocalizedString("contextMenuDeleteOption", comment: "Delete item")
        return UIAction(title: title, attributes: .destructive) { [weak self] action in
            guard let self = self else { return }
            self.yandexMetricaService.report(event: "click", params: ["screen" : "main", "item": "delete"])
            let actionSheetController = UIAlertController(
                title: NSLocalizedString("deleteConfirmationMessage",
                                         comment: "Are you sure you want to delete this tracker?"),
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("deleteButtonTitle",
                                         comment: "Delete button title"),
                style: .destructive
            ) { [weak self] _ in
                self?.trackerStore.deleteTracker(at: indexPath)
                self?.collectionView.reloadData()
                self?.configureViewState()
            }
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("cancelButtonTitle",
                                         comment: "Cancel button title"),
                style: .cancel,
                handler: nil
            )
            
            actionSheetController.addAction(deleteAction)
            actionSheetController.addAction(cancelAction)
            
            actionSheetController.preferredAction = cancelAction
            
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    private func createPinAction(for indexPath: IndexPath, isPinned: Bool) -> UIAction {
        let title = isPinned ? NSLocalizedString("contextMenuUnpinOption", comment: "Unpin item") :
        NSLocalizedString("contextMenuPinOption", comment: "Pin item")
        
        return UIAction(title: title) { [weak self] action in
            guard let self = self else { return }
            if isPinned {
                self.trackerStore.unpinTracker(at: indexPath)
                self.collectionView.reloadData()
            } else {
                self.trackerStore.pinTracker(at: indexPath)
                self.collectionView.reloadData()
            }
        }
    }
}

extension TrackersViewController: CreateHabbitDelegate {
    func didCreateHabbit(name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        //
    }
    
    func didCreateIrregularEvent(name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        //
    }
    
    func didUpdateHabbit(id: UUID,name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        let newTracker = TrackerModel(
            id: id,
            title: name,
            color: color,
            emoji: emoji,
            timeTable: days,
            type: .habit
        )
        self.category = category
        updateTracker(tracker: newTracker)
        collectionView.reloadData()
    }
    
    func didUpdateIrregularEvent(id:UUID,name: String, days: [WeekDay], color: UIColor, emoji: String, category: String) {
        let newTracker = TrackerModel(
            id: id,
            title: name,
            color: color,
            emoji: emoji,
            timeTable: days,
            type: .irregularEvent
        )
        self.category = category
        updateTracker(tracker: newTracker)
        collectionView.reloadData()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.searchText = searchText
        } else {
            self.searchText = nil
        }
        applyFilterAndUpdateView()
    }
}

