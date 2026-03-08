import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilofix/common/sajilofix_snackbar.dart';
import 'package:sajilofix/core/services/app_permissions.dart';
import 'package:sajilofix/features/report/domain/entities/geo_address.dart';
import 'package:sajilofix/features/report/presentation/pages/report_step4.dart';
import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';
import 'package:sajilofix/features/report/presentation/routes/report_route_names.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_app_bar.dart';
import 'package:sajilofix/features/report/presentation/widgets/navigation/report_progress_bar.dart';

class ReportStep3 extends ConsumerStatefulWidget {
  const ReportStep3({super.key});

  @override
  ConsumerState<ReportStep3> createState() => _ReportStep3State();
}

class _ReportStep3State extends ConsumerState<ReportStep3> {
  static const _defaultCenter = LatLng(27.7172, 85.3240);
  final MapController _mapController = MapController();
  Timer? _searchDebounce;

  LatLng _mapCenter = _defaultCenter;
  LatLng? _selectedLatLng;
  bool _loadingSearch = false;
  bool _loadingReverse = false;
  bool _loadingCurrent = false;
  List<GeoAddress> _searchResults = const [];

  late final TextEditingController _searchController;
  late final TextEditingController _addressController;
  late final TextEditingController _municipalityController;
  late final TextEditingController _districtController;
  late final TextEditingController _wardController;
  late final TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(reportFormDraftProvider);
    _searchController = TextEditingController();
    _addressController = TextEditingController(text: draft.locationTitle);
    _municipalityController = TextEditingController(
      text: draft.locationSubtitle,
    );
    _districtController = TextEditingController(text: draft.district);
    _wardController = TextEditingController(text: draft.ward);
    _landmarkController = TextEditingController(text: draft.landmark);

