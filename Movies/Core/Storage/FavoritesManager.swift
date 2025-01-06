//
//  FavoritesManager.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation
import CoreData

final class FavoritesManager {
    static let shared = FavoritesManager()
    private let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "FavoriteMovieModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("Error loading persistent stores: \(error)")
            }
        }
    }

    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Create
    func addFavorite(movieId: Int) {
        guard !isFavorite(movieId: movieId) else { return }

        let favorite = NSEntityDescription.insertNewObject(forEntityName: "FavoriteMovie",
                                                           into: context)
        favorite.setValue(movieId, forKey: "id")

        saveContext()
    }

    // MARK: - Read
    func isFavorite(movieId: Int) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.fetchLimit = 1

        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking favorite: \(error)")
            return false
        }
    }

    func fetchAllFavoriteMovieIds() -> [Int] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteMovie")
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0.value(forKey: "id") as? Int }
        } catch {
            print("Error fetching all favorites: \(error)")
            return []
        }
    }

    // MARK: - Delete
    func removeFavorite(movieId: Int) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteMovie")
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)

        do {
            let results = try context.fetch(fetchRequest)
            for obj in results {
                context.delete(obj)
            }
            saveContext()
        } catch {
            print("Error removing favorite: \(error)")
        }
    }

    // MARK: - Save
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
