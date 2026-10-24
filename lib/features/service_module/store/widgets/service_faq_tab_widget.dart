import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/service_module/store/controllers/service_faq_controller.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_faq_model.dart';
import 'package:sixam_mart_store/features/service_module/store/widgets/service_faq_form_bottom_sheet.dart';
import 'package:sixam_mart_store/features/service_module/store/widgets/service_faq_options_bottom_sheet.dart';
import 'package:sixam_mart_store/features/service_module/store/widgets/service_faq_shimmer_widget.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';

class ServiceFaqTabWidget extends StatelessWidget {
  final int serviceId;
  const ServiceFaqTabWidget({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Column(children: [

      /// Header + Add button
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('service_faq_setup'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              'manage_the_faqs_shown_on_service_detail_page'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
            ),
          ])),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          InkWell(
            onTap: () => _openForm(context),
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add, size: 18, color: Colors.white),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text('add_faq'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      Expanded(child: GetBuilder<ServiceFaqController>(builder: (faqController) {
        if (faqController.faqList == null) {
          return const ServiceFaqShimmerWidget();
        }

        if (faqController.faqList!.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => faqController.getFaqList(serviceId),
            child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(child: Column(children: [
                Image.asset(Images.emptyBox, width: 70, height: 70),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text('no_faq_added_yet'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
              ])),
            ]),
          );
        }

        return RefreshIndicator(
          onRefresh: () => faqController.getFaqList(serviceId),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            itemCount: faqController.faqList!.length,
            separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              final ServiceFaq faq = faqController.faqList![index];
              return _FaqCard(
                faq: faq,
                onOptions: () => _openOptions(context, faq),
              );
            },
          ),
        );
      })),

    ]);
  }

  void _openForm(BuildContext context, {ServiceFaq? faq}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceFaqFormBottomSheet(serviceId: serviceId, faq: faq),
    );
  }

  void _openOptions(BuildContext context, ServiceFaq faq) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ServiceFaqOptionsBottomSheet(
        serviceId: serviceId,
        faq: faq,
        onEdit: () => _openForm(context, faq: faq),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final ServiceFaq faq;
  final VoidCallback onOptions;
  const _FaqCard({required this.faq, required this.onOptions});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final BoxShadow boxShadow = BoxShadow(color: Theme.of(context).disabledColor.withValues(alpha: 0.3), blurRadius: 10);
    final bool isActive = widget.faq.status == 1;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
        boxShadow: [boxShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        /// Question row (tap to expand/collapse)
        InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Row(children: [

              /// Status dot
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 4, right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.green : Theme.of(context).disabledColor,
                ),
              ),

              Expanded(child: Text(
                widget.faq.question ?? '',
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              )),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).disabledColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              InkWell(
                onTap: widget.onOptions,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.more_vert, size: 20, color: Theme.of(context).disabledColor),
                ),
              ),

            ]),
          ),
        ),

        /// Answer (collapsible)
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(height: Dimensions.paddingSizeSmall, color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                widget.faq.answer ?? '',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
            ]),
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),

      ]),
    );
  }
}
