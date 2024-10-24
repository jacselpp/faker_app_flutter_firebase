import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart' hide Job;
import 'package:faker_app_flutter_firebase/src/data/firestore_repository.dart';
import 'package:faker_app_flutter_firebase/src/data/job.dart';
import 'package:faker_app_flutter_firebase/src/routing/app_router.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs'), actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => context.goNamed(AppRoute.profile.name),
        )
      ]),
      body: JobsListView(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final user = ref.read(firebaseAuthProvider).currentUser;
          final faker = Faker();
          final title = faker.job.title();
          final company = faker.company.name();

          ref
              .read(firestoreRepositoryProvider)
              .addJob(user!.uid, title, company);
        },
      ),
    );
  }
}

class JobsListView extends ConsumerWidget {
  const JobsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreRepository = ref.read(firestoreRepositoryProvider);
    final user = ref.read(firebaseAuthProvider).currentUser;
    return FirestoreListView<Job>(
      query: firestoreRepository.jobsQuery(user!.uid),
      pageSize: 10,
      errorBuilder: (context, error, st) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(error.toString())),
      ),
      emptyBuilder: (context) => const Center(child: Text('No jobs found')),
      itemBuilder: (BuildContext context, QueryDocumentSnapshot<Job> doc) {
        final job = doc.data();
        return Dismissible(
          key: ValueKey(doc.id),
          background: ColoredBox(color: Colors.red),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            ref.read(firestoreRepositoryProvider).deleteJob(user.uid, doc.id);
          },
          child: ListTile(
            title: Text(job.title),
            subtitle: Text(job.company),
            trailing: job.createdAt != null
                ? Text(job.createdAt.toString(),
                    style: Theme.of(context).textTheme.bodySmall)
                : null,
            onTap: () {
              final user = ref.read(firebaseAuthProvider).currentUser;
              final faker = Faker();
              final title = faker.job.title();
              final company = faker.company.name();

              ref
                  .read(firestoreRepositoryProvider)
                  .updateJob(user!.uid, doc.id, title, company);
            },
          ),
        );
      },
    );
  }
}
