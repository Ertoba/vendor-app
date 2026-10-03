class PredictionModel {
  String? description;
  String? id;
  int? distanceMeters;
  String? placeId;
  String? reference;
  String? place;
  TextModel? text;
  StructuredFormat? structuredFormat;
  List<String>? types;

  PredictionModel({
    this.description,
    this.id,
    this.distanceMeters,
    this.placeId,
    this.reference,
    this.place,
    this.text,
    this.structuredFormat,
    this.types,
  });

  PredictionModel.fromJson(Map<String, dynamic> json) {
    description = json['placePrediction']['text']['text'];
    id = json['placePrediction']['placeId'];
    placeId = json['placePrediction']['placeId'];
    place = json['placePrediction']['place'];
    reference = json['placePrediction']['text']['text'];
    types = List<String>.from(json['placePrediction']['types'] ?? []);
    text = json['placePrediction']['text'] != null ? TextModel.fromJson(json['placePrediction']['text']) : null;
    structuredFormat = json['placePrediction']['structuredFormat'] != null ? StructuredFormat.fromJson(json['placePrediction']['structuredFormat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['placePrediction'] = {
      'text': text?.toJson(),
      'placeId': placeId,
      'place': place,
      'types': types,
      'structuredFormat': structuredFormat?.toJson(),
    };
    return data;
  }
}

class TextModel {
  String? text;

  TextModel({this.text});

  TextModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}

class Match {
  int? endOffset;

  Match({this.endOffset});

  Match.fromJson(Map<String, dynamic> json) {
    endOffset = json['endOffset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['endOffset'] = endOffset;
    return data;
  }
}

class StructuredFormat {

  StructuredFormat();

  StructuredFormat.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    return data;
  }
}

class MainText {
  String? text;

  MainText({this.text});

  MainText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}

class SecondaryText {
  String? text;

  SecondaryText({this.text});

  SecondaryText.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}