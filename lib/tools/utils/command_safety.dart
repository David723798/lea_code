class BashCommandAssessment {
  const BashCommandAssessment({
    required this.requiresApproval,
    required this.reason,
  });

  final bool requiresApproval;
  final String? reason;
}

const List<String> _readOnlyPrefixes = <String>[
  'cat ',
  'cd ',
  'find ',
  'git diff',
  'git log',
  'git show',
  'git status',
  'grep ',
  'head ',
  'ls',
  'pwd',
  'rg ',
  'sed -n',
  'tail ',
  'wc ',
  'which ',
];

const List<String> _mutatingTokens = <String>[
  ' >',
  '>>',
  ' chmod ',
  ' chown ',
  ' cp ',
  ' git add',
  ' git checkout',
  ' git clean',
  ' git commit',
  ' git push',
  ' git reset',
  ' git restore',
  ' mkdir ',
  ' mv ',
  ' rm ',
  ' sed -i',
  ' tee ',
  ' touch ',
];

const List<String> _networkTokens = <String>[
  ' apt ',
  ' brew ',
  ' cargo install',
  ' curl ',
  ' git clone',
  ' git fetch',
  ' git pull',
  ' npm install',
  ' pip install',
  ' pnpm add',
  ' pnpm install',
  ' scp ',
  ' ssh ',
  ' wget ',
  ' yarn add',
  ' yarn install',
];

BashCommandAssessment assessBashCommand(String command) {
  final normalized = ' ${command.trim().replaceAll(RegExp(r'\s+'), ' ')} ';
  if (normalized.trim().isEmpty) {
    return const BashCommandAssessment(
      requiresApproval: false,
      reason: null,
    );
  }

  for (final token in _networkTokens) {
    if (normalized.contains(token)) {
      return const BashCommandAssessment(
        requiresApproval: true,
        reason: 'This command may access the network.',
      );
    }
  }

  for (final token in _mutatingTokens) {
    if (normalized.contains(token)) {
      return const BashCommandAssessment(
        requiresApproval: true,
        reason: 'This command may modify files or repository state.',
      );
    }
  }

  if (normalized.contains('&&') || normalized.contains('||')) {
    return const BashCommandAssessment(
      requiresApproval: true,
      reason: 'Compound commands require approval.',
    );
  }

  for (final prefix in _readOnlyPrefixes) {
    if (normalized.trim() == prefix.trim() || normalized.trim().startsWith(prefix.trim())) {
      return const BashCommandAssessment(
        requiresApproval: false,
        reason: null,
      );
    }
  }

  return const BashCommandAssessment(
    requiresApproval: true,
    reason: 'This command is not recognized as read-only.',
  );
}
