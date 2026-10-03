class ServiceFaqModel {
  int? totalSize;
  List<ServiceFaq>? faqs;

  ServiceFaqModel({this.totalSize, this.faqs});

  ServiceFaqModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    if (json['faqs'] != null) {
      faqs = <ServiceFaq>[];
      json['faqs'].forEach((v) {
        faqs!.add(ServiceFaq.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceFaq {
  int? id;
  String? question;
  String? answer;
  int? status;

  ServiceFaq({this.id, this.question, this.answer, this.status});

  ServiceFaq.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    answer = json['answer'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer, 'status': status};
  }
}
