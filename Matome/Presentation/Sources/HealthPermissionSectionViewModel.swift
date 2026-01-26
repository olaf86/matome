//
//  HealthPermissionSectionViewModel.swift
//  Matome
//
//  Created by Yuta Ogawa on 2026/01/25.
//

import Combine
import HealthKit
import UIKit
import SwiftUI

@MainActor
final class HealthPermissionSectionViewModel: ObservableObject {
    
    @Published var steps: Int? = nil
    @Published var isAuthorized: Bool = false
    
    private let store = HKHealthStore()
    private var readTypes: Set<HKObjectType> {
        guard
            let steps = HKQuantityType.quantityType(forIdentifier: .stepCount),
            let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else { return [] }
        return [steps, distance]
    }
    
    init() {
        refreshIsAuthorized()
    }
    
    func changePermissions() {
        
        store.getRequestStatusForAuthorization(
            toShare: [],
            read: readTypes
        ) { status, error in
            DispatchQueue.main.async {
                switch status {
                case .shouldRequest:
                    self.store.requestAuthorization(toShare: [], read: self.readTypes) { success, error in
                        if success {
                            Task {
                                await self.refreshIsAuthorized()
                            }
                        }
                    }
                    break
                case .unnecessary:
                    self.openAppSettings()
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func loadSteps() async {
        fetchTodaySteps { steps in
            Task {
                await MainActor.run {
                    self.steps = steps
                }
            }
        }
    }
    
    private func refreshIsAuthorized() {
        isAuthorized = HKHealthStore.isHealthDataAvailable()
    }
    
    private func fetchTodaySteps(completion: @escaping (Int) -> Void) {
        
        guard
            let type = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else {
            completion(0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let step = result?
                .sumQuantity()?
                .doubleValue(for: .count()) ?? 0
            completion(Int(step))
        }
        
        store.execute(query)
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

