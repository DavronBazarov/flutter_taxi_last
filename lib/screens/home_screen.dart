import 'package:flutter/material.dart';
import 'package:flutter_taxi/models/address.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  final Address? userAddress;

  HomePage({Key? key, this.userAddress}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late YandexMapController controller;

  GlobalKey mapKey = GlobalKey();

  Future<bool> get locationPermissionNotGranted async =>
      !(await Permission.location.request().isGranted);

  @override
  void initState() {
    super.initState();
  }

  Future<void> checkPermission(BuildContext context) async {
    if (await locationPermissionNotGranted) {
      _showMessage(context, Text('Location permission was NOT granted'));
      return;
    }

    // final mediaQuery = MediaQuery.of(context);
    // final height =
    //     mapKey.currentContext!.size!.height * mediaQuery.devicePixelRatio;
    // final width =
    //     mapKey.currentContext!.size!.width * mediaQuery.devicePixelRatio;
    //
    await controller.toggleUserLayer(
        visible: true,
        autoZoomEnabled: true,
        anchor: UserLocationAnchor(
            course: Offset(0.5 * 2, 0.5 * 2),
            normal: Offset(0.5 * 2, 0.5 * 2)));

    // final place = PlacemarkMapObject(
    //     icon: PlacemarkIcon.single(PlacemarkIconStyle(
    //         image: BitmapDescriptor.fromAssetImage('assets/user.png'),
    //         rotationType: RotationType.rotate)),
    //     mapId: MapObjectId('current'),
    //     opacity: 0.7,
    //     direction: 0,
    //     isDraggable: true,
    //     onDragStart: (_) => print('Drag start'),
    //     onDrag: (_, Point point) => print('Drag at point $point'),
    //     onDragEnd: (_) => print('Drag end'),
    //     point: Point(longitude: 0.0, latitude: 0.0));
    //
    // setState(() {
    //   mapObjects.add(place);
    // });
  }

  void _showMessage(BuildContext context, Text text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SlidingUpPanel(
        minHeight: MediaQuery.of(context).size.height * 0.25,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        body: buildBody(),
        panel: buildPanel(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      drawer: const Drawer(
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checkPermission(context);
        },
      ),
    );
  }

  Widget buildAppBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(4),
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Image.asset('assets/ic_menu.png'),
          ),
        )
      ],
    );
  }

  final List<MapObject> mapObjects = [];

  Widget buildBody() {
    return Container(
      child: Stack(
        children: [
          Expanded(
            child: YandexMap(
              onMapCreated: (YandexMapController yandexMapController) async {
                controller = yandexMapController;
              },
              onUserLocationAdded: (UserLocationView view) async {
                return view.copyWith(
                    pin: view.pin.copyWith(
                        icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                'assets/user.png')))),
                    arrow: view.arrow.copyWith(
                        icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                'assets/arrow.png')))),
                    accuracyCircle: view.accuracyCircle
                        .copyWith(fillColor: Colors.green.withOpacity(0.5)));
              },
              mapObjects: mapObjects,
              zoomGesturesEnabled: true,
            ),
          ),
          SafeArea(child: Expanded(child: buildAppBar())),
        ],
      ),
    );
  }

  Widget buildPanel() {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              height: 4,
              width: 32,
              color: const Color(0xffD5DDE0),
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xff7EAB3A),
                    size: 30,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: addressList())
          ],
        ));
  }

  List<Address> addresses = [
    Address(street: "ул. Таубе, 15", city: "Омск"),
    Address(street: "ул. Старозагородная Роща, д. 8", city: "Омск"),
  ];

  Widget addressList() {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          indent: MediaQuery.of(context).size.width * 0.2,
          endIndent: MediaQuery.of(context).size.width * 0.05,
          thickness: 1,
          color: Colors.black38,
        );
      },
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            child: Icon(
              Icons.place,
              color: Colors.white,
              size: 32,
            ),
            backgroundColor: Color(0xffD5DDE0),
          ),
          subtitle: Text(addresses[index].city ?? ""),
          title: Text(addresses[index].street ?? ""),
        );
      },
    );
  }
}
