import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(RGBColorPickerApp());
}

class RGBColorPickerApp extends StatefulWidget {
  @override
  _RGBColorPickerAppState createState() => _RGBColorPickerAppState();
}

class _RGBColorPickerAppState extends State<RGBColorPickerApp>
    with SingleTickerProviderStateMixin {
  bool _isDarkMode = false;

  // Define Light Theme with a Vibrant Color Scheme
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color(0xFFF0F4FF),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF3F51B5),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      titleLarge: TextStyle(color: Colors.black, fontSize: 20),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white, // Set selected tab color to white
      unselectedLabelColor: Colors.white70,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
  );

  // Define Dark Theme with a Darker Vibrant Color Scheme
  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      titleLarge: TextStyle(color: Colors.white, fontSize: 20),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white, // Set selected tab color to white
      unselectedLabelColor: Colors.white70,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2C2C2C),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced RGB Color & Servo Controller',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DefaultTabController(
        length: 2,
        child: RGBHomePage(
          isDarkMode: _isDarkMode,
          onThemeChanged: (bool value) {
            setState(() {
              _isDarkMode = value;
            });
          },
        ),
      ),
    );
  }
}

class RGBHomePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  RGBHomePage({required this.isDarkMode, required this.onThemeChanged});

  @override
  _RGBHomePageState createState() => _RGBHomePageState();
}

