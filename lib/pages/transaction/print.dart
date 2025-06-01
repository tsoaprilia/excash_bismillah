import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as thermal;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PrintSettingsPage extends StatefulWidget {
  const PrintSettingsPage({Key? key}) : super(key: key);

  @override
  State<PrintSettingsPage> createState() => _PrintSettingsPageState();
}

class _PrintSettingsPageState extends State<PrintSettingsPage> {
  thermal.BlueThermalPrinter bluetooth = thermal.BlueThermalPrinter.instance;
  List<thermal.BluetoothDevice> _devices = [];
  thermal.BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isBluetoothOn = false;
  List<BluetoothDevice> _availableDevices = []; // dari flutter_blue_plus

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
    try {
      // Dapatkan perangkat yang sudah disandingkan
      List<thermal.BluetoothDevice> bondedDevices =
          await bluetooth.getBondedDevices();
      bool isConnected = await bluetooth.isConnected ?? false;
      var state = await FlutterBluePlus.adapterState.first;

      // Scan perangkat baru yang tersedia
      _availableDevices.clear();
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_availableDevices
              .any((d) => d.remoteId == result.device.remoteId)) {
            setState(() {
              _availableDevices.add(result.device);
            });
          }
        }
      });

      setState(() {
        _devices = bondedDevices;
        _isConnected = isConnected;
        _isBluetoothOn = (state == BluetoothAdapterState.on);
      });
    } catch (e) {
      print("❌ Error initializing Bluetooth: $e");
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Future<void> _toggleBluetooth() async {
    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
      _showSnackbar("Bluetooth dinyalakan");
      setState(() => _isBluetoothOn = true);

      // Refresh the devices list after turning Bluetooth on
      await _initBluetooth(); // Reload the paired devices immediately
    } else {
      await FlutterBluePlus.turnOff();
      _showSnackbar("Bluetooth dimatikan");
      setState(() => _isBluetoothOn = false);
    }
  }

  void _showBluetoothSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Matikan Bluetooth"),
        content: const Text(
            "Silakan matikan Bluetooth secara manual di pengaturan perangkat."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToDevice() async {
    if (_selectedDevice == null) {
      _showSnackbar("Pilih printer terlebih dahulu!");
      return;
    }

    _showLoading();
    try {
      await bluetooth.connect(_selectedDevice!);
      setState(() {
        _isConnected = true;
      });
      _hideLoading();
      _showSnackbar("Terhubung ke ${_selectedDevice!.name}");
    } catch (e) {
      _hideLoading();
      _showSnackbar("Gagal terhubung ke printer!");
      print("❌ Gagal terhubung: $e");
    }
  }

  Future<void> _disconnectPrinter() async {
    await bluetooth.disconnect();
    setState(() {
      _isConnected = false;
    });
    _showSnackbar("Printer terputus");
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12), // Jarak antara ikon dan teks
            const Text(
              "Pengaturan Print",
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildBluetoothButton(),
            const SizedBox(height: 16),
            _buildPrinterDropdown(),
            const SizedBox(height: 16),
            _buildConnectionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 12), // Padding biar ada ruang
      decoration: BoxDecoration(
        color: Colors.white, // Tambahkan background putih
        borderRadius: BorderRadius.circular(8), // Opsional, biar lebih estetik
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.print, size: 20, color: Colors.black87),
          const SizedBox(width: 6),
          const Text(
            "Menyambungkan ke printer",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isBluetoothOn ? _showBluetoothSettings : _toggleBluetooth,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isBluetoothOn ? Colors.red : const Color(0xFFD39054),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          _isBluetoothOn ? "Matikan Bluetooth" : "Nyalakan Bluetooth",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPrinterDropdown() {
    final Map<String, thermal.BluetoothDevice> deviceMap = {
      for (var device in [
        ..._devices,
        ..._availableDevices.map((e) => thermal.BluetoothDevice(
              e.platformName,
              e.remoteId.str,
            )),
      ])
        device.address!: device,
    };

    final allDevices = deviceMap.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih Printer Bluetooth:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<thermal.BluetoothDevice>(
          value: _selectedDevice,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD39054), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          hint: const Text("Pilih Printer"),
          items: allDevices.map((device) {
            return DropdownMenuItem(
              value: device,
              child: Text(
                device.name ?? "Unknown",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (device) => setState(() => _selectedDevice = device),
        )
      ],
    );
  }

  Widget _buildConnectionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isConnected ? null : _connectToDevice,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isConnected ? Colors.grey : const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Sambungkan Koneksi",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (_isConnected) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _disconnectPrinter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Putuskan Koneksi",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
