//
//  CoreDataManager.swift
//  Swipe_Assignment
//
//  Created by Prince Yadav on 31/01/25.
//


import CoreData
import Foundation

//// Add this Core Data entity definition
//@objc(CDProduct)
//public class CDProduct: NSManagedObject {
//    @NSManaged public var productName: String?
//    @NSManaged public var productType: String?
//    @NSManaged public var price: Double
//    @NSManaged public var tax: Double
//    @NSManaged public var image: String?
//    @NSManaged public var isFavorite: Bool
//}

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProductModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveProducts(_ products: [Product]) {
        let context = persistentContainer.viewContext
        
        products.forEach { product in
            let fetchRequest: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productName == %@", product.productName)
            
            do {
                let results = try context.fetch(fetchRequest)
                let cdProduct = results.first ?? CDProduct(context: context)
                
                cdProduct.productName = product.productName
                cdProduct.productType = product.productType
                cdProduct.price = product.price
                cdProduct.tax = product.tax
                cdProduct.image = product.image
                cdProduct.isFavorite = product.isFavorite
            } catch {
                print("Failed to fetch product: \(error)")
            }
        }
        
        saveContext()
    }
    
    func fetchProducts() -> [Product] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        
        do {
            let cdProducts = try context.fetch(fetchRequest)
            return cdProducts.map { cdProduct in
                Product(
                    productName: cdProduct.productName ?? "",
                    productType: cdProduct.productType ?? "",
                    price: cdProduct.price,
                    tax: cdProduct.tax,
                    image: cdProduct.image,
                    isFavorite: cdProduct.isFavorite
                )
            }
        } catch {
            print("Failed to fetch products: \(error)")
            return []
        }
    }
    
    func updateProductFavorite(_ product: Product) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productName == %@", product.productName)
        
        do {
            let results = try context.fetch(fetchRequest)
            results.first?.isFavorite = product.isFavorite
            saveContext()
        } catch {
            print("Failed to update product favorite: \(error)")
        }
    }
    
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
//
//// Extension for fetch request
//extension CDProduct {
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProduct> {
//        return NSFetchRequest<CDProduct>(entityName: "CDProduct")
//    }
//}
