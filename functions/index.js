const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Esta es una función llamable para asignar un rol de administrador a un usuario.
// Para mayor seguridad en un entorno de producción, deberías proteger esta función,
// por ejemplo, asegurándote de que solo otros administradores puedan llamarla.
exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // 1. Verificación básica de autenticación.
  // Si no está autenticado, la función arrojará un error.
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Debes estar autenticado para realizar esta acción.",
    );
  }

  const emailToMakeAdmin = data.email;
  if (typeof emailToMakeAdmin !== "string" || emailToMakeAdmin.length === 0) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "El email proporcionado no es válido.",
    );
  }

  try {
    // 2. Busca al usuario por su email.
    const userRecord = await admin.auth().getUserByEmail(emailToMakeAdmin);

    // 3. Establece el "custom claim" de administrador.
    // El segundo argumento ({ admin: true }) es el payload del claim.
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });

    // 4. Devuelve un mensaje de éxito.
    return {
      message: `¡Éxito! ${emailToMakeAdmin} ahora es un administrador.`,
    };
  } catch (error) {
    console.error("Error al intentar hacer administrador a un usuario:", error);
    throw new functions.https.HttpsError(
        "internal",
        `Ocurrió un error al procesar la solicitud: ${error.message}`,
    );
  }
});
