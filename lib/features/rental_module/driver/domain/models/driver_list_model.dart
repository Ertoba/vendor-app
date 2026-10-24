class DriverListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Drivers>? drivers;

  DriverListModel({this.totalSize, this.limit, this.offset, this.drivers});

  DriverListModel.fromJson(Map<String, dynamic> json) {
    final dynamic pageRaw = json['pagination'];
    final Map<String, dynamic>? page = pageRaw is Map ? Map<String, dynamic>.from(pageRaw) : null;
    totalSize = int.tryParse('${(page != null ? page['total'] : json['total_size'])}');
    limit = int.tryParse('${(page != null ? page['per_page'] : json['limit'])}');
    offset = int.tryParse('${(page != null ? page['current_page'] : json['offset'])}');
    if ((json['data'] ?? json['drivers']) != null) {
      drivers = <Drivers>[];
      (json['data'] ?? json['drivers']).forEach((v) {
        drivers!.add(Drivers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (drivers != null) {
      data['drivers'] = drivers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Drivers {
  int? id;
  int? providerId;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? image;
  String? identityType;
  String? identityNumber;
  String? identityImage;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? imageFullUrl;
  List<String>? identityImageFullUrl;
  int? tripsCount;
  int? totalTripCompleted;
  int? totalTripCanceled;
  int? totalTripOngoing;

  Drivers({
    this.id,
    this.providerId,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.image,
    this.identityType,
    this.identityNumber,
    this.identityImage,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.imageFullUrl,
    this.identityImageFullUrl,
    this.tripsCount,
    this.totalTripCompleted,
    this.totalTripCanceled,
    this.totalTripOngoing,
  });

  Drivers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
    identityType = json['identity_type'];
    identityNumber = json['identity_number'];
    identityImage = json['identity_image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    imageFullUrl = json['image_full_url'];
    if (json['identity_image_full_url'] != null) {
      identityImageFullUrl = <String>[];
      json['identity_image_full_url'].forEach((v) {
        if (v != null) {
          identityImageFullUrl!.add(v.toString());
        }
      });
    }
    tripsCount = json['trips_count'];
    totalTripCompleted = json['total_trip_completed'];
    totalTripCanceled = json['total_trip_canceled'];
    totalTripOngoing = json['total_trip_ongoing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['image'] = image;
    data['identity_type'] = identityType;
    data['identity_number'] = identityNumber;
    data['identity_image'] = identityImage;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['image_full_url'] = imageFullUrl;
    data['identity_image_full_url'] = identityImageFullUrl;
    data['trips_count'] = tripsCount;
    data['total_trip_completed'] = totalTripCompleted;
    data['total_trip_canceled'] = totalTripCanceled;
    data['total_trip_ongoing'] = totalTripOngoing;
    return data;
  }
}
