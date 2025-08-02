//
//  EditDescriptorConfiguration.swift
//  Handy Dandy
//
//  Created by John Naputi on 7/29/25.
//

struct EditDescriptorConfiguration<TModel> {
    var confirmLabel: String
    var cancelLabel: String
    var onSubmit: ((TModel) -> Void)? = nil
    var onDelete: ((TModel) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
}
