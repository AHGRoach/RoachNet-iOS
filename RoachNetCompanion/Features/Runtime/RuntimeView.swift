@preconcurrency import CoreBluetooth
import CoreLocation
import SwiftUI

struct RuntimeView: View {
    @Bindable var model: CompanionAppModel
    @StateObject private var phoneGPS = RoachPhoneGPSAdvertiser()

    var body: some View {
        NavigationStack {
            ZStack {
                RoachBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        overviewPanel
                        connectionPanel
                        accountPanel
                        roachTailPanel
                        phoneGPSPanel
                        roachSyncPanel
                        machinePanel
                        roachClawPanel
                        servicesPanel
                        downloadsPanel
                        issuesPanel
                    }
                    .padding(16)
                    .padding(.bottom, RoachCompanionChrome.bottomContentClearance)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.clear.frame(height: RoachCompanionChrome.tabBarAvoidance)
                }
                .refreshable {
                    await model.refreshAll()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private var overviewPanel: some View {
        RoachHeroPanel(accent: RoachTheme.secondary) {
            VStack(alignment: .leading, spacing: 16) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                RoachSectionHeader(
                                    eyebrow: "Runtime",
                                    title: "Contained stack. No mystery boxes.",
                                    detail: "RoachTail, RoachSync, account state, and the local runtime stay in one readable control surface."
                                )

                                if let lastRefreshAt = model.lastRefreshAt {
                                    Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                                        .font(.caption)
                                        .foregroundStyle(RoachTheme.subduedText)
                                }
                            }

                            runtimePills
                        }

                        Spacer(minLength: 12)

                        VStack(alignment: .trailing, spacing: 12) {
                            Button {
                                Task { await model.refreshAll() }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(.bordered)
                            .tint(RoachTheme.secondary)

                            runtimeSignals
                                .frame(width: 280, alignment: .trailing)
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            RoachSectionHeader(
                                eyebrow: "Runtime",
                                title: "Contained stack. No mystery boxes.",
                                detail: "RoachTail, RoachSync, account state, and the local runtime stay in one readable control surface."
                            )

                            if let lastRefreshAt = model.lastRefreshAt {
                                Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }

                        runtimePills
                        runtimeSignals

                        Button {
                            Task { await model.refreshAll() }
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(RoachTheme.secondary)
                    }
                }
            }
        }
    }

