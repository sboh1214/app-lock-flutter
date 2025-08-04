import 'dart:convert';
import 'dart:typed_data';

List<ApplicationDataModel> applicationDataModelFromJson(String str) =>
    List<ApplicationDataModel>.from(
        json.decode(str).map((x) => ApplicationDataModel.fromJson(x)));

String applicationDataModelToJson(List<ApplicationDataModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ApplicationDataModel {
  ApplicationDataModel({
    this.isLocked,
    this.application,
  });

  bool? isLocked;
  ApplicationData? application;

  factory ApplicationDataModel.fromJson(Map<String, dynamic> json) =>
      ApplicationDataModel(
        isLocked: json["isLocked"],
        application: json["application"] == null
            ? null
            : ApplicationData.fromJson(json["application"]),
      );

  Map<String, dynamic> toJson() => {
        "isLocked": isLocked,
        "application": application == null ? null : application!.toJson(),
      };
}

class ApplicationData {
  ApplicationData({
    required this.appName,
    this.icon,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.installTimeMillis,
  });

  String appName;
  Uint8List? icon;
  String packageName;
  String versionName;
  String versionCode;
  String installTimeMillis;

  factory ApplicationData.fromJson(Map<String, dynamic> json) {
    Uint8List getUinit8List(data) {
      // log("$data", name: 'getUinit8List');
      List<int> list = utf8.encode(data.toString());
      // log("$data", name: 'getUinit8List2');
      return Uint8List.fromList(list);
    }

    return ApplicationData(
      appName: json["appName"] == null ? null : json["appName"],
      // icon: getUinit8List(json["icon"]),
      icon: getUinit8List(json["icon"]),
      packageName: json["packageName"] == null ? null : json["packageName"],
      versionName: json["versionName"] == null ? null : json["versionName"],
      versionCode: json["versionCode"] == null ? null : json["versionCode"],
      installTimeMillis:
          json["installTimeMillis"] == null ? null : json["installTimeMillis"],
    );
  }

  Map<String, dynamic> toJson() {
    String getUinit8List(data) {
      return base64Encode(Uint8List.fromList(utf8.encode(data.toString())));
    }

    return {
      "appName": appName == null ? null : appName,
      "icon": icon == null ? null : getUinit8List(icon),
      "packageName": packageName == null ? null : packageName,
      "versionName": versionName == null ? null : versionName,
      "versionCode": versionCode == null ? null : versionCode,
      "installTimeMillis": installTimeMillis == null ? null : installTimeMillis,
    };
  }
}
