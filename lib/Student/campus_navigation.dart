import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CampusNavigation extends StatefulWidget {
  const CampusNavigation({super.key});

  @override
  State<CampusNavigation> createState() => _CampusNavigationState();
}

class _CampusNavigationState extends State<CampusNavigation> {
  static const Color _primaryBlue = Color.fromARGB(255, 40, 80, 227);
  static const Color _deepBlue = Color.fromARGB(255, 22, 53, 165);
  static const Color _accentSky = Color.fromARGB(255, 97, 187, 255);
  static const Color _surfaceTint = Color.fromARGB(255, 246, 248, 255);

  static const LatLng _collegeCenter = LatLng(
    17.701986622937138,
    74.5399990234726,
  );

  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  final List<_CampusSpot> _spots = const [
    _CampusSpot(
      id: 'canteen',
      title: 'Canteen',
      snippet: 'Student Food Court',
      position: LatLng(18.52095, 73.85715),
      markerHue: BitmapDescriptor.hueOrange,
    ),
    _CampusSpot(
      id: 'library',
      title: 'Library',
      snippet: 'Central Library Block',
      position: LatLng(18.52005, 73.85645),
      markerHue: BitmapDescriptor.hueAzure,
    ),
    _CampusSpot(
      id: 'principal_cabin',
      title: 'Principal Cabin',
      snippet: 'Admin Building - Floor 1',
      position: LatLng(18.51985, 73.85695),
      markerHue: BitmapDescriptor.hueViolet,
    ),
    _CampusSpot(
      id: 'building_1',
      title: 'Building 1',
      snippet: 'First Year Classrooms',
      position: LatLng(17.702251293907604, 74.53930617353762),
      markerHue: BitmapDescriptor.hueGreen,
    ),
    _CampusSpot(
      id: 'building_2',
      title: 'Building 2',
      snippet: 'Labs and Workshops',
      position: LatLng(17.703202048085455, 74.53963126662991),
      markerHue: BitmapDescriptor.hueGreen,
    ),
    _CampusSpot(
      id: 'building_3',
      title: 'Building 3',
      snippet: 'Seminar Hall Wing',
      position: LatLng(18.51955, 73.85620),
      markerHue: BitmapDescriptor.hueGreen,
    ),
  ];

  Set<Marker> _markers = <Marker>{};
  Set<Polyline> _polylines = <Polyline>{};
  List<_CampusSpot> _searchResults = <_CampusSpot>[];

  LatLng? _userLocation;
  _CampusSpot? _selectedSpot;
  bool _isFetchingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    _searchController.addListener(() {
      _filterSpots(_searchController.text);
    });
    _requestLocationAndFetchUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _setupMarkers() {
    final Set<Marker> campusMarkers = {
      Marker(
        markerId: const MarkerId('college_center'),
        position: _collegeCenter,
        infoWindow: const InfoWindow(
          title: 'My College Campus',
          snippet: 'Permanent Campus Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    for (final spot in _spots) {
      campusMarkers.add(
        Marker(
          markerId: MarkerId(spot.id),
          position: spot.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(spot.markerHue),
          infoWindow: InfoWindow(title: spot.title, snippet: spot.snippet),
          onTap: () => _onSpotSelected(spot),
        ),
      );
    }

    setState(() {
      _markers = campusMarkers;
    });
  }

  Future<void> _requestLocationAndFetchUser() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isFetchingLocation = false;
        _locationError = 'Please enable location services to get directions.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _isFetchingLocation = false;
        _locationError = 'Location permission is required for routing.';
      });
      return;
    }

    try {
      final Position current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng livePosition = LatLng(current.latitude, current.longitude);

      if (!mounted) return;
      setState(() {
        _userLocation = livePosition;
        _isFetchingLocation = false;
      });

      if (_selectedSpot != null) {
        _buildRouteToSpot(_selectedSpot!);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isFetchingLocation = false;
        _locationError = 'Unable to fetch current location right now.';
      });
    }
  }

  void _filterSpots(String query) {
    final String normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      setState(() {
        _searchResults = <_CampusSpot>[];
      });
      return;
    }

    setState(() {
      _searchResults = _spots
          .where((spot) => spot.title.toLowerCase().contains(normalized))
          .toList();
    });
  }

  void _onSpotSelected(_CampusSpot spot) {
    _searchController.text = spot.title;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );

    setState(() {
      _selectedSpot = spot;
      _searchResults = <_CampusSpot>[];
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: spot.position,
          zoom: 18.2,
          tilt: 65,
          bearing: 20,
        ),
      ),
    );

    _buildRouteToSpot(spot);
  }

  void _buildRouteToSpot(_CampusSpot spot) {
    if (_userLocation == null) {
      setState(() {
        _polylines = <Polyline>{};
      });
      return;
    }

    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('route_to_${spot.id}'),
          points: [_userLocation!, spot.position],
          color: _deepBlue,
          width: 5,
          geodesic: true,
        ),
      };
    });
  }

  void _focusOnUser() {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location is not available yet.')),
      );
      return;
    }

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation!, zoom: 18, tilt: 60),
      ),
    );
  }

  String _distanceLabel() {
    if (_selectedSpot == null || _userLocation == null) {
      return 'Enable location to get route distance';
    }
    final double meters = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      _selectedSpot!.position.latitude,
      _selectedSpot!.position.longitude,
    );
    return 'Distance: ${(meters / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_surfaceTint, Color.fromARGB(255, 232, 240, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.94),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(24, 26, 43, 128),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: _deepBlue,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Campus Navigation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _deepBlue,
                        ),
                      ),
                    ),
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryBlue, _accentSky],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.map_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(24, 26, 43, 128),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search canteen, library, building...',
                          filled: true,
                          fillColor: const Color.fromARGB(255, 245, 248, 255),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: _deepBlue,
                          ),
                          suffixIcon: IconButton(
                            onPressed: _requestLocationAndFetchUser,
                            icon: _isFetchingLocation
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location_rounded,
                                    color: _deepBlue,
                                  ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (_searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 165),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 250, 251, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            itemCount: _searchResults.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final _CampusSpot spot = _searchResults[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.place,
                                  color: _primaryBlue,
                                ),
                                title: Text(spot.title),
                                subtitle: Text(spot.snippet),
                                onTap: () => _onSpotSelected(spot),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_locationError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color.fromARGB(255, 255, 237, 237),
                    ),
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        GoogleMap(
                          mapType: MapType.hybrid,
                          initialCameraPosition: const CameraPosition(
                            target: _collegeCenter,
                            zoom: 17.8,
                            tilt: 65,
                            bearing: 20,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          markers: _markers,
                          polylines: _polylines,
                          myLocationEnabled: _userLocation != null,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: true,
                          buildingsEnabled: true,
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: FloatingActionButton.small(
                            heroTag: 'focus_user',
                            backgroundColor: Colors.white,
                            onPressed: _focusOnUser,
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: _deepBlue,
                            ),
                          ),
                        ),
                        if (_selectedSpot != null)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedSpot!.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _deepBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_selectedSpot!.snippet),
                                  const SizedBox(height: 8),
                                  Text(
                                    _distanceLabel(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampusSpot {
  const _CampusSpot({
    required this.id,
    required this.title,
    required this.snippet,
    required this.position,
    required this.markerHue,
  });

  final String id;
  final String title;
  final String snippet;
  final LatLng position;
  final double markerHue;
}
