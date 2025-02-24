//
//  WalletConnectV1QRCodeView.swift
//  Planet
//
//  Created by Xin Liu on 11/8/22.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct WalletConnectV1QRCodeView: View {
    @Environment(\.dismiss) var dismiss

    var payload: String

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack(spacing: 0) {
            Text("Please scan the QR code with your wallet app")
                .font(.body)
                .fontWeight(.semibold)
                .padding(10)

            Divider()

            if let qrCode: NSImage = generateQRCode(from: payload) {
                Image(nsImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(10)
            } else {
                ProgressView()
                    .padding(10)
            }

            Divider()

            HStack(spacing: 8) {
                HelpLinkButton(helpLink: URL(string: "https://planetable.xyz/guides/siwe/")!)

                Button {
                    let pboard = NSPasteboard.general
                    pboard.clearContents()
                    pboard.setString(payload, forType: .string)
                } label: {
                    Text("Copy URL")
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(width: 50)
                }
                .keyboardShortcut(.escape, modifiers: [])
            }.padding(10)
        }
        .padding(0)
        .frame(width: 320, height: 400, alignment: .top)
    }

    func generateQRCode(from string: String) -> NSImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return NSImage(cgImage: cgimg, size: .zero)
            }
        }

        return NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "Unavailable")!
    }
}

struct WalletConnectV1QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectV1QRCodeView(payload: "https://walletconnect.org/")
    }
}
