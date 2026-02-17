//
//  SearchView.swift
//  Kompis-App
//
//  Created by Simen Theie Bretvik on 05/02/2026.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: TaskCategory? = nil
    let tasks = MockData.tasks
    
    var filteredTasks: [Task] {
        tasks.filter { task in
            if let category = selectedCategory {
                return task.category == category
            }
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Finn oppdrag")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.kompisTextPrimary)
                    
                    // Søkefelt
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.kompisTextMuted)
                        TextField("Søk etter oppdrag...", text: $searchText)
                    }
                    .padding(Spacing.lg)
                    .background(Color.kompisBgSecondary)
                    .cornerRadius(CornerRadius.md)
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            KategoriChip(
                                category: .other,
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(TaskCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                                KategoriChip(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
                .background(Color.kompisBgPrimary)
                
                // Resultat-liste
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        HStack {
                            Text("\(filteredTasks.count) oppdrag i nærheten")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.kompisTextSecondary)
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)
                        
                        ForEach(filteredTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskListRow(task: task)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, Spacing.lg)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(Color.kompisBgPrimary)
            }
            .background(Color.kompisBgPrimary)
            .navigationBarHidden(true)
        }
    }
}

struct TaskListRow: View {
    let task: Task
    
    var body: some View {
        KompisCard {
            HStack(spacing: Spacing.md) {
                // Bilde placeholder
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(Color.kompisBgSecondary)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: task.category.icon)
                            .font(.system(size: 28))
                            .foregroundColor(.kompisTextMuted)
                    )
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.kompisTextPrimary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.kompisAccent)
                        Text(task.pickupLocation.city ?? "Oslo")
                        Text("•")
                        Text(String(format: "%.1f km", task.distance))
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.kompisTextSecondary)
                    
                    HStack {
                        KompisBadge(text: "\(task.price) kr", variant: .price)
                        Spacer()
                        Text(task.createdBy.name)
                            .font(.system(size: 13))
                            .foregroundColor(.kompisTextSecondary)
                    }
                }
                
                Spacer()
            }
        }
    }
}
