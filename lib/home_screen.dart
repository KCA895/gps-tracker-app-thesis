import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'services/notification_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  LatLng? currentLatLng;
  GoogleMapController? mapController;

  final DatabaseReference latestRef = FirebaseDatabase.instance.ref('gps_tracker/latest');
  final DatabaseReference historyRef = FirebaseDatabase.instance.ref('gps_tracker/history');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    listenToGpsUpdates();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showNotification(message);
    });
  }

  /// Mendengarkan perubahan data GPS dan menyimpannya jika berbeda
  void listenToGpsUpdates() {
    latestRef.onValue.listen((event) {
      final rawData = event.snapshot.value;

      if (rawData != null && rawData is Map) {
        final latStr = rawData['latitude']?.toString();
        final lngStr = rawData['longitude']?.toString();

        final lat = double.tryParse(latStr ?? '');
        final lng = double.tryParse(lngStr ?? '');

        if (lat != null && lng != null) {
          final newLatLng = LatLng(lat, lng);

          if (currentLatLng == null || currentLatLng != newLatLng) {
            setState(() {
              currentLatLng = newLatLng;
            });

            try {
              mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
            } catch (_) {}

            final currentTime = DateTime.now().millisecondsSinceEpoch;

            historyRef.child(currentTime.toString()).set({
              'latitude': lat,
              'longitude': lng,
              'timestamp': currentTime,
            });
          }
        } else {
          print('⚠️ Latitude atau Longitude tidak valid: $latStr / $lngStr');
        }
      } else {
        print('⚠️ Data tidak valid dari Firebase: $rawData');
      }
    });
  }

  void openInGoogleMaps() {
    if (currentLatLng == null) return;
    final url =
        'https://www.google.com/maps/search/?api=1&query=${currentLatLng!.latitude},${currentLatLng!.longitude}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kosong: tidak hapus data lagi
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    isDarkMode: themeProvider.isDarkMode,
                    onThemeChanged: (val) => themeProvider.toggleTheme(val),
                    isNotificationEnabled: true,
                    onNotificationToggle: (_) {}, // add logic if needed
                  ),
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          },
        ),
      ),
      body: currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLatLng!,
          zoom: 16,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('device'),
            position: currentLatLng!,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openInGoogleMaps,
        label: const Text('Lacak Lokasi'),
        icon: const Icon(Icons.navigation),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
