import SwiftUI

struct ChatView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Bindable var model: CompanionAppModel
    @FocusState private var composerFocused: Bool

    private var promptSuggestions: [String] {
        [
            "Summarize my runtime state.",
            "What model am I running right now?",
            "Show the latest RoachBrain highlights.",
            "What can you still do offline?",
            model.recentInstallItems.first.map { _ in "What did I just send from Apps?" } ?? "What should I install next from Apps?",
        ]
    }

    private var headerDetail: String {
        if let title = model.currentSession?.title, !title.isEmpty {
            return title
        }

        if model.runtime?.account?.linked == true {
            return "Your account keeps the hosted chat lane open, while the local bridge stays opt-in."
        }

        if model.pairedMachineName != nil {
            return "Paired to your desktop, with cached state kept close on the phone."
        }

        return "Chat, queue installs, and keep cached context even when the Mac is asleep or nowhere nearby."
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RoachBackdrop()

                VStack(spacing: 14) {
                    header
                    banner
                    content
                    composer
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: Binding(
                get: { model.historyPresented },
                set: { model.historyPresented = $0 }
            )) {
                SessionHistorySheet(model: model)
            }
        }
    }

    private var header: some View {
        RoachHeroPanel(accent: RoachTheme.primary) {
            VStack(alignment: .leading, spacing: 16) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            headerCopy
                            heroPills
                        }

                        Spacer(minLength: 12)

                        VStack(alignment: .trailing, spacing: 12) {
                            headerButtons
                            heroSignals
                        }
                        .frame(width: 280, alignment: .trailing)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        headerCopy
                        heroPills
                        heroSignals
                        headerButtons
                    }
                }

                quickActions
            }
        }
    }

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoachSectionHeader(
                eyebrow: "RoachClaw",
                title: model.connection.isConfigured ? "Your chat, not one device." : "Offline first. Pair when needed.",
                detail: headerDetail
            )

            if let lastRefreshAt = model.lastRefreshAt {
                Text("Last sync \(formattedRelativeDate(lastRefreshAt))")
                    .font(.caption)
                    .foregroundStyle(RoachTheme.subduedText)
            }
        }
    }

    private var headerButtons: some View {
        HStack(spacing: 10) {
            if model.connection.isConfigured {
                Button {
                    model.historyPresented = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
            }

            Button {
                model.settingsPresented = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
        }
        .tint(RoachTheme.secondary)
    }

    private var heroPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                RoachStatusPill(
                    title: model.connection.isConfigured ? "Paired device" : "Phone-only cache",
                    accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.runtime?.account?.linked == true ? "Account linked" : "Account local",
                    accent: model.runtime?.account?.linked == true ? RoachTheme.tertiary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.runtime?.roachTail?.enabled == true ? "RoachTail armed" : "RoachTail off",
                    accent: model.runtime?.roachTail?.enabled == true ? RoachTheme.secondary : RoachTheme.primary
                )
                RoachStatusPill(
                    title: model.queuedInstallCount > 0 ? "\(model.queuedInstallCount) queued" : "Queue clear",
                    accent: model.queuedInstallCount > 0 ? RoachTheme.primary : RoachTheme.tertiary
                )
            }
            .padding(.vertical, 1)
        }
    }

    private var heroSignals: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(minimum: 0), spacing: 10),
                GridItem(.flexible(minimum: 0), spacing: 10),
            ],
            alignment: .leading,
            spacing: 10
        ) {
            RoachSignalTile(
                label: "Mode",
                value: model.connection.isConfigured ? model.connection.securityLabel : "Offline ready",
                accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary,
                systemImage: "shield.lefthalf.filled"
            )

            RoachSignalTile(
                label: "Model",
                value: model.activeModelName ?? "RoachBrain cache",
                accent: RoachTheme.primary,
                systemImage: "brain.head.profile"
            )

            RoachSignalTile(
                label: "Threads",
                value: "\(max(model.sessionList.count, model.currentSession == nil ? 0 : 1))",
                accent: RoachTheme.tertiary,
                systemImage: "text.bubble"
            )

            RoachSignalTile(
                label: "Installs",
                value: model.queuedInstallCount > 0 ? "\(model.queuedInstallCount) queued" : "Ready",
                accent: model.queuedInstallCount > 0 ? RoachTheme.secondary : RoachTheme.tertiary,
                systemImage: "square.and.arrow.down"
            )
        }
    }

    @ViewBuilder
    private var quickActions: some View {
        if horizontalSizeClass == .compact {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 0), spacing: 10),
                    GridItem(.flexible(minimum: 0), spacing: 10),
                ],
                alignment: .leading,
                spacing: 10
            ) {
                quickActionItems
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    quickActionItems
                }
            }
        }
    }

    @ViewBuilder
    private var quickActionItems: some View {
        actionChip("New chat", systemImage: "square.and.pencil", accent: RoachTheme.primary) {
            Task { await model.newChat() }
        }

        if model.connection.isConfigured {
            actionChip("History", systemImage: "clock.arrow.circlepath", accent: RoachTheme.secondary) {
                model.historyPresented = true
            }
        } else {
            actionChip("Link Mac", systemImage: "link", accent: RoachTheme.secondary) {
                model.settingsPresented = true
            }
        }

        actionChip("Runtime", systemImage: "switch.2", accent: RoachTheme.tertiary) {
            model.selectedTab = .runtime
        }

        actionChip("Apps", systemImage: "square.grid.2x2.fill", accent: RoachTheme.primary) {
            model.selectedTab = .apps
        }

        actionChip("Vault", systemImage: "archivebox.fill", accent: RoachTheme.secondary) {
            model.selectedTab = .vault
        }
    }

    @ViewBuilder
    private var banner: some View {
        if let errorText = model.errorText {
            RoachPanel {
                Text(errorText)
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(RoachTheme.primary.opacity(0.45), lineWidth: 1)
            )
        } else if let bannerText = model.bannerText {
            RoachPanel {
                Text(bannerText)
                    .font(.subheadline)
                    .foregroundStyle(RoachTheme.text)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let currentSession = model.currentSession {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if currentSession.messages.isEmpty {
                            RoachPanel {
                                VStack(alignment: .leading, spacing: 14) {
                                    RoachSectionHeader(
                                        eyebrow: "Start here",
                                        title: "This session is ready.",
                                        detail: "Drop a message below or use one of the quick prompts."
                                    )

                                    suggestionGrid
                                }
                            }
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(currentSession.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    await model.refreshAll()
                }
                .onChange(of: currentSession.messages.count) { _, _ in
                    guard let lastID = currentSession.messages.last?.id else { return }
                    withAnimation(.easeOut(duration: 0.24)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        } else if !model.connection.isConfigured {
            EmptyStateView(
                title: "Link the Mac lane",
                detail: "Paste the companion URL and token from your desktop install. Chat, runtime control, vault access, and app installs light up right after.",
                actionTitle: "Link Mac"
            ) {
                model.settingsPresented = true
            }
        } else if model.isBootstrapping, model.currentSession == nil, model.sessionList.isEmpty {
            RoachPanel {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(RoachTheme.primary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Loading RoachClaw lane")
                            .font(.headline)
                            .foregroundStyle(RoachTheme.text)
                        Text("Pulling the paired desktop session state.")
                            .font(.subheadline)
                            .foregroundStyle(RoachTheme.subduedText)
                    }
                    Spacer()
                }
            }
        } else {
            VStack(spacing: 14) {
                EmptyStateView(
                    title: "Chat from the phone",
                    detail: "Keep RoachClaw close while the real runtime stays on the Mac.",
                    actionTitle: "New chat"
                ) {
                    Task { await model.newChat() }
                }

                RoachPanel {
                    VStack(alignment: .leading, spacing: 14) {
                        RoachSectionHeader(
                            eyebrow: "Prompt ideas",
                            title: "Start with something useful.",
                            detail: nil
                        )

                        suggestionGrid
                    }
                }
            }
        }
    }

    private var suggestionGrid: some View {
        LazyVGrid(
            columns: horizontalSizeClass == .compact
                ? [GridItem(.flexible(minimum: 0), spacing: 10)]
                : [
                    GridItem(.flexible(minimum: 0), spacing: 10),
                    GridItem(.flexible(minimum: 0), spacing: 10),
                ],
            alignment: .leading,
            spacing: 10
        ) {
            ForEach(promptSuggestions, id: \.self) { suggestion in
                Button {
                    model.draft = suggestion
                    composerFocused = true
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(RoachTheme.primary)
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundStyle(RoachTheme.text)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(RoachTheme.elevatedSurface.opacity(0.92))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(RoachTheme.border, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var composer: some View {
        RoachPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    RoachSectionHeader(
                        eyebrow: "Composer",
                        title: "Ask something useful.",
                        detail: model.connection.isConfigured
                            ? "The paired stack will answer first. Cached context is still here if the bridge drops."
                            : "This stays useful even without a live desktop bridge."
                    )

                    Spacer(minLength: 12)
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .bottom, spacing: 12) {
                        composerField
                        composerSendButton
                    }

                    VStack(spacing: 12) {
                        composerField
                        composerSendButton
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
        }
        .padding(.bottom, 4)
    }

    private var composerField: some View {
        TextField("Message RoachClaw or the offline cache", text: $model.draft, axis: .vertical)
            .focused($composerFocused)
            .textInputAutocapitalization(.sentences)
            .lineLimit(1...6)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(RoachTheme.elevatedSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(RoachTheme.border, lineWidth: 1)
                    )
            )
    }

    private var composerSendButton: some View {
        Button {
            Task {
                await model.sendDraft()
            }
        } label: {
            HStack(spacing: 10) {
                if model.isSending {
                    ProgressView()
                        .tint(Color.white)
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                }

                Text(model.isSending ? "Sending" : "Send")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [RoachTheme.primary, RoachTheme.secondary.opacity(0.76)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(model.isSending || model.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(model.isSending || model.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.62 : 1)
    }

    private func actionChip(_ title: String, systemImage: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            RoachActionPill(title: title, systemImage: systemImage, accent: accent)
        }
        .buttonStyle(.plain)
        .foregroundStyle(RoachTheme.text)
    }
}

private struct MessageBubble: View {
    let message: CompanionChatMessage

    private var isUser: Bool {
        message.role.lowercased() == "user"
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(isUser ? "You" : "RoachClaw")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(RoachTheme.subduedText)

                    if !isUser {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                            .foregroundStyle(RoachTheme.secondary)
                    }
                }

                Text(message.content)
                    .font(.body)
                    .foregroundStyle(RoachTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(formattedRelativeDate(message.createdAt))
                    .font(.caption2)
                    .foregroundStyle(RoachTheme.subduedText)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isUser ? RoachTheme.primary.opacity(0.28) : RoachTheme.surface.opacity(0.98))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder((isUser ? RoachTheme.primary : RoachTheme.border).opacity(0.55), lineWidth: 1)
                    )
            )
            .frame(maxWidth: 320, alignment: .leading)

            if !isUser { Spacer(minLength: 40) }
        }
    }
}

private struct SessionHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var model: CompanionAppModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        dismiss()
                        Task { await model.newChat() }
                    } label: {
                        Label("Start new chat", systemImage: "square.and.pencil")
                    }
                }

                Section("History") {
                    ForEach(model.sessionList) { session in
                        Button {
                            dismiss()
                            Task {
                                try? await model.loadSession(session.id)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(session.id == model.currentSession?.id ? RoachTheme.primary : RoachTheme.border)
                                    .frame(width: 10, height: 10)
                                    .padding(.top, 6)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .foregroundStyle(RoachTheme.text)

                                    Text(session.model ?? "Default model")
                                        .font(.caption)
                                        .foregroundStyle(RoachTheme.subduedText)

                                    if let timestamp = session.timestamp {
                                        Text(formattedRelativeDate(timestamp))
                                            .font(.caption2)
                                            .foregroundStyle(RoachTheme.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(RoachBackdrop())
            .navigationTitle("Chats")
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
