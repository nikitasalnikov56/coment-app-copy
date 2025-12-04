// lib/src/feature/catalog/presentation/pages/map_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:coment_app/src/core/utils/extensions/context_extension.dart';
import 'package:coment_app/src/feature/app/presentation/widgets/custom_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

@RoutePage()
class MapPage extends StatefulWidget {
  final String country;
  final String city;
  final String address;

  const MapPage({
    required this.country,
    required this.city,
    required this.address,
    super.key,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Future<LatLng> _companyPosition;

  @override
  void initState() {
    _companyPosition =
        _geocodeAddress(widget.country, widget.city, widget.address);
    super.initState();
  }

  Future<LatLng> _geocodeAddress(
      String country, String city, String address) async {
    final query = Uri.encodeComponent('$country, $city, $address');
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

    try {
      final response = await Dio().get(url,
          options: Options(
              headers: {'User-Agent': 'ComentApp/1.0 (contact@coment.app)'}));
      if (response.data is List && response.data.isNotEmpty) {
        final lat = double.parse(response.data[0]['lat']);
        final lon = double.parse(response.data[0]['lon']);
        return LatLng(lat, lon);
      }
    } catch (e) {
      // fallback
    }

    return _getFallbackForCountry(country);
  }

  LatLng _getFallbackForCountry(String country) {
  final lower = country.toLowerCase();

  // Узбекистан
  if (lower.contains('uzbekistan') || lower.contains('ўзбекистон') || lower.contains('узбекистан') ) {
    return const LatLng(41.2995, 69.2401); // Ташкент
  }

  // Казахстан
  if (lower.contains('kazakhstan') || lower.contains('қазақстан') || lower.contains('казахстан')) {
    return const LatLng(43.2389, 76.8897); // Алматы (или 51.1694, 71.4491 — Нур-Султан)
  }

  // Китай
  if (lower.contains('china') || lower.contains('китай') || lower.contains('қытай') || lower.contains('中国')) {
    return const LatLng(39.9042, 116.4074); // Пекин
  }

  // Россия
  if (lower.contains('russia') || lower.contains('россия') || lower.contains('рф')) {
    return const LatLng(55.7558, 37.6176); // Москва
  }

  // По умолчанию — центр Узбекистана (если проект ориентирован на регион)
  return const LatLng(41.2995, 69.2401);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: context.localized.routeToCompany),
      body: FutureBuilder<LatLng>(
        future: _companyPosition,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final center = snapshot.data!;
          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag
                    .all, // или InteractiveFlag.drag | InteractiveFlag.zoom
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.coment.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin,
                        color: Colors.red, size: 40),
                  ),
                ],
              ),
              
            ],
          );
        },
      ),
    );
  }
}
