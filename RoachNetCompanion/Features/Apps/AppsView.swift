import SwiftUI

struct AppsView: View {
    @Bindable var model: CompanionAppModel
    private let columns = [GridItem(.adaptive(minimum: 170), spacing: 14)]

    var body: some View {
        NavigationStack {
            ZStack {
                RoachBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        storeHeader
                        featuredCard
                        searchField
                        categoryStrip
                        sectionIntro
                        savedStrip
                        recentInstallsStrip
                        queuedInstallsStrip
                        spotlightRow
                        catalogGrid
                    }
                    .padding(16)
                }
                .refreshable {
                    try? await model.loadCatalog()
                    if model.connection.isConfigured {
                        await model.refreshAll()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: Binding(
                get: { model.selectedStoreItem },
                set: { model.selectedStoreItem = $0 }
            )) { item in
                AppDetailSheet(model: model, item: item)
            }
        }
    }

    private var storeHeader: some View {
        RoachHeroPanel(accent: RoachTheme.tertiary) {
            VStack(alignment: .leading, spacing: 14) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            RoachSectionHeader(
                                eyebrow: "Apps",
                                title: "The same shelf as the web store.",
                                detail: "Curated maps, courses, models, and references, with the same RoachNet install handoff the desktop already understands."
                            )

                            appPills
                        }

                        Spacer(minLength: 12)

                        VStack(alignment: .trailing, spacing: 12) {
                            Button {
                                model.selectedTab = .chat
                            } label: {
                                Label("Chat", systemImage: "message.fill")
                            }
                            .buttonStyle(.bordered)
                            .tint(RoachTheme.secondary)

                            appSignals
                                .frame(width: 280, alignment: .trailing)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        RoachSectionHeader(
                            eyebrow: "Apps",
                            title: "The same shelf as the web store.",
                            detail: "Curated maps, courses, models, and references, with the same RoachNet install handoff the desktop already understands."
                        )

                        appPills
                        appSignals

                        Button {
                            model.selectedTab = .chat
                        } label: {
                            Label("Jump to chat", systemImage: "message.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(RoachTheme.secondary)
                    }
                }
            }
        }
    }

    private var appPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                RoachStatusPill(
                    title: model.connection.isConfigured ? "Install bridge ready" : "Link Mac to install",
                    accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.favoriteItems.isEmpty ? "No saved picks" : "\(model.favoriteItems.count) saved",
                    accent: model.favoriteItems.isEmpty ? RoachTheme.primary : RoachTheme.tertiary
                )
                RoachStatusPill(
                    title: model.queuedInstallCount > 0 ? "\(model.queuedInstallCount) queued" : "Queue clear",
                    accent: model.queuedInstallCount > 0 ? RoachTheme.primary : RoachTheme.secondary
                )
            }
            .padding(.vertical, 1)
        }
    }

    private var appSignals: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 10),
                GridItem(.flexible(minimum: 0), spacing: 10),
            ],
            alignment: .leading,
            spacing: 10
        ) {
            RoachSignalTile(
                label: "Visible",
                value: "\(model.visibleCatalogItems.count)",
                accent: RoachTheme.tertiary,
                systemImage: "square.grid.2x2"
            )
            RoachSignalTile(
                label: "Saved",
                value: "\(model.favoriteItems.count)",
                accent: RoachTheme.primary,
                systemImage: "heart"
            )
            RoachSignalTile(
                label: "Queue",
                value: "\(model.queuedInstallCount)",
                accent: model.queuedInstallCount > 0 ? RoachTheme.secondary : RoachTheme.tertiary,
                systemImage: "tray.full"
            )
            RoachSignalTile(
                label: "Link",
                value: model.connection.isConfigured ? "Ready" : "Pair first",
                accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary,
                systemImage: "link"
            )
        }
    }

    private var featuredCard: some View {
        let item = model.featuredItem
        return RoachPanel {
            if let item {
                VStack(alignment: .leading, spacing: 14) {
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top) {
                                    StoreGlyph(
                                        band: item.iconBand ?? "RoachNet",
                                        monogram: item.iconMonogram ?? "APP",
                                        accent: roachAccentColor(for: item.accent)
                                    )

                                    Spacer()

                                    favoriteButton(for: item)
                                }

                                RoachSectionHeader(
                                    eyebrow: "Today",
                                    title: item.title,
                                    detail: item.summary
                                )

                                ViewThatFits(in: .horizontal) {
                                    HStack(spacing: 10) {
                                        Button(item.installLabel ?? "Install to RoachNet") {
                                            Task { await model.install(item) }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(RoachTheme.primary)

                                        Button("Preview") {
                                            model.selectedStoreItem = item
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(RoachTheme.secondary)
                                    }

                                    VStack(alignment: .leading, spacing: 10) {
                                        Button(item.installLabel ?? "Install to RoachNet") {
                                            Task { await model.install(item) }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(RoachTheme.primary)

                                        Button("Preview") {
                                            model.selectedStoreItem = item
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(RoachTheme.secondary)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                RoachSignalTile(
                                    label: "Category",
                                    value: item.category,
                                    accent: roachAccentColor(for: item.accent),
                                    systemImage: "square.stack.3d.up"
                                )
                                RoachSignalTile(
                                    label: "Size",
                                    value: item.size ?? "Unknown",
                                    accent: RoachTheme.tertiary,
                                    systemImage: "externaldrive"
                                )
                                RoachSignalTile(
                                    label: "State",
                                    value: item.status ?? (model.connection.isConfigured ? "Install-ready" : "Link Mac first"),
                                    accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary,
                                    systemImage: "arrow.down.circle"
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top) {
                                StoreGlyph(
                                    band: item.iconBand ?? "RoachNet",
                                    monogram: item.iconMonogram ?? "APP",
                                    accent: roachAccentColor(for: item.accent)
                                )

                                Spacer()

                                favoriteButton(for: item)
                            }

                            RoachSectionHeader(
                                eyebrow: "Today",
                                title: item.title,
                                detail: item.summary
                            )

                            HStack(spacing: 8) {
                                RoachBadge(title: item.category, accent: roachAccentColor(for: item.accent))
                                if let status = item.status {
                                    RoachBadge(title: status, accent: RoachTheme.secondary)
                                }
                            }

                            ViewThatFits(in: .horizontal) {
                                HStack(spacing: 10) {
                                    Button(item.installLabel ?? "Install to RoachNet") {
                                        Task { await model.install(item) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(RoachTheme.primary)

                                    Button("Preview") {
                                        model.selectedStoreItem = item
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(RoachTheme.secondary)
                                }

                                VStack(alignment: .leading, spacing: 10) {
                                    Button(item.installLabel ?? "Install to RoachNet") {
                                        Task { await model.install(item) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(RoachTheme.primary)

                                    Button("Preview") {
                                        model.selectedStoreItem = item
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(RoachTheme.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                EmptyStateView(
                    title: "Apps catalog",
                    detail: "The companion app pulls the same install lanes that ship from apps.roachnet.org.",
                    actionTitle: nil,
                    action: nil
                )
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(RoachTheme.secondary)

            TextField("Search apps, maps, courses, or models", text: $model.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(14)
        .background(RoachTheme.surface.opacity(0.96), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(RoachTheme.border, lineWidth: 1)
        )
    }

    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(model.categories, id: \.self) { category in
                    Button(category) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            model.selectedCategory = category
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(model.selectedCategory == category ? RoachTheme.primary.opacity(0.26) : RoachTheme.surface.opacity(0.92))
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(
                                        model.selectedCategory == category ? RoachTheme.primary.opacity(0.55) : RoachTheme.border,
                                        lineWidth: 1
                                    )
                            )
                    )
                    .foregroundStyle(model.selectedCategory == category ? Color.white : RoachTheme.subduedText)
                }
            }
        }
    }

    private var sectionIntro: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 10) {
                RoachSectionHeader(
                    eyebrow: model.selectedCategory,
                    title: model.selectedCategory == "Today" ? "The fast start shelf." : "\(model.selectedCategory) installs.",
                    detail: model.categoryDescription(for: model.selectedCategory)
                )

                RoachMetricRow {
                    RoachMetricTile(
                        label: "Apps",
                        value: "\(model.appCount(for: model.selectedCategory))",
                        accent: RoachTheme.secondary
                    )

                    RoachMetricTile(
                        label: "Link",
                        value: model.connection.isConfigured ? "Ready" : "Needs pairing",
                        accent: model.connection.isConfigured ? RoachTheme.tertiary : RoachTheme.primary
                    )

                    RoachMetricTile(
                        label: "Saved",
                        value: "\(model.favoriteItems.count)",
                        accent: RoachTheme.primary
                    )

                    RoachMetricTile(
                        label: "Queued",
                        value: "\(model.queuedInstallCount)",
                        accent: model.queuedInstallCount > 0 ? RoachTheme.secondary : RoachTheme.tertiary
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var savedStrip: some View {
        if !model.favoriteItems.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Saved")
                    .font(.headline)
                    .foregroundStyle(RoachTheme.text)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(model.favoriteItems.prefix(8)) { item in
                            SpotlightCard(model: model, item: item)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recentInstallsStrip: some View {
        if !model.recentInstallItems.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Recently sent")
                    .font(.headline)
                    .foregroundStyle(RoachTheme.text)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(model.recentInstallItems.prefix(8)) { item in
                            SpotlightCard(model: model, item: item)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var queuedInstallsStrip: some View {
        if !model.pendingInstallQueue.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Queued for desktop")
                    .font(.headline)
                    .foregroundStyle(RoachTheme.text)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(model.pendingInstallQueue.prefix(8)) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(RoachTheme.text)
                                    .lineLimit(1)
                                Text("Queued \(formattedRelativeDate(item.createdAt))")
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                            .frame(width: 180, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(RoachTheme.surface.opacity(0.96))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .strokeBorder(RoachTheme.border, lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var spotlightRow: some View {
        if !model.spotlightItems.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(model.selectedCategory == "Today" ? "Quick installs" : "Spotlight")
                    .font(.headline)
                    .foregroundStyle(RoachTheme.text)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(model.spotlightItems) { item in
                            SpotlightCard(model: model, item: item)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var catalogGrid: some View {
        if model.catalogItems.isEmpty {
            RoachPanel {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(RoachTheme.primary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Loading Apps catalog")
                            .font(.headline)
                            .foregroundStyle(RoachTheme.text)
                        Text("Pulling install metadata and shelf definitions.")
                            .font(.subheadline)
                            .foregroundStyle(RoachTheme.subduedText)
                    }
                    Spacer()
                }
            }
        } else {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(model.visibleCatalogItems) { item in
                    AppCard(model: model, item: item)
                }
            }
        }
    }
}

private struct SpotlightCard: View {
    @Bindable var model: CompanionAppModel
    let item: StoreAppItem

    var body: some View {
        Button {
            model.selectedStoreItem = item
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    StoreGlyph(
                        band: item.iconBand ?? item.category,
                        monogram: item.iconMonogram ?? "APP",
                        accent: roachAccentColor(for: item.accent)
                    )

                    Spacer()

                    if let size = item.size {
                        Text(size)
                            .font(.caption2)
                            .foregroundStyle(RoachTheme.subduedText)
                    }
                }

                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(RoachTheme.text)
                    .lineLimit(2)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundStyle(RoachTheme.subduedText)
                    .lineLimit(2)
            }
            .frame(width: 220, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(RoachTheme.surface.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(RoachTheme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct AppCard: View {
    @Bindable var model: CompanionAppModel
    let item: StoreAppItem

    var body: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    StoreGlyph(
                        band: item.iconBand ?? item.category,
                        monogram: item.iconMonogram ?? "APP",
                        accent: roachAccentColor(for: item.accent)
                    )
                    Spacer()
                    if let size = item.size {
                        Text(size)
                            .font(.caption)
                            .foregroundStyle(RoachTheme.subduedText)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(RoachTheme.text)
                        .lineLimit(2)

                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(RoachTheme.subduedText)
                        .lineLimit(2)

                    Text(item.summary)
                        .font(.subheadline)
                        .foregroundStyle(RoachTheme.subduedText)
                        .lineLimit(3)
                }

                HStack(spacing: 8) {
                    Text(item.category)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(RoachTheme.secondary)
                    if let status = item.status {
                        Text(status)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(roachAccentColor(for: item.accent))
                    }
                }

                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    Button {
                        model.toggleFavorite(item)
                    } label: {
                        Image(systemName: model.isFavorite(item) ? "heart.fill" : "heart")
                    }
                    .buttonStyle(.bordered)
                    .tint(model.isFavorite(item) ? RoachTheme.primary : RoachTheme.secondary)

                    Button(item.installLabel ?? "Install") {
                        Task { await model.install(item) }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(roachAccentColor(for: item.accent))
                    .disabled(model.installingItemIDs.contains(item.id))

                    Button("More") {
                        model.selectedStoreItem = item
                    }
                    .buttonStyle(.bordered)
                    .tint(RoachTheme.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 270, alignment: .topLeading)
        }
    }
}

private struct AppDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var model: CompanionAppModel
    let item: StoreAppItem

    var body: some View {
        NavigationStack {
            ZStack {
                RoachBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RoachPanel {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    StoreGlyph(
                                        band: item.iconBand ?? item.category,
                                        monogram: item.iconMonogram ?? "APP",
                                        accent: roachAccentColor(for: item.accent)
                                    )
                                    Spacer()
                                    Button {
                                        model.toggleFavorite(item)
                                    } label: {
                                        Image(systemName: model.isFavorite(item) ? "heart.fill" : "heart")
                                            .font(.headline)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(model.isFavorite(item) ? RoachTheme.primary : RoachTheme.secondary)
                                    if let source = item.source {
                                        RoachBadge(title: source, accent: roachAccentColor(for: item.accent))
                                    }
                                }

                                RoachSectionHeader(
                                    eyebrow: item.category,
                                    title: item.title,
                                    detail: item.summary
                                )

                                HStack(spacing: 10) {
                                    if let size = item.size {
                                        RoachMetricTile(label: "Size", value: size, accent: RoachTheme.secondary)
                                    }

                                    if let status = item.status {
                                        RoachMetricTile(label: "Shelf", value: status, accent: roachAccentColor(for: item.accent))
                                    }
                                }

                                if !item.includes.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Inside")
                                            .font(.headline)
                                            .foregroundStyle(RoachTheme.text)

                                        ForEach(item.includes, id: \.self) { line in
                                            Text("• \(line)")
                                                .foregroundStyle(RoachTheme.subduedText)
                                        }
                                    }
                                }

                                Button(item.installLabel ?? "Install to RoachNet") {
                                    Task { await model.install(item) }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(RoachTheme.primary)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(item.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension AppsView {
    func favoriteButton(for item: StoreAppItem) -> some View {
        Button {
            model.toggleFavorite(item)
        } label: {
            Image(systemName: model.isFavorite(item) ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundStyle(Color.white)
        }
        .buttonStyle(.bordered)
        .tint(model.isFavorite(item) ? RoachTheme.primary : RoachTheme.secondary)
    }
}