    if (draft.latitude != null && draft.longitude != null) {
      _selectedLatLng = LatLng(draft.latitude!, draft.longitude!);
      _mapCenter = _selectedLatLng!;
    }

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _addressController.dispose();
    _municipalityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (query.isEmpty) {
        if (mounted) {
          setState(() => _searchResults = const []);
        }
        return;
      }
      _searchLocations(query);
    });
  }

  Future<void> _searchLocations(String query) async {
    setState(() => _loadingSearch = true);
    try {
      final remote = ref.read(reportRemoteDatasourceProvider);
      final results = await remote.searchLocations(query: query, limit: 6);
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: e.toString(),
        isError: true,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _loadingSearch = false);
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _loadingReverse = true);
    try {
      final remote = ref.read(reportRemoteDatasourceProvider);
      final address = await remote.reverseGeocode(
        latitude: point.latitude,
        longitude: point.longitude,
      );
      if (!mounted) return;
      _applyGeoAddress(address);
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: e.toString(),
        isError: true,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _loadingReverse = false);
    }
  }

  void _applyGeoAddress(GeoAddress address) {
    _addressController.text = address.address;
    _municipalityController.text = address.municipality ?? '';
    _districtController.text = address.district ?? '';
    _wardController.text = address.ward ?? '';
    _landmarkController.text = address.landmark ?? '';
    _selectedLatLng = LatLng(address.latitude, address.longitude);
    _mapCenter = _selectedLatLng!;
    _mapController.move(_mapCenter, 16);
    setState(() {});
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _loadingCurrent = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        showMySnackBar(
          context: context,
          message: 'Location services are disabled.',
          isError: true,
          icon: Icons.info_outline,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        showMySnackBar(
          context: context,
          message: 'Location permission denied.',
          isError: true,
          icon: Icons.info_outline,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      _selectedLatLng = point;
      _mapCenter = point;
      _mapController.move(point, 16);
      await _reverseGeocode(point);
    } catch (e) {
      if (!mounted) return;
      showMySnackBar(
        context: context,
        message: e.toString(),
        isError: true,
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _loadingCurrent = false);
    }
  }

  Future<void> _openFullScreenMap() async {
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => ReportMapFullScreenPage(
          initialCenter: _mapCenter,
          selected: _selectedLatLng,
        ),
      ),
    );
    if (selected == null) return;
    _selectedLatLng = selected;
    _mapCenter = selected;
    _mapController.move(selected, 16);
    if (mounted) setState(() {});
    await _reverseGeocode(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ReportAppBar(title: 'Report Issue'),
      backgroundColor: const Color(0xFFF4F6FB),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const ReportProgressBar(currentStep: 3, totalSteps: 6),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Where is it?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                Text(
                  'Confirm the exact location of the issue',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _MapCard(
            controller: _mapController,
            center: _mapCenter,
            selected: _selectedLatLng,
            onTap: (point) {
              _selectedLatLng = point;
              _mapCenter = point;
              setState(() {});
              _reverseGeocode(point);
            },
            onExpand: _openFullScreenMap,
          ),

          const SizedBox(height: 16),

          _SearchInputCard(
            controller: _searchController,
            loading: _loadingSearch,
          ),

          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SearchResults(
              results: _searchResults,
              onSelect: (item) {
                _applyGeoAddress(item);
                setState(() {
                  _searchResults = const [];
                });
                _searchController.clear();
              },
            ),
          ],

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _loadingCurrent
                ? null
                : () async {
                    final ok = await AppPermissions.ensureLocationWhenInUse(
                      context,
                    );
                    if (!ok || !context.mounted) return;
                    await _useCurrentLocation();
                  },
            icon: const Icon(Icons.my_location),
            label: Text(
              _loadingCurrent ? 'Locating...' : 'Use Current Location',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          if (_loadingReverse)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Resolving address...'),
                ],
              ),
            ),

          const SizedBox(height: 16),

          _LocationInputCard(
            addressController: _addressController,
            municipalityController: _municipalityController,
            districtController: _districtController,
            wardController: _wardController,
            landmarkController: _landmarkController,
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final address = _addressController.text.trim();
                final municipality = _municipalityController.text.trim();
                final district = _districtController.text.trim();
                final ward = _wardController.text.trim();
                final landmark = _landmarkController.text.trim();

                if (address.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter an address to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (municipality.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter municipality to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (district.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter district to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (ward.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter ward to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                if (landmark.isEmpty) {
                  showMySnackBar(
                    context: context,
                    message: 'Please enter a landmark to continue.',
                    isError: true,
                    icon: Icons.info_outline,
                  );
                  return;
                }

                ref
                    .read(reportFormDraftProvider.notifier)
                    .setLocation(
                      title: address,
                      subtitle: municipality,
                      landmark: landmark,
                      district: district,
                      ward: ward,
                      latitude: _selectedLatLng?.latitude,
                      longitude: _selectedLatLng?.longitude,
                    );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: const RouteSettings(name: ReportRouteNames.step4),
                    builder: (context) => const ReportStep4(),
                  ),
                );
              },
              child: const Text("Continue"),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back"),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;

  const _SearchInputCard({required this.controller, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF5),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search a place or address...',
          hintStyle: const TextStyle(
            color: Color(0xFFB6BDCA),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9CA3AF),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(color: Color(0xFF3A45D0), width: 2.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(color: Color(0xFF2A38D7), width: 2.4),
          ),
          suffixIcon: loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _LocationInputCard extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController municipalityController;
  final TextEditingController districtController;
  final TextEditingController wardController;
  final TextEditingController landmarkController;

  const _LocationInputCard({
    required this.addressController,
    required this.municipalityController,
    required this.districtController,
    required this.wardController,
    required this.landmarkController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF0EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.edit_location_alt_rounded,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Address Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE6EAF2)),
          const SizedBox(height: 14),
          _IconInputField(
            controller: addressController,
            labelText: 'Address',
            hintText: 'Street, area, or nearby address',
            icon: Icons.home_outlined,
            iconColor: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _IconInputField(
                  controller: municipalityController,
                  labelText: 'Municipality',
                  hintText: 'City / VDC',
                  icon: Icons.location_city_outlined,
                  iconColor: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IconInputField(
                  controller: districtController,
                  labelText: 'District',
                  hintText: 'District',
                  icon: Icons.map_outlined,
                  iconColor: const Color(0xFF0891B2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _IconInputField(
                  controller: wardController,
                  labelText: 'Ward No.',
                  hintText: 'e.g. 12',
                  icon: Icons.numbers,
                  iconColor: const Color(0xFFF97316),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _IconInputField(
                  controller: landmarkController,
                  labelText: 'Landmark',
                  hintText: 'Nearby landmark',
                  icon: Icons.flag_outlined,
                  iconColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final Color iconColor;
  final TextInputType? keyboardType;

  const _IconInputField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.iconColor,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8F97A6),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFB6BDCA),
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, size: 22, color: iconColor),
            filled: true,
            fillColor: const Color(0xFFF3F5FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE4E7EF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE4E7EF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: iconColor.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  final MapController controller;
  final LatLng center;
  final LatLng? selected;
  final ValueChanged<LatLng> onTap;
  final VoidCallback onExpand;

  const _MapCard({
    required this.controller,
    required this.center,
    required this.selected,
    required this.onTap,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14,
                onTap: (tapPos, point) => onTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sajilofix.app',
                ),
                if (selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selected!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Material(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.open_in_full),
                  onPressed: onExpand,
                  tooltip: 'Open map',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportMapFullScreenPage extends StatefulWidget {
  final LatLng initialCenter;
  final LatLng? selected;

  const ReportMapFullScreenPage({
    super.key,
    required this.initialCenter,
    this.selected,
  });

  @override
  State<ReportMapFullScreenPage> createState() =>
      _ReportMapFullScreenPageState();
}

class _ReportMapFullScreenPageState extends State<ReportMapFullScreenPage> {
  final MapController _controller = MapController();
  LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 15,
              onTap: (tapPos, point) {
                setState(() => _selected = point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sajilofix.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.pop(context, _selected),
                child: const Text('Use this location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<GeoAddress> results;
  final ValueChanged<GeoAddress> onSelect;

  const _SearchResults({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = results[index];
          return ListTile(
            title: Text(item.address),
            subtitle: Text(
              [
                item.municipality,
                item.district,
                item.ward,
              ].where((e) => (e ?? '').trim().isNotEmpty).join(', '),
            ),
            onTap: () => onSelect(item),
          );
        },
      ),
    );
  }
}
