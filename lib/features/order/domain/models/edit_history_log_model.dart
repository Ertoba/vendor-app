class EditHistoryLogModel {
  int? orderId;
  int? totalSize;
  String? limit;
  String? offset;
  List<EditLog>? editLogs;

  EditHistoryLogModel({
    this.orderId,
    this.totalSize,
    this.limit,
    this.offset,
    this.editLogs,
  });

  EditHistoryLogModel.fromJson(Map<String, dynamic> json) {
    final dynamic pageRaw = json['pagination'];
    final Map<String, dynamic>? page = pageRaw is Map
        ? Map<String, dynamic>.from(pageRaw)
        : null;
    orderId = json['order_id'];
    totalSize = int.tryParse(
      '${page != null ? page['total'] : json['total_size']}',
    );
    limit = (page != null ? page['per_page'] : json['limit'])?.toString();
    offset = (page != null ? page['current_page'] : json['offset'])?.toString();
    final dynamic rows = json['data'] ?? json['edit_logs'];
    if (rows is List) {
      editLogs = [];
      for (final dynamic v in rows) {
        editLogs!.add(EditLog.fromJson(v));
      }
    }
  }
}

class EditLog {
  int? id;
  String? log;
  String? remark;
  String? editedBy;
  String? editedByLabel;
  String? createdAt;

  EditLog({
    this.id,
    this.log,
    this.remark,
    this.editedBy,
    this.editedByLabel,
    this.createdAt,
  });

  EditLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    log = json['log'];
    remark = json['remark'];
    editedBy = json['edited_by'];
    editedByLabel = json['edited_by_label'];
    createdAt = json['created_at'];
  }
}
