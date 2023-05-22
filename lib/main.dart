// import 'dart:ffi';
//
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Dashboard'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Container(
//         child: SingleChildScrollView(
//           child: Column(
//             // children: (List<int>.generate(1000, (i) => i + 1)).map((e) => Container(
//             //   height: 150,
//             //   margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//             //   color: Colors.blueAccent,
//             // ) ).toList(),
//             children: (List<int>.generate(10, (i) => i + 1)).map((e) => Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//               color: Colors.blueAccent,
//               child: Image.network("https://media.licdn.com/dms/image/C5616AQHA3Bi0gd8qLw/profile-displaybackgroundimage-shrink_350_1400/0/1636752436409?e=1690416000&v=beta&t=y-fI48zD5OE6kT4l7-an8sFlPclcBvovFhACDzvOToU")
//             ) ).toList(),
//           ),
//         ),
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';
  String toPadded([int width = 3]) => toString().padLeft(width, '0');
  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}

class _MyAppState extends State<MyApp> {
  var availablePorts = [];

  @override
  void initState() {
    super.initState();
    initPorts();
  }

  void initPorts() {
    try{
      setState(() => availablePorts = SerialPort.availablePorts);
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Serial Port'),
        ),
        body: Scrollbar(
          child: ListView(
            children: [
              for (final address in availablePorts)
                Builder(builder: (context) {
                  final port = SerialPort(address);
                  if(port.description == "HOCOES64"){
                    port.openReadWrite();
                    print(port.isOpen);
                    print( port.write(Uint8List.fromList([1,2,4,7,3]),timeout: 200));
                    final reader = SerialPortReader(port);
                    reader.stream.listen((event) {
                      print("Received Data ${event}");
                    });
                  }
                  // port.write(bytes);
                  // port.read(bytes)
                  return ExpansionTile(
                    title: Text(address),
                    children: [
                      CardListTile('Description', port.description),
                      CardListTile('Transport', port.transport.toTransport()),
                      CardListTile('USB Bus', port.busNumber?.toPadded()),
                      CardListTile('USB Device', port.deviceNumber?.toPadded()),
                      CardListTile('Vendor ID', port.vendorId?.toHex()),
                      CardListTile('Product ID', port.productId?.toHex()),
                      CardListTile('Manufacturer', port.manufacturer),
                      CardListTile('Product Name', port.productName),
                      CardListTile('Serial Number', port.serialNumber),
                      CardListTile('MAC Address', port.macAddress),
                    ],
                  );
                }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: initPorts,
        ),
      ),
    );
  }
}

class CardListTile extends StatelessWidget {
  final String name;
  final String? value;

  CardListTile(this.name, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(value ?? 'N/A'),
        subtitle: Text(name),
      ),
    );
  }
}



