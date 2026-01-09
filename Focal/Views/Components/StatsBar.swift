import SwiftUI

struct StatsBar: View {
    let energy: Int
    let taskCount: Int
    let completedCount: Int

    var body: some View {
        HStack(spacing: 12) {
            // Energy circular progress
            EnergyCircularProgress(energy: energy)
            
            // Task stats
            HStack(spacing: 8) {
                StatCard(
                    value: "\(taskCount)",
                    label: "Tasks",
                    color: DS.Colors.textPrimary
                )
                
                StatCard(
                    value: "\(completedCount)",
                    label: "Done",
                    color: DS.Colors.success
                )
            }
        }
    }
}

// MARK: - Energy Circular Progress
struct EnergyCircularProgress: View {
    let energy: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(DS.Colors.borderSubtle, lineWidth: 4)
                    .frame(width: 40, height: 40)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(energy) / 100.0)
                    .stroke(DS.Colors.secondary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                // Emoji
                Text("🔥")
                    .scaledFont(size: 16, relativeTo: .body)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    Text("\(energy)")
                        .scaledFont(size: 18, weight: .bold, relativeTo: .headline)
                        .foregroundStyle(DS.Colors.textPrimary)
                    
                    Text("/ 100")
                        .scaledFont(size: 12, relativeTo: .caption)
                        .foregroundStyle(DS.Colors.textSecondary)
                }
                
                Text("ENERGY")
                    .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .tracking(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .scaledFont(size: 18, weight: .bold, relativeTo: .headline)
                .foregroundStyle(color)
            
            Text(label)
                .scaledFont(size: 10, weight: .medium, relativeTo: .caption2)
                .foregroundStyle(DS.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(DS.Colors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    StatsBar(energy: 20, taskCount: 3, completedCount: 1)
        .padding()
        .background(DS.Colors.bgPrimary)
}
