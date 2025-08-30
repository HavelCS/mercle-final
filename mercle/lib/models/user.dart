class User {
  final String? id;
  final String phone;
  final String? uid;
  final String? rekognitionFaceId;
  final String? s3Key;
  final double? livenessScore;
  final String status;
  final DateTime? createdAt;
  final DateTime? lastSeen;
  final int accessCount;
  final String? inviteCode; // For new user registration

  User({
    this.id,
    required this.phone,
    this.uid,
    this.rekognitionFaceId,
    this.s3Key,
    this.livenessScore,
    this.status = 'new',
    this.createdAt,
    this.lastSeen,
    this.accessCount = 0,
    this.inviteCode,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'] ?? '',
      uid: json['uid'],
      rekognitionFaceId: json['rekognition_face_id'],
      s3Key: json['s3_key'],
      livenessScore: json['liveness_score']?.toDouble(),
      status: json['status'] ?? 'new',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen']) : null,
      accessCount: json['access_count'] ?? 0,
      inviteCode: json['invite_code'],
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'uid': uid,
      'rekognition_face_id': rekognitionFaceId,
      's3_key': s3Key,
      'liveness_score': livenessScore,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
      'access_count': accessCount,
      'invite_code': inviteCode,
    };
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? phone,
    String? uid,
    String? rekognitionFaceId,
    String? s3Key,
    double? livenessScore,
    String? status,
    DateTime? createdAt,
    DateTime? lastSeen,
    int? accessCount,
    String? inviteCode,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      uid: uid ?? this.uid,
      rekognitionFaceId: rekognitionFaceId ?? this.rekognitionFaceId,
      s3Key: s3Key ?? this.s3Key,
      livenessScore: livenessScore ?? this.livenessScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      accessCount: accessCount ?? this.accessCount,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  // Check if user is new (needs face registration)
  bool get isNew => status == 'new';
  
  // Check if user is verified
  bool get isVerified => status == 'verified';
  
  // Check if user is pending
  bool get isPending => status == 'pending';
  
  // Check if user has completed face registration
  bool get hasFaceData => rekognitionFaceId != null && s3Key != null;

  @override
  String toString() {
    return 'User(id: $id, phone: $phone, status: $status, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.phone == phone;
  }

  @override
  int get hashCode => id.hashCode ^ phone.hashCode;
}
