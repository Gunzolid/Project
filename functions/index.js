// functions/index.js (เวอร์ชัน V2 ที่สมบูรณ์ที่สุด)

const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

/**
 * Recommends and holds a parking spot for a user.
 */
exports.recommendAndHold = onCall(async (request) => {
  const {uid, holdSeconds = 900} = request.data;
  if (!uid) {
    throw new HttpsError(
        "invalid-argument",
        "The function must be called with a valid user UID.",
    );
  }

  const result = await db.runTransaction(async (transaction) => {
    const existingHoldQuery = db
        .collection("parking_spots")
        .where("hold_by", "==", uid);
    const existingHoldSnap = await transaction.get(existingHoldQuery);
    if (!existingHoldSnap.empty) {
      console.log(`User ${uid} already has a held spot. Aborting.`);
      return {ok: false, reason: "Already has a held spot"};
    }

    const availableSpotQuery = db
        .collection("parking_spots")
        .where("status", "==", "available")
        .orderBy("id")
        .limit(1);
    const availableSpotSnap = await transaction.get(availableSpotQuery);
    if (availableSpotSnap.empty) {
      console.log("No available spots found.");
      return {ok: false, reason: "No available spots"};
    }

    const spotToHold = availableSpotSnap.docs[0];
    const holdExpiresAt = new Date(Date.now() + holdSeconds * 1000);

    transaction.update(spotToHold.ref, {
      status: "held",
      hold_by: uid,
      hold_until: holdExpiresAt,
    });

    console.log(`Spot ${spotToHold.id} is now held by user ${uid}.`);
    return {
      ok: true,
      docId: spotToHold.id,
      id: spotToHold.data().id,
      hold_expires_at: holdExpiresAt.toISOString(),
    };
  });

  return result;
});

/**
 * A trigger that cleans up hold information when a spot is taken.
 */
exports.onSpotTaken = onDocumentUpdated("parking_spots/{spotId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();

  const statusChanged = beforeData.status !== afterData.status;
  const isNowTaken = afterData.status === "occupied" || afterData.status === "unavailable";
  const wasHeld = beforeData.hold_by != null;

  if (statusChanged && isNowTaken && wasHeld) {
    console.log(
        `Spot ${event.params.spotId} is now ${afterData.status}. ` +
        `Clearing hold info for user ${beforeData.hold_by}.`,
    );

    return event.data.after.ref.update({
      hold_by: null,
      hold_until: null,
    });
  }

  return null;
});