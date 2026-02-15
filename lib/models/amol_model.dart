import 'package:hive/hive.dart';

/// -----------------------------------------------------------------------------
/// MODEL CLASS
/// -----------------------------------------------------------------------------

/// Represents a single Zikr/Amol item stored in Hive.
@HiveType(typeId: 1)
class AmolItem extends HiveObject {
  /// Title of the Amol.
  @HiveField(0)
  String title;

  /// Target count for completion.
  @HiveField(1)
  int target;

  /// Current progress count.
  @HiveField(2)
  int currentCount;

  /// Completion status flag.
  @HiveField(3)
  bool isCompleted;

  /// Creates an AmolItem instance with default values.
  AmolItem({
    required this.title,
    this.target = 100,
    this.currentCount = 0,
    this.isCompleted = false,
  });

  /// Converts the object to a JSON map for backup export.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target': target,
      'currentCount': currentCount,
      'isCompleted': isCompleted,
    };
  }

  /// Creates an AmolItem instance from a JSON map during restore.
  factory AmolItem.fromJson(Map<String, dynamic> json) {
    return AmolItem(
      title: json['title'] ?? '',
      target: json['target'] ?? 100,
      currentCount: json['currentCount'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

/// -----------------------------------------------------------------------------
/// MANUAL ADAPTER
/// -----------------------------------------------------------------------------

/// Hive adapter for serializing and deserializing AmolItem.
class AmolItemAdapter extends TypeAdapter<AmolItem> {
  @override
  final int typeId = 1;

  /// Reads AmolItem data from Hive binary format.
  @override
  AmolItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return AmolItem(
      title: fields[0] as String,
      target: fields[1] as int,
      currentCount: fields[2] as int,
      isCompleted: fields[3] as bool,
    );
  }

  /// Writes AmolItem data to Hive binary format.
  @override
  void write(BinaryWriter writer, AmolItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.target)
      ..writeByte(2)
      ..write(obj.currentCount)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }
}