class _RGBHomePageState extends State<RGBHomePage>
    with SingleTickerProviderStateMixin {
  Color _currentColor = Colors.indigo;
  final TextEditingController _ipController =
  TextEditingController(text: '172.20.10.2'); // Replace with your device's IP
  bool _isSending = false;
  bool _isWaving = false;
  bool _isDancing = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen to tab changes to trigger UI updates if necessary
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Function to send RGB values to the server
  Future<void> _sendColor() async {
    int r = _currentColor.red;
    int g = _currentColor.green;
    int b = _currentColor.blue;

    String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showMessage('Please enter the device IP address.');
      return;
    }

    if (!_isValidIP(ip)) {
      _showMessage('Please enter a valid IP address.');
      return;
    }

    String url = 'http://$ip:8080/set_color?r=$r&g=$g&b=$b';

    setState(() {
      _isSending = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _showMessage('Color sent successfully!');
      } else {
        _showMessage(
            'Failed to send color. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // Function to send wave command to the server
  Future<void> _sendWave() async {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showMessage('Please enter the device IP address.');
      return;
    }

    if (!_isValidIP(ip)) {
      _showMessage('Please enter a valid IP address.');
      return;
    }

    String url = 'http://$ip:8080/wave';

    setState(() {
      _isWaving = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _showMessage('Wave action triggered!');
      } else {
        _showMessage(
            'Failed to trigger wave. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isWaving = false;
      });
    }
  }

  // Function to send dance command to the server
  Future<void> _sendDance() async {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showMessage('Please enter the device IP address.');
      return;
    }

    if (!_isValidIP(ip)) {
      _showMessage('Please enter a valid IP address.');
      return;
    }

    String url = 'http://$ip:8080/dance';

    setState(() {
      _isDancing = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _showMessage('Dance action triggered!');
      } else {
        _showMessage(
            'Failed to trigger dance. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isDancing = false;
      });
    }
  }

  // Function to show SnackBar messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Function to open the color picker dialog
  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = _currentColor;
        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pick a Color',
                  style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                // Enhanced Color Picker
                MaterialPicker(
                  pickerColor: _currentColor,
                  onColorChanged: (Color color) {
                    tempColor = color;
                  },
                  enableLabel: true,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style:
                        TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      child: Text('Select',style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        setState(() {
                          _currentColor = tempColor;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to validate IP address format
  bool _isValidIP(String ip) {
    final regex = RegExp(
        r'^((25[0-5]|(2[0-4]\d)|(1\d\d)|([1-9]?\d))\.){3}(25[0-5]|(2[0-4]\d)|(1\d\d)|([1-9]?\d))$');
    return regex.hasMatch(ip);
  }

  // Function to update color via sliders
  void _updateColorFromSliders(int r, int g, int b) {
    setState(() {
      _currentColor = Color.fromARGB(255, r, g, b);
    });
  }

  // Helper method to determine if white text is needed
  bool useWhiteForeground(Color backgroundColor) {
    int v = sqrt(pow(backgroundColor.red, 2) * 0.299 +
        pow(backgroundColor.green, 2) * 0.587 +
        pow(backgroundColor.blue, 2) * 0.114)
        .round();
    return v < 130;
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current index of the TabController
    int currentTab = _tabController.index;

    return Scaffold(
      appBar: AppBar(
        title: Text('Robot Controller Dashboard'),
        actions: [
          // Theme Toggle Switch
          Row(
            children: [
              Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[400],
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.color_lens), // Removed manual color setting
              text: 'Color Picker',
            ),
            Tab(
              icon: Icon(Icons.play_circle_fill), // Removed manual color setting
              text: 'Actions',
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Color Picker Tab
            SingleChildScrollView(
              key: ValueKey<int>(0),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // IP Address Input
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _ipController,
                        decoration: InputDecoration(
                          labelText: 'Device IP Address',
                          prefixIcon: Icon(Icons.network_wifi),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true, signed: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Animated Color Display
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Selected Color',
                        style: TextStyle(
                          color: useWhiteForeground(_currentColor)
                              ? Colors.white
                              : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Send Color Button with Animation
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _sendColor,
                    icon: _isSending
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.send),
                    label: Text('Send Color'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  // RGB Sliders with Smooth Animations
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Red Slider
                          _buildColorSlider(
                              label: 'Red',
                              color: Colors.redAccent,
                              value: _currentColor.red.toDouble(),
                              onChanged: (double value) {
                                _updateColorFromSliders(
                                    value.toInt(),
                                    _currentColor.green,
                                    _currentColor.blue);
                              },
                              currentValue: _currentColor.red),
                          SizedBox(height: 20),
                          // Green Slider
                          _buildColorSlider(
                              label: 'Green',
                              color: Colors.greenAccent,
                              value: _currentColor.green.toDouble(),
                              onChanged: (double value) {
                                _updateColorFromSliders(
                                    _currentColor.red,
                                    value.toInt(),
                                    _currentColor.blue);
                              },
                              currentValue: _currentColor.green),
                          SizedBox(height: 20),
                          // Blue Slider
                          _buildColorSlider(
                              label: 'Blue',
                              color: Colors.blueAccent,
                              value: _currentColor.blue.toDouble(),
                              onChanged: (double value) {
                                _updateColorFromSliders(
                                    _currentColor.red,
                                    _currentColor.green,
                                    value.toInt());
                              },
                              currentValue: _currentColor.blue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Actions Tab
            SingleChildScrollView(
              key: ValueKey<int>(1),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Wave Action Button with Animated Feedback
                  ElevatedButton.icon(
                    onPressed: _isWaving ? null : _sendWave,
                    icon: _isWaving
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.waves),
                    label: Text('Wave'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Dance Action Button with Animated Feedback
                  ElevatedButton.icon(
                    onPressed: _isDancing ? null : _sendDance,
                    icon: _isDancing
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Icon(Icons.music_note),
                    label: Text('Dance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      textStyle: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Footer Section
                  FooterSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openColorPicker,
        backgroundColor: _currentColor,
        child: Icon(
          Icons.color_lens,
          color:
          useWhiteForeground(_currentColor) ? Colors.white : Colors.black,
        ),
        tooltip: 'Pick Color',
      ),
    );
  }

  // Helper method to build sliders
  Widget _buildColorSlider({
    required String label,
    required Color color,
    required double value,
    required Function(double) onChanged,
    required int currentValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $currentValue',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: color,
            overlayColor: color.withAlpha(32),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            divisions: 255,
            label: currentValue.toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// Footer Section
class FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : Colors.black54),
        SizedBox(height: 10),
        Text(
          '©️ 2024 Robot Controller',
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]
                  : Colors.black54,
              fontSize: 14),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flutter_dash,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.lightBlueAccent
                    : Colors.indigo,
                size: 20),
            SizedBox(width: 5),
            Text(
              'Powered by Flutter',
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.lightBlueAccent
                      : Colors.indigo,
                  fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}