// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localTaskDataSourceHash() =>
    r'3fe6a2ca544a866ca618d28a327b5013531f902f';

/// Provider for LocalTaskDataSource.
///
/// Copied from [localTaskDataSource].
@ProviderFor(localTaskDataSource)
final localTaskDataSourceProvider =
    AutoDisposeProvider<LocalTaskDataSource>.internal(
  localTaskDataSource,
  name: r'localTaskDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localTaskDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LocalTaskDataSourceRef = AutoDisposeProviderRef<LocalTaskDataSource>;
String _$taskRepositoryHash() => r'3631e5d4acc3ea0e8ad62ea64b5718d4fe20f328';

/// Provider for TaskRepository.
///
/// Copied from [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$taskListHash() => r'54a76754c358a8fa5a66fece9fec99a06d1848fe';

/// Provider for all tasks.
/// Automatically refreshes when tasks are modified.
///
/// Copied from [TaskList].
@ProviderFor(TaskList)
final taskListProvider =
    AutoDisposeAsyncNotifierProvider<TaskList, List<Task>>.internal(
  TaskList.new,
  name: r'taskListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskList = AutoDisposeAsyncNotifier<List<Task>>;
String _$taskSearchHash() => r'c5ae372d004d8ee5d3cd7d8bd05e1e9e8a841548';

/// Provider for searching tasks.
///
/// Copied from [TaskSearch].
@ProviderFor(TaskSearch)
final taskSearchProvider =
    AutoDisposeAsyncNotifierProvider<TaskSearch, List<Task>>.internal(
  TaskSearch.new,
  name: r'taskSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskSearch = AutoDisposeAsyncNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
