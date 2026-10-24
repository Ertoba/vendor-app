class ServiceCampaignModel {
  int? id;
  String? title;
  String? slug;
  String? description;
  String? imageFullUrl;
  int? moduleId;
  String? availableDateStarts;
  String? availableDateEnds;
  String? startTime;
  String? endTime;
  int? status;
  bool? isJoined;
  String? vendorStatus;

  ServiceCampaignModel({
    this.id, this.title, this.slug, this.description, this.imageFullUrl, this.moduleId,
    this.availableDateStarts, this.availableDateEnds, this.startTime, this.endTime,
    this.status, this.isJoined, this.vendorStatus,
  });

  ServiceCampaignModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    imageFullUrl = json['image_full_url'];
    moduleId = json['module_id'];
    availableDateStarts = json['available_date_starts'];
    availableDateEnds = json['available_date_ends'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    isJoined = json['is_joined'];
    vendorStatus = json['vendor_status'];
  }
}
