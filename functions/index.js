const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

exports.recommendAndHold = functions.https.onCall(async (data, context) => {
  // ไม่ใช้ optional chaining เพื่อลดปัญหา parser
  const uid = context.auth && context.auth.uid;
  if (!uid) {
    throw new functions.https.HttpsError("unauthenticated", "Login required");
  }

  const HOLD_SEC = data.holdSeconds || 120;

  // TODO: แทน logic คัดเลือกจริงของคุณ (ใกล้ทางเข้า/คะแนน ฯลฯ)
  const qs = await db
      .collection("parking_spots")
      .where("status", "==", "available")
      .orderBy("id")
      .limit(1)
      .get();

  if (qs.empty) {
    return {id: null};
  }

  const ref = qs.docs[0].ref;
  const now = admin.firestore.Timestamp.now();

  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const spot = snap.data() || {};

    const notExpired =
      spot.hold_expires_at &&
      spot.hold_expires_at.toMillis() > now.toMillis();

    if (spot.status !== "available" || notExpired) {
      return {id: null};
    }

    tx.update(ref, {
      status: "held",
      hold_by: uid,
      hold_expires_at: admin.firestore.Timestamp.fromMillis(
          now.toMillis() + HOLD_SEC * 1000,
      ),
      last_updated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {id: spot.id};
  });

  return result; // {id: <number>} หรือ {id: null}
});
