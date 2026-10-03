class EditHistoryLogModel {
  int? orderId;
  int? totalSize;
  String? limit;
  String? offset;
  List<EditLog>? editLogs;

  EditHistoryLogModel({this.orderId, this.totalSize, this.limit, this.offset, this.editLogs});

  EditHistoryLogModel.fromJson(Map<String, dynamic> json) {
    final dynamic pageRaw = json['pagination'];
    final Map<String, dynamic>? page = pageRaw is Map ? Map<String, dynamic>.from(pageRaw) : null;
    orderId = json['order_id'];
    totalSize = int.tryParse('${(page != null ? page['total'] : json['total_size'])}');
    limit = (page != null ? page['per_page'] : json['limit'])?.toString();
    offset = (page != null ? page['current_page'] : json['offset'])?.toString();
    if ((json['data'] ?? json['edit_logs']) != null) {
      editLogs = [];
      (json['data'] ?? json['edit_logs']).forEach((v) => editLogs!.add(EditLog.fromJson(v)));
    }
  }
}

class EditLog {
  int? id;
  String? remark;
  String? editedByLabel;
  String? createdAt;

  EditLog({this.id, this.remark, this.editedByLabel, this.createdAt});

  EditLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    remark = json['remark'];
    editedByLabel = json['edited_by_label'];
    createdAt = json['created_at'];
  }
}
