import 'package:sixam_mart_store/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart_store/helper/data_parser_helper.dart';

class MessageModel {
  int? totalSize;
  int? limit;
  int? offset;
  bool? status;
  Conversation? conversation;
  List<Message>? messages;

  MessageModel({
    this.totalSize,
    this.limit,
    this.offset,
    this.messages,
    this.status,
    this.conversation,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    final dynamic pageRaw = json['pagination'];
    final Map<String, dynamic>? page = pageRaw is Map
        ? Map<String, dynamic>.from(pageRaw)
        : null;
    totalSize = int.tryParse(
      '${page != null ? page['total'] : json['total_size']}',
    );
    limit = int.tryParse('${page != null ? page['per_page'] : json['limit']}');
    offset = int.tryParse(
      '${page != null ? page['current_page'] : json['offset']}',
    );
    status = DataParserHelper.parseBool(json['status']);
    conversation = json['conversation'] != null
        ? Conversation.fromJson(json['conversation'])
        : null;
    final dynamic rows = json['data'] ?? json['messages'];
    if (rows is List) {
      messages = <Message>[];
      for (final dynamic v in rows) {
        messages!.add(Message.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['status'] = status;
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Message {
  int? id;
  int? conversationId;
  int? senderId;
  String? message;
  List<String>? filesFullUrl;
  int? isSeen;
  String? createdAt;
  String? updatedAt;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    this.message,
    this.filesFullUrl,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    message = json['message'];
    filesFullUrl = json['file_full_url'].cast<String>();
    isSeen = json['is_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['file_full_url'] = filesFullUrl;
    data['is_seen'] = isSeen;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
