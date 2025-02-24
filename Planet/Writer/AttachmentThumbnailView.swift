import SwiftUI

struct AttachmentThumbnailView: View {
    @ObservedObject var attachment: Attachment

    @State private var isShowingControl = false

    var body: some View {
        ZStack {
            if let thumbnail = attachment.thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 4)
                    .frame(width: 64, height: 64, alignment: .center)
            }

            if attachment.type == .image || attachment.type == .file {
                VStack {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18, alignment: .center)
                            .opacity(isShowingControl ? 1.0 : 0.0)
                    }
                }
                .padding(4)
                .onTapGesture {
                    insertAttachment()
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12, alignment: .center)
                        .opacity(isShowingControl ? 1.0 : 0.0)
                        .onTapGesture {
                            deleteAttachment()
                        }
                }
                Spacer()
            }
            .padding(.leading, 0)
            .padding(.top, 2)
            .padding(.trailing, -10)
        }
        .frame(width: 60, height: 60, alignment: .center)
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .onHover { isHovering in
            withAnimation {
                isShowingControl = isHovering
            }
        }
    }

    func insertAttachment() {
        if let markdown = attachment.markdown {
            NotificationCenter.default.post(
                name: .writerNotification(.insertText, for: attachment.draft),
                object: markdown
            )
        }
    }

    func deleteAttachment() {
        try? attachment.draft.deleteAttachment(name: attachment.name)
        if let markdown = attachment.markdown {
            NotificationCenter.default.post(
                name: .writerNotification(.removeText, for: attachment.draft),
                object: markdown
            )
        }
    }
}
