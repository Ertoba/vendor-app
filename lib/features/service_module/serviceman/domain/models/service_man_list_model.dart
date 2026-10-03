import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_model.dart';

class ServiceManListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<ServiceManModel>? servicemen;

  ServiceManListModel({this.totalSize, this.limit, this.offset, this.servicemen});

  ServiceManListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['servicemen'] != null) {
      servicemen = <ServiceManModel>[];
      json['servicemen'].forEach((v) {
        servicemen!.add(ServiceManModel.fromJson(v));
      });
    }
  }
}
