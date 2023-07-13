import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../helpers/constants.dart';

class BannerAd extends StatelessWidget {
  const BannerAd({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: FutureBuilder(
              future: UnityAds.isInitialized(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == true) {
                    return UnityBannerAd(
                      placementId: BANNER_AD_PLACEMENT_ID,
                      onLoad: (placementId) =>
                          print('Banner loaded: $placementId'),
                      onClick: (placementId) =>
                          print('Banner clicked: $placementId'),
                      onFailed: (placementId, error, message) => print(
                          'Banner Ad $placementId failed: $error $message'),
                    );
                  }
                }
                return Container();
              })),
    );
  }
}
