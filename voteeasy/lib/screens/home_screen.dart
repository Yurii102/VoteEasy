// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../core/services/analytics_service.dart';
import '../core/services/user_preferences_service.dart';
import '../core/repositories/auth_repository.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/widgets/poll_card.dart';
import '../core/bloc/polls/polls_bloc.dart';
import '../core/bloc/polls/polls_event.dart';
import '../core/models/poll.dart';
import 'profile_screen.dart';
import 'poll_details_screen.dart';
import 'poll_results_screen.dart';
import 'create_poll_screen.dart';
import '../core/bloc/polls/polls_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PollsBloc()..add(const LoadPollsEvent()),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  static const String _userName = 'Yurii Surniak';
  
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  final UserPreferencesService _prefsService = UserPreferencesService();
  final AuthRepository _authRepository = AuthRepository();
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView(
      screenName: 'home_screen',
      screenClass: 'HomeScreen',
    );
    _searchController.addListener(_onSearchChanged);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final lastFilter = await _prefsService.getLastFilter();
    final searchHistory = await _prefsService.getSearchHistory();
    
    setState(() {
      _selectedFilter = lastFilter;
      _searchHistory = searchHistory;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _saveSearchQuery(String query) async {
    if (query.trim().isNotEmpty) {
      await _prefsService.addSearchQuery(query);
      final updatedHistory = await _prefsService.getSearchHistory();
      setState(() {
        _searchHistory = updatedHistory;
      });
    }
  }

  List<Poll> _getFilteredPolls(List<Poll> polls) {
    List<Poll> filtered = polls;
    
    // Apply filter
    if (_selectedFilter != 'All') {
      final currentUser = _authRepository.currentUser;
      
      filtered = filtered.where((poll) {
        switch (_selectedFilter) {
          case 'Open':
            return !poll.isPrivate;
          
          case 'Closed':
            return poll.isPrivate;
          
          case 'Mine':
            return currentUser != null && poll.authorId == currentUser.uid;
          
          default:
            return true;
        }
      }).toList();
    }
    
    // Apply search
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((poll) {
        final id = poll.id.toLowerCase();
        final question = poll.question.toLowerCase();
        final author = poll.author.toLowerCase();
        
        return id.contains(searchQuery) ||
               question.contains(searchQuery) ||
               author.contains(searchQuery);
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _analyticsService.logEvent(
            name: 'create_poll_button_pressed',
            parameters: {
              'screen': 'home_screen',
            },
          );
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePollScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Poll',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<PollsBloc, PollsState>(
        builder: (context, state) {
          final filteredPolls = _getFilteredPolls(state.data);
          
          return SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.poll,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'VoteEasy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications'),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      context.read<PollsBloc>().add(const TestErrorEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bug_report,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      FirebaseCrashlytics.instance.crash();
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _userName.substring(0, 1),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onSubmitted: (value) => _saveSearchQuery(value),
                          decoration: InputDecoration(
                            hintText: 'Search by ID or poll title...',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _searchHistory.isNotEmpty
                                ? PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.history,
                                      color: AppColors.textSecondary,
                                    ),
                                    tooltip: 'Search history',
                                    onSelected: (value) {
                                      _searchController.text = value;
                                      _saveSearchQuery(value);
                                    },
                                    itemBuilder: (context) => [
                                      ..._searchHistory.map(
                                        (query) => PopupMenuItem(
                                          value: query,
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.history,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(query),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                ),
                                                onPressed: () {
                                                  _prefsService.removeSearchQuery(query);
                                                  Navigator.pop(context);
                                                  _loadPreferences();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      PopupMenuItem(
                                        onTap: () async {
                                          await _prefsService.clearSearchHistory();
                                          _loadPreferences();
                                        },
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: AppColors.error,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Clear history',
                                              style: TextStyle(color: AppColors.error),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Open'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Closed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Mine'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Available Polls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      filteredPolls.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildPollsList(context, state, filteredPolls),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildPollsList(BuildContext context, PollsState state, List<Poll> filteredPolls) {

    if (state is PollsLoadingState && state.data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Loading polls...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show error message
    if (state is PollsErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PollsBloc>().add(const RefreshPollsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (filteredPolls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No polls found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show polls list
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PollsBloc>().add(const RefreshPollsEvent());
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.primary,
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredPolls.length,
        itemBuilder: (context, index) {
          final poll = filteredPolls[index];
          final pollMap = poll.toMap();
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PollDetailsScreen(
                    pollId: poll.id,
                    pollData: pollMap, // deprecated
                  ),
                ),
              );
            },
            child: PollCard(
              pollId: poll.id,
              question: poll.question,
              author: poll.author,
              timeAgo: poll.timeAgo,
              votes: poll.votes,
              status: poll.status,
              onActionPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PollDetailsScreen(
                      pollId: poll.id,
                      pollData: pollMap, // deprecated
                    ),
                  ),
                );
              },
              onResultsPressed: () {
                _analyticsService.logPollResultsViewed(
                  pollId: poll.id,
                );
                
                // Підготовка реальних даних опцій з votesCount
                final pollOptions = poll.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final optionText = entry.value;
                  final votes = poll.votesCount['$index'] ?? 0;
                  
                  return {
                    'id': index,
                    'text': optionText,
                    'votes': votes,
                  };
                }).toList();
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PollResultsScreen(
                      pollData: pollMap,
                      pollOptions: pollOptions,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedFilter = label;
        });
        
        await _prefsService.saveLastFilter(label);
        
        _analyticsService.logEvent(
          name: 'filter_changed',
          parameters: {
            'filter_type': label.toLowerCase(),
            'screen': 'home_screen',
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
