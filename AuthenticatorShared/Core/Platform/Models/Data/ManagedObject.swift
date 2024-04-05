import CoreData

/// A protocol for an `NSManagedObject` data model that adds some convenience methods for working
/// with Core Data.
///
protocol ManagedObject: AnyObject {
    /// The name of the entity of the managed object, as defined in the data model.
    static var entityName: String { get }

    /// Returns a `NSPredicate` used for filtering by a managed object ID.
    ///
    /// - Parameters:
    ///   - id: The ID of the object to fetch
    ///
    static func idPredicate(id: String) -> NSPredicate
}

extension ManagedObject where Self: NSManagedObject {
    static var entityName: String {
        String(describing: self)
    }

    /// Returns a `NSBatchInsertRequest` for batch inserting an array of objects.
    ///
    /// - Parameters:
    ///   - objects: The objects (or objects that can be converted to managed objects) to insert.
    ///   - handler: A handler that is called for each object to set the properties on the
    ///     `NSManagedObject` to insert.
    /// - Returns: A `NSBatchInsertRequest` for batch inserting an array of objects.
    ///
    static func batchInsertRequest<T>(
        objects: [T],
        handler: @escaping (Self, T) throws -> Void
    ) throws -> NSBatchInsertRequest {
        var index = 0
        var errorToThrow: Error?
        let insertRequest = NSBatchInsertRequest(entityName: entityName) { (managedObject: NSManagedObject) -> Bool in
            guard index < objects.count else { return true }
            defer { index += 1 }

            if let managedObject = (managedObject as? Self) {
                do {
                    try handler(managedObject, objects[index])
                } catch {
                    // The error can't be thrown directly in this closure, so capture it, return
                    // from the closure, and then throw it.
                    errorToThrow = error
                    return true
                }
            }

            return false
        }

        if let errorToThrow {
            throw errorToThrow
        }

        return insertRequest
    }

    /// Returns a `NSFetchRequest` for fetching instances of the managed object.
    ///
    /// - Parameter predicate: An optional predicate to apply to the fetch request.
    /// - Returns: A `NSFetchRequest` used to fetch instances of the managed object.
    ///
    static func fetchRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<Self> {
        let fetchRequest = NSFetchRequest<Self>(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    /// Returns a `NSFetchRequest` for fetching a generic `NSFetchRequestResult` instances of the
    /// managed object.
    ///
    /// - Parameter predicate: An optional predicate to apply to the fetch request.
    /// - Returns: A `NSFetchRequest` used to fetch generic `NSFetchRequestResult` instances of the
    ///     managed object.
    ///
    static func fetchResultRequest(predicate: NSPredicate? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        return fetchRequest
    }

    static func fetchRequest() -> NSFetchRequest<Self> {
        fetchRequest(predicate: nil)
    }

    /// A `NSFetchRequest` that fetches objects matching an ID.
    ///
    /// - Parameters:
    ///   - id: The ID of the object to fetch.
    /// - Returns: A `NSFetchRequest` that fetches all objects for the user.
    ///
    static func fetchByIdRequest(id: String) -> NSFetchRequest<Self> {
        fetchRequest(predicate: idPredicate(id: id))
    }

    /// A `NSBatchDeleteRequest` that deletes all objects
    ///
    /// - Returns: A `NSBatchDeleteRequest` that deletes all objects for the user.
    ///
    static func deleteAllRequest() -> NSBatchDeleteRequest {
        let fetchRequest = fetchResultRequest(predicate: nil)
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }

}
