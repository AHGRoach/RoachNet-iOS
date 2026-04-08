import SwiftUI

struct ConnectionSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var model: CompanionAppModel

    var body: some View {
        ZStack {
            RoachBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    RoachPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            RoachSectionHeader(
                                eyebrow: "Pairing",
                                title: "Link this phone to your Mac.",
                                detail: "Use the companion URL with a RoachTail join code, or paste the full companion token if you already have it."
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Companion URL")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(RoachTheme.subduedText)

                                TextField("http://RoachNet:38111", text: $model.connection.baseURL)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(RoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("RoachTail join code")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(RoachTheme.subduedText)

                                TextField("ROACH-ABCDE-12345", text: $model.connection.pairCode)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(RoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Companion token")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(RoachTheme.subduedText)

                                SecureField("Paste the RoachNet companion token", text: $model.connection.token)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding(12)
                                    .background(RoachTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }

                    RoachPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            RoachSectionHeader(
                                eyebrow: "What it opens",
                                title: "Chat, vault, runtime, and installs.",
                                detail: "The same token-gated bridge handles RoachClaw chat, RoachBrain reads, service controls, and Apps installs."
                            )

                            RoachBadge(
                                title: model.connection.isConfigured
                                    ? (model.usingRoachTailPeerToken ? "Paired over RoachTail" : "Configured")
                                    : "Needs setup",
                                accent: model.connection.isConfigured ? RoachTheme.secondary : RoachTheme.primary
                            )

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Desktop alias: http://RoachNet:38111")
                                Text("Phone lane: pair over RoachTail instead of targeting a raw IP.")
                                Text(
                                    model.usingRoachTailPeerToken
                                        ? "This iPhone is already using its own RoachTail peer token."
                                        : "Pair once with the join code to mint a private RoachTail bridge token for this device."
                                )
                            }
                            .font(.caption)
                            .foregroundStyle(RoachTheme.subduedText)
                        }
                    }

                    HStack(spacing: 12) {
                        Button("Pair with RoachTail") {
                            Task {
                                await model.pairWithRoachTail()
                                if model.connection.isConfigured {
                                    dismiss()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(RoachTheme.secondary)

                        Button("Save & Test") {
                            Task {
                                model.connection.save()
                                await model.refreshAll()
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(RoachTheme.primary)

                        Button("Refresh") {
                            Task {
                                await model.refreshAll()
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(RoachTheme.secondary)
                    }
                }
                .padding(18)
            }
        }
        .navigationTitle("Connection")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
