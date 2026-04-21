import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/about_content_model.dart';
import 'provider/about_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Usss'),
      ),
      body: Consumer<AboutProvider>(
        builder: (context, provider, _) {
          if (!provider.isLoading && provider.content == null && provider.error == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.read<AboutProvider>().loadAbout();
            });
          }

          if (provider.isLoading && provider.content == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.content == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: provider.retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final content = provider.content;
          if (content == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _AboutHeader(content: content),
              const SizedBox(height: 16),
              _StorySection(story: content.story),
              const SizedBox(height: 16),
              _HighlightsSection(highlights: content.highlights),
              const SizedBox(height: 16),
              _StatsSection(stats: content.stats),
              const SizedBox(height: 16),
              _ContactSection(content: content),
            ],
          );
        },
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.content});

  final AboutContent content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.heading, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(content.subheading, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _StorySection extends StatelessWidget {
  const _StorySection({required this.story});

  final String story;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our Story', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(story, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.highlights});

  final List<AboutHighlight> highlights;

  IconData _iconForName(String iconName) {
    switch (iconName) {
      case 'verified':
        return Icons.verified_user_outlined;
      case 'shipping':
        return Icons.local_shipping_outlined;
      case 'support':
        return Icons.support_agent_outlined;
      default:
        return Icons.star_border_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What We Value', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...highlights.map(
              (highlight) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_iconForName(highlight.iconName)),
                title: Text(highlight.title),
                subtitle: Text(highlight.description),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final List<AboutStat> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By The Numbers', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: stats
                  .map(
                    (stat) => Chip(
                      label: Text('${stat.label}: ${stat.value}'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.content});

  final AboutContent content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Email: ${content.email}'),
            const SizedBox(height: 4),
            Text('Phone: ${content.phone}'),
            const SizedBox(height: 4),
            Text('Address: ${content.address}'),
          ],
        ),
      ),
    );
  }
}
