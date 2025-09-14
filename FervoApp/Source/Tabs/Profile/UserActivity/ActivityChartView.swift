//
//  ActivityChartView.swift
//  FervoApp
//
//  Created by AI Assistant on 12/19/24.
//

import SwiftUI

struct ActivityChartView: View {
    @ObservedObject var viewModel: ProfileViewModel
    private let days = 15
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header com título
            Text("Atividade recente")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            // Gráfico
            chartView
                .background(Color.FVColor.headerCardbackgroundColor)
                .cornerRadius(16)
                .padding(.horizontal, 20)
        }
    }
    
    private var chartView: some View {
        VStack(alignment: .leading) {
            Text("Últimos 15 dias")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(Array(chartData.enumerated()), id: \.1.date) { index, data in
                            VStack(spacing: 4) {
                                // Bar com imagem de localização
                                ZStack {
                                    Rectangle()
                                        .fill(barColor(for: data.count))
                                        .frame(width: barWidth, height: barHeight(for: data.count))
                                        .cornerRadius(2)

                                    if data.count > 0 {
                                        Text("\(data.activities.count)x")
                                            .font(.caption2.bold())
                                            .foregroundColor(.white)
                                            .padding(2)
                                    }
                                }

                                Text(dayLabel(for: data.date))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .id(index) // Identificador único para scroll
                        }
                    }
                    .frame(height: 80)
                    .padding([.horizontal, .bottom], 10)
                }
                .onAppear {
                    if let lastIndex = chartData.indices.last {
                        proxy.scrollTo(lastIndex, anchor: .trailing)
                    }
                }
            }

        }

    }
    
    private var chartData: [DayActivity] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: endDate) ?? endDate
        
        var data: [DayActivity] = []
        
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
            let dayActivities = activitiesForDay(date)
            data.append(DayActivity(date: date, count: dayActivities.count, activities: dayActivities))
        }
        
        return data
    }
    
    private func activitiesForDay(_ date: Date) -> [UserActivityResponse] {
        let calendar = Calendar.current
        return viewModel.userActivityHistory.filter { activity in
            guard let checkInDate = activity.checkInDate else { return false }
            return calendar.isDate(checkInDate, inSameDayAs: date)
        }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        let maxCount = max(1, chartData.map(\.count).max() ?? 1)
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return max(4, ratio * 60) // Altura mínima de 4, máxima de 60
    }
    
    private var barWidth: CGFloat {
        return 30 // Barras médias para 15 dias
    }
    
    private var barSpacing: CGFloat {
        return 6 // Espaço médio para 15 dias
    }
    
    private func barColor(for count: Int) -> Color {
        if count == 0 {
            return Color.gray.opacity(0.3)
        } else if count <= 2 {
            return Color.blue.opacity(0.6)
        } else if count <= 4 {
            return Color.blue.opacity(0.8)
        } else {
            return Color.blue
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // 1, 2, 3, etc
        return formatter.string(from: date)
    }
}

struct DayActivity {
    let date: Date
    let count: Int
    let activities: [UserActivityResponse]
}

#Preview {
    ActivityChartView(viewModel: ProfileViewModel())
        .background(Color.fvBackground)
}
