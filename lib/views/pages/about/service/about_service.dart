import '../model/about_content_model.dart';

class AboutService {
  Future<AboutContent> getAboutContent() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const AboutContent(
      heading: 'About Us',
      subheading: 'Designed to simplify your everyday shopping',
      story:
          'Ecommerce Project started with one goal: make shopping effortless, '
          'transparent, and enjoyable. We combine curated products, secure checkout, '
          'and fast support so customers can confidently buy what they need.',
      email: 'support@ecommerceproject.app',
      phone: '+20 100 000 0000',
      address: 'Nasr City, Cairo, Egypt',
      stats: [
        AboutStat(label: 'Happy Customers', value: '12K+'),
        AboutStat(label: 'Products Listed', value: '2.4K'),
        AboutStat(label: 'Average Delivery', value: '48h'),
      ],
      highlights: [
        AboutHighlight(
          title: 'Reliable Quality',
          description:
              'We review each partner and product to maintain a consistent quality bar.',
          iconName: 'verified',
        ),
        AboutHighlight(
          title: 'Fast Fulfillment',
          description:
              'Our fulfillment workflow is optimized to keep delivery times short.',
          iconName: 'shipping',
        ),
        AboutHighlight(
          title: 'Human Support',
          description:
              'Real customer support is available to help before and after purchase.',
          iconName: 'support',
        ),
      ],
    );
  }
}
