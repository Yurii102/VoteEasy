// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_colors.dart';
import '../core/services/analytics_service.dart';
import '../core/bloc/update_poll/update_poll_bloc.dart';
import '../core/bloc/update_poll/update_poll_event.dart';
import '../core/bloc/update_poll/update_poll_state.dart';
import '../core/models/poll.dart';

class EditPollScreen extends StatelessWidget {
  final Poll poll;

  const EditPollScreen({
    super.key,
    required this.poll,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UpdatePollBloc(),
      child: _EditPollScreenContent(poll: poll),
    );
  }
}

class _EditPollScreenContent extends StatefulWidget {
  final Poll poll;

  const _EditPollScreenContent({required this.poll});

  @override
  State<_EditPollScreenContent> createState() => _EditPollScreenContentState();
}

class _EditPollScreenContentState extends State<_EditPollScreenContent> {
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _optionControllers;

  late String _selectedCategory;
  late bool _allowMultipleVotes;
  late bool _showResultsBeforeEnd;
  late bool _isPrivate;
  late TextEditingController _passwordController;

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

  @override
  void initState() {
    super.initState();
    
    // Ініціалізація контролерів з існуючими даними
    _questionController = TextEditingController(text: widget.poll.question);
    _descriptionController = TextEditingController(text: widget.poll.description ?? '');
    _optionControllers = widget.poll.options
        .map((option) => TextEditingController(text: option))
        .toList();

    _selectedCategory = widget.poll.category;
    _allowMultipleVotes = widget.poll.allowMultipleVotes;
    _showResultsBeforeEnd = widget.poll.showResultsBeforeEnd;
    _isPrivate = widget.poll.isPrivate;
    _passwordController = TextEditingController(text: widget.poll.password ?? '');

    _analyticsService.logScreenView(
      screenName: 'edit_poll_screen',
      screenClass: 'EditPollScreen',
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

  void _handleUpdatePoll() {
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

    // Відправка події в BLoC
    context.read<UpdatePollBloc>().add(
          UpdatePollSubmitted(
            pollId: widget.poll.id,
            question: _questionController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            options: options,
            category: _selectedCategory,
            allowMultipleVotes: _allowMultipleVotes,
            showResultsBeforeEnd: _showResultsBeforeEnd,
            isPrivate: _isPrivate,
            password: _isPrivate ? _passwordController.text.trim() : null,
          ),
        );

    // Analytics
    _analyticsService.logEvent(
      name: 'poll_update_attempted',
      parameters: {
        'poll_id': widget.poll.id,
        'options_count': options.length.toString(),
        'category': _selectedCategory,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdatePollBloc, UpdatePollState>(
      listener: (context, state) {
        if (state is PollUpdateSuccess) {
          // Analytics
          _analyticsService.logEvent(
            name: 'poll_updated',
            parameters: {
              'poll_id': state.poll.id,
              'question': state.poll.question,
              'options_count': state.poll.options.length.toString(),
              'category': state.poll.category,
            },
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poll updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Reset form
          context.read<UpdatePollBloc>().add(const UpdatePollReset());

          // Navigate back
          Navigator.pop(context, state.poll);
        } else if (state is PollUpdateError) {
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
            'Edit Poll',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            BlocBuilder<UpdatePollBloc, UpdatePollState>(
              builder: (context, state) {
                final isLoading = state is PollUpdating;
                return TextButton(
                  onPressed: isLoading ? null : _handleUpdatePoll,
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
                          'Save',
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
                  // Warning message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: Editing a poll with existing votes may affect the results',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question Section
                  const Text(
                    'Poll Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter your poll question...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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

                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    'Description (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add more context to your poll...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 8),

                  // Options List
                  ...List.generate(_optionControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                hintText: 'Option ${index + 1}',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(12),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.textHint,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (value.trim().length < 1) {
                                    return 'Option must not be empty';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.error,
                              onPressed: () => _removeOption(index),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Category Section
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
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

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Allow Multiple Votes'),
                          subtitle: const Text(
                            'Users can select multiple options',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _allowMultipleVotes,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _allowMultipleVotes = value;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Show Results Before End'),
                          subtitle: const Text(
                            'Display results while poll is active',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _showResultsBeforeEnd,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _showResultsBeforeEnd = value;
                            });
                          },
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Private Poll'),
                          subtitle: const Text(
                            'Require password to vote',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _isPrivate,
                          activeColor: AppColors.primary,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextFormField(
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
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
