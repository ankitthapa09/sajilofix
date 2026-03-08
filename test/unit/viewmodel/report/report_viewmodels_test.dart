import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sajilofix/features/report/presentation/providers/report_providers.dart';

void main() {
  test('ReportFormDraftNotifier starts with empty initial draft', () {
    final notifier = ReportFormDraftNotifier();

    expect(notifier.state.category, isNull);
    expect(notifier.state.locationTitle, isNull);
    expect(notifier.state.issueTitle, isNull);
    expect(notifier.state.urgency, isNull);
    expect(notifier.state.photos, isEmpty);
  });

  test('setCategory updates draft category', () {
    final notifier = ReportFormDraftNotifier();

    notifier.setCategory('Road Problem');

    expect(notifier.state.category, 'Road Problem');
  });

  test('setLocation updates all location fields', () {
    final notifier = ReportFormDraftNotifier();

    notifier.setLocation(
      title: 'Street 1',
      subtitle: 'Municipality X',
      landmark: 'Near School',
      district: 'Kathmandu',
      ward: '5',
      latitude: 27.71,
      longitude: 85.32,
    );

    expect(notifier.state.locationTitle, 'Street 1');
    expect(notifier.state.locationSubtitle, 'Municipality X');
    expect(notifier.state.landmark, 'Near School');
    expect(notifier.state.district, 'Kathmandu');
    expect(notifier.state.ward, '5');
    expect(notifier.state.latitude, 27.71);
    expect(notifier.state.longitude, 85.32);
  });

  test('setIssueDetails updates issue title and description', () {
    final notifier = ReportFormDraftNotifier();

    notifier.setIssueDetails(
      title: 'Leaking pipe',
      description: 'Water leaking continuously',
    );

    expect(notifier.state.issueTitle, 'Leaking pipe');
    expect(notifier.state.issueDescription, 'Water leaking continuously');
  });

  test('setUrgency updates urgency field', () {
    final notifier = ReportFormDraftNotifier();

    notifier.setUrgency('Urgent');

    expect(notifier.state.urgency, 'Urgent');
  });

  test('setPhotos stores a copy of provided list', () {
    final notifier = ReportFormDraftNotifier();
    final external = [XFile('/tmp/p1.jpg')];

    notifier.setPhotos(external);
    external.add(XFile('/tmp/p2.jpg'));

    expect(notifier.state.photos.length, 1);
    expect(notifier.state.photos.first.path, '/tmp/p1.jpg');
  });

  test('addPhoto appends one photo to draft', () {
    final notifier = ReportFormDraftNotifier();

    notifier.addPhoto(XFile('/tmp/new.jpg'));

    expect(notifier.state.photos.length, 1);
    expect(notifier.state.photos.first.path, '/tmp/new.jpg');
  });

  test('removePhotoAt removes photo at valid index', () {
    final notifier = ReportFormDraftNotifier();
    notifier.setPhotos([
      XFile('/tmp/a.jpg'),
      XFile('/tmp/b.jpg'),
      XFile('/tmp/c.jpg'),
    ]);

    notifier.removePhotoAt(1);

    expect(notifier.state.photos.length, 2);
    expect(notifier.state.photos[0].path, '/tmp/a.jpg');
    expect(notifier.state.photos[1].path, '/tmp/c.jpg');
  });

  test('removePhotoAt ignores invalid index without mutation', () {
    final notifier = ReportFormDraftNotifier();
    notifier.setPhotos([XFile('/tmp/a.jpg')]);

    notifier.removePhotoAt(5);

    expect(notifier.state.photos.length, 1);
    expect(notifier.state.photos.first.path, '/tmp/a.jpg');
  });

  test('reset clears previously entered draft values', () {
    final notifier = ReportFormDraftNotifier();
    notifier.setCategory('Garbage');
    notifier.setIssueDetails(title: 'Overflow', description: 'Bins are full');
    notifier.setUrgency('High');
    notifier.addPhoto(XFile('/tmp/reset.jpg'));

    notifier.reset();

    expect(notifier.state.category, isNull);
    expect(notifier.state.issueTitle, isNull);
    expect(notifier.state.issueDescription, isNull);
    expect(notifier.state.urgency, isNull);
    expect(notifier.state.photos, isEmpty);
  });
}
