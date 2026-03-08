import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sajilofix/features/report/domain/entities/issue_report.dart';
import 'package:sajilofix/features/report/domain/repositories/report_repository.dart';
import 'package:sajilofix/features/report/domain/usecases/submit_report_usecase.dart';

class _FakeReportRepository implements ReportRepository {
  CreateIssueReportInput? lastSubmitInput;
  IssueReport? submitResult;
  Object? submitError;

  @override
  Future<IssueReport> submitReport(CreateIssueReportInput input) async {
    if (submitError != null) throw submitError!;
    lastSubmitInput = input;
    return submitResult!;
  }

  @override
  Future<void> deleteIssue(String id) => throw UnimplementedError();

  @override
  Future<IssueReport> getIssueById(String id) => throw UnimplementedError();

  @override
  Future<List<IssueReport>> listAllReports() => throw UnimplementedError();

  @override
  Future<List<IssueReport>> listMyReports() => throw UnimplementedError();

  @override
  Future<List<IssueReport>> listReports() => throw UnimplementedError();

  @override
  Future<String> updateIssueStatus({
    required String id,
    required String status,
  }) => throw UnimplementedError();
}

IssueReport _sampleReport() {
  return const IssueReport(
    id: 'r-1',
    category: 'Road Issue',
    title: 'Pothole on main road',
    description: 'Large pothole near market area',
    urgency: 'HIGH',
    status: 'PENDING',
    location: IssueLocation(
      address: 'Main Street',
      district: 'Kathmandu',
      municipality: 'Kathmandu Metro',
      ward: '10',
      landmark: 'City Mall',
      latitude: 27.7,
      longitude: 85.3,
    ),
    photos: ['photo1.jpg'],
  );
}

CreateIssueReportInput _sampleInput() {
  return CreateIssueReportInput(
    category: 'ROAD',
    title: 'Broken road',
    description: 'Cracked road section',
    urgency: 'MEDIUM',
    location: const IssueLocation(
      address: 'Baneshwor',
      district: 'Kathmandu',
      municipality: 'KMC',
      ward: '31',
      landmark: 'Near Chowk',
      latitude: 27.69,
      longitude: 85.34,
    ),
    photos: [XFile('/tmp/fake-image.jpg')],
  );
}

void main() {
  test('SubmitReportUseCase forwards input to repository', () async {
    final repo = _FakeReportRepository()..submitResult = _sampleReport();
    final useCase = SubmitReportUseCase(repo);
    final input = _sampleInput();

    await useCase(input);

    expect(identical(repo.lastSubmitInput, input), isTrue);
  });

  test('SubmitReportUseCase returns repository report', () async {
    final expected = _sampleReport();
    final repo = _FakeReportRepository()..submitResult = expected;
    final useCase = SubmitReportUseCase(repo);

    final result = await useCase(_sampleInput());

    expect(identical(result, expected), isTrue);
  });

  test('SubmitReportUseCase propagates repository exception', () async {
    final repo = _FakeReportRepository()
      ..submitError = StateError('submit-failed');
    final useCase = SubmitReportUseCase(repo);

    await expectLater(
      () => useCase(_sampleInput()),
      throwsA(isA<StateError>()),
    );
  });
}
