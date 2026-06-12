enum HomeFilterStatusTier { replaceSoon, replaceRecommended, normal, fresh }

class HomeFilterStatus {
  const HomeFilterStatus({required this.tier, required this.label});

  final HomeFilterStatusTier tier;
  final String label;

  static const freshDefault = HomeFilterStatus(
    tier: HomeFilterStatusTier.fresh,
    label: '새거',
  );
}
