//
//  PortofolioDataService.swift
//  SwiftfulCrypto
//
//  Created by Magd on 30/10/2026.
//

import Foundation
import CoreData
import Combine

class PortofolioDataService {
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortofolioContainer"
    private let entityName: String = "PortofolioEntity"
    
    @Published var savedEntities: [PortofolioEntity] = []
    
    init(){
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores{ (_,error) in
            if let error = error {
                print("Error Loading Core Data : \(error)")
            }
            self.getPortofolio()
        }
    }
    
    // MARK: PUBLIC
    
    func updatePortofolio(coin: CoinModel,amount: Double){
        
        // check if coin is already in portofolio
        if let entity = savedEntities.first(where: { $0.coinID == coin.id}) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else{
                remove(entity: entity)
            }
        }else{
            // else add it
            add(coin: coin, amount: amount)
        }
    }
    
    // MARk: PRIVATE
    
    private func getPortofolio(){
        let request = NSFetchRequest<PortofolioEntity> (entityName: entityName)
        do{
            savedEntities =  try container.viewContext.fetch(request)
        }
        catch let error {
            print("Error fetching portofolio entities : \(error)")
        }
    }
    
    private func add (coin: CoinModel,amount:Double){
        let entity = PortofolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortofolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func remove(entity: PortofolioEntity){
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    private func save(){
        do{
            try container.viewContext.save()
        }
        catch let error {
            print("Error saving to Core Data : \(error)")
        }
    }
    
    private func applyChanges(){
        save()
        getPortofolio()
    }
    
}
