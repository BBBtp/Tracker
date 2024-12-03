//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Богдан Топорин on 03.12.2024.
//

import Foundation
import UIKit

typealias Binding<T> = (T) -> Void

final class CategoryViewModel: TrackerCategoryStoreDelegate {
    
    var returnCategory: Binding<String>?
    var updateCategories: Binding<Int>?
    
    lazy var categoryStore: TrackerCategoryStore = {
        return TrackerCategoryStore()
    }()
    
    var categoriesIsEmpty: Bool{
        return categoryStore.isEmpty
    }
    
    init(){
        categoryStore.delegate = self
    }
    
    func numberOfCategories(in section: Int) -> Int {
        let count = categoryStore.numberOfItemsInSection(section)
        return count
    }
    
    func numberOfSections() -> Int {
        let count = categoryStore.numberOfSections
        return count
    }
    
    func getCategory(at indexPath: IndexPath) -> String{
        guard let title =  categoryStore.categoryName(at: indexPath) else { preconditionFailure("Error") }
        return title
    }
    
    func didSelectRowAt(at indexPath: IndexPath) {
        guard let title =  categoryStore.categoryName(at: indexPath) else { preconditionFailure("Error") }
        returnCategory?(title)
    }
    
    func addNewCategory(_ newCategory: String) {
        categoryStore.addCategory(title: newCategory)
    }
    
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        updateCategories?(categoryStore.numberOfItemsInSection(0))
    }
}
