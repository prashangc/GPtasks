class PlotModel {
  String? powerId;
  String? type;
  List<Plot>? data;

  PlotModel({this.powerId, this.type, this.data});

  PlotModel.fromJson(Map<String, dynamic> json) {
    powerId = json['powerId'];
    type = json['type'];
    if (json['data'] != null) {
      data = <Plot>[];
      json['data'].forEach((v) {
        data!.add(Plot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['powerId'] = powerId;
    data['type'] = type;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Plot {
  num? i2022;
  num? i2023;
  num? d2024;
  num? d2025;
  String? date;
  num? temperature;

  Plot(
      {this.i2022,
      this.i2023,
      this.d2024,
      this.d2025,
      this.date,
      this.temperature});

  Plot.fromJson(Map<String, dynamic> json) {
    i2022 = json['2022'];
    i2023 = json['2023'];
    d2024 = json['2024'];
    d2025 = json['2025'];
    date = json['date'];
    temperature = json['temperature'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['2022'] = i2022;
    data['2023'] = i2023;
    data['2024'] = d2024;
    data['2025'] = d2025;
    data['date'] = date;
    data['temperature'] = temperature;
    return data;
  }
}
