// 지역코드조회

// import packages
import 'dart:convert'; //json으로 바꿔주기 위해 필요한 패키지
import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // api 호출 위해 필요한 패키지

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AreaCodeWidget(),
    );
  }
}

// api 호출
Future<List<AreaCode>> fetchAreaCode({required String areaCode}) async {
  String Url = "https://apis.data.go.kr/B551011/KorService/areaCode";
  String queryParams =
      "?serviceKey=mNbd2x4ks2HlhJCaa9VeqYslDUC%2Bdnzj4IOybVIFeSRU5tZtINpW3B2FMpDs8Mc0%2FMxp24VxxqWpuveYOmV%2FDA%3D%3D";
  queryParams += "&_type=json&MobileOS=ETC&MobileApp=Fing";
  queryParams += "&areaCode=$areaCode";

  print('api 호출$Url$queryParams');

  final response = await http.get(Uri.parse(Url + queryParams));

  if (response.statusCode == 200) {
    Map<String, dynamic> fes = jsonDecode(response.body);
    var modelObject = AreaCode.fromJson(fes);
    String totalNum = modelObject.response!.body!.totalCount!.toString();

    queryParams = "$queryParams&numOfRows=$totalNum";
    queryParams = "$queryParams&pageNo=1";

    print('총개수만큼 api 호출\n$Url$queryParams');

    final res = await http.get(Uri.parse(Url + queryParams));

    if (res.statusCode == 200) {
      print('api 호출 성공');
      return (jsonDecode("[${utf8.decode(res.bodyBytes)}]") as List<dynamic>)
          .map((e) => AreaCode.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to load data");
    }
  } else {
    throw Exception('Failed to load data');
  }
}

// widget example
class AreaCodeWidget extends StatefulWidget {
  const AreaCodeWidget({Key? key}) : super(key: key);

  @override
  State<AreaCodeWidget> createState() => _AreaCodeWidgetState();
}

class _AreaCodeWidgetState extends State<AreaCodeWidget> {
  late Future<List<AreaCode>> futureAreaCode;

  @override
  void initState() {
    super.initState();
    // 여기 적혀 있는 변수들 다 넣어야됨
    futureAreaCode = fetchAreaCode(
      areaCode: "1",
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<AreaCode>>(
        future: futureAreaCode,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('hasData');

            // tranditional_festival_model[index].변수명 으로 쓰면 됨
            List<Item> areacode_model =
                snapshot.data![0].response!.body!.items!.item!;
            print(areacode_model.length);

            return Container(
                color: Colors.white,
                child: ListView.builder(
                    itemCount: areacode_model.length,
                    itemBuilder: (BuildContext context, index) => Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          title: Text(areacode_model[index].name.toString()),
                          subtitle: Text(areacode_model[index].code.toString()),
                        ))));
          } else if (snapshot.hasError) {
            print('error');
            print(snapshot.error);
            return Text('error${snapshot.error}');
          }
          return Center(child: CupertinoActivityIndicator());
        });
  }
}

// json to dart
class AreaCode {
  Response? response;

  AreaCode({this.response});

  AreaCode.fromJson(Map<String, dynamic> json) {
    response = json['response'] != null
        ? new Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.response != null) {
      data['response'] = this.response!.toJson();
    }
    return data;
  }
}

class Response {
  Header? header;
  Body? body;

  Response({this.header, this.body});

  Response.fromJson(Map<String, dynamic> json) {
    header =
        json['header'] != null ? new Header.fromJson(json['header']) : null;
    body = json['body'] != null ? new Body.fromJson(json['body']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.header != null) {
      data['header'] = this.header!.toJson();
    }
    if (this.body != null) {
      data['body'] = this.body!.toJson();
    }
    return data;
  }
}

class Header {
  String? resultCode;
  String? resultMsg;

  Header({this.resultCode, this.resultMsg});

  Header.fromJson(Map<String, dynamic> json) {
    resultCode = json['resultCode'];
    resultMsg = json['resultMsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resultCode'] = this.resultCode;
    data['resultMsg'] = this.resultMsg;
    return data;
  }
}

class Body {
  Items? items;
  int? numOfRows;
  int? pageNo;
  int? totalCount;

  Body({this.items, this.numOfRows, this.pageNo, this.totalCount});

  Body.fromJson(Map<String, dynamic> json) {
    items = json['items'] != null ? new Items.fromJson(json['items']) : null;
    numOfRows = json['numOfRows'];
    pageNo = json['pageNo'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.toJson();
    }
    data['numOfRows'] = this.numOfRows;
    data['pageNo'] = this.pageNo;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Items {
  List<Item>? item;

  Items({this.item});

  Items.fromJson(Map<String, dynamic> json) {
    if (json['item'] != null) {
      item = <Item>[];
      json['item'].forEach((v) {
        item!.add(new Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.item != null) {
      data['item'] = this.item!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Item {
  int? rnum;
  String? code;
  String? name;

  Item({this.rnum, this.code, this.name});

  Item.fromJson(Map<String, dynamic> json) {
    rnum = json['rnum'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rnum'] = this.rnum;
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}
