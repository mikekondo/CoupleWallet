import GoogleMobileAds
import SwiftUI

struct AddMobBannerContentView: View {
    var body: some View {
        AdMobBannerView()
            .frame(maxWidth: .infinity)
            .frame(height: 70)
    }
}

private struct AdMobBannerView: UIViewRepresentable {
    private let adUnitID = Bundle.main.object(forInfoDictionaryKey: "ADMOBBannerUNITID") as? String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView()
        banner.adUnitID = adUnitID
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
