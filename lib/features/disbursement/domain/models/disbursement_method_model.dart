class DisbursementMethodBody {
  int? totalSize;
  String? limit;
  String? offset;
  List<Methods>? methods;

  DisbursementMethodBody({
    this.totalSize,
    this.limit,
    this.offset,
    this.methods,
  });

  DisbursementMethodBody.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    methods = <Methods>[];
    if (json['methods'] != null) {
      json['methods'].forEach((v) {
        methods!.add(Methods.fromJson(v));
      });
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
    } else {
      methodFields = <MethodFields>[];
    }
    isDefault = _parseBool(json['is_default']);
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }

    return false;
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
