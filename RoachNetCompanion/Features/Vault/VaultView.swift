import SwiftUI

struct VaultView: View {
    @Bindable var model: CompanionAppModel

    var body: some View {
        NavigationStack {
            ZStack {
                RoachBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        vaultHeader
                        if let vault = model.vault {
                            summaryPanel(vault)
                            notesPanel(vault)
                            knowledgePanel(vault)
                            archivesPanel(vault)
                        } else if model.connection.isConfigured, model.isBootstrapping {
                            RoachPanel {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .tint(RoachTheme.primary)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Loading Vault")
                                            .font(.headline)
                                            .foregroundStyle(RoachTheme.text)
                                        Text("Pulling RoachBrain, files, and archive summaries from the paired Mac.")
                                            .font(.subheadline)
                                            .foregroundStyle(RoachTheme.subduedText)
                                    }
                                    Spacer()
                                }
                            }
                        } else {
                            EmptyStateView(
                                title: "Vault stays on the Mac",
                                detail: "Link the companion lane to browse RoachBrain, archive stubs, and knowledge files from the phone.",
                                actionTitle: "Open connection"
                            ) {
                                model.settingsPresented = true
                            }
                        }
                    }
                    .padding(16)
                }
                .refreshable {
                    await model.refreshAll()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var vaultHeader: some View {
        RoachHeroPanel(accent: RoachTheme.secondary) {
            VStack(alignment: .leading, spacing: 14) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                RoachSectionHeader(
                                    eyebrow: "Vault",
                                    title: "Your shelf, carried forward.",
                                    detail: "RoachBrain notes, indexed files, and saved captures stay readable on the phone without opening the whole desktop shell."
                                )

                                if let lastRefreshAt = model.lastRefreshAt {
                                    Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                                        .font(.caption)
                                        .foregroundStyle(RoachTheme.subduedText)
                                }
                            }

                            vaultPills
                        }

                        Spacer(minLength: 12)

                        VStack(alignment: .trailing, spacing: 12) {
                            Button {
                                model.settingsPresented = true
                            } label: {
                                Label("Settings", systemImage: "slider.horizontal.3")
                            }
                            .buttonStyle(.bordered)
                            .tint(RoachTheme.secondary)

                            vaultSignals
                                .frame(width: 280, alignment: .trailing)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            RoachSectionHeader(
                                eyebrow: "Vault",
                                title: "Your shelf, carried forward.",
                                detail: "RoachBrain notes, indexed files, and saved captures stay readable on the phone without opening the whole desktop shell."
                            )

                            if let lastRefreshAt = model.lastRefreshAt {
                                Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }

                        vaultPills
                        vaultSignals

                        Button {
                            model.settingsPresented = true
                        } label: {
                            Label("Connection settings", systemImage: "slider.horizontal.3")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(RoachTheme.secondary)
                    }
                }
            }
        }
    }

    private var vaultPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                RoachStatusPill(
                    title: model.connection.isConfigured ? "Paired vault" : "Local cache",
                    accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.runtime?.account?.linked == true ? "Account sync" : "Account local",
                    accent: model.runtime?.account?.linked == true ? RoachTheme.tertiary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.runtime?.roachSync?.enabled == true ? "RoachSync armed" : "RoachSync off",
                    accent: model.runtime?.roachSync?.enabled == true ? RoachTheme.secondary : RoachTheme.primary
                )
            }
            .padding(.vertical, 1)
        }
    }

    private var vaultSignals: some View {
        let roachBrainCount = model.vault?.roachBrain.count ?? 0
        let knowledgeCount = model.vault?.knowledgeFiles.count ?? 0
        let archiveCount = model.vault?.siteArchives.count ?? 0

        return LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 10),
                GridItem(.flexible(minimum: 0), spacing: 10),
            ],
            alignment: .leading,
            spacing: 10
        ) {
            RoachSignalTile(
                label: "RoachBrain",
                value: "\(roachBrainCount)",
                accent: RoachTheme.primary,
                systemImage: "brain.head.profile"
            )
            RoachSignalTile(
                label: "Files",
                value: "\(knowledgeCount)",
                accent: RoachTheme.secondary,
                systemImage: "doc.text"
            )
            RoachSignalTile(
                label: "Archives",
                value: "\(archiveCount)",
                accent: RoachTheme.tertiary,
                systemImage: "shippingbox"
            )
            RoachSignalTile(
                label: "Link",
                value: model.connection.isConfigured ? "Ready" : "Pair first",
                accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary,
                systemImage: "link"
            )
        }
    }

    private func summaryPanel(_ vault: CompanionVaultSummary) -> some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "Vault",
                    title: "The Mac shelf, from the phone.",
                    detail: "RoachBrain notes, indexed files, and site archives stay browseable without opening the full desktop shell."
                )

                RoachMetricRow {
                    RoachMetricTile(label: "RoachBrain", value: "\(vault.roachBrain.count)", accent: RoachTheme.primary)
                    RoachMetricTile(label: "Files", value: "\(vault.knowledgeFiles.count)", accent: RoachTheme.secondary)
                    RoachMetricTile(label: "Archives", value: "\(vault.siteArchives.count)", accent: RoachTheme.tertiary)
                }

                HStack(spacing: 10) {
                    RoachActionPill(title: "RoachBrain", systemImage: "brain.head.profile", accent: RoachTheme.primary)
                    RoachActionPill(title: "Archives", systemImage: "shippingbox", accent: RoachTheme.tertiary)
                }

                if let lastRefreshAt = model.lastRefreshAt {
                    Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                        .font(.caption)
                        .foregroundStyle(RoachTheme.subduedText)
                }
            }
        }
    }

    private func notesPanel(_ vault: CompanionVaultSummary) -> some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "RoachBrain",
                    title: "Pinned memory and recent notes.",
                    detail: vault.roachBrain.isEmpty ? "No captured memory yet." : nil
                )

                if vault.roachBrain.isEmpty {
                    Text("No captured memory yet.")
                        .font(.subheadline)
                        .foregroundStyle(RoachTheme.subduedText)
                } else {
                    ForEach(vault.roachBrain.prefix(6)) { memory in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(memory.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(RoachTheme.text)
                                Spacer()
                                if memory.pinned {
                                    Image(systemName: "pin.fill")
                                        .foregroundStyle(RoachTheme.primary)
                                }
                            }

                            Text(memory.summary)
                                .font(.subheadline)
                                .foregroundStyle(RoachTheme.subduedText)

                            Text(memory.tags.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(RoachTheme.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private func knowledgePanel(_ vault: CompanionVaultSummary) -> some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "Knowledge files",
                    title: "Indexed docs in the vault.",
                    detail: vault.knowledgeFiles.isEmpty ? "No indexed files yet." : nil
                )

                if vault.knowledgeFiles.isEmpty {
                    Text("No indexed files yet.")
                        .font(.subheadline)
                        .foregroundStyle(RoachTheme.subduedText)
                } else {
                    ForEach(vault.knowledgeFiles.prefix(8), id: \.self) { file in
                        Text(file)
                            .font(.subheadline.monospaced())
                            .foregroundStyle(RoachTheme.text)
                    }
                }
            }
        }
    }

    private func archivesPanel(_ vault: CompanionVaultSummary) -> some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "Site archives",
                    title: "Offline captures and saved shelves.",
                    detail: vault.siteArchives.isEmpty ? "No archives yet." : nil
                )

                if vault.siteArchives.isEmpty {
                    Text("No archives yet.")
                        .font(.subheadline)
                        .foregroundStyle(RoachTheme.subduedText)
                } else {
                    ForEach(vault.siteArchives.prefix(6)) { archive in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(archive.title ?? archive.slug)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(RoachTheme.text)
                            Text(archive.note ?? archive.sourceUrl ?? "Offline archive ready.")
                                .font(.caption)
                                .foregroundStyle(RoachTheme.subduedText)
                        }
                    }
                }
            }
        }
    }
}
