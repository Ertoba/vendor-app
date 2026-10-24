import 'package:sixam_mart_store/common/widgets/rating_bar_widget.dart';
import 'package:sixam_mart_store/features/service_module/service_reviews/domain/models/service_review_model.dart';
import 'package:sixam_mart_store/helper/date_converter_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceReviewWidget extends StatelessWidget {
  final ServiceReviewModel review;
  const ServiceReviewWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text(
          review.customer != null ? review.customerName : 'customer_not_found'.tr,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        RatingBarWidget(rating: review.rating!.toDouble(), ratingCount: null),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(DateConverterHelper.convertDateToDate(review.createdAt!), style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(
          review.comment ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7), fontSize: Dimensions.fontSizeSmall),
        ),

      ]),
    );
  }
}
