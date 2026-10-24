import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_button_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:sixam_mart_store/common/widgets/rating_bar_widget.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/controllers/service_review_controller.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/models/service_review_model.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceReviewReplyScreen extends StatefulWidget {
  final bool isGiveReply;
  final ServiceReviewModel review;
  final bool? storeReviewReplyStatus;
  const ServiceReviewReplyScreen({super.key, required this.isGiveReply, required this.review, this.storeReviewReplyStatus = false});

  @override
  State<ServiceReviewReplyScreen> createState() => _ServiceReviewReplyScreenState();
}

class _ServiceReviewReplyScreenState extends State<ServiceReviewReplyScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
