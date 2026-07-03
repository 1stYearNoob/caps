import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/translation_service.dart';
import '../../theme/colors/light_colors.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Position? _currentPosition;
  LatLng? _riceFieldLatLng;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeLocationData();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _initializeLocationData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. Get current GPS position
      try {
        final position = await _determinePosition();
        _currentPosition = position;
      } catch (e) {
        debugPrint('Geolocator error: $e');
        // Do not block initialization completely if GPS fails,
        // since the user might still want to see their saved rice field location.
      }

      // 2. Fetch saved rice field location from Firestore
      final userId = AuthService().currentUserId;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (data.containsKey('riceFieldLatitude') && data.containsKey('riceFieldLongitude')) {
            final double? lat = (data['riceFieldLatitude'] as num?)?.toDouble();
            final double? lng = (data['riceFieldLongitude'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              _riceFieldLatLng = LatLng(lat, lng);
            }
          }
        }
      }

      if (_currentPosition == null && _riceFieldLatLng == null) {
        setState(() {
          _errorMessage = 'Could not determine location and no saved rice field location found. Please enable location services.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLocation() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final userId = AuthService().currentUserId;
      if (userId == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Please log in to save your location.'.tr)),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('Saving location...'.tr)),
      );

      final position = await Geolocator.getCurrentPosition();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_locations')
          .add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'riceFieldLatitude': _riceFieldLatLng?.latitude,
        'riceFieldLongitude': _riceFieldLatLng?.longitude,
      });

      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(content: Text('Location logged successfully in history!'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(content: Text('${'Failed to log location:'.tr} $e')),
        );
      }
    }
  }

  Future<void> _saveRiceFieldLocation() async {
    if (_riceFieldLatLng == null) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final userId = AuthService().currentUserId;
      if (userId == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('Please log in to save your rice field location.'.tr)),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(content: Text('Saving rice field location...'.tr)),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'riceFieldLatitude': _riceFieldLatLng!.latitude,
        'riceFieldLongitude': _riceFieldLatLng!.longitude,
        'riceFieldUpdatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Rice field location saved successfully! 🌾'.tr),
            backgroundColor: LightColors.kGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(content: Text('${'Failed to save rice field location:'.tr} $e')),
        );
      }
    }
  }

  void _handleMapTap(LatLng point) {
    setState(() {
      _riceFieldLatLng = point;
      _hasUnsavedChanges = true;
    });
  }

  LatLng get _initialMapCenter {
    if (_riceFieldLatLng != null) {
      return _riceFieldLatLng!;
    }
    if (_currentPosition != null) {
      return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    }
    return const LatLng(14.5995, 120.9842); // Default fallback: Manila, PH
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Location'.tr,
          style: const TextStyle(
            color: LightColors.kDarkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LightColors.kDarkBlue),
            )
          : _errorMessage != null && _currentPosition == null && _riceFieldLatLng == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 60, color: LightColors.kRed),
                        const SizedBox(height: 15),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: LightColors.kDarkBlue, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _initializeLocationData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColors.kDarkBlue,
                          ),
                          child: Text('Retry'.tr, style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialMapCenter,
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) => _handleMapTap(point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.my_capstone_application_',
                        ),
                        MarkerLayer(
                          markers: [
                            if (_currentPosition != null)
                              Marker(
                                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      color: LightColors.kRed,
                                      size: 50,
                                    ),
                                    Positioned(
                                      top: 8,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_riceFieldLatLng != null)
                              Marker(
                                point: _riceFieldLatLng!,
                                width: 80,
                                height: 80,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      color: LightColors.kGreen,
                                      size: 55,
                                    ),
                                    Positioned(
                                      top: 8,
                                      child: Icon(
                                        Icons.grass,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Floating instructions / coordinates card at the top
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: LightColors.kGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Rice Field Location Marker'.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: LightColors.kDarkBlue,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _riceFieldLatLng == null
                                        ? 'Tap anywhere on the map to mark your rice field.'.tr
                                        : '${'Marked at:'.tr} ${_riceFieldLatLng!.latitude.toStringAsFixed(5)}, ${_riceFieldLatLng!.longitude.toStringAsFixed(5)}',
                                    style: TextStyle(
                                      color: LightColors.kDarkBlue.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_riceFieldLatLng != null)
                              IconButton(
                                icon: const Icon(Icons.clear, color: LightColors.kRed),
                                onPressed: () {
                                  setState(() {
                                    _riceFieldLatLng = null;
                                    _hasUnsavedChanges = true;
                                  });
                                },
                                tooltip: 'Remove marker',
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Center buttons on the map (above the bottom controls)
                    Positioned(
                      bottom: 180,
                      right: 16,
                      child: Column(
                        children: [
                          if (_currentPosition != null)
                            FloatingActionButton(
                              mini: true,
                              heroTag: 'center_me_btn',
                              backgroundColor: Colors.white,
                              onPressed: () {
                                _mapController.move(
                                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                  15.0,
                                );
                              },
                              child: const Icon(Icons.my_location, color: LightColors.kDarkBlue),
                            ),
                          const SizedBox(height: 8),
                          if (_riceFieldLatLng != null)
                            FloatingActionButton(
                              mini: true,
                              heroTag: 'center_rice_field_btn',
                              backgroundColor: Colors.white,
                              onPressed: () {
                                _mapController.move(_riceFieldLatLng!, 16.0);
                              },
                              child: const Icon(Icons.grass, color: LightColors.kGreen),
                            ),
                        ],
                      ),
                    ),

                    // Modern bottom control dashboard
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LightColors.kDarkBlue,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      try {
                                        final position = await Geolocator.getCurrentPosition();
                                        final url = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
                                        if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
                                          messenger.showSnackBar(
                                            SnackBar(content: Text('Could not launch Google Maps'.tr)),
                                          );
                                        }
                                      } catch (e) {
                                        messenger.showSnackBar(
                                          SnackBar(content: Text('${'Error getting location:'.tr} $e')),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.map, size: 18),
                                    label: Text(
                                      'Open in Google Maps'.tr,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _saveLocation,
                                    icon: const Icon(Icons.history, size: 18),
                                    label: Text(
                                      'Log Position'.tr,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasUnsavedChanges
                                      ? LightColors.kGreen
                                      : LightColors.kGreen.withOpacity(0.6),
                                  foregroundColor: Colors.white,
                                  elevation: _hasUnsavedChanges ? 3 : 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: _hasUnsavedChanges
                                        ? const BorderSide(color: Colors.white24, width: 1.5)
                                        : BorderSide.none,
                                  ),
                                ),
                                onPressed: _riceFieldLatLng == null ? null : _saveRiceFieldLocation,
                                icon: const Icon(Icons.save, size: 20),
                                label: Text(
                                  _hasUnsavedChanges
                                      ? 'Save Rice Field Location *'.tr
                                      : 'Rice Field Saved'.tr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
