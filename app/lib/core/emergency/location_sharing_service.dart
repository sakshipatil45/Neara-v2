import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';

class LocationSharingService {
  static Future<void> shareLocationWithContact(EmergencyContact contact) async {
    try {
      // 1. Get current location
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 2. Format Google Maps URL
      final mapsUrl =
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      // 3. Compose SMS message
      final message = 'EMERGENCY: My live location link: $mapsUrl';

      // 4. Launch SMS app
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: contact.phoneNumber,
        queryParameters: <String, String>{
          'body': message,
        },
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(
          smsUri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else {
        throw Exception('Could not launch SMS app');
      }
    } catch (e) {
      print('Error sharing location: $e');
      rethrow;
    }
  }
}
