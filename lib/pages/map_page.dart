import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_navigator/constants/api_constants.dart';
import 'package:osm_navigator/models/favorites.dart';
import 'package:osm_navigator/controllers/map_controller.dart';
import 'package:osm_navigator/pages/save_locations_page.dart';
import 'package:osm_navigator/provider/map_providers.dart';
import 'package:provider/provider.dart';

import '../models/saved.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<TextEditingController> controllers = [TextEditingController()];
  final sheetController = DraggableScrollableController();
  final mapController = MapControllerHelper();
  bool isLiked = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Wiget build');
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(),
      body: Stack(
        children: [
          _buildMap(),
          Consumer<RouteProvider>(
            builder: (context, route, child) {
              return route.carRoute != null
                  ? Positioned(
                      top: 100,
                      right: 50,
                      left: 50,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          spacing: 1,
                          children: [
                            _showRoutesBar(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    '${route.carDistance?.toStringAsFixed(1)} Km'),
                                Text(
                                    '${route.bikeDistance?.toStringAsFixed(1)} Km'),
                                Text(
                                    '${route.walkDistance?.toStringAsFixed(1)} Km'),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Container();
            },
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 1,
                    blurRadius: 5,
                  )
                ],
              ),
              child: TextField(
                controller: controllers[0],
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: IconButton(
                    icon: Icon(Icons.refresh_rounded),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: () =>
                        mapController.addCurrentLocationMarker(true, context),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  // Add search logic
                },
                onSubmitted: (value) =>
                    mapController.addSearchMarker(value, context),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: 10,
            child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                spacing: 5,
                children: [
                  IconButton(
                      onPressed: mapController.zoomIn,
                      icon: Icon(
                        Icons.add,
                        size: 45,
                      )),
                  IconButton(
                      onPressed: mapController.zoomOut,
                      icon: Icon(
                        Icons.remove,
                        size: 45,
                      )),
                ],
              ),
            ),
          ),
          _buildBottomSheet()
        ],
      ),
    );
  }

  Widget _showRoutesBar() {
    return Consumer<SelectedRouteProvider>(
        builder: (context, selectedRoute, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => selectedRoute.updateSelectedRoute('car'),
            icon: Icon(Icons.directions_car),
            color:
                selectedRoute.vehicleType == 'car' ? Colors.black : Colors.grey,
          ),
          IconButton(
            onPressed: () => selectedRoute.updateSelectedRoute('bike'),
            icon: Icon(Icons.directions_bike),
            color: selectedRoute.vehicleType == 'bike'
                ? Colors.black
                : Colors.grey,
          ),
          IconButton(
            onPressed: () => selectedRoute.updateSelectedRoute('walk'),
            icon: Icon(Icons.directions_walk),
            color: selectedRoute.vehicleType == 'walk'
                ? Colors.black
                : Colors.grey,
          ),
        ],
      );
    });
  }

  FlutterMap _buildMap() {
    return FlutterMap(
      mapController: mapController.mapController,
      
      options: MapOptions(
        initialCenter: LatLng(31.5204, 74.3587),
        initialZoom: 8,
        initialRotation: BorderSide.strokeAlignInside,
        onTap: (tapPosition, point) =>
            mapController.handleMapTap(point, context),
      ),
      children: [
        TileLayer(
          urlTemplate: ApiConstants.mapBoxBaseUrl,
          additionalOptions: {
            'accessToken': ApiConstants.mapBoxAccessToken,
            'id': ApiConstants.mapBoxTileData,
          },
        ),
        MarkerLayer(
          markers: context.read<MarkerProvider>().marker,
        ),
        Consumer<RouteProvider>(
          builder: (context, routeProvider, child) {
            // Watch vehicleType changes
            final vehicleType =
                context.watch<SelectedRouteProvider>().vehicleType;

            List<LatLng> routePoints = [];
            switch (vehicleType) {
              case 'car':
                routePoints = routeProvider.carRoute ?? [];
                break;
              case 'bike':
                routePoints = routeProvider.bikeRoute ?? [];
                break;
              case 'walk':
                routePoints = routeProvider.walkRoute ?? [];
                break;
              default:
                routePoints = [];
            }

            return PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 4.0,
                  color: _getPolylineColor(
                      context.read<SelectedRouteProvider>().vehicleType),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      controller: sheetController,
      builder: (BuildContext context, scrollController) {
        return Container(
          padding: EdgeInsets.only(top: 2, right: 20, left: 20),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(45),
              topRight: Radius.circular(45),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0, left: 70, right: 70),
                child: Divider(
                  color: Colors.black,
                  height: 10,
                  thickness: 3,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Consumer<SelectedLocationsProvider>(
                                      builder: (context, value, child) {
                                        return Text(
                                          '${value.locationCity}',
                                          style: TextStyle(fontSize: 40),
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          tooltip: 'Share location',
                                          onPressed: () => mapController
                                              .shareLocation(context),
                                          icon: Icon(Icons.share_rounded)),
                                      IconButton(
                                          tooltip: 'Get directions',
                                          onPressed: () => mapController
                                              .handleDirectionsPress(context),
                                          icon: Icon(Icons.directions)),
                                    ],
                                  ),
                                ],
                              ),
                              Consumer<SelectedLocationsProvider>(
                                builder: (context, value, child) {
                                  return Text(
                                    '${value.locationData}',
                                    style: TextStyle(fontSize: 15),
                                  );
                                },
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final favorite = Favorites(
                                          latitude: context
                                              .read<SelectedLocationsProvider>()
                                              .lat!,
                                          longitude: context
                                              .read<SelectedLocationsProvider>()
                                              .lon!,
                                          title: context
                                                  .read<
                                                      SelectedLocationsProvider>()
                                                  .locationCity ??
                                              'No city name found',
                                          address: context
                                                  .read<
                                                      SelectedLocationsProvider>()
                                                  .locationData ??
                                              'No Address');
                                      favorites.add(favorite);
                                      setState(() {
                                        isLiked = !isLiked;
                                      });
                                    },
                                    icon: !isLiked
                                        ? Icon(Icons.favorite_border)
                                        : Icon(Icons.favorite_sharp),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        final save = Saved(
                                            latitude: double.parse(context
                                                .read<
                                                    SelectedLocationsProvider>()
                                                .lat!
                                                .toStringAsFixed(2)),
                                            longitude: double.parse(context
                                                .read<
                                                    SelectedLocationsProvider>()
                                                .lon!
                                                .toStringAsFixed(2)),
                                            title: context
                                                    .read<
                                                        SelectedLocationsProvider>()
                                                    .locationCity ??
                                                'No city name found',
                                            address: context
                                                    .read<
                                                        SelectedLocationsProvider>()
                                                    .locationData ??
                                                'No Address');
                                        saved.add(save);
                                        setState(() {
                                          isSaved = !isSaved;
                                        });
                                      },
                                      icon: !isSaved
                                          ? Icon(Icons.bookmark_add_outlined)
                                          : Icon(Icons.bookmark_add)),
                                ],
                              ),
                            ],
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
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<FloatingActionButtonMenuProvider>(
        builder: (context, value, child) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.isMenuOpen) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                      tooltip: 'Saved Locations',
                      foregroundColor: Colors.white,
                      mini: true,
                      backgroundColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SavedLocationPage()));
                      },
                      child: Icon(
                        Icons.save_as_outlined,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                      foregroundColor: Colors.white,
                      mini: true,
                      backgroundColor: Colors.black,
                      onPressed: () {},
                      child: Icon(
                        Icons.star,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton(
                      foregroundColor: Colors.white,
                      mini: true,
                      backgroundColor: Colors.black,
                      onPressed: () {},
                      child: Icon(
                        Icons.stay_current_portrait_rounded,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          FloatingActionButton(
            isExtended: value.isMenuOpen,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            enableFeedback: true,
            tooltip: 'Options',
            splashColor: const Color.fromARGB(255, 105, 104, 104),
            onPressed: () => value.updateMenuOption(),
            child: Icon(value.isMenuOpen ? Icons.close : Icons.add),
          ),
        ],
      );
    });
  }
}

// Helper function to get polyline color based on vehicle type
Color _getPolylineColor(String vehicleType) {
  switch (vehicleType) {
    case 'car':
      return Colors.blue;
    case 'bike':
      return Colors.green;
    case 'walk':
      return Colors.orange;
    default:
      return Colors.black;
  }
}
