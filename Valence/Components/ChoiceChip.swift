import SwiftUI

/// A big rounded button you can select, used for feeling words and settings.
struct ChoiceChip: View {
    let title: String
    var symbol: String? = nil
    var hint: String? = nil
    let isSelected: Bool
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 52

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: minHeight)
            .padding(.horizontal, 10)
            .foregroundStyle(isSelected ? Color.onBrand : Color.ink)
            .background(isSelected ? Color.brand : Color.card,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color.clear : Color.brandSoft, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(hint ?? "")
    }
}

/// Lays chips out in a grid that fits as many per row as the text size allows.
struct ChipGrid<Content: View>: View {
    @ViewBuilder let content: () -> Content
    @ScaledMetric(relativeTo: .body) private var minChipWidth: CGFloat = 140

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minChipWidth), spacing: 10)],
                  spacing: 10,
                  content: content)
    }
}
