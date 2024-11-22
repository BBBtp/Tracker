//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Богдан Топорин on 09.11.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorTransformer()
    private let uiWeekDayMarshalling = WeekDayArrayTransformer()
    
    // MARK: - Инициализация
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Методы управления категориями
    
    // Добавление категории
    func addCategory(title: String, completion: @escaping (Bool) -> Void) {
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.title = title
        
        do {
            try context.save()
            completion(true)
        } catch {
            print("Failed to add category: \(error)")
            completion(false)
        }
    }
    
    // Получение всех категорий
    func fetchCategories(completion: @escaping ([TrackerCategoryModel]) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        
        do {
            let categoriesFromCoreData = try context.fetch(fetchRequest)
            let categories = categoriesFromCoreData.map { category -> TrackerCategoryModel in
                // Преобразуем NSSet в массив
                let trackersArray: [TrackerModel] = (category.trackers as? Set<TrackerCD>)?.compactMap { trackerCD in
                    guard
                        let colorString = trackerCD.color,
                        let timetableString = trackerCD.timeTable
                    else {
                        return nil
                    }
                    
                    let color = uiColorMarshalling.stringToColor(from: colorString)
                    let weekDays = uiWeekDayMarshalling.StringToWeekDayArray(timetableString)
                    
                    return TrackerModel(
                        id: trackerCD.id ?? UUID(),
                        title: trackerCD.title ?? "",
                        color: color,
                        emoji: trackerCD.emoji ?? "",
                        timeTable: weekDays,
                        type: trackerCD.type == 1 ? .habit : .irregularEvent
                    )
                } ?? []
                
                return TrackerCategoryModel(
                    title: category.title ?? "",
                    trackers: trackersArray
                )
            }
            completion(categories)
        } catch {
            print("Failed to fetch categories: \(error)")
            completion([])
        }
    }


    // Удаление категории
    func deleteCategory(_ category: TrackerCategoryModel, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let categoryToDelete = categories.first {
                context.delete(categoryToDelete)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to delete category: \(error)")
            completion(false)
        }
    }
    
    // Обновление категории
    func updateCategory(_ category: TrackerCategoryModel, newTitle: String, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        do {
            let categories = try context.fetch(fetchRequest)
            if let categoryToUpdate = categories.first {
                categoryToUpdate.title = newTitle
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Failed to update category: \(error)")
            completion(false)
        }
    }
}

