// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../core/services/analytics_service.dart';
import '../core/bloc/create_poll/create_poll_bloc.dart';
import '../core/bloc/create_poll/create_poll_event.dart';
import '../core/bloc/create_poll/create_poll_state.dart';

class CreatePollScreen extends StatelessWidget {
  const CreatePollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePollBloc(),
      child: const _CreatePollScreenContent(),
    );
  }
}

class _CreatePollScreenContent extends StatefulWidget {
  const _CreatePollScreenContent();

  @override
  State<_CreatePollScreenContent> createState() => _CreatePollScreenContentState();
}

class _CreatePollScreenContentState extends State<_CreatePollScreenContent> {
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String _selectedCategory = 'General';
  String _selectedDuration = '7 days';
  bool _allowMultipleVotes = false;
  bool _showResultsBeforeEnd = true;
  bool _isPrivate = false;
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _categories = [
    'General',
    'Technology',
    'Entertainment',
    'Sports',
    'Politics',
    'Science',
    'Education',
    'Other',
  ];

  final List<String> _durations = [
    '1 day',
    '3 days',
    '7 days',
    '14 days',
    '30 days',
    'No limit',
  ];

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView(
      screenName: 'create_poll_screen',
      screenClass: 'CreatePollScreen',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 options allowed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 2 options required'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCreatePoll() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if at least 2 options have text
    final filledOptions = _optionControllers
        .where((controller) => controller.text.trim().isNotEmpty)
        .toList();

    if (filledOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least 2 options'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Підготовка даних
    final options = filledOptions
        .map((controller) => controller.text.trim())
        .toList();

    // Конвертація тривалості в дні
    int durationDays = 0;
    switch (_selectedDuration) {
      case '1 day':
        durationDays = 1;
        break;
      case '3 days':
        durationDays = 3;
        break;
      case '7 days':
        durationDays = 7;
        break;
      case '14 days':
        durationDays = 14;
        break;
      case '30 days':
        durationDays = 30;
        break;
      case 'No limit':
        durationDays = 0; // 0 = без обмеження
        break;
    }

    // Відправка події в BLoC
    context.read<CreatePollBloc>().add(
          CreatePollSubmitted(
            question: _questionController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            options: options,
            category: _selectedCategory,
            durationDays: durationDays,
            allowMultipleVotes: _allowMultipleVotes,
            showResultsBeforeEnd: _showResultsBeforeEnd,
            isPrivate: _isPrivate,
            password: _isPrivate ? _passwordController.text.trim() : null,
          ),
        );

    // Analytics
    _analyticsService.logEvent(
      name: 'poll_creation_attempted',
      parameters: {
        'question_length': _questionController.text.length.toString(),
        'options_count': options.length.toString(),
        'category': _selectedCategory,
        'duration': _selectedDuration,
        'allow_multiple_votes': _allowMultipleVotes.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePollBloc, CreatePollState>(
      listener: (context, state) {
        if (state is PollCreateSuccess) {
          // Analytics
          _analyticsService.logEvent(
            name: 'poll_created',
            parameters: {
              'poll_id': state.poll.id,
              'question': state.poll.question,
              'options_count': state.poll.options.length.toString(),
              'category': state.poll.category,
            },
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poll created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Reset form
          context.read<CreatePollBloc>().add(const CreatePollReset());

          // Navigate back
          Navigator.pop(context);
        } else if (state is PollCreateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Create New Poll',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<CreatePollBloc, CreatePollState>(
              builder: (context, state) {
                final isLoading = state is PollCreating;
                return TextButton(
                  onPressed: isLoading ? null : _handleCreatePoll,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Section
                  const Text(
                  'Poll Question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'What would you like to ask?',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a question';
                      }
                      if (value.trim().length < 10) {
                        return 'Question must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Description Section (Optional)
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add more details about your poll...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Options Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Poll Options',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Option'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Options List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _optionControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                hintStyle: TextStyle(
                                  color: AppColors.textHint,
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (index < 2 &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.error,
                              ),
                              onPressed: () => _removeOption(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Settings Section
                const Text(
                  'Poll Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Category Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),

                // Duration Dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                    items: _durations
                        .map((duration) => DropdownMenuItem(
                              value: duration,
                              child: Text(duration),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Switch Options
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text(
                          'Allow multiple votes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Users can select multiple options',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _allowMultipleVotes,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _allowMultipleVotes = value;
                          });
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text(
                          'Show results before poll ends',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Users can see results while voting',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _showResultsBeforeEnd,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _showResultsBeforeEnd = value;
                          });
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text(
                          'Private Poll',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'Require password to vote',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: _isPrivate,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value;
                            if (!value) {
                              _passwordController.clear();
                            }
                          });
                        },
                      ),
                      if (_isPrivate) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Poll Password',
                            hintText: 'Enter password for private poll',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (_isPrivate && (value == null || value.trim().isEmpty)) {
                              return 'Password is required for private polls';
                            }
                            if (_isPrivate && value!.length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
