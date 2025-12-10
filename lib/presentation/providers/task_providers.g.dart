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
String _$completedTasksCountHash() =>
    r'6d375bc336bc6afb5276f90573958f548b09133d';

/// Provider for completed tasks count.
///
/// Copied from [completedTasksCount].
@ProviderFor(completedTasksCount)
final completedTasksCountProvider = AutoDisposeFutureProvider<int>.internal(
  completedTasksCount,
  name: r'completedTasksCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedTasksCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CompletedTasksCountRef = AutoDisposeFutureProviderRef<int>;
String _$allTasksHash() => r'699aca699249c2072ba4802104b3566cf80b84b1';

/// Provider for all tasks (including completed) - used for search.
///
/// Copied from [allTasks].
@ProviderFor(allTasks)
final allTasksProvider = AutoDisposeFutureProvider<List<Task>>.internal(
  allTasks,
  name: r'allTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllTasksRef = AutoDisposeFutureProviderRef<List<Task>>;
String _$taskListHash() => r'4f0ba930090e86aa11a14726390ad4117d3f40fe';

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
String _$taskSearchHash() => r'24662492665a973ce6b26736a1e0ef86de2c84d1';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, inference_failure_on_uninitialized_variable, inference_failure_on_function_return_type, inference_failure_on_untyped_parameter, deprecated_member_use_from_same_package
