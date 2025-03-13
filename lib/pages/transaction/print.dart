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

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
    try {
      List<thermal.BluetoothDevice> devices =
          await bluetooth.getBondedDevices();
      bool isConnected = await bluetooth.isConnected ?? false;
      var state = await FlutterBluePlus.adapterState.first;
      setState(() {
        _devices = devices;
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
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.print, color: const Color(0xFF1E1E1E)),
            const SizedBox(width: 8),
            const Text(
              "Pengaturan Printer",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ],
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
              borderSide:
                  const BorderSide(color: Colors.black), // Default border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.black), // Border normal
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFD39054), width: 2), // Border aktif
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          hint: const Text("Pilih Printer"),
          items: _devices.map((device) {
            return DropdownMenuItem(
              value: device,
              child: Text(
                device.name ?? "Unknown",
                style: const TextStyle(
                  fontSize: 14, // Ukuran teks input lebih kecil
                  fontWeight:
                      FontWeight.w500, // Medium agar mirip dengan gambar
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (device) => setState(() => _selectedDevice = device),
        ),
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
