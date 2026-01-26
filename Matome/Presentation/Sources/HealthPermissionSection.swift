//
//  HealthPermissionSection.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import SwiftUI

struct HealthPermissionSection: View {

    @StateObject private var vm = HealthPermissionSectionViewModel()

    var body: some View {
        Section("Health") {

            LabeledContent("Status") {
                Text(vm.isAuthorized ? "Authorized" : "Not Authorized")
                    .foregroundStyle(vm.isAuthorized ? .green : .red)
            }
            
            ForEach(vm.permissions) { permission in
                HStack {
                    Text(permission.type.description)
                    Spacer()
                    Text(permission.status.text)
                        .foregroundStyle(permission.status.color)
                }
            }

            Button("Change Permissions") {
                vm.changePermissions()
            }
        }
    }
}

