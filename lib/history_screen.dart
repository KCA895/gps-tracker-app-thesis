import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String formatTimestamp(dynamic raw) {
    try {
      final millis = raw is int ? raw : int.parse(raw.toString());
      final date = DateTime.fromMillisecondsSinceEpoch(millis);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    } catch (e) {
      return 'Invalid time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference historyRef =
    FirebaseDatabase.instance.ref().child('gps_tracker/history');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Lokasi'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: historyRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal mengambil data.'));
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final raw = snapshot.data!.snapshot.value;

          if (raw is! Map) {
            return const Center(child: Text('Data tidak valid.'));
          }

          final data = Map<String, dynamic>.from(raw);

          final entries = data.entries
              .where((e) => e.value is Map)
              .toList()
            ..sort((a, b) {
              final aTimestamp = int.tryParse(
                  Map<String, dynamic>.from(a.value)['timestamp'].toString()) ??
                  0;
              final bTimestamp = int.tryParse(
                  Map<String, dynamic>.from(b.value)['timestamp'].toString()) ??
                  0;
              return bTimestamp.compareTo(aTimestamp); // Newest first
            });

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final item = Map<String, dynamic>.from(entries[index].value);
              final lat = item['latitude'];
              final lng = item['longitude'];
              final timestamp = item['timestamp'];

              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('Lat: $lat, Lng: $lng'),
                subtitle: Text('Waktu: ${formatTimestamp(timestamp)}'),
              );
            },
          );
        },
      ),
    );
  }
}
