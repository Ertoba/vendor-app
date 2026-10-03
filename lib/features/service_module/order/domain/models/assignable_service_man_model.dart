class AssignableServiceManModel {
  int? id;
  String? name;
  String? phone;
  String? imageFullUrl;
  bool? isAssigned;
  int? conflictCount;

  AssignableServiceManModel({
    this.id, this.name, this.phone, this.imageFullUrl, this.isAssigned, this.conflictCount,
  });

  AssignableServiceManModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    imageFullUrl = json['image_full_url'];
    final dynamic assigned = json['is_assigned'];
    isAssigned = assigned == true || assigned == 1;
    conflictCount = json['conflict_count'];
  }
}
