import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Search")) {
                    TextField("City, address, or marina", text: $viewModel.queryText)
                    HStack {
                        Slider(value: $viewModel.radiusKm, in: 5...100, step: 5)
                        Text(radiusLabel(km: viewModel.radiusKm, useMetric: viewModel.useMetric))
                            .frame(width: 70, alignment: .trailing)
                    }
                    Toggle("Use Metric", isOn: $viewModel.useMetric)
                }

                Section(header: Text("Boat Specs (Display Only)")) {
                    LabeledContent("LOA") {
                        TextField("m", value: $viewModel.boat.loaMeters, formatter: NumberFormatter.decimal)
                            .keyboardType(.decimalPad)
                    }
                    LabeledContent("Beam") {
                        TextField("m", value: $viewModel.boat.beamMeters, formatter: NumberFormatter.decimal)
                            .keyboardType(.decimalPad)
                    }
                    LabeledContent("Draft") {
                        TextField("m", value: $viewModel.boat.draftMeters, formatter: NumberFormatter.decimal)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Score Weights")) {
                    WeightSlider(title: "Distance", value: $viewModel.weights.distance)
                    WeightSlider(title: "Wind", value: $viewModel.weights.wind)
                    WeightSlider(title: "Current", value: $viewModel.weights.current)
                    WeightSlider(title: "Tide Range", value: $viewModel.weights.tideRange)
                }

                Section {
                    Button("Find marinas") {
                        Task { await viewModel.findMarinas() }
                    }
                    .disabled(viewModel.queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if case .searchingLocation = viewModel.state {
                    StatusRow(text: "Searching location…")
                }
                if case .findingMarinas = viewModel.state {
                    StatusRow(text: "Finding marinas…")
                }
                if case .fetchingEnvironment(let current, let total) = viewModel.state {
                    StatusRow(text: "Fetching wind, currents, tides… (\(current)/\(total))")
                }
                if case .error(let message) = viewModel.state {
                    Section {
                        Text(message).foregroundStyle(.red)
                        Button("Retry") {
                            Task { await viewModel.findMarinas() }
                        }
                    }
                }
            }
            .navigationTitle("MarinaMatch")
            .navigationDestination(isPresented: $viewModel.showResults) {
                if let resultsViewModel = viewModel.resultsViewModel {
                    ResultsView(viewModel: resultsViewModel)
                        .onChange(of: viewModel.weights) { _, newValue in
                            resultsViewModel.weights = newValue
                        }
                        .onChange(of: viewModel.useMetric) { _, newValue in
                            resultsViewModel.useMetric = newValue
                        }
                }
            }
        }
    }
}

private func radiusLabel(km: Double, useMetric: Bool) -> String {
    if useMetric {
        return "\(Int(km)) km"
    }
    let miles = km * 0.621371
    return String(format: "%.0f mi", miles)
}

private struct WeightSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
            Slider(value: $value, in: 0...1, step: 0.05)
            Text(String(format: "%.2f", value))
                .frame(width: 50, alignment: .trailing)
        }
    }
}

private struct StatusRow: View {
    let text: String

    var body: some View {
        HStack {
            ProgressView()
            Text(text)
        }
    }
}

private extension NumberFormatter {
    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