    private var phoneGPSPanel: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "RoachAtlas",
                    title: phoneGPS.isRunning ? "iPhone GPS is advertising." : "Share live GPS with the Mac.",
                    detail: "Foreground BLE only. The phone sends a local RoachAtlas packet to the paired desktop receiver; it does not upload location through RoachNet."
                )

                RoachMetricRow {
                    RoachMetricTile(
                        label: "Bridge",
                        value: phoneGPS.state.label,
                        accent: phoneGPS.state.accent
                    )
                    RoachMetricTile(
                        label: "Fix",
                        value: phoneGPS.latestFix?.coordinateLabel ?? "No fix",
                        accent: phoneGPS.latestFix == nil ? RoachTheme.primary : RoachTheme.secondary
                    )
                    RoachMetricTile(
                        label: "Packets",
                        value: "\(phoneGPS.packetCount)",
                        accent: RoachTheme.tertiary
                    )
                }

                HStack(spacing: 10) {
                    Image(systemName: phoneGPS.isRunning ? "location.fill" : "location")
                        .font(.headline)
                        .foregroundStyle(phoneGPS.state.accent)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(phoneGPS.state.accent.opacity(0.14))
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(phoneGPS.state.detail)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(RoachTheme.text)
                        Text(phoneGPS.latestFix.map { "Accuracy \($0.accuracyLabel) · \($0.ageLabel)" } ?? "No location leaves the phone until you start this bridge.")
                            .font(.caption)
                            .foregroundStyle(RoachTheme.subduedText)
                    }

                    Spacer(minLength: 0)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        Button {
                            phoneGPS.isRunning ? phoneGPS.stop() : phoneGPS.start()
                        } label: {
                            Label(phoneGPS.isRunning ? "Stop GPS" : "Start GPS", systemImage: phoneGPS.isRunning ? "stop.fill" : "antenna.radiowaves.left.and.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(phoneGPS.isRunning ? RoachTheme.primary : RoachTheme.secondary)

                        Button {
                            phoneGPS.publishDemoFix()
                        } label: {
                            Label("Demo packet", systemImage: "location.north.line")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(RoachTheme.tertiary)
                    }

                    VStack(spacing: 10) {
                        Button {
                            phoneGPS.isRunning ? phoneGPS.stop() : phoneGPS.start()
                        } label: {
                            Label(phoneGPS.isRunning ? "Stop GPS" : "Start GPS", systemImage: phoneGPS.isRunning ? "stop.fill" : "antenna.radiowaves.left.and.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(phoneGPS.isRunning ? RoachTheme.primary : RoachTheme.secondary)

                        Button {
                            phoneGPS.publishDemoFix()
                        } label: {
                            Label("Demo packet", systemImage: "location.north.line")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(RoachTheme.tertiary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $phoneGPS.highAccuracy) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Precise drive mode")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(RoachTheme.text)
                            Text("Uses the best foreground location accuracy while the bridge is running.")
                                .font(.caption)
                                .foregroundStyle(RoachTheme.subduedText)
                        }
                    }
                    .toggleStyle(.switch)
                    .tint(RoachTheme.secondary)

                    Toggle(isOn: $phoneGPS.includeMotionDetails) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Include speed, heading, altitude")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(RoachTheme.text)
                            Text("RoachAtlas can draw richer traces; turn it off for a lean lat/lon packet.")
                                .font(.caption)
                                .foregroundStyle(RoachTheme.subduedText)
                        }
                    }
                    .toggleStyle(.switch)
                    .tint(RoachTheme.tertiary)
                }

                if let packet = phoneGPS.lastPacket, !packet.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Packet")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoachTheme.secondary)
                        Text(packet)
                            .font(.caption2.monospaced())
                            .foregroundStyle(RoachTheme.subduedText)
                            .lineLimit(3)
                            .textSelection(.enabled)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("BLE contract")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RoachTheme.secondary)
                    Text("\(RoachPhoneGPSAdvertiser.gpsServiceUUIDString) · \(RoachPhoneGPSAdvertiser.gpsCharacteristicUUIDString)")
                        .font(.caption2.monospaced())
                        .foregroundStyle(RoachTheme.subduedText)
                        .textSelection(.enabled)
                }
            }
        }
    }

    private var runtimePills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                RoachStatusPill(
                    title: model.runtime?.account?.linked == true ? "Account linked" : "Account local",
                    accent: model.runtime?.account?.linked == true ? RoachTheme.tertiary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.runtime?.roachTail?.enabled == true ? "RoachTail armed" : "RoachTail off",
                    accent: model.runtime?.roachTail?.enabled == true ? RoachTheme.secondary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.runtime?.roachSync?.enabled == true ? "RoachSync armed" : "RoachSync off",
                    accent: model.runtime?.roachSync?.enabled == true ? RoachTheme.secondary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.connection.isConfigured ? "Bridge ready" : "Bridge local-only",
                    accent: model.connection.isConfigured ? RoachTheme.tertiary : RoachTheme.primary
                )
            }
            .padding(.vertical, 1)
        }
    }

    private var runtimeSignals: some View {
        let hasLiveService = model.runtime?.services.contains(where: {
            ($0.status ?? "").localizedCaseInsensitiveContains("live") ||
            ($0.status ?? "").localizedCaseInsensitiveContains("running")
        }) == true

        return LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 10),
                GridItem(.flexible(minimum: 0), spacing: 10),
            ],
            alignment: .leading,
            spacing: 10
        ) {
            RoachSignalTile(
                label: "Runtime",
                value: hasLiveService ? "Live" : "Local",
                accent: hasLiveService ? RoachTheme.secondary : RoachTheme.primary,
                systemImage: "switch.2"
            )
            RoachSignalTile(
                label: "Services",
                value: "\(model.runtime?.services.count ?? 0)",
                accent: RoachTheme.tertiary,
                systemImage: "server.rack"
            )
            RoachSignalTile(
                label: "Downloads",
                value: "\(model.runtime?.downloads.count ?? 0)",
                accent: RoachTheme.primary,
                systemImage: "arrow.down.circle"
            )
            RoachSignalTile(
                label: "Issues",
                value: "\(model.runtimeIssues.count)",
                accent: model.runtimeIssues.isEmpty ? RoachTheme.secondary : RoachTheme.primary,
                systemImage: "exclamationmark.triangle"
            )
        }
    }

    @ViewBuilder
    private var accountPanel: some View {
        if let account = model.runtime?.account {
            RoachPanel {
                VStack(alignment: .leading, spacing: 12) {
                    RoachSectionHeader(
                        eyebrow: "Account",
                        title: account.linked ? "Account lane is linked." : "Account lane is still local-only.",
                        detail: "RoachClaw web chat, synced settings, and saved app picks can ride the same contained identity."
                    )

                    RoachMetricRow {
                        RoachMetricTile(
                            label: "State",
                            value: account.status.capitalized,
                            accent: account.linked ? RoachTheme.secondary : RoachTheme.primary
                        )

                        RoachMetricTile(
                            label: "Settings",
                            value: account.settingsSyncEnabled ? "Synced" : "Local",
                            accent: account.settingsSyncEnabled ? RoachTheme.tertiary : RoachTheme.primary
                        )

                        RoachMetricTile(
                            label: "Apps",
                            value: account.savedAppsSyncEnabled ? "Synced" : "Local",
                            accent: account.savedAppsSyncEnabled ? RoachTheme.tertiary : RoachTheme.primary
                        )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alias")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoachTheme.secondary)
                        Text(account.aliasHost)
                            .font(.caption.monospaced())
                            .foregroundStyle(RoachTheme.text)
                    }

                    if let bridgeUrl = account.bridgeUrl, !bridgeUrl.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bridge")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(RoachTheme.secondary)
                            Text(bridgeUrl)
                                .font(.caption.monospaced())
                                .foregroundStyle(RoachTheme.text)
                                .textSelection(.enabled)
                        }
                    }

                    if !account.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(account.notes.prefix(3), id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var roachTailPanel: some View {
        if let roachTail = model.runtime?.roachTail {
            RoachPanel {
                VStack(alignment: .leading, spacing: 12) {
                    RoachSectionHeader(
                        eyebrow: "RoachTail",
                        title: roachTail.enabled ? "Private device lane is \(roachTail.status)." : "Private device lane is off.",
                        detail: "RoachTail is the private overlay for mobile control, thread carryover, and remote installs."
                    )

                    RoachMetricRow {
                        RoachMetricTile(
                            label: "Network",
                            value: roachTail.networkName,
                            accent: RoachTheme.primary
                        )

                        RoachMetricTile(
                            label: "Peers",
                            value: "\(roachTail.peers.count)",
                            accent: RoachTheme.secondary
                        )

                        RoachMetricTile(
                            label: "State",
                            value: roachTail.status.capitalized,
                            accent: roachTail.enabled ? RoachTheme.tertiary : RoachTheme.primary
                        )
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 10) {
                                roachTailToggle(roachTail)

                                if !model.usingRoachTailPeerToken {
                                    Button {
                                        Task { await model.affectRoachTail("refresh-join-code") }
                                    } label: {
                                        Text("Refresh code")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(RoachTheme.tertiary)
                                    .disabled(model.isActingRoachTail || !roachTail.enabled)
                                }
                            }

                            VStack(spacing: 10) {
                                roachTailToggle(roachTail)

                                if !model.usingRoachTailPeerToken {
                                    Button {
                                        Task { await model.affectRoachTail("refresh-join-code") }
                                    } label: {
                                        Text("Refresh code")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(RoachTheme.tertiary)
                                    .disabled(model.isActingRoachTail || !roachTail.enabled)
                                }
                            }
                        }

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 10) {
                                Button {
                                    Task {
                                        if model.roachTailIsLinked {
                                            await model.unlinkThisDeviceFromRoachTail()
                                        } else {
                                            await model.linkThisDeviceToRoachTail()
                                        }
                                    }
                                } label: {
                                    Text(model.roachTailIsLinked ? "Unlink this device" : "Link this device")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(model.roachTailIsLinked ? RoachTheme.primary : RoachTheme.secondary)
                                .disabled(model.isActingRoachTail || !roachTail.enabled)

                                if !model.usingRoachTailPeerToken {
                                    Button {
                                        Task { await model.affectRoachTail("clear-peers") }
                                    } label: {
                                        Text("Clear peers")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(RoachTheme.primary)
                                    .disabled(model.isActingRoachTail || roachTail.peers.isEmpty)
                                }
                            }

                            VStack(spacing: 10) {
                                Button {
                                    Task {
                                        if model.roachTailIsLinked {
                                            await model.unlinkThisDeviceFromRoachTail()
                                        } else {
                                            await model.linkThisDeviceToRoachTail()
                                        }
                                    }
                                } label: {
                                    Text(model.roachTailIsLinked ? "Unlink this device" : "Link this device")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(model.roachTailIsLinked ? RoachTheme.primary : RoachTheme.secondary)
                                .disabled(model.isActingRoachTail || !roachTail.enabled)

                                if !model.usingRoachTailPeerToken {
                                    Button {
                                        Task { await model.affectRoachTail("clear-peers") }
                                    } label: {
                                        Text("Clear peers")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(RoachTheme.primary)
                                    .disabled(model.isActingRoachTail || roachTail.peers.isEmpty)
                                }
                            }
                        }
                    }

                    if let advertisedUrl = roachTail.advertisedUrl, !advertisedUrl.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bridge")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(RoachTheme.secondary)
                            Text(advertisedUrl)
                                .font(.caption.monospaced())
                                .foregroundStyle(RoachTheme.text)
                                .textSelection(.enabled)
                        }
                    }

                    if let joinCode = roachTail.joinCode, !joinCode.isEmpty {
                        HStack(spacing: 8) {
                            Text("Join code")
                                .font(.caption)
                                .foregroundStyle(RoachTheme.subduedText)
                            Text(joinCode)
                                .font(.caption.monospaced().weight(.semibold))
                                .foregroundStyle(RoachTheme.text)
                        }
                    } else if model.usingRoachTailPeerToken {
                        Text("Join-code controls stay on the Mac or any device still using the desktop companion token.")
                            .font(.caption)
                            .foregroundStyle(RoachTheme.subduedText)
                    }

                    if !roachTail.peers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Linked devices")
                                .font(.headline)
                                .foregroundStyle(RoachTheme.text)

                            ForEach(roachTail.peers.prefix(4)) { peer in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(peer.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(RoachTheme.text)
                                        Spacer()
                                        Text(peer.status.capitalized)
                                            .font(.caption)
                                            .foregroundStyle(RoachTheme.secondary)
                                    }

                                    Text("\(peer.platform) · \(peer.endpoint ?? "Peer lane ready")")
                                        .font(.caption)
                                        .foregroundStyle(RoachTheme.subduedText)

                                    if !peer.tags.isEmpty {
                                        Text(peer.tags.joined(separator: " · "))
                                            .font(.caption2)
                                            .foregroundStyle(RoachTheme.tertiary)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }

                    if !roachTail.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(roachTail.notes.prefix(3), id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var roachSyncPanel: some View {
        if let roachSync = model.runtime?.roachSync {
            RoachPanel {
                VStack(alignment: .leading, spacing: 12) {
                    RoachSectionHeader(
                        eyebrow: "RoachSync",
                        title: roachSync.enabled ? "Contained sync lane is \(roachSync.status)." : "Contained sync lane is off.",
                        detail: "RoachSync keeps the vault and future shared state grouped under one private sync lane."
                    )

                    RoachMetricRow {
                        RoachMetricTile(
                            label: "Network",
                            value: roachSync.networkName,
                            accent: RoachTheme.primary
                        )

                        RoachMetricTile(
                            label: "Peers",
                            value: "\(roachSync.peers.count)",
                            accent: RoachTheme.secondary
                        )

                        RoachMetricTile(
                            label: "State",
                            value: roachSync.status.capitalized,
                            accent: roachSync.enabled ? RoachTheme.tertiary : RoachTheme.primary
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(
                            isOn: Binding(
                                get: { model.runtime?.roachSync?.enabled ?? false },
                                set: { nextValue in
                                    Task {
                                        await model.affectRoachSync(nextValue ? "enable" : "disable")
                                    }
                                }
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("RoachSync")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(RoachTheme.text)
                                Text(roachSync.enabled ? "Contained sync lane is armed." : "Contained sync lane is off.")
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }
                        .toggleStyle(.switch)
                        .tint(RoachTheme.secondary)
                        .disabled(model.isActingRoachSync)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 10) {
                                Button {
                                    Task { await model.affectRoachSync("refresh") }
                                } label: {
                                    Text("Refresh sync")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(model.isActingRoachSync)

                                Button {
                                    Task { await model.affectRoachSync("clear-peers") }
                                } label: {
                                    Text("Clear peers")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(model.isActingRoachSync || roachSync.peers.isEmpty)
                            }

                            VStack(spacing: 10) {
                                Button {
                                    Task { await model.affectRoachSync("refresh") }
                                } label: {
                                    Text("Refresh sync")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(model.isActingRoachSync)

                                Button {
                                    Task { await model.affectRoachSync("clear-peers") }
                                } label: {
                                    Text("Clear peers")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(model.isActingRoachSync || roachSync.peers.isEmpty)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Folder")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RoachTheme.secondary)
                        Text(roachSync.folderPath)
                            .font(.caption.monospaced())
                            .foregroundStyle(RoachTheme.text)
                            .textSelection(.enabled)
                    }

                    if !roachSync.peers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synced devices")
                                .font(.headline)
                                .foregroundStyle(RoachTheme.text)

                            ForEach(roachSync.peers.prefix(4)) { peer in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(peer.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(RoachTheme.text)
                                        Spacer()
                                        Text(peer.status.capitalized)
                                            .font(.caption)
                                            .foregroundStyle(RoachTheme.secondary)
                                    }

                                    Text(peer.lastSeenAt.map(formattedRelativeDate) ?? "Contained sync lane ready")
                                        .font(.caption)
                                        .foregroundStyle(RoachTheme.subduedText)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }

                    if !roachSync.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(roachSync.notes.prefix(3), id: \.self) { note in
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }
                    }
                }
            }
        }
    }

    private var connectionPanel: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "Companion lane",
                    title: model.connection.isConfigured ? "Phone to Mac link is live." : "Pair the desktop first.",
                    detail: "Runtime status, service controls, and RoachClaw all run through the same companion bridge."
                )

                RoachMetricRow {
                    RoachMetricTile(
                        label: "URL",
                        value: model.connection.baseURL,
                        accent: RoachTheme.tertiary
                    )

                    RoachMetricTile(
                        label: "Token",
                        value: model.connection.isConfigured
                            ? (model.usingRoachTailPeerToken ? "RoachTail peer" : "Desktop token")
                            : "Missing",
                        accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary
                    )
                }

                if model.pairedMachineName != nil {
                    Text("Paired desktop linked.")
                        .font(.caption)
                        .foregroundStyle(RoachTheme.subduedText)
                } else if !model.connection.isConfigured {
                    Text("Previewing the runtime lane until you pair the Mac.")
                        .font(.caption)
                        .foregroundStyle(RoachTheme.subduedText)
                }

                if let lastRefreshAt = model.lastRefreshAt {
                    Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                        .font(.caption)
                        .foregroundStyle(RoachTheme.secondary)
                }
            }
        }
    }

    private var machinePanel: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "Machine",
                    title: model.runtime?.systemInfo?.hardwareProfile?.platformLabel ?? "RoachNet desktop",
                    detail: model.runtime?.systemInfo?.hardwareProfile?.recommendedModelClass ?? "Model guidance is not available yet."
                )

                RoachMetricRow {
                    if let available = model.runtime?.systemInfo?.mem?.available {
                        RoachMetricTile(
                            label: "Memory",
                            value: formattedBytes(Int64(available)),
                            accent: RoachTheme.secondary
                        )
                    }

                    RoachMetricTile(
                        label: "Services",
                        value: "\(model.runtime?.services.count ?? 0)",
                        accent: RoachTheme.tertiary
                    )
                }

                if let notes = model.runtime?.systemInfo?.hardwareProfile?.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(notes.prefix(3), id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(RoachTheme.subduedText)
                        }
                    }
                }
            }
        }
    }

    private var roachClawPanel: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                RoachSectionHeader(
                    eyebrow: "RoachClaw",
                    title: (model.runtime?.roachClaw.ready ?? false) ? "Local AI lane is ready." : "RoachClaw is warming up.",
                    detail: model.runtime?.roachClaw.error ?? "Model selection, installed packs, and provider state all show here without leaving the phone."
                )

                RoachMetricRow {
                    RoachMetricTile(
                        label: "State",
                        value: (model.runtime?.roachClaw.ready ?? false) ? "Ready" : "Booting",
                        accent: (model.runtime?.roachClaw.ready ?? false) ? RoachTheme.secondary : RoachTheme.primary
                    )

                    RoachMetricTile(
                        label: "Model",
                        value: model.runtime?.roachClaw.resolvedDefaultModel ?? model.runtime?.roachClaw.defaultModel ?? "Not set",
                        accent: RoachTheme.tertiary
                    )
                }

                if let installedModels = model.runtime?.installedModels, !installedModels.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Installed models")
                            .font(.headline)
                            .foregroundStyle(RoachTheme.text)

                        ForEach(installedModels.prefix(6)) { model in
                            HStack {
                                Text(model.name)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(RoachTheme.text)
                                Spacer()
                                Text(formattedBytes(model.size))
                                    .font(.caption2)
                                    .foregroundStyle(RoachTheme.subduedText)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var servicesPanel: some View {
        if let services = model.runtime?.services, !services.isEmpty {
            RoachPanel {
                VStack(alignment: .leading, spacing: 12) {
                    RoachSectionHeader(
                        eyebrow: "Services",
                        title: "Control the desktop lane from here.",
                        detail: "Restart or stop pieces of the runtime without leaving the phone."
                    )

                    ForEach(services.prefix(6)) { service in
                        serviceRow(service)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var downloadsPanel: some View {
        if let downloads = model.runtime?.downloads, !downloads.isEmpty {
            RoachPanel {
                VStack(alignment: .leading, spacing: 10) {
                    RoachSectionHeader(
                        eyebrow: "Downloads",
                        title: "Current install queue.",
                        detail: "These are the active jobs on the paired desktop."
                    )

                    ForEach(downloads.prefix(5)) { job in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(job.filepath ?? job.jobId)
                                .font(.caption.monospaced())
                                .foregroundStyle(RoachTheme.text)
                                .lineLimit(1)

                            HStack {
                                Text(job.status ?? "Queued")
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.subduedText)
                                Spacer()
                                Text(job.progress.map { "\($0)%" } ?? "--")
                                    .font(.caption)
                                    .foregroundStyle(RoachTheme.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var issuesPanel: some View {
        if !model.runtimeIssues.isEmpty {
            RoachPanel {
                VStack(alignment: .leading, spacing: 10) {
                    RoachSectionHeader(
                        eyebrow: "Runtime notes",
                        title: "A few things need attention.",
                        detail: nil
                    )

                    ForEach(model.runtimeIssues) { issue in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.path)
                                .font(.caption.monospaced())
                                .foregroundStyle(RoachTheme.secondary)
                            Text(issue.error)
                                .font(.caption)
                                .foregroundStyle(RoachTheme.subduedText)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func serviceRow(_ service: CompanionService) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.friendlyName ?? service.serviceName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RoachTheme.text)

                    Text(service.status ?? "Unknown state")
                        .font(.caption)
                        .foregroundStyle(RoachTheme.subduedText)
                }

                Spacer()

                RoachBadge(
                    title: (service.installed ?? false) ? "Installed" : "Optional",
                    accent: (service.installed ?? false) ? RoachTheme.secondary : RoachTheme.tertiary
                )
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    runtimeActionButton(title: "Start", service: service.serviceName, action: "start")
                    runtimeActionButton(title: "Restart", service: service.serviceName, action: "restart")
                    runtimeActionButton(title: "Stop", service: service.serviceName, action: "stop")
                }

                VStack(spacing: 8) {
                    runtimeActionButton(title: "Start", service: service.serviceName, action: "start")
                    runtimeActionButton(title: "Restart", service: service.serviceName, action: "restart")
                    runtimeActionButton(title: "Stop", service: service.serviceName, action: "stop")
                }
            }
        }
    }

    private func runtimeActionButton(title: String, service: String, action: String) -> some View {
        Button(title) {
            Task {
                await model.affectService(service, action: action)
            }
        }
        .buttonStyle(.bordered)
        .tint(action == "stop" ? RoachTheme.primary : RoachTheme.secondary)
        .disabled(model.actingServiceNames.contains(service))
        .frame(maxWidth: .infinity)
    }

    private func roachTailToggle(_ roachTail: CompanionRoachTailStatus) -> some View {
        Toggle(
            isOn: Binding(
                get: { model.runtime?.roachTail?.enabled ?? false },
                set: { nextValue in
                    Task {
                        await model.affectRoachTail(nextValue ? "enable" : "disable")
                    }
                }
            )
        ) {
            VStack(alignment: .leading, spacing: 2) {
                Text("RoachTail")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RoachTheme.text)
                Text(roachTail.enabled ? "Private overlay is armed." : "Private overlay is off.")
                    .font(.caption)
                    .foregroundStyle(RoachTheme.subduedText)
            }
        }
        .toggleStyle(.switch)
        .tint(RoachTheme.secondary)
        .disabled(model.isActingRoachTail)
    }
}

enum RoachPhoneGPSAdvertiserState: Equatable {
    case idle
    case requestingLocation
    case waitingForBluetooth
    case advertising
    case streaming(Int)
    case bluetoothOff
    case bluetoothDenied
    case bluetoothUnsupported
    case locationDenied
    case failed(String)

    var label: String {
        switch self {
        case .idle:
            return "Off"
        case .requestingLocation:
            return "Location"
        case .waitingForBluetooth:
            return "Bluetooth"
        case .advertising:
            return "Advertising"
        case let .streaming(count):
            return count == 1 ? "1 Mac" : "\(count) Macs"
        case .bluetoothOff:
            return "BT off"
        case .bluetoothDenied:
            return "BT blocked"
        case .bluetoothUnsupported:
            return "No BLE"
        case .locationDenied:
            return "Location off"
        case .failed:
            return "Retry"
        }
    }

    var detail: String {
        switch self {
        case .idle:
            return "Ready to advertise a RoachAtlas GPS packet when you start it."
        case .requestingLocation:
            return "Waiting for foreground location permission."
        case .waitingForBluetooth:
            return "Waiting for Bluetooth to become available."
        case .advertising:
            return "RoachPhone GPS is visible to the desktop RoachAtlas receiver."
        case let .streaming(count):
            return count == 1 ? "One desktop receiver subscribed." : "\(count) desktop receivers subscribed."
        case .bluetoothOff:
            return "Turn on Bluetooth to advertise the GPS bridge."
        case .bluetoothDenied:
            return "Allow Bluetooth access for RoachNetiOS."
        case .bluetoothUnsupported:
            return "This device cannot act as the RoachAtlas BLE GPS source."
        case .locationDenied:
            return "Allow Location access while using RoachNetiOS."
        case let .failed(message):
            return message
        }
    }

    var accent: Color {
        switch self {
        case .advertising, .streaming:
            return RoachTheme.secondary
        case .requestingLocation, .waitingForBluetooth:
            return RoachTheme.tertiary
        case .idle:
            return RoachTheme.primary
        default:
            return RoachTheme.primary
        }
    }
}

struct RoachPhoneGPSFix: Equatable {
    let latitude: Double
    let longitude: Double
    let accuracyMeters: Double?
    let speedMetersPerSecond: Double?
    let courseDegrees: Double?
    let altitudeMeters: Double?
    let timestamp: Date

    var coordinateLabel: String {
        String(format: "%.5f, %.5f", latitude, longitude)
    }

    var accuracyLabel: String {
        guard let accuracyMeters else { return "unknown" }
        return accuracyMeters >= 1_609.344
            ? String(format: "%.1f mi", accuracyMeters / 1_609.344)
            : String(format: "%.0f m", accuracyMeters)
    }

    var speedLabel: String {
        guard let speedMetersPerSecond, speedMetersPerSecond >= 0 else { return "idle" }
        return String(format: "%.0f mph", speedMetersPerSecond * 2.2369362921)
    }

    var headingLabel: String {
        guard let courseDegrees, courseDegrees >= 0 else { return "no heading" }
        return "\(Int(courseDegrees.rounded())) deg"
    }

    var ageLabel: String {
        formattedRelativeDate(timestamp)
    }
}

final class RoachPhoneGPSAdvertiser: NSObject, ObservableObject {
    static let gpsServiceUUIDString = "E4B29778-2F25-4C70-9B4A-0F9D1D481105"
    static let gpsCharacteristicUUIDString = "E4B29779-2F25-4C70-9B4A-0F9D1D481105"
    private static let gpsServiceUUID = CBUUID(string: gpsServiceUUIDString)
    private static let gpsCharacteristicUUID = CBUUID(string: gpsCharacteristicUUIDString)

    @Published var highAccuracy = true {
        didSet { applyLocationConfiguration() }
    }
    @Published var includeMotionDetails = true {
        didSet {
            if let lastLocation {
                publish(location: lastLocation)
            }
        }
    }
    @Published private(set) var state: RoachPhoneGPSAdvertiserState = .idle
    @Published private(set) var latestFix: RoachPhoneGPSFix?
    @Published private(set) var lastPacket: String?
    @Published private(set) var packetCount = 0

    private let locationManager = CLLocationManager()
    private var peripheralManager: CBPeripheralManager?
    private var gpsCharacteristic: CBMutableCharacteristic?
    private var pendingNotifyData: Data?
    private var subscribedCentralCount = 0
    private var lastLocation: CLLocation?
    private var wantsBridgeRunning = false

    var isRunning: Bool {
        switch state {
        case .requestingLocation, .waitingForBluetooth, .advertising, .streaming:
            return wantsBridgeRunning
        default:
            return false
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        applyLocationConfiguration()
    }

    func start() {
        wantsBridgeRunning = true
        state = .requestingLocation

        guard CLLocationManager.locationServicesEnabled() else {
            state = .locationDenied
            return
        }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationAndBluetooth()
        case .denied, .restricted:
            state = .locationDenied
        @unknown default:
            state = .failed("Unknown Location permission state.")
        }
    }

    func stop() {
        wantsBridgeRunning = false
        locationManager.stopUpdatingLocation()
        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
        gpsCharacteristic = nil
        pendingNotifyData = nil
        subscribedCentralCount = 0
        state = .idle
    }

    func publishDemoFix() {
        let index = Double(packetCount % 8)
        let location = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: 39.76862 + index * 0.00032,
                longitude: -86.15823 - index * 0.00029
            ),
            altitude: 218 + index,
            horizontalAccuracy: 8 + index,
            verticalAccuracy: 12,
            course: 244 + index * 3,
            speed: 10.4 + index,
            timestamp: Date()
        )
        publish(location: location)
    }

    private func startLocationAndBluetooth() {
        guard wantsBridgeRunning else { return }
        applyLocationConfiguration()
        locationManager.startUpdatingLocation()

        if peripheralManager == nil {
            state = .waitingForBluetooth
            peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
        } else {
            configurePeripheralIfPossible()
        }
    }

    private func applyLocationConfiguration() {
        locationManager.desiredAccuracy = highAccuracy ? kCLLocationAccuracyBest : kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = highAccuracy ? 5 : 25
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
    }

    private func configurePeripheralIfPossible() {
        guard wantsBridgeRunning, let peripheralManager else { return }

        switch peripheralManager.state {
        case .poweredOn:
            let characteristic = CBMutableCharacteristic(
                type: Self.gpsCharacteristicUUID,
                properties: [.read, .notify],
                value: nil,
                permissions: [.readable]
            )
            let service = CBMutableService(type: Self.gpsServiceUUID, primary: true)
            service.characteristics = [characteristic]
            gpsCharacteristic = characteristic
            peripheralManager.removeAllServices()
            peripheralManager.add(service)
            state = .waitingForBluetooth
        case .poweredOff:
            state = .bluetoothOff
        case .unauthorized:
            state = .bluetoothDenied
        case .unsupported:
            state = .bluetoothUnsupported
        case .resetting, .unknown:
            state = .waitingForBluetooth
        @unknown default:
            state = .failed("Unknown Bluetooth state.")
        }
    }

    private func startAdvertising() {
        guard wantsBridgeRunning, let peripheralManager else { return }

        peripheralManager.stopAdvertising()
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Self.gpsServiceUUID],
            CBAdvertisementDataLocalNameKey: "RoachPhone GPS",
        ])
    }

    private func publish(location: CLLocation) {
        lastLocation = location

        guard CLLocationCoordinate2DIsValid(location.coordinate) else {
            state = .failed("The current location fix is invalid.")
            return
        }

        let fix = RoachPhoneGPSFix(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracyMeters: location.horizontalAccuracy >= 0 ? location.horizontalAccuracy : nil,
            speedMetersPerSecond: includeMotionDetails && location.speed >= 0 ? location.speed : nil,
            courseDegrees: includeMotionDetails && location.course >= 0 ? normalizedCourse(location.course) : nil,
            altitudeMeters: includeMotionDetails && location.verticalAccuracy >= 0 ? location.altitude : nil,
            timestamp: location.timestamp
        )
        latestFix = fix

        guard let packet = makePacket(from: fix), let data = packet.data(using: .utf8) else {
            state = .failed("RoachAtlas could not encode the GPS packet.")
            return
        }

        guard packet.count <= 4_096 else {
            state = .failed("RoachAtlas GPS packet exceeded the desktop bridge limit.")
            return
        }

        lastPacket = packet
        packetCount += 1

        guard subscribedCentralCount > 0, let gpsCharacteristic else { return }
        let accepted = peripheralManager?.updateValue(data, for: gpsCharacteristic, onSubscribedCentrals: nil) ?? false
        if !accepted {
            pendingNotifyData = data
        }
    }

    private func makePacket(from fix: RoachPhoneGPSFix) -> String? {
        var payload: [String: Any] = [
            "lat": fix.latitude,
            "lon": fix.longitude,
            "timestamp": Self.isoTimestamp(fix.timestamp),
            "source": "RoachPhone",
        ]

        if let accuracyMeters = fix.accuracyMeters {
            payload["accuracy"] = accuracyMeters
        }
        if let speedMetersPerSecond = fix.speedMetersPerSecond {
            payload["speed"] = speedMetersPerSecond
        }
        if let courseDegrees = fix.courseDegrees {
            payload["course"] = courseDegrees
        }
        if let altitudeMeters = fix.altitudeMeters {
            payload["altitude"] = altitudeMeters
        }

        guard
            JSONSerialization.isValidJSONObject(payload),
            let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func updateStreamingState() {
        guard wantsBridgeRunning else { return }
        state = subscribedCentralCount > 0 ? .streaming(subscribedCentralCount) : .advertising
    }

    private func normalizedCourse(_ value: Double) -> Double {
        let remainder = value.truncatingRemainder(dividingBy: 360)
        return remainder < 0 ? remainder + 360 : remainder
    }

    private static func isoTimestamp(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

extension RoachPhoneGPSAdvertiser: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard wantsBridgeRunning else { return }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationAndBluetooth()
        case .notDetermined:
            state = .requestingLocation
        case .denied, .restricted:
            state = .locationDenied
        @unknown default:
            state = .failed("Unknown Location permission state.")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard wantsBridgeRunning, let location = locations.last else { return }
        publish(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard wantsBridgeRunning else { return }
        state = .failed(error.localizedDescription)
    }
}

extension RoachPhoneGPSAdvertiser: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        configurePeripheralIfPossible()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error {
            state = .failed(error.localizedDescription)
            return
        }
        startAdvertising()
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error {
            state = .failed(error.localizedDescription)
            return
        }
        updateStreamingState()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        guard characteristic.uuid == Self.gpsCharacteristicUUID else { return }
        subscribedCentralCount += 1
        updateStreamingState()

        if let lastPacket, let data = lastPacket.data(using: .utf8), let gpsCharacteristic {
            let accepted = peripheral.updateValue(data, for: gpsCharacteristic, onSubscribedCentrals: [central])
            if !accepted {
                pendingNotifyData = data
            }
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        guard characteristic.uuid == Self.gpsCharacteristicUUID else { return }
        subscribedCentralCount = max(0, subscribedCentralCount - 1)
        updateStreamingState()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard request.characteristic.uuid == Self.gpsCharacteristicUUID else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
            return
        }

        guard let data = lastPacket?.data(using: .utf8) else {
            request.value = Data()
            peripheral.respond(to: request, withResult: .success)
            return
        }

        guard request.offset <= data.count else {
            peripheral.respond(to: request, withResult: .invalidOffset)
            return
        }

        request.value = data.subdata(in: request.offset..<data.count)
        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        guard let pendingNotifyData, let gpsCharacteristic else { return }
        let accepted = peripheral.updateValue(pendingNotifyData, for: gpsCharacteristic, onSubscribedCentrals: nil)
        if accepted {
            self.pendingNotifyData = nil
        }
    }
}
