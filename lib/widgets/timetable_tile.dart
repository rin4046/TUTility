import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import '../font_scaler.dart';
import '../constants.dart';
import '../providers/timetable.dart';
import '../providers/timetable_visibility.dart';

@immutable
class TimetableTile extends ConsumerWidget {
  const TimetableTile({Key? key, required this.row, required this.col})
      : super(key: key);

  final int row, col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timetable? timetable = ref.watch(timetableProvider);
    TimetableVisibility? visibility = ref.watch(timetableVisibilityProvider);
    if (timetable == null || visibility == null) {
      return const SizedBox.shrink();
    }

    List<Subject> subjects = timetable.list[row][col];
    int? selected = visibility.list[row][col];
    if (subjects.isEmpty && selected != null) {
      throw const SizedBox.shrink();
    }

    if (selected != null) {
      Subject subject = subjects[selected];

      return GestureDetector(
        child: Container(
          margin: const EdgeInsets.all(2),
          child: AspectRatio(
            aspectRatio: 0.75,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints.expand(),
                  decoration: BoxDecoration(
                    color: palette[subject.id.hashCode % palette.length][100],
                    border: Border.all(
                      color: palette[subject.id.hashCode % palette.length]
                          [200]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subject.name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: TextStyle(
                      height: 1.2,
                      color: Colors.black87,
                      fontSize: 13.scale(context),
                    ),
                  ),
                ),
                if (subject.room != null)
                  Container(
                    width: double.infinity,
                    height: 22.scale(context),
                    padding: const EdgeInsets.all(2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette[subject.id.hashCode % palette.length][200],
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      subject.room!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.scale(context),
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => _SubjectDetailsDialog(subject: subject),
          );
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => _SubjectSelectorDialog(row: row, col: col),
          );
        },
      );
    } else {
      return GestureDetector(
        child: Container(
          margin: const EdgeInsets.all(2),
          child: AspectRatio(
            aspectRatio: 0.75,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => _SubjectSelectorDialog(row: row, col: col),
          );
        },
      );
    }
  }
}

@immutable
class _SubjectDetailsDialog extends StatelessWidget {
  const _SubjectDetailsDialog({Key? key, required this.subject})
      : super(key: key);

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(subject.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${subject.term} ${subject.required}'),
            if (subject.units != null) Text('?????????: ${subject.units}'),
            if (subject.area != null) Text('??????: ${subject.area}'),
            if (subject.staff != null) Text('????????????: ${subject.staff}'),
            if (subject.room != null) Text('??????: ${subject.room}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("????????????"),
          onPressed: () {
            launch(subject.url);
          },
        ),
        TextButton(
          child: const Text("?????????"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

@immutable
class _SubjectSelectorDialog extends ConsumerWidget {
  const _SubjectSelectorDialog({Key? key, required this.row, required this.col})
      : super(key: key);

  final int row, col;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Timetable? timetable = ref.watch(timetableProvider);
    TimetableVisibility? visibility = ref.watch(timetableVisibilityProvider);
    if (timetable == null || visibility == null) {
      return const SizedBox.shrink();
    }

    List<Subject> subjects = timetable.list[row][col];
    int? selected = visibility.list[row][col];
    if (subjects.isEmpty && selected != null) {
      throw const SizedBox.shrink();
    }

    return SimpleDialog(
      title: Text('${weekdays[col + 1]}??? ${row + 1}??? ??????????????????'),
      children: [
        ...subjects.asMap().entries.map<Widget>((item) {
          return SimpleDialogOption(
            onPressed: () async {
              visibility.list[row][col] = item.key;
              await ref
                  .read(timetableVisibilityProvider.notifier)
                  .update(TimetableVisibility(list: visibility.list));
              Navigator.of(context).pop();
            },
            child: Text(
              '${item.value.name} (${item.value.staff})',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
        SimpleDialogOption(
          onPressed: () async {
            visibility.list[row][col] = null;
            await ref
                .read(timetableVisibilityProvider.notifier)
                .update(TimetableVisibility(list: visibility.list));
            Navigator.of(context).pop();
          },
          child: const Text('?????????'),
        )
      ],
    );
  }
}
