
import Foundation

// MARK: - CategoryListViewModel

final class CategoryListViewModel: TrackerCategoryStoreDelegate {
    
    // MARK: - Bindings
    
    var onCategoriesDidChange: Binding<[TrackerCategory]>?
    var onSelectedCategoryDidChange: Binding<TrackerCategory?>?
    var onErrorStateChange: Binding<String?>?
    var onEmptyStateDidChange: Binding<Bool>?
    
    // MARK: - Private Properties
    
    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesDidChange?(categories)
            onEmptyStateDidChange?(categories.isEmpty)
        }
    }
    
    private var selectedCategory: TrackerCategory? {
        didSet {
            onSelectedCategoryDidChange?(selectedCategory)
        }
    }
    
    // MARK: - Computed Properties
    
    var numberOfCategories: Int {
        return categories.count
    }
    
    var isEmpty: Bool {
        return categories.isEmpty
    }
    
    // MARK: - Initialization
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        loadCategories()
    }
    
    // MARK: - Public Methods
    
    func loadCategories() {
        do {
            let loadedCategories = try categoryStore.fetchAll()
            self.categories = loadedCategories
            onErrorStateChange?(nil)
        } catch {
            self.categories = []
            let storeError = StoreError.categoryLoadFailed(error)
            onErrorStateChange?(storeError.localizedDescription)
        }
    }
    
    func category(at index: Int) -> TrackerCategory? {
        guard index >= 0 && index < categories.count else { return nil }
        return categories[index]
    }
    
    func selectCategory(at index: Int) {
        guard let category = category(at: index) else { return }
        selectedCategory = category
    }
    
    func selectCategory(_ category: TrackerCategory) {
        selectedCategory = category
    }
    
    func addCategory(title: String) {
        do {
            try validateCategoryTitle(title)
            _ = try categoryStore.add(title: title)
            onErrorStateChange?(nil)
        } catch let storeError as StoreError {
            onErrorStateChange?(storeError.localizedDescription)
        } catch {
            let storeError = StoreError.categoryCreateFailed(error)
            onErrorStateChange?(storeError.localizedDescription)
        }
    }
    
    func updateCategory(at index: Int, newTitle: String) {
        guard let category = category(at: index) else {
            onErrorStateChange?(StoreError.categoryNotFound.localizedDescription)
            return
        }
        
        do {
            try validateCategoryTitle(newTitle)
            try categoryStore.update(id: category.id, title: newTitle)
            onErrorStateChange?(nil)
        } catch let storeError as StoreError {
            onErrorStateChange?(storeError.localizedDescription)
        } catch {
            let storeError = StoreError.categoryUpdateFailed(error)
            onErrorStateChange?(storeError.localizedDescription)
        }
    }
    
    func deleteCategory(at index: Int) {
        guard let category = category(at: index) else {
            onErrorStateChange?(StoreError.categoryNotFound.localizedDescription)
            return
        }
        
        if !category.trackers.isEmpty {
            onErrorStateChange?(StoreError.categoryHasTrackers.localizedDescription)
            return
        }
        
        do {
            try categoryStore.delete(id: category.id)
            if selectedCategory?.id == category.id {
                selectedCategory = nil
            }
            
            onErrorStateChange?(nil)
        } catch {
            let storeError = StoreError.categoryDeleteFailed(error)
            onErrorStateChange?(storeError.localizedDescription)
        }
    }
    
    func isSelected(category: TrackerCategory) -> Bool {
        return selectedCategory?.id == category.id
    }
    
    func getSelectedCategory() -> TrackerCategory? {
        return selectedCategory
    }
    
    // MARK: - Private Methods
    
    private func validateCategoryTitle(_ title: String) throws {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedTitle.isEmpty {
            throw StoreError.categoryTitleEmpty
        }
        
        if trimmedTitle.count > 38 {
            throw StoreError.categoryTitleTooLong
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryListViewModel {
    func storeDidChange() {
        loadCategories()
    }
}
