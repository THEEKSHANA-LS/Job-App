import 'package:flutter/material.dart';
import 'package:mobile_app/models/saved_job_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/saved_job_provider.dart';
import 'package:mobile_app/screens/jobseeker/job_detail_screen.dart';
import 'package:provider/provider.dart';

class SavedJobScreen extends StatefulWidget {
  const SavedJobScreen({super.key});

  @override
  State<SavedJobScreen> createState() => _SavedJobScreenState();
}

class _SavedJobScreenState extends State<SavedJobScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final token =
          context.read<AuthProvider>().user?.token ?? "";

      context.read<SavedJobProvider>().fetchSavedJobs(token);
    });
  }

  Future<void> _refresh() async {
    final token =
        context.read<AuthProvider>().user?.token ?? "";

    await context.read<SavedJobProvider>().fetchSavedJobs(token);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Jobs"),
      ),

      body: Consumer<SavedJobProvider>(
        builder: (context, provider, child) {

          /// Loading
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// Error
          if (provider.errorMessage != null) {
            return Center(
              child: Text(provider.errorMessage!),
            );
          }

          /// Empty
          if (provider.savedJobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 250),
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "No saved jobs",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          /// List
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: provider.savedJobs.length,
              itemBuilder: (context, index) {

                SavedJobModel savedJob =
                    provider.savedJobs[index];

                final job = savedJob.job;

                if (job == null) {
                  return const SizedBox();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 2,

                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(
                        Icons.work,
                        color: Colors.blue,
                      ),
                    ),

                    title: Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 4),

                        Text(
                          job.location,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Rs. ${job.salary}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),

                      onPressed: () async {

                        final token =
                            context.read<AuthProvider>().user?.token ?? "";

                        bool success =
                            await provider.removeSavedJob(
                          token: token,
                          savedJobId: savedJob.id,
                          jobId: job.id,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? "Removed from saved jobs"
                                  : "Failed to remove job",
                            ),
                          ),
                        );
                      },
                    ),

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JobDetailScreen(
                                job: job,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}