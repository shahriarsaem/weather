import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: forcastMap != null
            ? Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [
                          Text(
                            "${Jiffy("${forcastMap!["list"][0]["dt_txt"]}").format("MMM do yy")}, ${Jiffy("${forcastMap!["list"][0]["dt_txt"]}").format("h:mm")}",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            "${weatherMap!["name"]}",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Image.network(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSe4nkORQ1H7aRgZ4h5Mpraxxjq9LOU73AP6vKJpWZUSgVFH4UPHxVFsdbkWIfSkW8HcQ8&usqp=CAU",
                            height: 90,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "${forcastMap!["list"][0]["main"]["temp"]} °",
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Text(
                            "Feels Like ${forcastMap!["list"][0]["main"]["feels_like"]} °",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            "${forcastMap!["list"][0]["weather"][0]["description"]} °",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Humidity ${forcastMap!["list"][0]["main"]["humidity"]}, Pressure  ${forcastMap!["list"][0]["main"]["pressure"]}",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            "Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format("h:mm:a")}, Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format("h:mm:a")}",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 180,
                      width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: forcastMap!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            width: 90,
                            color: Colors.blueGrey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "${Jiffy("${forcastMap!["list"][index]["dt_txt"]}").format("EEE")} ,${Jiffy("${forcastMap!["list"][index]["dt_txt"]}").format("h:mm")}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Image.network(
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSe4nkORQ1H7aRgZ4h5Mpraxxjq9LOU73AP6vKJpWZUSgVFH4UPHxVFsdbkWIfSkW8HcQ8&usqp=CAU",
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  "${forcastMap!["list"][index]["main"]["temp_min"]}/${forcastMap!["list"][index]["main"]["temp_max"]}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  "${forcastMap!["list"][index]["weather"][0]["description"]}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  _determinePosition() async {
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
    fetchWeather();
    print("my latitude is $latitude, and longitude is $longitude");
  }

  fetchWeather() async {
    var weatherResponce = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&exclude=hourly%2Cdaily&appid=cc93193086a048993d938d8583ede38a&fbclid=IwAR1rg9BHqDzqxJia8bplKeuzaNLUVMWNCsfmGjp1-IHI0hpsrGe7Hnq5FMI"));

    var forcastResponce = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=cc93193086a048993d938d8583ede38a&fbclid=IwAR3Hr9_sSo-ju9Us4-W-MpsVaeQyp10SZvo84iTiJ7WjrqTNSkbxRURH5RQ"));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forcastMap = Map<String, dynamic>.from(jsonDecode(forcastResponce.body));
    });
    print(weatherResponce.body);
    print(forcastResponce.body);
  }

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forcastMap;

  late Position position;
  double? latitude;
  double? longitude;
}
