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

            Button("Change Permissions") {
                vm.changePermissions()
            }
        }
    }
}