//
// import 'dart:async';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:usb_serial/transaction.dart';
// import 'package:usb_serial/usb_serial.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   UsbPort? _port;
//   String _status = "Idle";
//   List<Widget> _ports = [];
//   List<Widget> _serialData = [];
//
//   StreamSubscription<String>? _subscription;
//   Transaction<String>? _transaction;
//   UsbDevice? _device;
//
//   TextEditingController _textController = TextEditingController();
//
//   Future<bool> _connectTo(device) async {
//     _serialData.clear();
//
//     if (_subscription != null) {
//       _subscription!.cancel();
//       _subscription = null;
//     }
//
//     if (_transaction != null) {
//       _transaction!.dispose();
//       _transaction = null;
//     }
//
//     if (_port != null) {
//       _port!.close();
//       _port = null;
//     }
//
//     if (device == null) {
//       _device = null;
//       setState(() {
//         _status = "Disconnected";
//       });
//       return true;
//     }
//
//     _port = await device.create();
//     if (await (_port!.open()) != true) {
//       setState(() {
//         _status = "Failed to open port";
//       });
//       return false;
//     }
//     _device = device;
//
//     await _port!.setDTR(true);
//     await _port!.setRTS(true);
//     await _port!.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
//
//     _transaction = Transaction.stringTerminated(_port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));
//
//     _subscription = _transaction!.stream.listen((String line) {
//       setState(() {
//         _serialData.add(Text(line));
//         if (_serialData.length > 20) {
//           _serialData.removeAt(0);
//         }
//       });
//     });
//
//     setState(() {
//       _status = "Connected";
//     });
//     return true;
//   }
//
//   void _getPorts() async {
//     _ports = [];
//     List<UsbDevice> devices = await UsbSerial.listDevices();
//     if (!devices.contains(_device)) {
//       _connectTo(null);
//     }
//     print(devices);
//
//     devices.forEach((device) {
//       _ports.add(ListTile(
//           leading: Icon(Icons.usb),
//           title: Text(device.productName!),
//           subtitle: Text(device.manufacturerName!),
//           trailing: ElevatedButton(
//             child: Text(_device == device ? "Disconnect" : "Connect"),
//             onPressed: () {
//               _connectTo(_device == device ? null : device).then((res) {
//                 _getPorts();
//               });
//             },
//           )));
//     });
//
//     setState(() {
//       print(_ports);
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     UsbSerial.usbEventStream!.listen((UsbEvent event) {
//       _getPorts();
//     });
//
//     _getPorts();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _connectTo(null);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//           appBar: AppBar(
//             title: const Text('USB Serial Plugin example app'),
//           ),
//           body: Center(
//               child: Column(children: <Widget>[
//                 Text(_ports.length > 0 ? "Available Serial Ports" : "No serial devices available", style: Theme.of(context).textTheme.headline6),
//                 ..._ports,
//                 Text('Status: $_status\n'),
//                 Text('info: ${_port.toString()}\n'),
//                 ListTile(
//                   title: TextField(
//                     controller: _textController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Text To Send',
//                     ),
//                   ),
//                   trailing: ElevatedButton(
//                     child: Text("Send"),
//                     onPressed: _port == null
//                         ? null
//                         : () async {
//                       if (_port == null) {
//                         return;
//                       }
//                       String data = _textController.text + "\r\n";
//                       await _port!.write(Uint8List.fromList(data.codeUnits));
//                       _textController.text = "";
//                     },
//                   ),
//                 ),
//                 Text("Result Data", style: Theme.of(context).textTheme.headline6),
//                 ..._serialData,
//               ])),
//         ));
//   }
// }


// import 'package:flutter/material.dart';
// import 'main_presenter.dart';
// import 'main_viewmodel.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MainPage(),
//     );
//   }
// }
//
// abstract class MainView {
//   void refresh() {}
//
//   void showToast(String message) {}
// }
//
// class MainPage extends StatefulWidget {
//   MainPage({
//     Key? key,
//   });
//
//   @override
//   _MainPageState createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> implements MainView {
//   bool _didInitState = false;
//   late MainPresenter presenter;
//   late MainViewModel? model;
//
//   @override
//   @mustCallSuper
//   void didChangeDependencies() {
//     if (!_didInitState) {
//       afterViewInit();
//       _didInitState = true;
//     }
//     super.didChangeDependencies();
//   }
//
//   @override
//   void dispose() {
//     this.presenter.dispose();
//     super.dispose();
//   }
//
//   void initState() {
//     super.initState();
//     this.presenter = MainPresenter(
//       MainViewModel(),
//       this,
//     ).init();
//     this.model = this.presenter.viewModel;
//   }
//
//   void afterViewInit() {
//     this.presenter.initServices();
//     this.presenter.loadData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("WebUSB"),
//       ),
//       body: this.model!.isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Center(
//               child: Text("Web USB supported: " +
//                   this.model!.isSupported.toString()),
//             ),
//             SizedBox(height: 20.0),
//             if (this.model!.pairedDevice != null)
//               this._buildPairedDeviceInfo()
//             else
//               this._buildRequestDeviceButton()
//           ],
//         ),
//       ),
//       floatingActionButton: AnimatedOpacity(
//         child: FloatingActionButton(
//           child: this.presenter.isDeviceOpen()
//               ? Icon(Icons.close)
//               : Icon(Icons.usb),
//           tooltip: "Start session",
//           onPressed: () {
//             if (this.presenter.isDeviceOpen()) {
//               this.presenter.closeSession();
//             } else {
//               this.presenter.startSession();
//             }
//           },
//         ),
//         duration: Duration(milliseconds: 100),
//         opacity: this.model!.fabIsVisible ? 1 : 0,
//       ),
//     );
//   }
//
//   Widget _buildPairedDeviceInfo() {
//     Map<String, dynamic> _deviceInfos = this.presenter.getPairedDeviceInfo();
//     return Expanded(
//       child: Row(
//         children: [
//           Container(
//             width: 400,
//             child: ListView(
//                 shrinkWrap: true,
//                 children: _deviceInfos.keys.map(
//                       (String property) {
//                     return Row(
//                       children: <Widget>[
//                         Container(
//                           padding: const EdgeInsets.only(right: 10.0),
//                           child: Text(
//                             property,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                             child: Container(
//                               padding:
//                               const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
//                               child: Text(
//                                 '${_deviceInfos[property]}',
//                                 maxLines: 10,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             )),
//                       ],
//                     );
//                   },
//                 ).toList()),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRequestDeviceButton() {
//     return ElevatedButton(
//       onPressed: () {
//         return this.model!.isLoading ? null : this.presenter.requestDevices();
//       },
//       child: const Text('Request Device'),
//     );
//   }
//
//   @override
//   void refresh() => this.setState(() {});
//
//   @override
//   void showToast(String message) {
//     final scaffold = ScaffoldMessenger.of(context);
//     scaffold.showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }
// }