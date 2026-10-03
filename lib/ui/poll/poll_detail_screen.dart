import 'package:flutter/material.dart';
import 'package:sasacation/l10n/app_localizations.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/poll_model.dart';
import 'package:sasacation/data/repo/poll_repository.dart';

/// F7: detail voting grup + tombol "Vote now".
/// Dibuka dari kartu "New Vote" di notifikasi (data.action poll_detail)
/// atau deep-link. Pembuatan poll baru belum ada entry UI-nya — saat ini
/// lewat API langsung (terdokumentasi di handoff backend).
class PollDetailScreen extends StatefulWidget {
  final String pollId;
  const PollDetailScreen({super.key, required this.pollId});

  @override
  State<PollDetailScreen> createState() => _PollDetailScreenState();
}

class _PollDetailScreenState extends State<PollDetailScreen> {
  final _repo = PollRepository();
  PollModel? _poll;
  bool _loading = true;
  String? _votingOptionId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final poll = await _repo.getPoll(widget.pollId);
    if (!mounted) return;
    setState(() {
      _poll = poll;
      _loading = false;
    });
  }

  Future<void> _vote(String optionId) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _votingOptionId = optionId);
    final result =
        await _repo.vote(pollId: widget.pollId, optionId: optionId);
    if (!mounted) return;
    setState(() => _votingOptionId = null);
    if (result['success'] == true) {
      setState(() => _poll = result['poll'] as PollModel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ait_pollVoted)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? l10n.ait_pollVoteFailed),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: Text(l10n.ait_pollTitle), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _poll == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.how_to_vote_outlined,
                          size: 56, color: AppTheme.outlineVariant),
                      const SizedBox(height: 12),
                      Text(l10n.ait_pollNotFound,
                          style:
                              Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: Text(l10n.common_retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_poll!.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _poll!.isOpen
                                  ? AppTheme.successColor
                                      .withOpacity(0.12)
                                  : AppTheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull),
                            ),
                            child: Text(
                              _poll!.isOpen ? l10n.ait_pollOpen : l10n.ait_pollClosed,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _poll!.isOpen
                                    ? AppTheme.successColor
                                    : AppTheme.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_poll!.description != null &&
                          _poll!.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(_poll!.description!,
                            style:
                                Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        l10n.ait_pollTotalVotes(_poll!.totalVotes),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.outline),
                      ),
                      const SizedBox(height: 16),
                      ..._poll!.options.map((o) {
                        final mine = _poll!.myOptionId == o.id;
                        final votingThis =
                            _votingOptionId == o.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(
                                AppTheme.radiusLg),
                            border: mine
                                ? Border.all(
                                    color: AppTheme.primaryContainer,
                                    width: 1.5)
                                : null,
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(o.label,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                  ),
                                  if (mine)
                                    const Icon(Icons.check_circle,
                                        size: 18,
                                        color: AppTheme.primary),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull),
                                child: LinearProgressIndicator(
                                  value: (o.pct / 100).clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor:
                                      AppTheme.surfaceContainerHigh,
                                  valueColor:
                                      const AlwaysStoppedAnimation(
                                          AppTheme.primaryContainer),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.ait_pollOptionStats(o.pct.toStringAsFixed(0), o.votes),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.outline),
                                  ),
                                  if (_poll!.isOpen)
                                    TextButton(
                                      onPressed: votingThis
                                          ? null
                                          : () => _vote(o.id),
                                      child: votingThis
                                          ? const SizedBox(
                                              height: 14,
                                              width: 14,
                                              child:
                                                  CircularProgressIndicator(
                                                      strokeWidth: 2),
                                            )
                                          : Text(mine
                                              ? l10n.ait_pollChangeVote
                                              : l10n.ait_pollVoteNow),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
