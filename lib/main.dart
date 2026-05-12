import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(SmartMapAI());
}

class SmartMapAI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapHome(),
    );
  }
}

class MapHome extends StatefulWidget {
  @override
  _MapHomeState createState() => _MapHomeState();
}

class _MapHomeState extends State<MapHome> {
  List<dynamic> results = [];
  MapController mapController = MapController();
  TextEditingController searchController = TextEditingController();

  late stt.SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  // ذكاء اصطناعي بسيط لتحليل النص
  String aiParser(String text) {
    text = text.toLowerCase();

    if (text.contains("مطعم") && text.contains("رخيص")) {
      return "cheap restaurant";
    }
    if (text.contains("مقهى") && text.contains("هادي")) {
      return "quiet cafe";
    }
    if (text.contains("مقهى")) {
      return "cafe";
    }
    if (text.contains("صيدلية")) {
      return "pharmacy";
    }
    if (text.contains("مستشفى")) {
      return "hospital";
    }
    if (text.contains("موقف")) {
      return "parking";
    }

    return text;
  }

  Future<void> searchOSM(String keyword) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$keyword&format=json&limit=10";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    setState(() {
      results = data;
    });

    if (results.isNotEmpty) {
      mapController.move(
        LatLng(
          double.parse(results[0]["lat"]),
          double.parse(results[0]["lon"]),
        ),
        15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Smart Map AI"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // مربع البحث + المايك
          Padding(
