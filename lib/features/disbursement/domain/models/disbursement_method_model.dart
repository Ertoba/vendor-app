import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class DisbursementMethodBody {
  int? totalSize;
  String? limit;
  String? offset;
  List<Methods>? methods;

  DisbursementMethodBody({this.totalSize, this.limit, this.offset, this.methods});

  DisbursementMethodBody.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? pagination = json['pagination'] != null ? Map<String, dynamic>.from(json['pagination']) : null;
    totalSize = pagination != null ? pagination['total'] : json['total_size'];
    limit = (pagination != null ? pagination['per_page'] : json['limit'])?.toString();
    offset = (pagination != null ? pagination['current_page'] : json['offset'])?.toString();
    final dynamic methodList = json['data'] ?? json['methods'];
    if (methodList is List) {
      methods = <Methods>[];
      for (dynamic v in methodList) {
        methods!.add(Methods.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (methods != null) {
      data['methods'] = methods!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Methods {
  int? id;
  int? storeId;
  int? deliveryManId;
  int? withdrawalMethodId;
  String? methodName;
  List<MethodFields>? methodFields;
  bool? isDefault;
  String? createdAt;
  String? updatedAt;

  Methods({
    this.id,
    this.storeId,
    this.deliveryManId,
    this.withdrawalMethodId,
    this.methodName,
    this.methodFields,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  Methods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    deliveryManId = json['delivery_man_id'];
    withdrawalMethodId = json['withdrawal_method_id'];
    methodName = json['method_name'];
    if (json['method_fields'] != null) {
      methodFields = <MethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(MethodFields.fromJson(v));
      });
    }
    isDefault = DataParserHelper.parseBool(json['is_default']);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_id'] = storeId;
    data['delivery_man_id'] = deliveryManId;
    data['withdrawal_method_id'] = withdrawalMethodId;
    data['method_name'] = methodName;
    if (methodFields != null) {
      data['method_fields'] = methodFields!.map((v) => v.toJson()).toList();
    }
    data['is_default'] = isDefault;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class MethodFields {
  String? userInput;
  String? userData;

  MethodFields({this.userInput, this.userData});

  MethodFields.fromJson(Map<String, dynamic> json) {
    userInput = json['user_input'];
    userData = json['user_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_input'] = userInput;
    data['user_data'] = userData;
    return data;
  }
}