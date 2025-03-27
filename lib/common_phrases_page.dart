import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';

enum SnackBarType { success, error, info }

class CommonPhrase {
  final String id;
  String text;

  CommonPhrase({required this.id, required this.text});

  factory CommonPhrase.fromJson(Map<String, dynamic> json) {
    return CommonPhrase(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJsonForEdit() {
    return {
      'id': id,
      'text': text,
    };
  }

  Map<String, dynamic> toJsonForAdd() {
    return {
      'text': text,
    };
  }
}

class CommonPhrasesPage extends StatefulWidget {
  // If userId is needed for fetching, pass it here
  final String? userId; // Example: Assuming userId is passed to this page

  const CommonPhrasesPage({required this.userId, super.key});

  @override
  State<CommonPhrasesPage> createState() => _CommonPhrasesPageState();
}

class _CommonPhrasesPageState extends State<CommonPhrasesPage> {
  final dio = DioClient().dio; // Get the Dio instance
  List<CommonPhrase> _commonPhrases = []; // Use the CommonPhrase model
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCommonPhrases(); // Fetch data when the page loads
  }

  // --- API Call Methods ---

  Future<void> _fetchCommonPhrases() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null; // Clear previous errors
    });

    try {
      // *** IMPORTANT: Endpoint Confirmation ***
      // The user provided '/job/list GET userId'. This seems unusual for common phrases.
      // Assuming the correct endpoint is '/commonPhrases/list' and it takes 'userId' as a query parameter.
      // If '/job/list' is truly the endpoint, replace the path below.
      final response = await dio.get(
        '/commonPhrases/list', // Or '/job/list' if that's correct
        queryParameters: {
          'userId': widget.userId
        }, // Pass userId as query param
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> dataList = response.data['data'] ?? [];

        setState(() {
          _commonPhrases = dataList
              .map(
                  (json) => CommonPhrase.fromJson(json as Map<String, dynamic>))
              .toList();
          _error = null; // Clear error on success
        });
      } else {
        // Handle non-200 status codes or null data
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load phrases: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio specific errors (network, timeout, status code)
      print("DioError fetching phrases: $e");
      setState(() {
        _error = "Error fetching phrases: ${e.message}";
        // You might want more specific error handling based on e.response?.statusCode
      });
    } catch (e) {
      // Handle other potential errors (e.g., parsing errors)
      print("Error fetching phrases: $e");
      setState(() {
        _error = "An unexpected error occurred.";
      });
    } finally {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addPhraseApi(String text) async {
    if (text.isEmpty) {
      _showSnackBar('Phrase cannot be empty.');
      return;
    }
    // Show loading indicator maybe? (Optional)
    // setState(() => _isLoading = true); // Consider a separate loading state for add/edit

    try {
      // Prepare data according to CommonPhrasesBO for add
      // Assuming 'add' only needs 'text'. Add 'userId' if needed by backend.
      final data = {'text': text, 'id': widget.userId};
      // If userId is needed in the body:
      // final data = {'text': text, 'userId': widget.userId};

      final response = await dio.post(
        '/commonPhrases/add',
        data: data, // Send data as request body
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check for success status
        _showSnackBar('Phrase added successfully!');
        _fetchCommonPhrases();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to add phrase: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print("DioError adding phrase: $e");
      _showSnackBar("Error adding phrase: ${e.message}");
    } catch (e) {
      print("Error adding phrase: $e");
      _showSnackBar("An unexpected error occurred while adding.");
    } finally {
      // setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  Future<void> _editPhraseApi(CommonPhrase phrase, String newText) async {
    if (newText.isEmpty) {
      _showSnackBar('Phrase cannot be empty.');
      return;
    }
    if (phrase.text == newText) {
      _showSnackBar('No changes made.');
      return; // No need to call API if text hasn't changed
    }
    // Show loading indicator maybe?

    try {
      // Prepare data according to CommonPhrasesBO for edit
      final data = {
        'id': phrase.id,
        'text': newText,
      };

      final response = await dio.post(
        '/commonPhrases/edit',
        data: data,
      );

      if (response.statusCode == 200) {
        // Check for success status
        _showSnackBar('Phrase updated successfully!');
        _fetchCommonPhrases(); // Refresh the list
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to edit phrase: Status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print("DioError editing phrase: $e");
      _showSnackBar("Error editing phrase: ${e.message}");
    } catch (e) {
      print("Error editing phrase: $e");
      _showSnackBar("An unexpected error occurred while editing.");
    } finally {
      // Hide loading indicator
    }
  }



  void _showSnackBar(String message, {SnackBarType type = SnackBarType.info}) { // Default to info
    if (!mounted) return; // Check if the widget is still mounted

    Color backgroundColor;
    IconData? iconData; // Optional icon

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green[600]!; // Use a slightly darker green
        iconData = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red[700]!; // Use a slightly darker red
        iconData = Icons.error_outline;
        break;
      case SnackBarType.info:
      default:
      // Use default SnackBar colors or a neutral one
        backgroundColor = Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]! // Dark theme neutral
            : Colors.black87;   // Light theme neutral (default SnackBar like)
        iconData = Icons.info_outline; // Optional info icon
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row( // Use a Row to include an icon
          children: [
            if (iconData != null) ...[ // Conditionally add icon
              Icon(iconData, color: Colors.white),
              const SizedBox(width: 8), // Spacing between icon and text
            ],
            Expanded( // Allow text to wrap
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating, // Makes it float, often looks nicer
        margin: const EdgeInsets.all(10), // Add margin when floating
        shape: RoundedRectangleBorder( // Optional: Rounded corners
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3), // Adjust duration as needed
      ),
    );
  }

  // --- Dialog Methods ---

  void _showAddPhraseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String newPhraseText = '';
        final controller = TextEditingController(); // Use a controller

        return AlertDialog(
          title: const Text('添加常用语'),
          content: TextField(
            controller: controller,
            onChanged: (value) => newPhraseText = value,
            // Still useful if needed elsewhere
            decoration: const InputDecoration(hintText: '输入常用语'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog first
                _addPhraseApi(controller.text.trim()); // Call API
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPhraseDialog(CommonPhrase phrase) {
    // Pass the whole object
    showDialog(
      context: context,
      builder: (context) {
        // Use a controller initialized with the current text
        final controller = TextEditingController(text: phrase.text);
        // Keep track of changes separately if needed, but controller.text is usually enough
        // String editedPhraseText = phrase.text;

        return AlertDialog(
          title: const Text('编辑常用语'),
          content: TextField(
            controller: controller,
            // onChanged: (value) => editedPhraseText = value, // Update tracked variable if needed
            decoration: const InputDecoration(hintText: '输入常用语'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog first
                _editPhraseApi(phrase,
                    controller.text.trim()); // Call API with ID and new text
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('常用语'),
        actions: [
          // Add a refresh button for manual refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : _fetchCommonPhrases, // Disable while loading
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(), // Use a helper method for the body content
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              // Disable button while loading
              onPressed: _isLoading ? null : _showAddPhraseDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Make button wider
              ),
              child: _isLoading
                  ? const SizedBox(
                      // Show small indicator inside button when loading
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('添加常用语'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the main body content based on state
  Widget _buildBody() {
    if (_isLoading && _commonPhrases.isEmpty) {
      // Show loading only on initial load
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_commonPhrases.isEmpty) {
      return const Center(child: Text('没有常用语，请添加。'));
    } else {
      // Use RefreshIndicator for pull-to-refresh functionality
      return RefreshIndicator(
        onRefresh: _fetchCommonPhrases,
        child: ListView.builder(
          itemCount: _commonPhrases.length,
          itemBuilder: (context, index) {
            final phrase = _commonPhrases[index];
            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(phrase.text),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: '编辑',
                  // Disable edit button while loading to prevent conflicts
                  onPressed:
                      _isLoading ? null : () => _showEditPhraseDialog(phrase),
                ),
                // Optional: Add onTap for quick selection/copy
                // onTap: () { /* Handle phrase selection */ },
              ),
            );
          },
        ),
      );
    }
  }
}
