class DropdownItem {
  final int id;
  final String text;

  const DropdownItem({
    required this.id,
    required this.text,
  });

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: int.tryParse((json['id'] ?? json['value'] ?? 0).toString()) ?? 0,
      text: (json['text'] ?? json['name'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}
