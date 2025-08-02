//
//  ContainerModel.swift
//  Handy Dandy
//
//  Created by John Naputi on 8/5/25.
//

protocol ContainerModel {
    associatedtype TModel
    
    func add(_ item: TModel)
    func remove(_ item: TModel) -> TModel?
}
