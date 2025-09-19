
import Foundation

// MARK: - CategoryListViewModel

final class CategoryListViewModel {
    
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
            onErrorStateChange?("Не удалось загрузить категории: \(error.localizedDescription)")
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
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            onErrorStateChange?("Название категории не может быть пустым")
            return
        }
        
        guard title.count <= 38 else {
            onErrorStateChange?("Название категории не должно превышать 38 символов")
            return
        }
        
        do {
            _ = try categoryStore.add(title: title)
            loadCategories()
            onErrorStateChange?(nil)
        } catch {
            onErrorStateChange?("Не удалось создать категорию: \(error.localizedDescription)")
        }
    }
    
    func updateCategory(at index: Int, newTitle: String) {
        guard let category = category(at: index) else {
            onErrorStateChange?("Категория не найдена")
            return
        }
        
        guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            onErrorStateChange?("Название категории не может быть пустым")
            return
        }
        
        guard newTitle.count <= 38 else {
            onErrorStateChange?("Название категории не должно превышать 38 символов")
            return
        }
        
        do {
            try categoryStore.update(id: category.id, title: newTitle)
            loadCategories()
            onErrorStateChange?(nil)
        } catch {
            onErrorStateChange?("Не удалось обновить категорию: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(at index: Int) {
        guard let category = category(at: index) else {
            onErrorStateChange?("Категория не найдена")
            return
        }
        
        // Проверяем, есть ли трекеры в этой категории
        if !category.trackers.isEmpty {
            onErrorStateChange?("Нельзя удалить категорию, в которой есть трекеры")
            return
        }
        
        do {
            try categoryStore.delete(id: category.id)
            
            // Сбрасываем выбранную категорию, если она была удалена
            if selectedCategory?.id == category.id {
                selectedCategory = nil
            }
            
            loadCategories()
            onErrorStateChange?(nil)
        } catch {
            onErrorStateChange?("Не удалось удалить категорию: \(error.localizedDescription)")
        }
    }
    
    func isSelected(category: TrackerCategory) -> Bool {
        return selectedCategory?.id == category.id
    }
    
    func getSelectedCategory() -> TrackerCategory? {
        return selectedCategory
    }
}
