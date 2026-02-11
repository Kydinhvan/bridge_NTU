import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/app_user.dart';
import '../../models/wellbeing_snapshot.dart';
import '../../models/chat_message.dart';
import '../../models/match_result.dart';

/// Firestore abstraction layer.
/// Currently backed by SharedPreferences (local mock).
/// Swap implementation bodies for real Firestore calls when Firebase is wired up.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  FirebaseService._();
  static FirebaseService get instance => _instance;

  final _uuid = const Uuid();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<String> signInAnonymously() async {
    final prefs = await _prefs;
    var uid = prefs.getString('uid');
    if (uid == null) {
      uid = _uuid.v4();
      await prefs.setString('uid', uid);
    }
    return uid;

    // REAL:
    // final credential = await FirebaseAuth.instance.signInAnonymously();
    // return credential.user!.uid;
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await _prefs;
    return prefs.getString('uid');

    // REAL:
    // return FirebaseAuth.instance.currentUser?.uid;
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<void> saveUser(AppUser user) async {
    final prefs = await _prefs;
    await prefs.setString('user_role', user.role.name);
    await prefs.setString('user_age_decade', user.ageDecade);

    // REAL:
    // await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toJson());
  }

  Future<AppUser?> getUser(String userId) async {
    final prefs = await _prefs;
    final role = prefs.getString('user_role');
    if (role == null) return null;
    return AppUser(
      id: userId,
      role: UserRole.values.firstWhere((e) => e.name == role),
      ageDecade: prefs.getString('user_age_decade') ?? '20s',
    );

    // REAL:
    // final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // if (!doc.exists) return null;
    // return AppUser.fromJson(doc.data()!);
  }

  // ── Wellbeing ──────────────────────────────────────────────────────────────

  Future<void> saveWellbeingSnapshot(String userId, WellbeingSnapshot snap) async {
    final prefs = await _prefs;
    final snapshots = prefs.getStringList('snapshots_$userId') ?? [];
    snapshots.add(snap.toJsonString());
    await prefs.setStringList('snapshots_$userId', snapshots);

    // REAL:
    // await FirebaseFirestore.instance
    //     .collection('wellbeing_snapshots').doc(userId)
    //     .collection('entries').add(snap.toJson());
  }

  Future<List<WellbeingSnapshot>> getWellbeingHistory(String userId) async {
    final prefs = await _prefs;
    final raw = prefs.getStringList('snapshots_$userId') ?? [];
    return raw.map<WellbeingSnapshot>(WellbeingSnapshot.fromJsonString).toList();

    // REAL:
    // final snap = await FirebaseFirestore.instance
    //     .collection('wellbeing_snapshots').doc(userId)
    //     .collection('entries').orderBy('createdAt').get();
    // return snap.docs.map((d) => WellbeingSnapshot.fromJson(d.data())).toList();
  }

  // ── Vents ─────────────────────────────────────────────────────────────────

  Future<String> createVent({
    required String seekerId,
    required String audioUrl,
  }) async {
    final ventId = _uuid.v4();
    final prefs = await _prefs;
    await prefs.setString('vent_$ventId', seekerId);
    await prefs.setString('current_vent_id', ventId);
    return ventId;

    // REAL:
    // final ref = FirebaseFirestore.instance.collection('vents').doc();
    // await ref.set({'seekerId': seekerId, 'audioUrl': audioUrl, 'status': 'processing'});
    // return ref.id;
  }

  // ── Matches ───────────────────────────────────────────────────────────────

  Future<String> saveMatch(MatchResult match) async {
    final matchId = _uuid.v4();
    final prefs = await _prefs;
    await prefs.setString('current_match_id', matchId);
    return matchId;

    // REAL:
    // final ref = FirebaseFirestore.instance.collection('matches').doc();
    // await ref.set(match.toJson());
    // return ref.id;
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String matchId, ChatMessage message) async {
    final prefs = await _prefs;
    final msgs = prefs.getStringList('chat_$matchId') ?? [];
    msgs.add(message.toJsonString());
    await prefs.setStringList('chat_$matchId', msgs);

    // REAL:
    // await FirebaseFirestore.instance
    //     .collection('chats').doc(matchId)
    //     .collection('messages').add(message.toJson());
  }

  Future<List<ChatMessage>> getMessages(String matchId) async {
    final prefs = await _prefs;
    final raw = prefs.getStringList('chat_$matchId') ?? [];
    return raw.map<ChatMessage>(ChatMessage.fromJsonString).toList();

    // REAL (stream):
    // FirebaseFirestore.instance
    //     .collection('chats').doc(matchId)
    //     .collection('messages').orderBy('createdAt').snapshots()
    //     .map((s) => s.docs.map((d) => ChatMessage.fromJson(d.data())).toList());
  }
}
