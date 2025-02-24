import SwiftUI
import WebKit
import UniformTypeIdentifiers

struct WriterView: View {
    @ObservedObject var draft: DraftModel
    @ObservedObject var viewModel: WriterViewModel
    @FocusState var focusTitle: Bool
    let dragAndDrop: WriterDragAndDrop

    init(draft: DraftModel, viewModel: WriterViewModel) {
        self.draft = draft
        self.viewModel = viewModel
        dragAndDrop = WriterDragAndDrop(draft: draft)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let videoAttachment = draft.attachments.first(where: {$0.type == .video}) {
                WriterVideoView(videoAttachment: videoAttachment)
            }
            if let audioAttachment = draft.attachments.first(where: {$0.type == .audio}) {
                WriterAudioView(audioAttachment: audioAttachment)
            }

            TextField("Title", text: $draft.title)
                .frame(height: 34, alignment: .leading)
                .padding(.bottom, 2)
                .padding(.horizontal, 16)
                .font(.system(size: 15, weight: .regular, design: .default))
                .background(Color(NSColor.textBackgroundColor))
                .textFieldStyle(PlainTextFieldStyle())
                .focused($focusTitle)

            Divider()


            GeometryReader { geometry in
                HSplitView {
                    WriterTextView(draft: draft, text: $draft.content)
                        .frame(minWidth: geometry.size.width / 2, minHeight: 300)
                    WriterPreview(draft: draft)
                        .frame(minWidth: geometry.size.width / 2, minHeight: 300)
                }.frame(minWidth: 640, minHeight: 300)
            }
            

            if viewModel.isMediaTrayOpen {
                Divider()
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(
                            draft.attachments.filter { $0.type == .image || $0.type == .audio || $0.type == .file },
                            id: \.name
                        ) { attachment in
                            AttachmentThumbnailView(attachment: attachment)
                        }
                    }
                }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.03))
            }
        }
        .frame(minWidth: 640, minHeight: 440)
            .alert(
                "This article has no title. Please enter the title before clicking send.",
                isPresented: $viewModel.isShowingEmptyTitleAlert
            ) {
                Button("OK", role: .cancel) { }
            }
            .onChange(of: draft.title) { _ in
                try? draft.save()
            }
            .onChange(of: draft.content) { _ in
                try? draft.save()
                try? draft.renderPreview()
                NotificationCenter.default.post(
                    name: .writerNotification(.loadPreview, for: draft),
                    object: nil
                )
            }
            .onChange(of: draft.attachments) { _ in
                if draft.attachments.contains(where: { $0.type == .image || $0.type == .file }) {
                    viewModel.isMediaTrayOpen = true
                }
                try? draft.renderPreview()
            }
            .onAppear {
                if draft.attachments.contains(where: { $0.type == .image || $0.type == .file }) {
                    viewModel.isMediaTrayOpen = true
                }
                Task { @MainActor in
                    // workaround: wrap in a task to delay focusing the title a little
                    focusTitle = true
                }
            }
            .fileImporter(
                isPresented: $viewModel.isChoosingAttachment,
                allowedContentTypes: viewModel.allowedContentTypes,
                allowsMultipleSelection: viewModel.allowMultipleSelection
            ) { result in
                if let urls = try? result.get() {
                    if viewModel.attachmentType == .image {
                        viewModel.isMediaTrayOpen = true
                    }
                    urls.forEach { url in
                        _ = try? draft.addAttachment(path: url, type: viewModel.attachmentType)
                    }
                    try? draft.renderPreview()
                    try? draft.save()
                }
            }
            // .confirmationDialog(
            //     Text("Do you want to save your changes as a draft?"),
            //     isPresented: $viewModel.isShowingClosingWindowConfirmation
            // ) {
            //     Button {
            //         try? draft.save()
            //     } label: {
            //         Text("Save Draft")
            //     }
            //     Button(role: .destructive) {
            //         try? draft.delete()
            //     } label: {
            //         Text("Discard Changes")
            //     }
            // }
            .onDrop(of: [.fileURL], delegate: dragAndDrop)
    }
}
