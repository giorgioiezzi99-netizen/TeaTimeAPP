import SwiftUI
import ActivityKit
import PhotosUI
import UIKit
import UserNotifications
import VisionKit
internal import Combine

private enum TeaTimerLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case italian = "it"
    case french = "fr"
    case spanish = "es"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: return "English"
        case .italian: return "Italiano"
        case .french: return "Français"
        case .spanish: return "Español"
        }
    }
}

private struct LocalUserProfile: Codable, Equatable {
    var firstName: String
    var lastName: String
    var email: String
    var birthday: Date?
    var gender: String
    var nationality: String
    var language: TeaTimerLanguage
    var createdAt: Date
    var updatedAt: Date

    var displayName: String {
        let fullName = [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return fullName.isEmpty ? firstName : fullName
    }
}

private enum LocalizedTextKey: Hashable {
    case addPhoto, birthday, cancel, chooseFromLibrary, createPersonalizedTea, delete, diary, edit, email, english, firstName, gender
    case italian, language, lastName, logout, nationality, noMomentsOnDay, pause, perfectTeaEveryTime, profile, register, reset
    case resetProfile, reviews, save, saveTea, savedTeas, scanTea, settings, share, startScan, startTimer, starterDatabase, stats
    case takePhoto, teaIsReady, useTimer, welcome
    case addPhotoShort, camera, close, library, moments, openSavedTea, scanAgain, saveChanges
    case appTitle, brewing, brewingYourTea, customTimer, french, optional, photoAttached, remaining, spanish, tagline, teaMoments, useScannedBefore
    case addThought, addThoughtBrewing, alreadySavedTea, avgRating, badges, brand, brandName, caffeine, calendarView, cameraUnavailable
    case cameraUnavailableDetail, centerTeaText, completeTimerFirst, deleteMomentAlert, deleteMomentMessage, deletePersonalizedTimer
    case deleteSavedTeaAlert, detectedText, editMoment, editMomentSubtitle, editSavedTea, editScan, fiveStarFavorite, fiveStarFavoriteDetail
    case flavorNotes, fromPackage, defaultLabel, defaultFor, greenRitual, greenRitualDetail, highestToLowest, historySubtitle, infusion, infusionLabel, last7Days, loyalSipper, loyalSipperDetail
    case lowestToHighest, newestFirst, oldestFirst
    case manualTimerNote, medium, min, minutes, month, mood, mostCommonMood, mostConsumedTea, noData, noPendingReviews, noRatings, noReviewsDetail, noReviewsYet
    case noSavedTeasDetail, noSavedTeasYet, noTeaMomentsYet, noTeaReviewsYet, notFoundDatabase, notReviewedYet, notYet, note, notes
    case openTeaCalendar, optionalShortNote, personalized, personalizedBrewingProfile, personalizedTeaSubtitle, pointCamera, previewUpdated, rate, rateThisTea, rating, reduceTimer15
    case remove, removePhoto, review, reviewedTeas, reviewPlaceholder, reviewSortOrder, reviewSubtitle, reviewTea, saveReview, saveThought
    case savedFromPersonalizedSettings, savedMomentMessage, savedTeaMessage, savedTimerRemoval, savedTeaRemoval, scannerBrandDetectedManual, scannerSubtitle, scannerUnclear, sec
    case scannedBefore, scannedCodePrompt, scanTeaLabel, sectionTea
    case simpleSavedNote, suggested, suggestedInfusion, takeMoment, tea, teaCalendar, teaCalendarSubtitle, teaExplorer, teaExplorerDetail
    case teaDetails, teaFound, teaMoment, teaMomentsToReview, teaName, teaRating, teaStyle, teaType, thisMoment, thisTea, thisTimer, thought, thoughtPlaceholder
    case thoughtSaved, timer, timer15SecSteps, topType, totalMoments, type, updateMoodThought, water, waterC, week
}

private let localizedTextTable: [TeaTimerLanguage: [LocalizedTextKey: String]] = [
    .english: [
        .addPhoto: "Add Photo", .addPhotoShort: "Add a tea moment photo", .appTitle: "Tea Timer", .birthday: "Birthday",
        .brewing: "Brewing...", .brewingYourTea: "Brewing your tea", .camera: "Camera", .cancel: "Cancel",
        .chooseFromLibrary: "Choose From Library", .close: "Close", .createPersonalizedTea: "Create Personalized Tea",
        .customTimer: "Custom Timer", .delete: "Delete", .diary: "Diary", .edit: "Edit", .email: "Email",
        .english: "English", .firstName: "First Name", .french: "Français", .gender: "Gender", .italian: "Italiano",
        .language: "Language", .lastName: "Last Name", .library: "Library", .logout: "Logout", .moments: "Moments",
        .nationality: "Nationality", .noMomentsOnDay: "No tea moments recorded on this day.", .openSavedTea: "Open Saved Tea",
        .optional: "Optional", .pause: "Pause", .perfectTeaEveryTime: "Perfect tea, every time.", .photoAttached: "Photo attached",
        .profile: "Profile", .register: "Register", .remaining: "remaining", .reset: "Reset", .resetProfile: "Reset Profile",
        .reviews: "Reviews", .save: "Save", .saveChanges: "Save Changes", .saveTea: "Save Tea", .savedTeas: "Saved Teas",
        .scanAgain: "Scan Again", .scanTea: "Scan Tea", .settings: "Settings", .share: "Share", .spanish: "Español",
        .startScan: "Start Scan", .startTimer: "Start Timer", .starterDatabase: "Starter Database", .stats: "Stats",
        .tagline: "Precise steeping for a cleaner, richer cup.", .takePhoto: "Take Photo", .teaIsReady: "Tea is ready",
        .teaMoments: "Tea Moments", .useScannedBefore: "Use teas you scanned before.", .useTimer: "Use Timer", .welcome: "Welcome",
        .addThought: "Add Thought", .addThoughtBrewing: "Add a thought while your tea is brewing.", .alreadySavedTea: "This tea is already saved.",
        .avgRating: "Avg Rating", .badges: "Badges", .brand: "Brand", .brandName: "Brand name", .caffeine: "Caffeine",
        .calendarView: "Calendar View", .cameraUnavailable: "Camera scanning is unavailable.",
        .cameraUnavailableDetail: "Please try on a real iPhone with camera access enabled, or select the tea manually.",
        .centerTeaText: "Center tea type text in the camera view.", .completeTimerFirst: "Complete a tea timer to save your first moment.",
        .deleteMomentAlert: "Delete this tea moment?", .deleteMomentMessage: "This moment will be removed from your history.",
        .deletePersonalizedTimer: "Remove this personalized timer?", .deleteSavedTeaAlert: "Remove this saved tea?",
        .detectedText: "Detected text", .editMoment: "Edit Moment", .editMomentSubtitle: "Update the mood or thought for this tea moment.",
        .editSavedTea: "Edit Saved Tea", .editScan: "Edit Scan", .fiveStarFavorite: "Five-Star Favorite",
        .fiveStarFavoriteDetail: "Rated a tea 5 stars", .flavorNotes: "Flavor Notes", .fromPackage: "from package",
        .defaultLabel: "default", .defaultFor: "default for", .greenRitual: "Green Ritual",
        .greenRitualDetail: "Green tea 5 times in the last 10 days", .highestToLowest: "Highest to Lowest",
        .historySubtitle: "A quiet history of what you brewed and when.", .infusion: "infusion", .infusionLabel: "Infusion",
        .last7Days: "Last 7 Days", .loyalSipper: "Loyal Sipper", .loyalSipperDetail: "Same tea/product brewed 3 times",
        .lowestToHighest: "Lowest to Highest", .newestFirst: "Newest First", .oldestFirst: "Oldest First",
        .manualTimerNote: "Changing minutes marks the timer as manual.", .medium: "Medium", .min: "min", .minutes: "Minutes",
        .month: "Month", .mood: "Mood", .mostCommonMood: "Most common mood", .mostConsumedTea: "Most consumed tea",
        .noData: "No data", .noPendingReviews: "No pending reviews.", .noRatings: "No ratings",
        .noReviewsDetail: "Complete a tea timer and rate your tea when you're ready.", .noReviewsYet: "No reviews yet.",
        .noSavedTeasDetail: "Scan a tea package, then save it here for next time.", .noSavedTeasYet: "No saved teas yet.",
        .noTeaMomentsYet: "No tea moments yet.", .noTeaReviewsYet: "No tea reviews yet.", .notFoundDatabase: "Tea not found in database.",
        .notReviewedYet: "You haven't reviewed this tea moment yet.", .notYet: "Not yet", .note: "Note", .notes: "Notes",
        .openTeaCalendar: "Open tea calendar", .optionalShortNote: "Optional short note", .personalized: "Personalized",
        .personalizedBrewingProfile: "Personalized brewing profile", .personalizedTeaSubtitle: "Save a tea that is not in the database yet.", .pointCamera: "Point the camera at the front of the tea package.",
        .previewUpdated: "Preview updated. Tap Save Tea when it looks right.", .rate: "Rate", .rateThisTea: "Rate This Tea",
        .rating: "Rating", .reduceTimer15: "Reduce timer by 15 seconds", .remove: "Remove", .removePhoto: "Remove photo",
        .review: "Review", .reviewedTeas: "Reviewed Teas", .reviewPlaceholder: "Write what you thought about the tea...", .reviewSortOrder: "Review Sort Order",
        .reviewSubtitle: "A review is about the tea itself, separate from your diary thought.", .reviewTea: "Review Tea",
        .saveReview: "Save Review", .saveThought: "Save Moment", .savedFromPersonalizedSettings: "Saved from your personalized tea settings. Brand: %@.",
        .savedMomentMessage: "Your tea moment has been saved.",
        .savedTeaMessage: "Saved tea. You can use it again without scanning.",
        .savedTimerRemoval: "This timer will be removed from your saved timers.", .savedTeaRemoval: "This tea will be removed from Saved Teas.", .sec: "sec",
        .scannerBrandDetectedManual: "%@ detected. Please select the tea type manually.", .scannerSubtitle: "Scan tea package text to detect tea type and suggest infusion settings.",
        .scannerUnclear: "I couldn't detect the tea type. Please try again or select it manually.", .scannedBefore: "Scanned before",
        .scannedCodePrompt: "Scanned code: %@. You can create a personalized timer from the label.", .scanTeaLabel: "Scan Tea Label",
        .sectionTea: "Tea", .simpleSavedNote: "Simple note: Saved tea. You can use it again without scanning.",
        .suggested: "Suggested", .suggestedInfusion: "Suggested Infusion", .takeMoment: "Take a moment for yourself.",
        .tea: "Tea", .teaCalendar: "Tea Calendar", .teaCalendarSubtitle: "See what you drank on each day.",
        .teaDetails: "Tea Details", .teaExplorer: "Tea Explorer", .teaExplorerDetail: "Tried 5 different teas/products", .teaFound: "Tea Found", .teaMoment: "Tea Moment",
        .teaMomentsToReview: "Tea Moments to Review", .teaName: "Tea name", .teaRating: "Tea rating", .teaStyle: "Tea Style", .teaType: "Tea type",
        .thisMoment: "This moment", .thisTea: "This tea", .thisTimer: "This timer", .thought: "Thoughts",
        .thoughtPlaceholder: "Add your thoughts...", .thoughtSaved: "Moment saved", .timer: "Timer",
        .timer15SecSteps: "15 sec steps", .topType: "Top Type", .totalMoments: "Total Moments", .type: "Type",
        .updateMoodThought: "Update the mood or thought for this tea moment.", .water: "Water", .waterC: "Water C", .week: "Week"
    ],
    .italian: [
        .addPhoto: "Aggiungi foto", .addPhotoShort: "Aggiungi una foto del momento", .appTitle: "Tea Timer", .birthday: "Compleanno",
        .brewing: "In infusione...", .brewingYourTea: "Il tuo tè è in infusione", .camera: "Fotocamera", .cancel: "Annulla",
        .chooseFromLibrary: "Scegli dalla libreria", .close: "Chiudi", .createPersonalizedTea: "Crea tè personalizzato",
        .customTimer: "Timer personalizzato", .delete: "Elimina", .diary: "Diario", .edit: "Modifica", .email: "Email",
        .english: "English", .firstName: "Nome", .french: "Français", .gender: "Genere", .italian: "Italiano",
        .language: "Lingua", .lastName: "Cognome", .library: "Libreria", .logout: "Esci", .moments: "Momenti",
        .nationality: "Nazionalità", .noMomentsOnDay: "Nessun momento tè registrato in questo giorno.", .openSavedTea: "Apri tè salvato",
        .optional: "Opzionale", .pause: "Pausa", .perfectTeaEveryTime: "Il tè perfetto, ogni volta.", .photoAttached: "Foto allegata",
        .profile: "Profilo", .register: "Registrati", .remaining: "rimanenti", .reset: "Reimposta", .resetProfile: "Reimposta profilo",
        .reviews: "Recensioni", .save: "Salva", .saveChanges: "Salva modifiche", .saveTea: "Salva tè", .savedTeas: "Tè salvati",
        .scanAgain: "Scansiona di nuovo", .scanTea: "Scansiona tè", .settings: "Impostazioni", .share: "Condividi", .spanish: "Español",
        .startScan: "Avvia scansione", .startTimer: "Avvia timer", .starterDatabase: "Database iniziale", .stats: "Statistiche",
        .tagline: "Infusione precisa per una tazza più pulita e ricca.", .takePhoto: "Scatta foto", .teaIsReady: "Il tè è pronto",
        .teaMoments: "Momenti tè", .useScannedBefore: "Usa i tè che hai già scansionato.", .useTimer: "Usa timer", .welcome: "Benvenuto",
        .addThought: "Aggiungi pensiero", .addThoughtBrewing: "Aggiungi un pensiero mentre il tè è in infusione.", .alreadySavedTea: "Questo tè è già salvato.",
        .avgRating: "Valutazione media", .badges: "Badge", .brand: "Marca", .brandName: "Nome marca", .caffeine: "Caffeina",
        .calendarView: "Vista calendario", .cameraUnavailable: "La scansione con fotocamera non è disponibile.",
        .cameraUnavailableDetail: "Prova su un iPhone reale con accesso alla fotocamera attivo, oppure seleziona il tè manualmente.",
        .centerTeaText: "Centra il testo del tè nella vista della fotocamera.", .completeTimerFirst: "Completa un timer per salvare il tuo primo momento.",
        .deleteMomentAlert: "Eliminare questo momento tè?", .deleteMomentMessage: "Questo momento sarà rimosso dalla tua cronologia.",
        .deletePersonalizedTimer: "Rimuovere questo timer personalizzato?", .deleteSavedTeaAlert: "Rimuovere questo tè salvato?",
        .detectedText: "Testo rilevato", .editMoment: "Modifica momento", .editMomentSubtitle: "Aggiorna umore o pensiero di questo momento tè.",
        .editSavedTea: "Modifica tè salvato", .editScan: "Modifica scansione", .fiveStarFavorite: "Preferito a cinque stelle",
        .fiveStarFavoriteDetail: "Hai valutato un tè 5 stelle", .flavorNotes: "Note di gusto", .fromPackage: "dalla confezione",
        .defaultLabel: "predefinito", .defaultFor: "predefinito per", .greenRitual: "Rituale verde",
        .greenRitualDetail: "Tè verde 5 volte negli ultimi 10 giorni", .highestToLowest: "Dal più alto al più basso",
        .historySubtitle: "Una cronologia tranquilla di cosa hai preparato e quando.", .infusion: "infusione", .infusionLabel: "Infusione",
        .last7Days: "Ultimi 7 giorni", .loyalSipper: "Sorseggiatore fedele", .loyalSipperDetail: "Stesso tè/prodotto preparato 3 volte",
        .lowestToHighest: "Dal più basso al più alto", .newestFirst: "Più recenti prima", .oldestFirst: "Più vecchi prima",
        .manualTimerNote: "Cambiare i minuti imposta il timer come manuale.", .medium: "Media", .min: "min", .minutes: "Minuti",
        .month: "Mese", .mood: "Umore", .mostCommonMood: "Umore più comune", .mostConsumedTea: "Tè più consumato",
        .noData: "Nessun dato", .noPendingReviews: "Nessuna recensione in sospeso.", .noRatings: "Nessuna valutazione",
        .noReviewsDetail: "Completa un timer e valuta il tè quando vuoi.", .noReviewsYet: "Nessuna recensione.",
        .noSavedTeasDetail: "Scansiona un pacchetto di tè, poi salvalo qui per la prossima volta.", .noSavedTeasYet: "Nessun tè salvato.",
        .noTeaMomentsYet: "Nessun momento tè.", .noTeaReviewsYet: "Nessuna recensione tè.", .notFoundDatabase: "Tè non trovato nel database.",
        .notReviewedYet: "Non hai ancora recensito questo momento tè.", .notYet: "Non ancora", .note: "Nota", .notes: "Note",
        .openTeaCalendar: "Apri calendario tè", .optionalShortNote: "Nota breve opzionale", .personalized: "Personalizzato",
        .personalizedBrewingProfile: "Profilo di infusione personalizzato", .personalizedTeaSubtitle: "Salva un tè che non è ancora nel database.", .pointCamera: "Punta la fotocamera sul fronte della confezione.",
        .previewUpdated: "Anteprima aggiornata. Tocca Salva tè quando va bene.", .rate: "Valuta", .rateThisTea: "Valuta questo tè",
        .rating: "Valutazione", .reduceTimer15: "Riduci timer di 15 secondi", .remove: "Rimuovi", .removePhoto: "Rimuovi foto",
        .review: "Recensione", .reviewedTeas: "Tè recensiti", .reviewPlaceholder: "Scrivi cosa pensi del tè...", .reviewSortOrder: "Ordine recensioni",
        .reviewSubtitle: "Una recensione riguarda il tè, separata dal pensiero nel diario.", .reviewTea: "Recensisci tè",
        .saveReview: "Salva recensione", .saveThought: "Salva momento", .savedFromPersonalizedSettings: "Salvato dalle impostazioni personalizzate. Marca: %@.",
        .savedMomentMessage: "Il tuo momento tè è stato salvato.",
        .savedTeaMessage: "Tè salvato. Puoi usarlo di nuovo senza scansionare.",
        .savedTimerRemoval: "Questo timer sarà rimosso dai timer salvati.", .savedTeaRemoval: "Questo tè sarà rimosso da Tè salvati.", .sec: "sec",
        .scannerBrandDetectedManual: "%@ rilevato. Seleziona manualmente il tipo di tè.", .scannerSubtitle: "Scansiona il testo della confezione per rilevare il tipo e suggerire l'infusione.",
        .scannerUnclear: "Non sono riuscito a rilevare il tipo di tè. Riprova o selezionalo manualmente.", .scannedBefore: "Già scansionati",
        .scannedCodePrompt: "Codice scansionato: %@. Puoi creare un timer personalizzato dall'etichetta.", .scanTeaLabel: "Scansiona etichetta tè",
        .sectionTea: "Tè", .simpleSavedNote: "Nota: tè salvato. Puoi usarlo di nuovo senza scansionare.",
        .suggested: "Suggerito", .suggestedInfusion: "Infusione suggerita", .takeMoment: "Prenditi un momento per te.",
        .tea: "Tè", .teaCalendar: "Calendario tè", .teaCalendarSubtitle: "Vedi cosa hai bevuto ogni giorno.",
        .teaDetails: "Dettagli tè", .teaExplorer: "Esploratore di tè", .teaExplorerDetail: "Hai provato 5 tè/prodotti diversi", .teaFound: "Tè trovato", .teaMoment: "Momento tè",
        .teaMomentsToReview: "Momenti tè da recensire", .teaName: "Nome tè", .teaRating: "Valutazione tè", .teaStyle: "Stile tè", .teaType: "Tipo tè",
        .thisMoment: "Questo momento", .thisTea: "Questo tè", .thisTimer: "Questo timer", .thought: "Pensieri",
        .thoughtPlaceholder: "Aggiungi i tuoi pensieri...", .thoughtSaved: "Momento salvato", .timer: "Timer",
        .timer15SecSteps: "Passi da 15 sec", .topType: "Tipo più usato", .totalMoments: "Momenti totali", .type: "Tipo",
        .updateMoodThought: "Aggiorna umore o pensiero di questo momento tè.", .water: "Acqua", .waterC: "Acqua C", .week: "Settimana"
    ],
    .french: [
        .addPhoto: "Ajouter une photo", .addPhotoShort: "Ajouter une photo du moment", .appTitle: "Tea Timer", .birthday: "Anniversaire",
        .brewing: "Infusion...", .brewingYourTea: "Votre thé infuse", .camera: "Appareil photo", .cancel: "Annuler",
        .chooseFromLibrary: "Choisir dans la galerie", .close: "Fermer", .createPersonalizedTea: "Créer un thé personnalisé",
        .customTimer: "Minuteur personnalisé", .delete: "Supprimer", .diary: "Journal", .edit: "Modifier", .email: "Email",
        .english: "English", .firstName: "Prénom", .french: "Français", .gender: "Genre", .italian: "Italiano",
        .language: "Langue", .lastName: "Nom", .library: "Galerie", .logout: "Se déconnecter", .moments: "Moments",
        .nationality: "Nationalité", .noMomentsOnDay: "Aucun moment thé enregistré ce jour-là.", .openSavedTea: "Ouvrir le thé enregistré",
        .optional: "Facultatif", .pause: "Pause", .perfectTeaEveryTime: "Le thé parfait, à chaque fois.", .photoAttached: "Photo ajoutée",
        .profile: "Profil", .register: "S’inscrire", .remaining: "restant", .reset: "Réinitialiser", .resetProfile: "Réinitialiser le profil",
        .reviews: "Avis", .save: "Enregistrer", .saveChanges: "Enregistrer", .saveTea: "Enregistrer le thé", .savedTeas: "Thés enregistrés",
        .scanAgain: "Scanner à nouveau", .scanTea: "Scanner un thé", .settings: "Paramètres", .share: "Partager", .spanish: "Español",
        .startScan: "Démarrer le scan", .startTimer: "Démarrer le minuteur", .starterDatabase: "Base de données initiale", .stats: "Statistiques",
        .tagline: "Une infusion précise pour une tasse plus pure et plus riche.", .takePhoto: "Prendre une photo", .teaIsReady: "Votre thé est prêt",
        .teaMoments: "Moments thé", .useScannedBefore: "Utilisez les thés que vous avez déjà scannés.", .useTimer: "Utiliser le minuteur", .welcome: "Bienvenue",
        .addThought: "Ajouter une pensée", .addThoughtBrewing: "Ajoutez une pensée pendant que votre thé infuse.", .alreadySavedTea: "Ce thé est déjà enregistré.",
        .avgRating: "Note moyenne", .badges: "Badges", .brand: "Marque", .brandName: "Nom de marque", .caffeine: "Caféine",
        .calendarView: "Vue calendrier", .cameraUnavailable: "Le scan par caméra est indisponible.",
        .cameraUnavailableDetail: "Essayez sur un iPhone réel avec l'accès caméra activé, ou sélectionnez le thé manuellement.",
        .centerTeaText: "Centrez le texte du thé dans la vue caméra.", .completeTimerFirst: "Terminez un minuteur pour enregistrer votre premier moment.",
        .deleteMomentAlert: "Supprimer ce moment thé ?", .deleteMomentMessage: "Ce moment sera supprimé de votre historique.",
        .deletePersonalizedTimer: "Supprimer ce minuteur personnalisé ?", .deleteSavedTeaAlert: "Supprimer ce thé enregistré ?",
        .detectedText: "Texte détecté", .editMoment: "Modifier le moment", .editMomentSubtitle: "Modifiez l'humeur ou la pensée de ce moment thé.",
        .editSavedTea: "Modifier le thé enregistré", .editScan: "Modifier le scan", .fiveStarFavorite: "Favori cinq étoiles",
        .fiveStarFavoriteDetail: "Vous avez noté un thé 5 étoiles", .flavorNotes: "Notes de goût", .fromPackage: "depuis le paquet",
        .defaultLabel: "par défaut", .defaultFor: "par défaut pour", .greenRitual: "Rituel vert",
        .greenRitualDetail: "Thé vert 5 fois dans les 10 derniers jours", .highestToLowest: "Du plus élevé au plus bas",
        .historySubtitle: "Un historique paisible de ce que vous avez préparé et quand.", .infusion: "infusion", .infusionLabel: "Infusion",
        .last7Days: "7 derniers jours", .loyalSipper: "Fidèle buveur", .loyalSipperDetail: "Même thé/produit préparé 3 fois",
        .lowestToHighest: "Du plus bas au plus élevé", .newestFirst: "Plus récents d’abord", .oldestFirst: "Plus anciens d’abord",
        .manualTimerNote: "Modifier les minutes marque le minuteur comme manuel.", .medium: "Moyenne", .min: "min", .minutes: "Minutes",
        .month: "Mois", .mood: "Humeur", .mostCommonMood: "Humeur la plus fréquente", .mostConsumedTea: "Thé le plus consommé",
        .noData: "Aucune donnée", .noPendingReviews: "Aucun avis en attente.", .noRatings: "Aucune note",
        .noReviewsDetail: "Terminez un minuteur et notez votre thé quand vous êtes prêt.", .noReviewsYet: "Aucun avis.",
        .noSavedTeasDetail: "Scannez un paquet de thé, puis enregistrez-le ici pour la prochaine fois.", .noSavedTeasYet: "Aucun thé enregistré.",
        .noTeaMomentsYet: "Aucun moment thé.", .noTeaReviewsYet: "Aucun avis sur les thés.", .notFoundDatabase: "Thé introuvable dans la base.",
        .notReviewedYet: "Vous n'avez pas encore évalué ce moment thé.", .notYet: "Pas encore", .note: "Note", .notes: "Notes",
        .openTeaCalendar: "Ouvrir le calendrier thé", .optionalShortNote: "Courte note facultative", .personalized: "Personnalisé",
        .personalizedBrewingProfile: "Profil d'infusion personnalisé", .personalizedTeaSubtitle: "Enregistrez un thé qui n'est pas encore dans la base.", .pointCamera: "Pointez la caméra vers l'avant du paquet.",
        .previewUpdated: "Aperçu mis à jour. Touchez Enregistrer le thé quand c'est bon.", .rate: "Noter", .rateThisTea: "Noter ce thé",
        .rating: "Note", .reduceTimer15: "Réduire le minuteur de 15 secondes", .remove: "Supprimer", .removePhoto: "Supprimer la photo",
        .review: "Avis", .reviewedTeas: "Thés évalués", .reviewPlaceholder: "Écrivez ce que vous avez pensé du thé...", .reviewSortOrder: "Ordre des avis",
        .reviewSubtitle: "Un avis concerne le thé lui-même, séparé de votre pensée du journal.", .reviewTea: "Évaluer le thé",
        .saveReview: "Enregistrer l'avis", .saveThought: "Enregistrer le moment", .savedFromPersonalizedSettings: "Enregistré depuis vos paramètres personnalisés. Marque : %@.",
        .savedMomentMessage: "Votre moment thé a été enregistré.",
        .savedTeaMessage: "Thé enregistré. Vous pouvez le réutiliser sans scanner.",
        .savedTimerRemoval: "Ce minuteur sera supprimé de vos minuteurs enregistrés.", .savedTeaRemoval: "Ce thé sera supprimé des Thés enregistrés.", .sec: "s",
        .scannerBrandDetectedManual: "%@ détecté. Sélectionnez le type de thé manuellement.", .scannerSubtitle: "Scannez le texte du paquet pour détecter le type et suggérer l'infusion.",
        .scannerUnclear: "Je n'ai pas pu détecter le type de thé. Réessayez ou sélectionnez-le manuellement.", .scannedBefore: "Déjà scannés",
        .scannedCodePrompt: "Code scanné : %@. Vous pouvez créer un minuteur personnalisé depuis l'étiquette.", .scanTeaLabel: "Scanner l'étiquette",
        .sectionTea: "Thé", .simpleSavedNote: "Note : thé enregistré. Vous pouvez le réutiliser sans scanner.",
        .suggested: "Suggéré", .suggestedInfusion: "Infusion suggérée", .takeMoment: "Prenez un moment pour vous.",
        .tea: "Thé", .teaCalendar: "Calendrier thé", .teaCalendarSubtitle: "Voyez ce que vous avez bu chaque jour.",
        .teaDetails: "Détails du thé", .teaExplorer: "Explorateur de thé", .teaExplorerDetail: "Vous avez essayé 5 thés/produits différents", .teaFound: "Thé trouvé", .teaMoment: "Moment thé",
        .teaMomentsToReview: "Moments thé à évaluer", .teaName: "Nom du thé", .teaRating: "Note du thé", .teaStyle: "Style de thé", .teaType: "Type de thé",
        .thisMoment: "Ce moment", .thisTea: "Ce thé", .thisTimer: "Ce minuteur", .thought: "Pensées",
        .thoughtPlaceholder: "Ajoutez vos pensées...", .thoughtSaved: "Moment enregistré", .timer: "Minuteur",
        .timer15SecSteps: "Pas de 15 sec", .topType: "Type principal", .totalMoments: "Moments totaux", .type: "Type",
        .updateMoodThought: "Modifiez l'humeur ou la pensée de ce moment thé.", .water: "Eau", .waterC: "Eau C", .week: "Semaine"
    ],
    .spanish: [
        .addPhoto: "Añadir foto", .addPhotoShort: "Añadir una foto del momento", .appTitle: "Tea Timer", .birthday: "Cumpleaños",
        .brewing: "En infusión...", .brewingYourTea: "Tu té se está preparando", .camera: "Cámara", .cancel: "Cancelar",
        .chooseFromLibrary: "Elegir de la galería", .close: "Cerrar", .createPersonalizedTea: "Crear té personalizado",
        .customTimer: "Temporizador personalizado", .delete: "Eliminar", .diary: "Diario", .edit: "Editar", .email: "Email",
        .english: "English", .firstName: "Nombre", .french: "Français", .gender: "Género", .italian: "Italiano",
        .language: "Idioma", .lastName: "Apellido", .library: "Galería", .logout: "Cerrar sesión", .moments: "Momentos",
        .nationality: "Nacionalidad", .noMomentsOnDay: "No hay momentos de té registrados en este día.", .openSavedTea: "Abrir té guardado",
        .optional: "Opcional", .pause: "Pausa", .perfectTeaEveryTime: "El té perfecto, cada vez.", .photoAttached: "Foto adjunta",
        .profile: "Perfil", .register: "Registrarse", .remaining: "restante", .reset: "Restablecer", .resetProfile: "Restablecer perfil",
        .reviews: "Reseñas", .save: "Guardar", .saveChanges: "Guardar cambios", .saveTea: "Guardar té", .savedTeas: "Tés guardados",
        .scanAgain: "Escanear de nuevo", .scanTea: "Escanear té", .settings: "Ajustes", .share: "Compartir", .spanish: "Español",
        .startScan: "Iniciar escaneo", .startTimer: "Iniciar temporizador", .starterDatabase: "Base de datos inicial", .stats: "Estadísticas",
        .tagline: "Infusión precisa para una taza más limpia y rica.", .takePhoto: "Tomar foto", .teaIsReady: "Tu té está listo",
        .teaMoments: "Momentos de té", .useScannedBefore: "Usa los tés que ya escaneaste.", .useTimer: "Usar temporizador", .welcome: "Bienvenido",
        .addThought: "Añadir pensamiento", .addThoughtBrewing: "Añade un pensamiento mientras el té está en infusión.", .alreadySavedTea: "Este té ya está guardado.",
        .avgRating: "Valoración media", .badges: "Insignias", .brand: "Marca", .brandName: "Nombre de marca", .caffeine: "Cafeína",
        .calendarView: "Vista de calendario", .cameraUnavailable: "El escaneo con cámara no está disponible.",
        .cameraUnavailableDetail: "Prueba en un iPhone real con acceso a la cámara activado, o selecciona el té manualmente.",
        .centerTeaText: "Centra el texto del té en la vista de cámara.", .completeTimerFirst: "Completa un temporizador para guardar tu primer momento.",
        .deleteMomentAlert: "¿Eliminar este momento de té?", .deleteMomentMessage: "Este momento se eliminará de tu historial.",
        .deletePersonalizedTimer: "¿Eliminar este temporizador personalizado?", .deleteSavedTeaAlert: "¿Eliminar este té guardado?",
        .detectedText: "Texto detectado", .editMoment: "Editar momento", .editMomentSubtitle: "Actualiza el ánimo o pensamiento de este momento de té.",
        .editSavedTea: "Editar té guardado", .editScan: "Editar escaneo", .fiveStarFavorite: "Favorito de cinco estrellas",
        .fiveStarFavoriteDetail: "Valoraste un té con 5 estrellas", .flavorNotes: "Notas de sabor", .fromPackage: "del paquete",
        .defaultLabel: "predeterminado", .defaultFor: "predeterminado para", .greenRitual: "Ritual verde",
        .greenRitualDetail: "Té verde 5 veces en los últimos 10 días", .highestToLowest: "De mayor a menor",
        .historySubtitle: "Un historial tranquilo de lo que preparaste y cuándo.", .infusion: "infusión", .infusionLabel: "Infusión",
        .last7Days: "Últimos 7 días", .loyalSipper: "Bebedor fiel", .loyalSipperDetail: "Mismo té/producto preparado 3 veces",
        .lowestToHighest: "De menor a mayor", .newestFirst: "Más recientes primero", .oldestFirst: "Más antiguos primero",
        .manualTimerNote: "Cambiar los minutos marca el temporizador como manual.", .medium: "Media", .min: "min", .minutes: "Minutos",
        .month: "Mes", .mood: "Estado de ánimo", .mostCommonMood: "Estado de ánimo más común", .mostConsumedTea: "Té más consumido",
        .noData: "Sin datos", .noPendingReviews: "No hay reseñas pendientes.", .noRatings: "Sin valoraciones",
        .noReviewsDetail: "Completa un temporizador y valora tu té cuando quieras.", .noReviewsYet: "No hay reseñas.",
        .noSavedTeasDetail: "Escanea un paquete de té y guárdalo aquí para la próxima vez.", .noSavedTeasYet: "No hay tés guardados.",
        .noTeaMomentsYet: "No hay momentos de té.", .noTeaReviewsYet: "No hay reseñas de té.", .notFoundDatabase: "Té no encontrado en la base.",
        .notReviewedYet: "Todavía no has reseñado este momento de té.", .notYet: "Todavía no", .note: "Nota", .notes: "Notas",
        .openTeaCalendar: "Abrir calendario de té", .optionalShortNote: "Nota breve opcional", .personalized: "Personalizado",
        .personalizedBrewingProfile: "Perfil de infusión personalizado", .personalizedTeaSubtitle: "Guarda un té que aún no está en la base.", .pointCamera: "Apunta la cámara al frente del paquete.",
        .previewUpdated: "Vista previa actualizada. Toca Guardar té cuando esté bien.", .rate: "Valorar", .rateThisTea: "Valorar este té",
        .rating: "Valoración", .reduceTimer15: "Reducir temporizador 15 segundos", .remove: "Eliminar", .removePhoto: "Eliminar foto",
        .review: "Reseña", .reviewedTeas: "Tés reseñados", .reviewPlaceholder: "Escribe qué te pareció el té...", .reviewSortOrder: "Orden de reseñas",
        .reviewSubtitle: "Una reseña trata sobre el té, separada del pensamiento del diario.", .reviewTea: "Reseñar té",
        .saveReview: "Guardar reseña", .saveThought: "Guardar momento", .savedFromPersonalizedSettings: "Guardado desde tus ajustes personalizados. Marca: %@.",
        .savedMomentMessage: "Tu momento de té se ha guardado.",
        .savedTeaMessage: "Té guardado. Puedes usarlo de nuevo sin escanear.",
        .savedTimerRemoval: "Este temporizador se eliminará de tus temporizadores guardados.", .savedTeaRemoval: "Este té se eliminará de Tés guardados.", .sec: "s",
        .scannerBrandDetectedManual: "%@ detectado. Selecciona manualmente el tipo de té.", .scannerSubtitle: "Escanea el texto del paquete para detectar el tipo y sugerir la infusión.",
        .scannerUnclear: "No pude detectar el tipo de té. Inténtalo de nuevo o selecciónalo manualmente.", .scannedBefore: "Ya escaneados",
        .scannedCodePrompt: "Código escaneado: %@. Puedes crear un temporizador personalizado desde la etiqueta.", .scanTeaLabel: "Escanear etiqueta",
        .sectionTea: "Té", .simpleSavedNote: "Nota: té guardado. Puedes usarlo de nuevo sin escanear.",
        .suggested: "Sugerido", .suggestedInfusion: "Infusión sugerida", .takeMoment: "Tómate un momento para ti.",
        .tea: "Té", .teaCalendar: "Calendario de té", .teaCalendarSubtitle: "Mira qué bebiste cada día.",
        .teaDetails: "Detalles del té", .teaExplorer: "Explorador de té", .teaExplorerDetail: "Probaste 5 tés/productos diferentes", .teaFound: "Té encontrado", .teaMoment: "Momento de té",
        .teaMomentsToReview: "Momentos de té por reseñar", .teaName: "Nombre del té", .teaRating: "Valoración del té", .teaStyle: "Estilo de té", .teaType: "Tipo de té",
        .thisMoment: "Este momento", .thisTea: "Este té", .thisTimer: "Este temporizador", .thought: "Pensamientos",
        .thoughtPlaceholder: "Añade tus pensamientos...", .thoughtSaved: "Momento guardado", .timer: "Temporizador",
        .timer15SecSteps: "Pasos de 15 sec", .topType: "Tipo principal", .totalMoments: "Momentos totales", .type: "Tipo",
        .updateMoodThought: "Actualiza el ánimo o pensamiento de este momento de té.", .water: "Agua", .waterC: "Agua C", .week: "Semana"
    ]
]

private func localizedText(_ key: LocalizedTextKey, language: TeaTimerLanguage) -> String {
    localizedTextTable[language]?[key] ?? localizedTextTable[.english]?[key] ?? ""
}

private func localizedText(_ key: LocalizedTextKey, languageRaw: String) -> String {
    localizedText(key, language: TeaTimerLanguage(rawValue: languageRaw) ?? .english)
}

private func localizedProfileIntro(language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return "Create a local profile to personalize your TeaTimer experience. Your data stays on this iPhone."
    case .italian:
        return "Crea un profilo locale per personalizzare la tua esperienza. I dati restano su questo iPhone."
    case .french:
        return "Créez un profil local pour personnaliser votre expérience TeaTimer. Vos données restent sur cet iPhone."
    case .spanish:
        return "Crea un perfil local para personalizar tu experiencia TeaTimer. Tus datos se quedan en este iPhone."
    }
}

private func localizedPrivacyNote(language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return "We use your profile information to personalize your TeaTimer experience. Your data stays on this iPhone in this version."
    case .italian:
        return "Usiamo le informazioni del profilo per personalizzare TeaTimer. In questa versione i tuoi dati restano su questo iPhone."
    case .french:
        return "Nous utilisons les informations de votre profil pour personnaliser TeaTimer. Dans cette version, vos données restent sur cet iPhone."
    case .spanish:
        return "Usamos la información de tu perfil para personalizar TeaTimer. En esta versión, tus datos se quedan en este iPhone."
    }
}

private func localizedProfileEditIntro(language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return "Edit your local TeaTimer profile."
    case .italian:
        return "Modifica il tuo profilo locale TeaTimer."
    case .french:
        return "Modifiez votre profil local TeaTimer."
    case .spanish:
        return "Edita tu perfil local de TeaTimer."
    }
}

private func localizedResetProfileNote(language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return "Reset Profile removes only the local profile. Saved teas, diary, reviews, and photos stay on this phone."
    case .italian:
        return "Reset profilo rimuove solo il profilo locale. Tè salvati, diario, recensioni e foto restano sul telefono."
    case .french:
        return "Réinitialiser le profil supprime seulement le profil local. Les thés enregistrés, le journal, les avis et les photos restent sur ce téléphone."
    case .spanish:
        return "Restablecer perfil elimina solo el perfil local. Los tés guardados, el diario, las reseñas y las fotos permanecen en este teléfono."
    }
}

private func localizedResetProfileConfirmation(language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return "This only removes your local profile. Tea data will not be deleted."
    case .italian:
        return "Rimuove solo il profilo locale. I dati del tè non vengono eliminati."
    case .french:
        return "Cela supprime seulement votre profil local. Les données de thé ne seront pas supprimées."
    case .spanish:
        return "Esto solo elimina tu perfil local. Los datos de té no se eliminarán."
    }
}

private func localizedBirthdayBody(for profile: LocalUserProfile) -> String {
    switch profile.language {
    case .english:
        return "Happy birthday, \(profile.firstName) 🎉 Enjoy a perfect tea moment today."
    case .italian:
        return "Buon compleanno, \(profile.firstName) 🎉 Goditi un momento tè perfetto oggi."
    case .french:
        return "Joyeux anniversaire, \(profile.firstName) 🎉 Profitez d’un parfait moment thé aujourd’hui."
    case .spanish:
        return "Feliz cumpleaños, \(profile.firstName) 🎉 Disfruta de un momento de té perfecto hoy."
    }
}

private let genderOptionKeys = ["prefer-not", "female", "male", "non-binary", "other"]

private func localizedGenderOption(_ key: String, language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return ["prefer-not": "Prefer not to say", "female": "Female", "male": "Male", "non-binary": "Non-binary", "other": "Other"][key] ?? key
    case .italian:
        return ["prefer-not": "Preferisco non dirlo", "female": "Donna", "male": "Uomo", "non-binary": "Non binario", "other": "Altro"][key] ?? key
    case .french:
        return ["prefer-not": "Je préfère ne pas le dire", "female": "Femme", "male": "Homme", "non-binary": "Non binaire", "other": "Autre"][key] ?? key
    case .spanish:
        return ["prefer-not": "Prefiero no decirlo", "female": "Mujer", "male": "Hombre", "non-binary": "No binario", "other": "Otro"][key] ?? key
    }
}

private func genderKey(for storedValue: String) -> String {
    if genderOptionKeys.contains(storedValue) {
        return storedValue
    }

    let normalized = normalizedTeaScanText(storedValue)
    for key in genderOptionKeys {
        if TeaTimerLanguage.allCases.contains(where: { normalizedTeaScanText(localizedGenderOption(key, language: $0)) == normalized }) {
            return key
        }
    }
    return storedValue.isEmpty ? "prefer-not" : "other"
}

private func localizedDefaultTeaName(_ tea: TeaProfile, language: TeaTimerLanguage, shorten: Bool = false) -> String {
    localizedDefaultTeaName(name: tea.name, source: tea.source, language: language, shorten: shorten)
}

private func localizedDefaultTeaName(name: String, source: String?, language: TeaTimerLanguage, shorten: Bool = false) -> String {
    guard source == "default" || source == nil else { return name }
    let normalizedName = normalizedTeaScanText(name)
    let translated: String
    switch language {
    case .english:
        translated = name
    case .italian:
        translated = ["green tea": "Tè verde", "black tea": "Tè nero", "white tea": "Tè bianco", "oolong": "Oolong", "herbal": "Tisana", "herbal tea": "Tisana", "infusion": "Infuso", "matcha": "Matcha", "rooibos": "Rooibos", "mate": "Mate", "fruit infusion": "Infuso alla frutta", "chai": "Chai", "other": "Altro"][normalizedName] ?? name
    case .french:
        translated = ["green tea": "Thé vert", "black tea": "Thé noir", "white tea": "Thé blanc", "oolong": "Oolong", "herbal": "Tisane", "herbal tea": "Tisane", "infusion": "Infusion", "matcha": "Matcha", "rooibos": "Rooibos", "mate": "Maté", "fruit infusion": "Infusion fruitée", "chai": "Chai", "other": "Autre"][normalizedName] ?? name
    case .spanish:
        translated = ["green tea": "Té verde", "black tea": "Té negro", "white tea": "Té blanco", "oolong": "Oolong", "herbal": "Tisana", "herbal tea": "Tisana", "infusion": "Infusión", "matcha": "Matcha", "rooibos": "Rooibos", "mate": "Mate", "fruit infusion": "Infusión de frutas", "chai": "Chai", "other": "Otro"][normalizedName] ?? name
    }
    return shorten ? translated.replacingOccurrences(of: " Tea", with: "") : translated
}

private func localizedDefaultTeaFlavor(_ tea: TeaProfile, language: TeaTimerLanguage) -> String {
    guard tea.source == "default" else { return tea.flavor }
    let key = normalizedTeaScanText(tea.name)
    switch language {
    case .english:
        return tea.flavor
    case .italian:
        return [
            "green tea": "Erbaceo, brillante, leggermente dolce",
            "black tea": "Maltato, ricco, corposo",
            "white tea": "Mielato, delicato, pulito",
            "herbal": "Aromatico, rilassante, espressivo",
            "infusion": "Botanico, delicato, senza caffeina",
            "matcha": "Vivace, erbaceo, concentrato",
            "oolong": "Floreale, tostato, setoso",
            "rooibos": "Rotondo, naturalmente dolce, morbido",
            "chai": "Speziato, caldo, aromatico",
            "fruit infusion": "Fruttato, brillante, senza caffeina"
        ][key] ?? tea.flavor
    case .french:
        return [
            "green tea": "Herbacé, vif, légèrement doux",
            "black tea": "Malté, riche, corsé",
            "white tea": "Mielleux, doux, pur",
            "herbal": "Aromatique, apaisant, expressif",
            "infusion": "Botanique, douce, sans caféine",
            "matcha": "Vif, herbacé, concentré",
            "oolong": "Floral, grillé, soyeux",
            "rooibos": "Rond, naturellement doux, souple",
            "chai": "Épicé, chaleureux, aromatique",
            "fruit infusion": "Fruité, vif, sans caféine"
        ][key] ?? tea.flavor
    case .spanish:
        return [
            "green tea": "Herbáceo, brillante, ligeramente dulce",
            "black tea": "Maltoso, rico, con cuerpo",
            "white tea": "Meloso, suave, limpio",
            "herbal": "Aromático, relajante, expresivo",
            "infusion": "Botánica, suave, sin cafeína",
            "matcha": "Vivo, herbáceo, concentrado",
            "oolong": "Floral, tostado, sedoso",
            "rooibos": "Redondo, naturalmente dulce, suave",
            "chai": "Especiado, cálido, aromático",
            "fruit infusion": "Frutal, brillante, sin cafeína"
        ][key] ?? tea.flavor
    }
}

private func localizedDefaultTeaDetail(_ tea: TeaProfile, language: TeaTimerLanguage) -> String {
    guard tea.source == "default" else { return tea.detail }
    let key = normalizedTeaScanText(tea.name)
    switch language {
    case .english:
        return tea.detail
    case .italian:
        return [
            "green tea": "La maggior parte dei tè verdi viene da Cina e Giappone. Le foglie vengono scaldate subito dopo la raccolta, mantenendo colore fresco e gusto pulito.",
            "black tea": "Il tè nero è diffuso in India, Sri Lanka, Kenya e Cina. L'ossidazione completa dona foglia scura, aroma intenso e più corpo.",
            "white tea": "Il tè bianco è associato soprattutto al Fujian, in Cina. Germogli e foglie giovani sono lavorati poco, per una tazza morbida e delicata.",
            "herbal": "La tisana non è vero tè da Camellia sinensis. Può unire fiori, menta, radici, spezie e frutta per infusioni senza caffeina.",
            "infusion": "Gli infusi usano erbe, fiori, spezie o frutta invece delle foglie di tè. Di solito rendono bene con acqua bollente e infusione più lunga.",
            "matcha": "Il matcha è tè verde in polvere mescolato nell'acqua, non lasciato in infusione come le foglie.",
            "oolong": "L'oolong è legato a Taiwan e al Fujian, in Cina. Sta tra tè verde e nero, spesso con note floreali, tostate o cremose.",
            "rooibos": "Il rooibos è un'infusione sudafricana senza caffeina che regge bene l'acqua bollente.",
            "chai": "Chai e tè speziati spesso uniscono tè nero con cannella, cardamomo, zenzero e altre spezie.",
            "fruit infusion": "Gli infusi alla frutta richiedono spesso acqua calda e più tempo per estrarre sapore da frutta e ibisco."
        ][key] ?? tea.detail
    case .french:
        return [
            "green tea": "La plupart des thés verts viennent de Chine et du Japon. Les feuilles sont chauffées juste après la cueillette, ce qui garde une couleur fraîche et un goût net.",
            "black tea": "Le thé noir est courant en Inde, au Sri Lanka, au Kenya et en Chine. L'oxydation complète donne une feuille sombre, un arôme fort et plus de corps.",
            "white tea": "Le thé blanc est surtout associé au Fujian, en Chine. Les jeunes bourgeons et feuilles sont très peu travaillés, pour une tasse douce et délicate.",
            "herbal": "La tisane n'est pas un vrai thé issu du Camellia sinensis. Elle peut mêler fleurs, menthe, racines, épices et fruits pour des infusions sans caféine.",
            "infusion": "Les infusions utilisent herbes, fleurs, épices ou fruits plutôt que des feuilles de thé. Elles aiment souvent l'eau bouillante et une infusion plus longue.",
            "matcha": "Le matcha est un thé vert en poudre fouetté dans l'eau, plutôt qu'infusé comme des feuilles.",
            "oolong": "L'oolong est lié à Taïwan et au Fujian, en Chine. Il se situe entre thé vert et thé noir, avec des notes souvent florales, grillées ou crémeuses.",
            "rooibos": "Le rooibos est une infusion sud-africaine sans caféine qui supporte bien l'eau bouillante.",
            "chai": "Les chai et thés épicés associent souvent thé noir, cannelle, cardamome, gingembre et autres épices.",
            "fruit infusion": "Les infusions fruitées demandent souvent de l'eau chaude et un temps plus long pour extraire le goût des fruits et de l'hibiscus."
        ][key] ?? tea.detail
    case .spanish:
        return [
            "green tea": "La mayoría de los tés verdes vienen de China y Japón. Las hojas se calientan poco después de la cosecha, conservando color fresco y sabor limpio.",
            "black tea": "El té negro es común en India, Sri Lanka, Kenia y China. La oxidación completa da una hoja más oscura, aroma intenso y más cuerpo.",
            "white tea": "El té blanco se asocia especialmente con Fujian, China. Brotes y hojas jóvenes se procesan muy poco, dando una taza suave y delicada.",
            "herbal": "La tisana no es té verdadero de Camellia sinensis. Puede mezclar flores, menta, raíces, especias y fruta para infusiones sin cafeína.",
            "infusion": "Las infusiones usan hierbas, flores, especias o fruta en lugar de hojas de té. Suelen ir bien con agua hirviendo y más tiempo de infusión.",
            "matcha": "El matcha es té verde en polvo batido en agua, no infusionado como hojas sueltas.",
            "oolong": "El oolong está muy ligado a Taiwán y Fujian, China. Está entre té verde y negro, con notas a menudo florales, tostadas o cremosas.",
            "rooibos": "El rooibos es una infusión sudafricana sin cafeína que funciona bien con agua hirviendo.",
            "chai": "El chai y los tés especiados suelen combinar té negro con canela, cardamomo, jengibre y otras especias.",
            "fruit infusion": "Las infusiones de frutas suelen necesitar agua caliente y más tiempo para extraer sabor de fruta e hibisco."
        ][key] ?? tea.detail
    }
}

private func localizedTeaCategoryLabel(_ name: String, language: TeaTimerLanguage) -> String {
    let normalized = normalizedTeaScanText(name)
    let englishMap: [String: String] = [
        "green": "Green Tea", "green tea": "Green Tea", "black": "Black Tea", "black tea": "Black Tea",
        "white": "White Tea", "white tea": "White Tea", "oolong": "Oolong", "oolong tea": "Oolong",
        "yellow": "Yellow Tea", "yellow tea": "Yellow Tea", "pu erh": "Pu-erh", "puerh": "Pu-erh",
        "herbal": "Herbal Tea", "herbal tea": "Herbal Tea", "infusion": "Infusion", "infuso": "Infusion", "infusione": "Infusion", "fruit": "Fruit Infusion", "fruit infusion": "Fruit Infusion",
        "chai": "Chai", "chai spiced tea": "Chai", "wellness": "Wellness Tea", "wellness tea": "Wellness Tea",
        "cold brew": "Cold Infusion", "cold infusion": "Cold Infusion", "matcha": "Matcha", "rooibos": "Rooibos",
        "mate": "Mate", "other": "Other"
    ]
    let canonical = englishMap[normalized] ?? name

    switch language {
    case .english:
        return canonical
    case .italian:
        return [
            "Green Tea": "Tè verde", "Black Tea": "Tè nero", "White Tea": "Tè bianco", "Oolong": "Oolong",
            "Yellow Tea": "Tè giallo", "Pu-erh": "Pu-erh", "Herbal Tea": "Tisana", "Infusion": "Infuso", "Fruit Infusion": "Infuso alla frutta",
            "Chai": "Chai", "Wellness Tea": "Tè benessere", "Cold Infusion": "Infuso freddo", "Matcha": "Matcha",
            "Rooibos": "Rooibos", "Mate": "Mate", "Other": "Altro"
        ][canonical] ?? name
    case .french:
        return [
            "Green Tea": "Thé vert", "Black Tea": "Thé noir", "White Tea": "Thé blanc", "Oolong": "Oolong",
            "Yellow Tea": "Thé jaune", "Pu-erh": "Pu-erh", "Herbal Tea": "Tisane", "Infusion": "Infusion", "Fruit Infusion": "Infusion fruitée",
            "Chai": "Chai", "Wellness Tea": "Thé bien-être", "Cold Infusion": "Infusion froide", "Matcha": "Matcha",
            "Rooibos": "Rooibos", "Mate": "Maté", "Other": "Autre"
        ][canonical] ?? name
    case .spanish:
        return [
            "Green Tea": "Té verde", "Black Tea": "Té negro", "White Tea": "Té blanco", "Oolong": "Oolong",
            "Yellow Tea": "Té amarillo", "Pu-erh": "Pu-erh", "Herbal Tea": "Tisana", "Infusion": "Infusión", "Fruit Infusion": "Infusión de frutas",
            "Chai": "Chai", "Wellness Tea": "Té bienestar", "Cold Infusion": "Infusión fría", "Matcha": "Matcha",
            "Rooibos": "Rooibos", "Mate": "Mate", "Other": "Otro"
        ][canonical] ?? name
    }
}

private func localizedTeaCategoryLabel(_ name: String, languageRaw: String) -> String {
    localizedTeaCategoryLabel(name, language: TeaTimerLanguage(rawValue: languageRaw) ?? .english)
}

private func localizedMood(_ mood: String, languageRaw: String) -> String {
    let language = TeaTimerLanguage(rawValue: languageRaw) ?? .english
    switch language {
    case .english:
        return mood
    case .italian:
        return ["Peaceful": "Sereno", "Focused": "Concentrato", "Cozy": "Accogliente", "Tired": "Stanco", "Grateful": "Grato", "Reflective": "Riflessivo"][mood] ?? mood
    case .french:
        return ["Peaceful": "Paisible", "Focused": "Concentré", "Cozy": "Douillet", "Tired": "Fatigué", "Grateful": "Reconnaissant", "Reflective": "Réfléchi"][mood] ?? mood
    case .spanish:
        return ["Peaceful": "Tranquilo", "Focused": "Concentrado", "Cozy": "Acogedor", "Tired": "Cansado", "Grateful": "Agradecido", "Reflective": "Reflexivo"][mood] ?? mood
    }
}

private func localizedCaffeineLevel(_ value: String, languageRaw: String) -> String {
    let language = TeaTimerLanguage(rawValue: languageRaw) ?? .english
    let normalized = normalizedTeaScanText(value)
    switch language {
    case .english:
        return value
    case .italian:
        return ["high": "Alta", "medium": "Media", "low": "Bassa", "none": "Senza"][normalized] ?? value
    case .french:
        return ["high": "Élevée", "medium": "Moyenne", "low": "Faible", "none": "Sans"][normalized] ?? value
    case .spanish:
        return ["high": "Alta", "medium": "Media", "low": "Baja", "none": "Sin"][normalized] ?? value
    }
}

private func localizedTeaMomentMessage(for mood: String?, languageRaw: String) -> String {
    let language = TeaTimerLanguage(rawValue: languageRaw) ?? .english
    switch language {
    case .english:
        return teaMomentMessage(for: mood)
    case .italian:
        return "Questo momento tè appartiene a te."
    case .french:
        return "Ce moment thé vous appartient."
    case .spanish:
        return "Este momento de té es tuyo."
    }
}

private func localizedTeaReadyNotificationBody(for session: ActiveTeaTimerSession, teaName: String, language: TeaTimerLanguage) -> String {
    switch language {
    case .english:
        return "Your \(teaName) is ready."
    case .italian:
        return "Il tuo \(teaName) è pronto."
    case .french:
        return "Votre \(teaName) est prêt."
    case .spanish:
        return "Tu \(teaName) está listo."
    }
}

private let birthdayNotificationIdentifier = "TeaTimer.localProfile.birthday"

private func decodeLocalUserProfile(from data: String) -> LocalUserProfile? {
    guard let profileData = data.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(LocalUserProfile.self, from: profileData)
}

private func encodeLocalUserProfile(_ profile: LocalUserProfile) -> String {
    guard let data = try? JSONEncoder().encode(profile),
          let json = String(data: data, encoding: .utf8) else {
        return ""
    }

    return json
}

private func scheduleBirthdayNotification(for profile: LocalUserProfile) {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [birthdayNotificationIdentifier])

    guard let birthday = profile.birthday else { return }

    let calendar = Calendar.current
    var components = calendar.dateComponents([.month, .day], from: birthday)
    components.hour = 9
    components.minute = 0

    let content = UNMutableNotificationContent()
    content.title = "TeaTimer"
    content.body = localizedBirthdayBody(for: profile)
    content.sound = .default

    let request = UNNotificationRequest(
        identifier: birthdayNotificationIdentifier,
        content: content,
        trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    )

    center.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            center.add(request)
        case .notDetermined:
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted {
                    center.add(request)
                }
            }
        default:
            break
        }
    }
}

private func cancelBirthdayNotification() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [birthdayNotificationIdentifier])
}

struct TeaTimerRootView: View {
    @AppStorage("localUserProfile") private var localUserProfileData = ""
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    private var profile: LocalUserProfile? {
        decodeLocalUserProfile(from: localUserProfileData)
    }

    var body: some View {
        if profile == nil {
            LocalProfileRegistrationView { profile in
                languageRaw = profile.language.rawValue
                localUserProfileData = encodeLocalUserProfile(profile)
                scheduleBirthdayNotification(for: profile)
            }
        } else {
            ContentView()
        }
    }
}

private struct LocalProfileRegistrationView: View {
    let onRegister: (LocalUserProfile) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var birthday = Date()
    @State private var hasBirthday = false
    @State private var selectedGenderKey = "prefer-not"
    @State private var nationality = ""
    @State private var language: TeaTimerLanguage = .english

    private var canRegister: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            registrationBackground

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(localizedText(.welcome, language: language))
                            .font(.system(size: 44, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        Text("TeaTimer")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundStyle(Color(red: 0.96, green: 0.67, blue: 0.29))

                        Text(localizedProfileIntro(language: language))
                            .font(.system(size: 16, weight: .medium))
                            .lineSpacing(3)
                            .foregroundStyle(.white.opacity(0.66))
                    }
                    .padding(.top, 44)

                    VStack(spacing: 14) {
                        PremiumTextField(title: localizedText(.firstName, language: language), text: $firstName, placeholder: localizedText(.firstName, language: language))
                        PremiumTextField(title: localizedText(.lastName, language: language), text: $lastName, placeholder: localizedText(.lastName, language: language))
                        PremiumTextField(title: localizedText(.email, language: language), text: $email, placeholder: "name@example.com")
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.gender, language: language))
                                .font(.system(size: 13, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.46))

                            Picker(localizedText(.gender, language: language), selection: $selectedGenderKey) {
                                ForEach(genderOptionKeys, id: \.self) { key in
                                    Text(localizedGenderOption(key, language: language)).tag(key)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                        }
                        PremiumTextField(title: localizedText(.nationality, language: language), text: $nationality, placeholder: localizedText(.optional, language: language))

                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(localizedText(.birthday, language: language), isOn: $hasBirthday)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .tint(Color(red: 0.96, green: 0.67, blue: 0.29))

                            if hasBirthday {
                                DatePicker(localizedText(.birthday, language: language), selection: $birthday, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color(red: 0.96, green: 0.67, blue: 0.29))
                            }
                        }
                        .padding(14)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.language, language: language))
                                .font(.system(size: 13, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.46))

                            Picker(localizedText(.language, language: language), selection: $language) {
                                ForEach(TeaTimerLanguage.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .onChange(of: language) { _, newLanguage in
                                languageRaw = newLanguage.rawValue
                            }
                        }
                    }

                    Text(localizedPrivacyNote(language: language))
                        .font(.system(size: 13, weight: .medium))
                        .lineSpacing(3)
                        .foregroundStyle(.white.opacity(0.52))
                        .padding(14)
                        .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))

                    Button {
                        register()
                    } label: {
                        Label(localizedText(.register, language: language), systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(PrimaryTeaButtonStyle(tint: Color(red: 0.96, green: 0.67, blue: 0.29)))
                    .disabled(!canRegister)
                    .opacity(canRegister ? 1 : 0.45)
                }
                .padding(22)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            language = TeaTimerLanguage(rawValue: languageRaw) ?? .english
        }
    }

    private var registrationBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.025, green: 0.035, blue: 0.030),
                Color(red: 0.07, green: 0.055, blue: 0.032),
                Color(red: 0.005, green: 0.008, blue: 0.006)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func register() {
        let now = Date()
        let profile = LocalUserProfile(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            birthday: hasBirthday ? birthday : nil,
            gender: selectedGenderKey,
            nationality: nationality.trimmingCharacters(in: .whitespacesAndNewlines),
            language: language,
            createdAt: now,
            updatedAt: now
        )
        onRegister(profile)
    }
}

private struct ProfileSettingsSheet: View {
    let tint: Color
    @AppStorage("localUserProfile") private var localUserProfileData = ""
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var birthday = Date()
    @State private var hasBirthday = false
    @State private var selectedGenderKey = "prefer-not"
    @State private var nationality = ""
    @State private var language: TeaTimerLanguage = .english
    @State private var isConfirmingResetProfile = false

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.07, green: 0.055, blue: 0.032),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.profile, language: language))
                                .font(.system(size: 36, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedProfileEditIntro(language: language))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.64))
                        }
                        .padding(.top, 8)

                        VStack(spacing: 14) {
                            PremiumTextField(title: localizedText(.firstName, language: language), text: $firstName, placeholder: localizedText(.firstName, language: language))
                            PremiumTextField(title: localizedText(.lastName, language: language), text: $lastName, placeholder: localizedText(.lastName, language: language))
                            PremiumTextField(title: localizedText(.email, language: language), text: $email, placeholder: "name@example.com")
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizedText(.gender, language: language))
                                    .font(.system(size: 13, weight: .bold))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white.opacity(0.46))

                                Picker(localizedText(.gender, language: language), selection: $selectedGenderKey) {
                                    ForEach(genderOptionKeys, id: \.self) { key in
                                        Text(localizedGenderOption(key, language: language)).tag(key)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                            }
                            PremiumTextField(title: localizedText(.nationality, language: language), text: $nationality, placeholder: localizedText(.optional, language: language))

                            VStack(alignment: .leading, spacing: 10) {
                                Toggle(localizedText(.birthday, language: language), isOn: $hasBirthday)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                                    .tint(tint)

                                if hasBirthday {
                                    DatePicker(localizedText(.birthday, language: language), selection: $birthday, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(tint)
                                }
                            }
                            .padding(14)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizedText(.language, language: language))
                                    .font(.system(size: 13, weight: .bold))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white.opacity(0.46))

                                Picker(localizedText(.language, language: language), selection: $language) {
                                    ForEach(TeaTimerLanguage.allCases) { option in
                                        Text(option.title).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.white)
                            }
                        }

                        Text(localizedResetProfileNote(language: language))
                            .font(.system(size: 13, weight: .medium))
                            .lineSpacing(3)
                            .foregroundStyle(.white.opacity(0.52))
                            .padding(14)
                            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))

                        VStack(spacing: 10) {
                            Button {
                                saveProfile()
                            } label: {
                                Label(localizedText(.save, language: language), systemImage: "checkmark")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(PrimaryTeaButtonStyle(tint: tint))
                            .disabled(!canSave)
                            .opacity(canSave ? 1 : 0.45)

                            Button(role: .destructive) {
                                isConfirmingResetProfile = true
                            } label: {
                                Label(localizedText(.resetProfile, language: language), systemImage: "person.crop.circle.badge.xmark")
                                    .font(.system(size: 15, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                            }
                            .buttonStyle(SecondaryTeaButtonStyle())
                        }
                    }
                    .padding(22)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.cancel, language: language)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
            .alert(localizedText(.resetProfile, language: language), isPresented: $isConfirmingResetProfile) {
                Button(localizedText(.resetProfile, language: language), role: .destructive) {
                    localUserProfileData = ""
                    cancelBirthdayNotification()
                    dismiss()
                }
                Button(localizedText(.cancel, language: language), role: .cancel) {}
            } message: {
                Text(localizedResetProfileConfirmation(language: language))
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear(perform: loadProfile)
    }

    private func loadProfile() {
        language = TeaTimerLanguage(rawValue: languageRaw) ?? .english
        guard let profile = decodeLocalUserProfile(from: localUserProfileData) else { return }
        firstName = profile.firstName
        lastName = profile.lastName
        email = profile.email
        if let profileBirthday = profile.birthday {
            birthday = profileBirthday
            hasBirthday = true
        } else {
            hasBirthday = false
        }
        selectedGenderKey = genderKey(for: profile.gender)
        nationality = profile.nationality
        language = profile.language
    }

    private func saveProfile() {
        let existingProfile = decodeLocalUserProfile(from: localUserProfileData)
        let profile = LocalUserProfile(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            birthday: hasBirthday ? birthday : nil,
            gender: selectedGenderKey,
            nationality: nationality.trimmingCharacters(in: .whitespacesAndNewlines),
            language: language,
            createdAt: existingProfile?.createdAt ?? Date(),
            updatedAt: Date()
        )

        languageRaw = language.rawValue
        localUserProfileData = encodeLocalUserProfile(profile)
        scheduleBirthdayNotification(for: profile)
        dismiss()
    }
}


struct TeaProfile: Identifiable, Equatable {
    let id: UUID
    let name: String
    let category: String
    let temperature: String
    let steepSeconds: Int
    let caffeine: String
    let flavor: String
    let detail: String
    let imageName: String
    let origin: String
    let process: String
    let character: String
    let source: String?
    let productId: String?
    let producer: String?
    let qrCodeValue: String?
    let barcodeValue: String?
    let brewTimeSource: String?
    let originalDetectedTimeText: String?
    let temperatureSource: String?
    let originalDetectedTemperatureText: String?
    let tint: Color

    init(
        id: UUID = UUID(),
        name: String,
        category: String,
        temperature: String,
        steepSeconds: Int,
        caffeine: String,
        flavor: String,
        detail: String,
        imageName: String,
        origin: String,
        process: String,
        character: String,
        source: String? = nil,
        productId: String? = nil,
        producer: String? = nil,
        qrCodeValue: String? = nil,
        barcodeValue: String? = nil,
        brewTimeSource: String? = nil,
        originalDetectedTimeText: String? = nil,
        temperatureSource: String? = nil,
        originalDetectedTemperatureText: String? = nil,
        tint: Color
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.temperature = temperature
        self.steepSeconds = steepSeconds
        self.caffeine = caffeine
        self.flavor = flavor
        self.detail = detail
        self.imageName = imageName
        self.origin = origin
        self.process = process
        self.character = character
        self.source = source
        self.productId = productId
        self.producer = producer
        self.qrCodeValue = qrCodeValue
        self.barcodeValue = barcodeValue
        self.brewTimeSource = brewTimeSource
        self.originalDetectedTimeText = originalDetectedTimeText
        self.temperatureSource = temperatureSource
        self.originalDetectedTemperatureText = originalDetectedTemperatureText
        self.tint = tint
    }

    var steepTime: String {
        let minutes = steepSeconds / 60
        let seconds = steepSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

private struct SavedTeaProfile: Codable {
    let id: UUID
    let name: String
    let category: String
    let temperature: String
    let steepSeconds: Int
    let caffeine: String
    let flavor: String
    let detail: String
    let imageName: String
    let origin: String
    let process: String
    let character: String
    let source: String?
    let productId: String?
    let producer: String?
    let qrCodeValue: String?
    let barcodeValue: String?
    let brewTimeSource: String?
    let originalDetectedTimeText: String?
    let temperatureSource: String?
    let originalDetectedTemperatureText: String?
    let tintRed: Double
    let tintGreen: Double
    let tintBlue: Double

    init(from tea: TeaProfile, tintRGB: (Double, Double, Double)) {
        id = tea.id
        name = tea.name
        category = tea.category
        temperature = tea.temperature
        steepSeconds = tea.steepSeconds
        caffeine = tea.caffeine
        flavor = tea.flavor
        detail = tea.detail
        imageName = tea.imageName
        origin = tea.origin
        process = tea.process
        character = tea.character
        source = tea.source
        productId = tea.productId
        producer = tea.producer
        qrCodeValue = tea.qrCodeValue
        barcodeValue = tea.barcodeValue
        brewTimeSource = tea.brewTimeSource
        originalDetectedTimeText = tea.originalDetectedTimeText
        temperatureSource = tea.temperatureSource
        originalDetectedTemperatureText = tea.originalDetectedTemperatureText
        tintRed = tintRGB.0
        tintGreen = tintRGB.1
        tintBlue = tintRGB.2
    }

    var teaProfile: TeaProfile {
        TeaProfile(
            id: id,
            name: name,
            category: category,
            temperature: temperature,
            steepSeconds: steepSeconds,
            caffeine: caffeine,
            flavor: flavor,
            detail: detail,
            imageName: imageName,
            origin: origin,
            process: process,
            character: character,
            source: source,
            productId: productId,
            producer: producer,
            qrCodeValue: qrCodeValue,
            barcodeValue: barcodeValue,
            brewTimeSource: brewTimeSource,
            originalDetectedTimeText: originalDetectedTimeText,
            temperatureSource: temperatureSource,
            originalDetectedTemperatureText: originalDetectedTemperatureText,
            tint: Color(red: tintRed, green: tintGreen, blue: tintBlue)
        )
    }
}

private struct TeaMoment: Identifiable, Codable {
    let id: UUID
    let teaName: String
    let date: Date
    let infusionTimeUsed: Int
    let suggestedInfusionTime: Int
    let waterTemperature: String
    let caffeineLevel: String
    let mood: String?
    let note: String?
    let teaImageName: String
    let teaCategory: String
    let source: String?
    let rating: Int?
    let review: String?
    let productId: String?
    let producer: String?
    let qrCodeValue: String?
    let barcodeValue: String?
    let photoFilename: String?
}

private func teaMomentPhotosDirectory() -> URL? {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }

    let directory = documentsDirectory.appendingPathComponent("TeaMomentPhotos", isDirectory: true)
    if !FileManager.default.fileExists(atPath: directory.path) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    return directory
}

private func teaMomentPhotoURL(filename: String?) -> URL? {
    guard let filename,
          !filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          let directory = teaMomentPhotosDirectory() else {
        return nil
    }

    return directory.appendingPathComponent(filename)
}

private func teaMomentPhotoImage(filename: String?) -> UIImage? {
    guard let url = teaMomentPhotoURL(filename: filename) else { return nil }
    return UIImage(contentsOfFile: url.path)
}

private func saveTeaMomentPhoto(_ image: UIImage) -> String? {
    guard let directory = teaMomentPhotosDirectory(),
          let data = image.jpegData(compressionQuality: 0.82) else {
        return nil
    }

    let filename = "\(UUID().uuidString).jpg"
    let url = directory.appendingPathComponent(filename)

    do {
        try data.write(to: url, options: [.atomic])
        return filename
    } catch {
        return nil
    }
}

private func deleteTeaMomentPhoto(filename: String?) {
    guard let url = teaMomentPhotoURL(filename: filename) else { return }
    try? FileManager.default.removeItem(at: url)
}

private func normalizedReviewComponent(_ value: String?) -> String {
    (value ?? "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
}

private func teaReviewIdentity(
    teaName: String,
    teaCategory: String,
    productId: String?,
    producer: String?,
    qrCodeValue: String?,
    barcodeValue: String?
) -> String {
    let cleanProductId = normalizedReviewComponent(productId)
    if !cleanProductId.isEmpty {
        return "product:\(cleanProductId)"
    }

    let cleanQRCode = normalizedReviewComponent(qrCodeValue)
    if !cleanQRCode.isEmpty {
        return "qr:\(cleanQRCode)"
    }

    let cleanBarcode = normalizedReviewComponent(barcodeValue)
    if !cleanBarcode.isEmpty {
        return "barcode:\(cleanBarcode)"
    }

    let cleanProducer = normalizedReviewComponent(producer)
    let cleanTeaName = normalizedReviewComponent(teaName)
    if !cleanProducer.isEmpty {
        return "producer:\(cleanProducer):\(cleanTeaName)"
    }

    return "generic:\(normalizedReviewComponent(teaCategory)):\(cleanTeaName)"
}

private func teaReviewIdentity(for moment: TeaMoment) -> String {
    teaReviewIdentity(
        teaName: moment.teaName,
        teaCategory: moment.teaCategory,
        productId: moment.productId,
        producer: moment.producer,
        qrCodeValue: moment.qrCodeValue,
        barcodeValue: moment.barcodeValue
    )
}

private func isTeaMomentReviewed(_ moment: TeaMoment) -> Bool {
    let hasRating = (moment.rating ?? 0) > 0
    let hasReview = !(moment.review?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    return hasRating || hasReview
}

private struct TeaSessionDraft: Identifiable {
    let id: UUID
    let teaName: String
    let infusionTimeUsed: Int
    let suggestedInfusionTime: Int
    let waterTemperature: String
    let caffeineLevel: String
    let teaImageName: String
    let teaCategory: String
    let source: String?
    let productId: String?
    let producer: String?
    let qrCodeValue: String?
    let barcodeValue: String?
    var mood: String?
    var note: String?
    var photoFilename: String?
    var didSaveMoment: Bool
}

private struct ActiveTeaTimerSession: Identifiable, Codable {
    var id: UUID
    var teaName: String
    var teaType: String
    var durationSeconds: Int
    var remainingSeconds: Int
    var startDate: Date
    var endDate: Date
    var timerState: String
    var suggestedInfusionTime: Int
    var waterTemperature: String
    var caffeineLevel: String
    var teaImageName: String
    var teaCategory: String
    var source: String?
    var productId: String?
    var producer: String?
    var qrCodeValue: String?
    var barcodeValue: String?
    var origin: String
    var process: String
    var character: String
    var detail: String
    var brewTimeSource: String?
    var originalDetectedTimeText: String?
    var mood: String?
    var note: String?
    var photoFilename: String?
    var didSaveMoment: Bool
}

private let teaReadyNotificationIdentifier = "TeaTimer.activeTeaTimer.ready"

private struct TeaStylePreset: Identifiable {
    let id: String
    let title: String
    let category: String
    let temperature: String
    let caffeine: String
    let imageName: String
    let tintRGB: (Double, Double, Double)
    let process: String
    let character: String

    var tint: Color {
        Color(red: tintRGB.0, green: tintRGB.1, blue: tintRGB.2)
    }
}

private let teaStylePresets: [TeaStylePreset] = [
    TeaStylePreset(id: "green", title: "Green", category: "Fresh", temperature: "80 C", caffeine: "Medium", imageName: "green-tea-leaves", tintRGB: (0.45, 0.86, 0.53), process: "Unoxidized", character: "Fresh"),
    TeaStylePreset(id: "black", title: "Black", category: "Bold", temperature: "95 C", caffeine: "High", imageName: "black-tea-leaves", tintRGB: (0.95, 0.67, 0.28), process: "Fully oxidized", character: "Bold"),
    TeaStylePreset(id: "oolong", title: "Oolong", category: "Layered", temperature: "90 C", caffeine: "Medium", imageName: "oolong-tea-leaves", tintRGB: (0.70, 0.84, 0.68), process: "Part oxidized", character: "Layered"),
    TeaStylePreset(id: "white", title: "White", category: "Soft", temperature: "75 C", caffeine: "Low", imageName: "white-tea-leaves", tintRGB: (0.92, 0.88, 0.70), process: "Minimal", character: "Delicate"),
    TeaStylePreset(id: "yellow", title: "Yellow", category: "Mellow", temperature: "80 C", caffeine: "Medium", imageName: "green-tea-leaves", tintRGB: (0.92, 0.78, 0.34), process: "Lightly oxidized", character: "Mellow"),
    TeaStylePreset(id: "puerh", title: "Pu-erh", category: "Earthy", temperature: "95 C", caffeine: "Medium", imageName: "black-tea-leaves", tintRGB: (0.63, 0.40, 0.25), process: "Fermented", character: "Earthy"),
    TeaStylePreset(id: "matcha", title: "Matcha", category: "Vivid", temperature: "75 C", caffeine: "High", imageName: "green-tea-leaves", tintRGB: (0.40, 0.82, 0.38), process: "Powdered", character: "Vivid"),
    TeaStylePreset(id: "rooibos", title: "Rooibos", category: "Soft", temperature: "100 C", caffeine: "None", imageName: "herbal-tea-leaves", tintRGB: (0.88, 0.42, 0.26), process: "Infusion", character: "Naturally sweet"),
    TeaStylePreset(id: "mate", title: "Mate", category: "Energizing", temperature: "80 C", caffeine: "High", imageName: "herbal-tea-leaves", tintRGB: (0.48, 0.72, 0.34), process: "Infusion", character: "Energizing"),
    TeaStylePreset(id: "herbal", title: "Herbal", category: "Calm", temperature: "100 C", caffeine: "None", imageName: "herbal-tea-leaves", tintRGB: (0.83, 0.55, 0.88), process: "Infusion", character: "Calm"),
    TeaStylePreset(id: "infusion", title: "Infusion", category: "Botanical", temperature: "100 C", caffeine: "None", imageName: "herbal-tea-leaves", tintRGB: (0.70, 0.62, 0.90), process: "Infusion", character: "Botanical"),
    TeaStylePreset(id: "fruit", title: "Fruit", category: "Bright", temperature: "100 C", caffeine: "None", imageName: "herbal-tea-leaves", tintRGB: (0.92, 0.36, 0.48), process: "Fruit infusion", character: "Juicy"),
    TeaStylePreset(id: "chai", title: "Chai", category: "Spiced", temperature: "95 C", caffeine: "High", imageName: "black-tea-leaves", tintRGB: (0.90, 0.55, 0.25), process: "Spiced blend", character: "Warming"),
    TeaStylePreset(id: "wellness", title: "Wellness", category: "Botanical", temperature: "100 C", caffeine: "None", imageName: "herbal-tea-leaves", tintRGB: (0.62, 0.76, 0.54), process: "Functional infusion", character: "Restorative"),
    TeaStylePreset(id: "cold", title: "Cold Brew", category: "Cold", temperature: "20 C", caffeine: "Low", imageName: "green-tea-leaves", tintRGB: (0.44, 0.78, 0.86), process: "Cold infusion", character: "Refreshing"),
    TeaStylePreset(id: "other", title: "Other", category: "Flexible", temperature: "90 C", caffeine: "Medium", imageName: "herbal-tea-leaves", tintRGB: (0.72, 0.72, 0.72), process: "Tea", character: "Flexible")
]

private func teaStylePreset(id: String) -> TeaStylePreset {
    teaStylePresets.first { $0.id == id } ?? teaStylePresets[0]
}

private struct KnownTeaProduct: Identifiable {
    let id: String
    let teaName: String
    let type: String
    let producer: String
    let styleId: String
    let suggestedInfusionTime: Int
    let waterTemperature: String
    let caffeineLevel: String
    let flavorNotes: String
    let description: String
    let qrCodeValue: String
    let barcodeValue: String?
    let imageName: String?
}

private let knownTeaProducts: [KnownTeaProduct] = [
    KnownTeaProduct(id: "twinings-pure-green", teaName: "Pure Green Tea", type: "Green Tea", producer: "Twinings", styleId: "green", suggestedInfusionTime: 150, waterTemperature: "80 C", caffeineLevel: "Medium", flavorNotes: "Green tea", description: "Default green tea profile.", qrCodeValue: "TWININGS-GREEN-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "dammann-jasmine-green", teaName: "Jasmine Green Tea", type: "Green Tea", producer: "Dammann Frères", styleId: "green", suggestedInfusionTime: 150, waterTemperature: "80 C", caffeineLevel: "Medium", flavorNotes: "Jasmine green tea", description: "Default jasmine green tea profile.", qrCodeValue: "DAMMANN-GREEN-JASMINE-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "kusmi-green-tea", teaName: "Green Tea", type: "Green Tea", producer: "Kusmi Tea", styleId: "green", suggestedInfusionTime: 180, waterTemperature: "80 C", caffeineLevel: "Medium", flavorNotes: "Green tea", description: "Default green tea profile.", qrCodeValue: "KUSMI-GREEN-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "sencha-classic", teaName: "Sencha Classic", type: "Green Tea", producer: "Starter Database", styleId: "green", suggestedInfusionTime: 150, waterTemperature: "80 C", caffeineLevel: "Medium", flavorNotes: "Sencha green tea", description: "Default sencha profile.", qrCodeValue: "TEA-GREEN-SENCHA-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "matcha", teaName: "Matcha", type: "Matcha", producer: "Starter Database", styleId: "matcha", suggestedInfusionTime: 90, waterTemperature: "75 C", caffeineLevel: "High", flavorNotes: "Matcha", description: "Default matcha profile.", qrCodeValue: "TEA-MATCHA-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "twinings-english-breakfast", teaName: "English Breakfast", type: "Black Tea", producer: "Twinings", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Black tea", description: "Default English Breakfast profile.", qrCodeValue: "TWININGS-BLACK-ENGLISH-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "twinings-earl-grey", teaName: "Earl Grey", type: "Black Tea", producer: "Twinings", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Earl Grey black tea", description: "Default Earl Grey profile.", qrCodeValue: "TWININGS-BLACK-EARLGREY-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "dammann-earl-grey", teaName: "Earl Grey", type: "Black Tea", producer: "Dammann Frères", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Earl Grey black tea", description: "Default Dammann Earl Grey profile.", qrCodeValue: "DAMMANN-BLACK-EARLGREY-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "yorkshire-tea", teaName: "Yorkshire Tea", type: "Black Tea", producer: "Yorkshire Tea", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Black tea", description: "Default black tea profile.", qrCodeValue: "YORKSHIRE-BLACK-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "pg-tips", teaName: "PG Tips", type: "Black Tea", producer: "PG Tips", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Black tea", description: "Default black tea profile.", qrCodeValue: "PGTIPS-BLACK-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "tetley-original", teaName: "Tetley Original", type: "Black Tea", producer: "Tetley", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Black tea", description: "Default black tea profile.", qrCodeValue: "TETLEY-BLACK-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "ahmad-english-breakfast", teaName: "English Breakfast", type: "Black Tea", producer: "Ahmad Tea", styleId: "black", suggestedInfusionTime: 240, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Black tea", description: "Default English Breakfast profile.", qrCodeValue: "AHMAD-BLACK-ENGLISH-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "white-tea", teaName: "White Tea", type: "White Tea", producer: "Starter Database", styleId: "white", suggestedInfusionTime: 180, waterTemperature: "75 C", caffeineLevel: "Low", flavorNotes: "White tea", description: "Default white tea profile.", qrCodeValue: "TEA-WHITE-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "pai-mu-tan", teaName: "Pai Mu Tan / Bai Mu Dan", type: "White Tea", producer: "Starter Database", styleId: "white", suggestedInfusionTime: 180, waterTemperature: "75 C", caffeineLevel: "Low", flavorNotes: "White tea", description: "Default white tea profile.", qrCodeValue: "TEA-WHITE-PAIMUTAN-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "white-tea-jasmine", teaName: "White Tea Jasmine", type: "White Tea", producer: "Starter Database", styleId: "white", suggestedInfusionTime: 180, waterTemperature: "75 C", caffeineLevel: "Low", flavorNotes: "White tea jasmine", description: "Default white tea profile.", qrCodeValue: "TEA-WHITE-JASMINE-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "oolong", teaName: "Oolong", type: "Oolong", producer: "Starter Database", styleId: "oolong", suggestedInfusionTime: 210, waterTemperature: "90 C", caffeineLevel: "Medium", flavorNotes: "Oolong", description: "Default oolong profile.", qrCodeValue: "TEA-OOLONG-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "milky-oolong", teaName: "Milky Oolong", type: "Oolong", producer: "Starter Database", styleId: "oolong", suggestedInfusionTime: 210, waterTemperature: "90 C", caffeineLevel: "Medium", flavorNotes: "Oolong", description: "Default oolong profile.", qrCodeValue: "TEA-OOLONG-MILKY-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "tie-guan-yin", teaName: "Tie Guan Yin", type: "Oolong", producer: "Starter Database", styleId: "oolong", suggestedInfusionTime: 210, waterTemperature: "90 C", caffeineLevel: "Medium", flavorNotes: "Oolong", description: "Default oolong profile.", qrCodeValue: "TEA-OOLONG-TIEGUANYIN-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "chamomile", teaName: "Chamomile / Camomilla", type: "Herbal Tea", producer: "Starter Database", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Chamomile", description: "Default chamomile infusion profile.", qrCodeValue: "TEA-HERBAL-CHAMOMILE-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "peppermint", teaName: "Peppermint / Menta", type: "Herbal Tea", producer: "Starter Database", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Mint", description: "Default mint infusion profile.", qrCodeValue: "TEA-HERBAL-MINT-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "fennel", teaName: "Fennel / Finocchio", type: "Herbal Tea", producer: "Starter Database", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Fennel", description: "Default fennel infusion profile.", qrCodeValue: "TEA-HERBAL-FENNEL-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "ginger-lemon", teaName: "Ginger Lemon", type: "Herbal Tea", producer: "Starter Database", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Ginger lemon", description: "Default ginger infusion profile.", qrCodeValue: "TEA-HERBAL-GINGERLEMON-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "verbena", teaName: "Verbena", type: "Herbal Tea", producer: "Starter Database", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Verbena", description: "Default verbena infusion profile.", qrCodeValue: "TEA-HERBAL-VERBENA-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "hibiscus", teaName: "Hibiscus", type: "Herbal Tea", producer: "Starter Database", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Hibiscus", description: "Default hibiscus infusion profile.", qrCodeValue: "TEA-HERBAL-HIBISCUS-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "rooibos-vanilla", teaName: "Rooibos Vanilla", type: "Rooibos", producer: "Starter Database", styleId: "rooibos", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Rooibos vanilla", description: "Default rooibos profile.", qrCodeValue: "TEA-ROOIBOS-VANILLA-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "yogi-classic", teaName: "Yogi Tea Classic", type: "Chai / Spiced Tea", producer: "Yogi Tea", styleId: "chai", suggestedInfusionTime: 420, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Spiced infusion", description: "Default spiced infusion profile.", qrCodeValue: "YOGI-CLASSIC-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "pukka-night-time", teaName: "Night Time", type: "Wellness Tea", producer: "Pukka", styleId: "wellness", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Wellness infusion", description: "Default wellness infusion profile.", qrCodeValue: "PUKKA-NIGHTTIME-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "clipper-herbal", teaName: "Herbal Infusion", type: "Herbal Tea", producer: "Clipper", styleId: "herbal", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Herbal infusion", description: "Default herbal infusion profile.", qrCodeValue: "CLIPPER-HERBAL-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "forest-fruits", teaName: "Forest Fruits", type: "Fruit Infusion", producer: "Starter Database", styleId: "fruit", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Fruit infusion", description: "Default fruit infusion profile.", qrCodeValue: "TEA-FRUIT-FOREST-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "apple-cinnamon", teaName: "Apple Cinnamon", type: "Fruit Infusion", producer: "Starter Database", styleId: "fruit", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Fruit infusion", description: "Default fruit infusion profile.", qrCodeValue: "TEA-FRUIT-APPLECINNAMON-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "lemon-ginger", teaName: "Lemon Ginger", type: "Fruit Infusion", producer: "Starter Database", styleId: "fruit", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Fruit infusion", description: "Default fruit infusion profile.", qrCodeValue: "TEA-FRUIT-LEMONGINGER-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "berry-infusion", teaName: "Berry Infusion", type: "Fruit Infusion", producer: "Starter Database", styleId: "fruit", suggestedInfusionTime: 300, waterTemperature: "100 C", caffeineLevel: "None", flavorNotes: "Fruit infusion", description: "Default berry infusion profile.", qrCodeValue: "TEA-FRUIT-BERRY-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "chai", teaName: "Chai", type: "Chai / Spiced Tea", producer: "Starter Database", styleId: "chai", suggestedInfusionTime: 300, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Chai", description: "Default chai profile.", qrCodeValue: "TEA-CHAI-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "masala-chai", teaName: "Masala Chai", type: "Chai / Spiced Tea", producer: "Starter Database", styleId: "chai", suggestedInfusionTime: 300, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Masala chai", description: "Default chai profile.", qrCodeValue: "TEA-CHAI-MASALA-001", barcodeValue: nil, imageName: nil),
    KnownTeaProduct(id: "cinnamon-cardamom", teaName: "Cinnamon Cardamom", type: "Chai / Spiced Tea", producer: "Starter Database", styleId: "chai", suggestedInfusionTime: 300, waterTemperature: "95 C", caffeineLevel: "High", flavorNotes: "Spiced tea", description: "Default spiced tea profile.", qrCodeValue: "TEA-CHAI-CINNAMONCARDAMOM-001", barcodeValue: nil, imageName: nil)
]

private func teaProfile(from product: KnownTeaProduct) -> TeaProfile {
    let style = teaStylePreset(id: product.styleId)
    return TeaProfile(
        name: product.teaName,
        category: style.category,
        temperature: product.waterTemperature,
        steepSeconds: product.suggestedInfusionTime,
        caffeine: product.caffeineLevel,
        flavor: product.flavorNotes,
        detail: "\(product.description) Matched from \(product.producer) using code \(product.qrCodeValue).",
        imageName: product.imageName ?? style.imageName,
        origin: product.producer,
        process: style.process,
        character: style.character,
        source: "scanned",
        productId: product.id,
        producer: product.producer,
        qrCodeValue: product.qrCodeValue,
        barcodeValue: product.barcodeValue,
        tint: style.tint
    )
}

private func knownTeaProduct(matching scannedValue: String, in products: [KnownTeaProduct] = knownTeaProducts) -> KnownTeaProduct? {
    let normalizedScan = scannedValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return products.first { product in
        product.qrCodeValue.lowercased() == normalizedScan || product.barcodeValue?.lowercased() == normalizedScan
    }
}

private func knownTeaProduct(matchingText normalizedText: String, in products: [KnownTeaProduct] = knownTeaProducts) -> KnownTeaProduct? {
    products.first { product in
        let producer = normalizedTeaScanText(product.producer)
        let teaName = normalizedTeaScanText(product.teaName)
        guard !teaName.isEmpty else { return false }

        if !producer.isEmpty, normalizedText.contains(producer), normalizedText.contains(teaName) {
            return true
        }

        return normalizedText.contains(teaName) && teaTextKeywordMatches.contains { normalizedText.contains(normalizedTeaScanText($0.keyword)) }
    }
}

private struct TeaTextScanResult: Identifiable, Equatable {
    let id = UUID()
    var rawText: String
    var styleId: String
    var detectedName: String
    var detectedTeaTypeName: String?
    var matchedKeyword: String
    var brandName: String?
    var packageBrewTimeSeconds: Int?
    var editedBrewTimeSeconds: Int?
    var originalDetectedTimeText: String?
    var packageTemperature: String?
    var editedTemperature: String?
    var originalDetectedTemperatureText: String?
    var notes: String?

    var teaTypeName: String {
        if let detectedTeaTypeName, !detectedTeaTypeName.isEmpty {
            return detectedTeaTypeName
        }

        let style = teaStylePreset(id: styleId)
        if style.title == "Herbal" { return "Herbal Tea" }
        if style.title == "Infusion" { return "Infusion" }
        return "\(style.title) Tea"
    }

    var suggestedBrewTime: Int {
        if let editedBrewTimeSeconds {
            return editedBrewTimeSeconds
        }

        if let packageBrewTimeSeconds {
            return packageBrewTimeSeconds
        }

        return defaultBrewTime
    }

    var defaultBrewTime: Int {
        let style = teaStylePreset(id: styleId)
        if ["herbal", "infusion", "fruit", "rooibos", "wellness"].contains(style.id) { return 300 }
        if style.id == "chai" { return 300 }
        if style.id == "cold" { return 480 }
        if style.id == "matcha" { return 90 }
        if style.id == "black" { return 240 }
        if style.id == "puerh" { return 240 }
        if style.id == "mate" { return 300 }
        if style.id == "yellow" { return 180 }
        return teaProfiles.first { $0.name.localizedCaseInsensitiveContains(style.title) }?.steepSeconds ?? 180
    }

    var brewTimeSource: String {
        if editedBrewTimeSeconds != nil {
            return "manual"
        }

        return packageBrewTimeSeconds == nil ? "default" : "package"
    }

    var brewTimeSourceLabel: String {
        if editedBrewTimeSeconds != nil {
            return "Timer: \(suggestedBrewTime.minuteText) · manual"
        } else if packageBrewTimeSeconds != nil {
            return "Timer: \(suggestedBrewTime.minuteText) · from package"
        }

        return "Timer: \(suggestedBrewTime.minuteText) · default for \(teaTypeName)"
    }

    var suggestedTemperature: String {
        if let editedTemperature, !editedTemperature.isEmpty {
            return editedTemperature
        }

        if let packageTemperature, !packageTemperature.isEmpty {
            return packageTemperature
        }

        return teaStylePreset(id: styleId).temperature
    }

    var temperatureSource: String {
        if editedTemperature != nil {
            return "manual"
        }

        return packageTemperature == nil ? "default" : "package"
    }

    var temperatureSourceLabel: String {
        if editedTemperature != nil {
            return "\(suggestedTemperature) · manual"
        } else if packageTemperature != nil {
            return "\(suggestedTemperature) · from package"
        }

        return "\(suggestedTemperature) · default"
    }
}

private struct BrewTimeDetection: Equatable {
    let seconds: Int
    let originalText: String
}

private struct TemperatureDetection: Equatable {
    let temperature: String
    let originalText: String
}

private let editableTeaTypeOptions = [
    "Green Tea",
    "Black Tea",
    "White Tea",
    "Oolong Tea",
    "Yellow Tea",
    "Pu-erh",
    "Herbal Tea",
    "Infusion",
    "Fruit Infusion",
    "Chai / Spiced Tea",
    "Wellness Tea",
    "Cold Infusion",
    "Matcha",
    "Rooibos",
    "Mate",
    "Other"
]

private struct TeaBrandMatch: Equatable {
    let canonicalName: String
    let variations: [String]
}

private struct SavedScannedTea: Identifiable, Codable, Equatable {
    var id: UUID
    var teaName: String
    var brandName: String?
    var teaType: String
    var styleId: String
    var suggestedBrewTime: Int
    var brewTimeSource: String?
    var originalDetectedTimeText: String?
    var detectedTemperature: String?
    var temperatureSource: String?
    var originalDetectedTemperatureText: String?
    var scannedText: String
    var detectionKeywords: [String]
    var dateAdded: Date
    var lastUsedDate: Date
    var usageCount: Int
    var notes: String?

    var brewTimeSourceLabel: String {
        if brewTimeSource == "manual" {
            return "Timer: \(suggestedBrewTime.minuteText) · manual"
        } else if brewTimeSource == "package" {
            return "Timer: \(suggestedBrewTime.minuteText) · from package"
        }

        return "Timer: \(suggestedBrewTime.minuteText) · default for \(teaType)"
    }

    var temperatureSourceLabel: String {
        guard let detectedTemperature, !detectedTemperature.isEmpty else { return "" }
        if temperatureSource == "manual" {
            return "\(detectedTemperature) · manual"
        } else if temperatureSource == "package" {
            return "\(detectedTemperature) · from package"
        }

        return "\(detectedTemperature) · default"
    }
}

private let teaTextKeywordMatches: [(keyword: String, styleId: String, detectedName: String)] = [
    ("earl grey", "black", "Earl Grey"),
    ("english breakfast", "black", "English Breakfast"),
    ("pure green tea", "green", "Pure Green Tea"),
    ("jasmine green", "green", "Jasmine Green Tea"),
    ("yellow tea", "yellow", "Yellow Tea"),
    ("the jaune", "yellow", "Yellow Tea"),
    ("te amarillo", "yellow", "Yellow Tea"),
    ("green tea", "green", "Green Tea"),
    ("the vert", "green", "Green Tea"),
    ("te verde", "green", "Green Tea"),
    ("black tea", "black", "Black Tea"),
    ("the noir", "black", "Black Tea"),
    ("te nero", "black", "Black Tea"),
    ("te negro", "black", "Black Tea"),
    ("white tea", "white", "White Tea"),
    ("the blanc", "white", "White Tea"),
    ("te bianco", "white", "White Tea"),
    ("te blanco", "white", "White Tea"),
    ("pu erh", "puerh", "Pu-erh"),
    ("puerh", "puerh", "Pu-erh"),
    ("pu er", "puerh", "Pu-erh"),
    ("oolong tea", "oolong", "Oolong Tea"),
    ("oolong", "oolong", "Oolong"),
    ("matcha", "matcha", "Matcha"),
    ("rooibos vanilla", "rooibos", "Rooibos Vanilla"),
    ("rooibos", "rooibos", "Rooibos"),
    ("yerba mate", "mate", "Yerba Mate"),
    ("mate", "mate", "Mate"),
    ("cold brew", "cold", "Cold Brew Tea"),
    ("cold infusion", "cold", "Cold Infusion"),
    ("infusion froide", "cold", "Cold Infusion"),
    ("fruit infusion", "fruit", "Fruit Infusion"),
    ("forest fruits", "fruit", "Forest Fruits"),
    ("berry infusion", "fruit", "Berry Infusion"),
    ("apple cinnamon", "fruit", "Apple Cinnamon"),
    ("chai", "chai", "Chai"),
    ("masala chai", "chai", "Masala Chai"),
    ("spiced tea", "chai", "Spiced Tea"),
    ("wellness tea", "wellness", "Wellness Tea"),
    ("night time", "wellness", "Night Time"),
    ("chamomile", "herbal", "Chamomile"),
    ("camomilla", "herbal", "Chamomile"),
    ("camomille", "herbal", "Chamomile"),
    ("manzanilla", "herbal", "Chamomile"),
    ("peppermint", "herbal", "Peppermint"),
    ("menthe", "herbal", "Mint Infusion"),
    ("menta", "herbal", "Mint Infusion"),
    ("hierbabuena", "herbal", "Mint Infusion"),
    ("fennel", "herbal", "Fennel"),
    ("finocchio", "herbal", "Fennel"),
    ("fenouil", "herbal", "Fennel"),
    ("hinojo", "herbal", "Fennel"),
    ("ginger", "herbal", "Ginger Infusion"),
    ("zenzero", "herbal", "Ginger Infusion"),
    ("gingembre", "herbal", "Ginger Infusion"),
    ("jengibre", "herbal", "Ginger Infusion"),
    ("lemon balm", "herbal", "Lemon Balm"),
    ("melissa", "herbal", "Lemon Balm"),
    ("melisse", "herbal", "Lemon Balm"),
    ("melisa", "herbal", "Lemon Balm"),
    ("lemongrass", "herbal", "Lemongrass"),
    ("citronella", "herbal", "Lemongrass"),
    ("citronnelle", "herbal", "Lemongrass"),
    ("hierba limon", "herbal", "Lemongrass"),
    ("hibiscus", "herbal", "Hibiscus"),
    ("ibisco", "herbal", "Hibiscus"),
    ("rosehip", "herbal", "Rosehip"),
    ("rosa canina", "herbal", "Rosehip"),
    ("cynorrhodon", "herbal", "Rosehip"),
    ("escaramujo", "herbal", "Rosehip"),
    ("lavender", "herbal", "Lavender"),
    ("lavanda", "herbal", "Lavender"),
    ("lavande", "herbal", "Lavender"),
    ("licorice", "herbal", "Licorice"),
    ("liquirizia", "herbal", "Licorice"),
    ("reglisse", "herbal", "Licorice"),
    ("regaliz", "herbal", "Licorice"),
    ("verbena", "herbal", "Verbena"),
    ("verveine", "herbal", "Verbena"),
    ("turmeric", "herbal", "Turmeric"),
    ("curcuma", "herbal", "Turmeric"),
    ("cinnamon", "chai", "Cinnamon Cardamom"),
    ("cannella", "chai", "Cinnamon Cardamom"),
    ("cannelle", "chai", "Cinnamon Cardamom"),
    ("canela", "chai", "Cinnamon Cardamom"),
    ("cardamom", "chai", "Cinnamon Cardamom"),
    ("cardamomo", "chai", "Cinnamon Cardamom"),
    ("cardamome", "chai", "Cinnamon Cardamom"),
    ("jasmine", "green", "Jasmine Green Tea"),
    ("mint", "herbal", "Mint Infusion"),
    ("vanilla", "herbal", "Vanilla Infusion"),
    ("vaniglia", "herbal", "Vanilla Infusion"),
    ("vanille", "herbal", "Vanilla Infusion"),
    ("vainilla", "herbal", "Vanilla Infusion"),
    ("herbal tea", "herbal", "Herbal Tea"),
    ("tisane", "herbal", "Tisane"),
    ("tisana", "herbal", "Tisana"),
    ("infuso", "infusion", "Infusion"),
    ("infusione", "infusion", "Infusion"),
    ("infusion", "infusion", "Infusion"),
    ("other", "other", "Other")
]

private let teaBrandMatches: [TeaBrandMatch] = [
    TeaBrandMatch(canonicalName: "Dammann Frères", variations: ["DAMMANN", "Dammann", "Dammann Frères", "Dammann Freres", "DAMMANN FRÈRES", "DAMMANN FRERES"]),
    TeaBrandMatch(canonicalName: "Twinings", variations: ["Twinings", "TWININGS"]),
    TeaBrandMatch(canonicalName: "Lipton", variations: ["Lipton"]),
    TeaBrandMatch(canonicalName: "PG Tips", variations: ["PG Tips", "PGTips"]),
    TeaBrandMatch(canonicalName: "Tetley", variations: ["Tetley"]),
    TeaBrandMatch(canonicalName: "Yorkshire Tea", variations: ["Yorkshire Tea"]),
    TeaBrandMatch(canonicalName: "Teekanne", variations: ["Teekanne"]),
    TeaBrandMatch(canonicalName: "Dallmayr", variations: ["Dallmayr"]),
    TeaBrandMatch(canonicalName: "Kusmi Tea", variations: ["Kusmi Tea", "Kusmi"]),
    TeaBrandMatch(canonicalName: "Mariage Frères", variations: ["Mariage Frères", "Mariage Freres", "Mariage"]),
    TeaBrandMatch(canonicalName: "Palais des Thés", variations: ["Palais des Thés", "Palais des Thes", "Palais des"]),
    TeaBrandMatch(canonicalName: "Whittard", variations: ["Whittard", "Whittard of Chelsea"]),
    TeaBrandMatch(canonicalName: "Fortnum & Mason", variations: ["Fortnum & Mason", "Fortnum Mason", "Fortnum"]),
    TeaBrandMatch(canonicalName: "Pukka", variations: ["Pukka", "Pukka Herbs"]),
    TeaBrandMatch(canonicalName: "Clipper", variations: ["Clipper"]),
    TeaBrandMatch(canonicalName: "Yogi Tea", variations: ["Yogi Tea", "Yogi"]),
    TeaBrandMatch(canonicalName: "Teapigs", variations: ["Teapigs", "Tea pigs"]),
    TeaBrandMatch(canonicalName: "Ahmad Tea", variations: ["Ahmad Tea", "Ahmad"]),
    TeaBrandMatch(canonicalName: "La Via del Tè", variations: ["La Via del Tè", "La Via del Te"]),
    TeaBrandMatch(canonicalName: "Neavita", variations: ["Neavita"]),
    TeaBrandMatch(canonicalName: "Hampstead Tea", variations: ["Hampstead Tea", "Hampstead"]),
    TeaBrandMatch(canonicalName: "Alveus", variations: ["Alveus"])
]

private func normalizedTeaScanText(_ text: String) -> String {
    let folded = text
        .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        .lowercased()
        .replacingOccurrences(of: "\n", with: " ")
    let cleaned = folded.map { character -> Character in
        if character.isLetter || character.isNumber || character.isWhitespace {
            return character
        }
        return " "
    }
    return String(cleaned)
        .split(separator: " ")
        .joined(separator: " ")
}

private func teaBrandMatch(in normalizedText: String) -> TeaBrandMatch? {
    teaBrandMatches.first { brand in
        brand.variations.contains { variation in
            normalizedText.contains(normalizedTeaScanText(variation))
        }
    }
}

private func teaTextScanResult(from text: String) -> TeaTextScanResult? {
    let normalizedText = normalizedTeaScanText(text)
    let productMatch = knownTeaProduct(matchingText: normalizedText)
    guard let match = productMatch.map({ (keyword: normalizedTeaScanText($0.teaName), styleId: $0.styleId, detectedName: $0.teaName) }) ??
            teaTextKeywordMatches.first(where: { normalizedText.contains(normalizedTeaScanText($0.keyword)) }) else {
        return nil
    }
    let brand = teaBrandMatch(in: normalizedText)
    let brewTime = brewTimeDetection(in: text)
    let temperature = temperatureDetection(in: text)

    return TeaTextScanResult(
        rawText: text.trimmingCharacters(in: .whitespacesAndNewlines),
        styleId: match.styleId,
        detectedName: detectedProductName(from: text, fallback: match.detectedName, brandName: brand?.canonicalName ?? productMatch?.producer),
        detectedTeaTypeName: detectedTeaTypeName(for: match.detectedName, styleId: match.styleId),
        matchedKeyword: match.keyword,
        brandName: brand?.canonicalName ?? productMatch?.producer,
        packageBrewTimeSeconds: brewTime?.seconds,
        editedBrewTimeSeconds: nil,
        originalDetectedTimeText: brewTime?.originalText,
        packageTemperature: temperature?.temperature,
        editedTemperature: nil,
        originalDetectedTemperatureText: temperature?.originalText
    )
}

private func detectedTeaTypeName(for detectedName: String, styleId: String) -> String? {
    switch normalizedTeaScanText(detectedName) {
    case "matcha":
        return "Matcha"
    case "rooibos":
        return "Rooibos"
    case "yerba mate", "mate":
        return "Mate"
    case "pu erh", "puerh", "pu er":
        return "Pu-erh"
    default:
        let style = teaStylePreset(id: styleId)
        switch style.id {
        case "herbal":
            return "Herbal Tea"
        case "fruit":
            return "Fruit Infusion"
        case "chai":
            return "Chai / Spiced Tea"
        case "wellness":
            return "Wellness Tea"
        case "cold":
            return "Cold Infusion"
        case "puerh", "matcha", "rooibos", "mate", "oolong":
            return style.title
        default:
            return "\(style.title) Tea"
        }
    }
}

private func styleId(forTeaTypeName teaTypeName: String) -> String {
    switch normalizedTeaScanText(teaTypeName) {
    case "green tea", "te verde", "the vert":
        return "green"
    case "black tea", "te nero", "the noir", "te negro":
        return "black"
    case "white tea", "te bianco", "the blanc", "te blanco":
        return "white"
    case "yellow tea":
        return "yellow"
    case "pu erh", "puerh", "pu er":
        return "puerh"
    case "matcha":
        return "matcha"
    case "oolong tea", "oolong":
        return "oolong"
    case "rooibos":
        return "rooibos"
    case "mate", "yerba mate":
        return "mate"
    case "infusion", "infuso", "infusione":
        return "infusion"
    case "fruit infusion":
        return "fruit"
    case "chai", "masala chai", "chai spiced tea", "spiced tea":
        return "chai"
    case "wellness tea":
        return "wellness"
    case "cold infusion", "cold brew tea":
        return "cold"
    case "herbal tea", "tisane", "tisana":
        return "herbal"
    case "other":
        return "other"
    default:
        return "herbal"
    }
}

private func minutesInputText(for seconds: Int) -> String {
    let minutes = Double(seconds) / 60.0
    if seconds % 60 == 0 {
        return "\(seconds / 60)"
    }

    return String(format: "%.1f", minutes)
}

private func secondsFromMinutesInput(_ text: String) -> Int? {
    let normalized = text
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: ",", with: ".")
    guard let minutes = Double(normalized), minutes > 0 else {
        return nil
    }

    return min(max(Int((minutes * 60).rounded()), 15), 30 * 60)
}

private func brewTimeDetection(in text: String) -> BrewTimeDetection? {
    let pattern = #"(?i)\b([1-9]|[12][0-9]|30)\s*(?:[-–—/]\s*([1-9]|[12][0-9]|30))?\s*(?:minutes?|mins?|minuti?|minuto|minutos?|minute|min|′|')"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return nil
    }

    let nsText = text as NSString
    let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
    for match in matches {
        guard match.numberOfRanges >= 2,
              let firstRange = Range(match.range(at: 1), in: text),
              let firstValue = Int(text[firstRange]) else {
            continue
        }

        var detectedMinutes = firstValue
        if match.numberOfRanges >= 3,
           match.range(at: 2).location != NSNotFound,
           let secondRange = Range(match.range(at: 2), in: text),
           let secondValue = Int(text[secondRange]) {
            detectedMinutes = max(firstValue, secondValue)
        }

        guard (1...30).contains(detectedMinutes),
              let fullRange = Range(match.range, in: text) else {
            continue
        }

        return BrewTimeDetection(
            seconds: detectedMinutes * 60,
            originalText: String(text[fullRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    return nil
}

private func temperatureDetection(in text: String) -> TemperatureDetection? {
    let pattern = #"(?i)\b([5-9][0-9]|100)\s*°?\s*c\b"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else {
        return nil
    }

    let nsText = text as NSString
    let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
    for match in matches {
        guard match.numberOfRanges >= 2,
              let valueRange = Range(match.range(at: 1), in: text),
              let value = Int(text[valueRange]),
              (50...100).contains(value),
              let fullRange = Range(match.range, in: text) else {
            continue
        }

        return TemperatureDetection(
            temperature: "\(value) C",
            originalText: String(text[fullRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    return nil
}

private func detectedProductName(from text: String, fallback: String, brandName: String?) -> String {
    let lines = text
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { $0.count >= 3 && $0.count <= 48 }

    let blockedFragments = [
        "ingredient", "ingredients", "ingredienti", "ingredientes", "infusion", "infusione", "temps", "tempo", "tiempo",
        "brew", "brewing", "steep", "minutes", "minute", "minuti", "minuto", "water", "temperatura", "temperature", "température",
        "best before", "avant fin", "consommer", "barcode", "nutrition", "valori", "valeurs"
    ]
    let normalizedBrand = normalizedTeaScanText(brandName ?? "")

    if let line = lines.first(where: { line in
        let normalizedLine = normalizedTeaScanText(line)
        guard normalizedLine != normalizedBrand else { return false }
        return !blockedFragments.contains { normalizedLine.contains($0) } &&
            teaTextKeywordMatches.contains { normalizedLine.contains(normalizedTeaScanText($0.keyword)) }
    }) {
        return line
    }

    return fallback
}

private func teaBrandName(from text: String) -> String? {
    teaBrandMatch(in: normalizedTeaScanText(text))?.canonicalName
}

private func normalizedSavedTeaIdentity(_ value: String?) -> String {
    normalizedTeaScanText(value ?? "")
        .filter { $0.isLetter || $0.isNumber || $0.isWhitespace }
        .split(separator: " ")
        .joined(separator: " ")
}

private func savedScannedTeaIdentity(brandName: String?, teaName: String) -> String {
    "\(normalizedSavedTeaIdentity(brandName))|\(normalizedSavedTeaIdentity(teaName))"
}

private func savedScannedTea(from scanResult: TeaTextScanResult) -> SavedScannedTea {
    SavedScannedTea(
        id: UUID(),
        teaName: scanResult.detectedName,
        brandName: scanResult.brandName,
        teaType: scanResult.teaTypeName,
        styleId: scanResult.styleId,
        suggestedBrewTime: scanResult.suggestedBrewTime,
        brewTimeSource: scanResult.brewTimeSource,
        originalDetectedTimeText: scanResult.originalDetectedTimeText,
        detectedTemperature: scanResult.suggestedTemperature,
        temperatureSource: scanResult.temperatureSource,
        originalDetectedTemperatureText: scanResult.originalDetectedTemperatureText,
        scannedText: scanResult.rawText,
        detectionKeywords: [scanResult.matchedKeyword],
        dateAdded: Date(),
        lastUsedDate: Date(),
        usageCount: 1,
        notes: scanResult.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? scanResult.notes : "Saved tea. You can use it again without scanning."
    )
}

private func teaProfile(from scanResult: TeaTextScanResult) -> TeaProfile {
    let style = teaStylePreset(id: scanResult.styleId)
    let origin = scanResult.brandName ?? "Scanned label"

    return TeaProfile(
        name: scanResult.detectedName,
        category: style.category,
        temperature: scanResult.suggestedTemperature,
        steepSeconds: scanResult.suggestedBrewTime,
        caffeine: style.caffeine,
        flavor: scanResult.teaTypeName,
        detail: scanResult.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? scanResult.notes! : "Saved tea. You can use it again without scanning.",
        imageName: style.imageName,
        origin: origin,
        process: style.process,
        character: style.character,
        source: "scanned",
        producer: scanResult.brandName,
        brewTimeSource: scanResult.brewTimeSource,
        originalDetectedTimeText: scanResult.originalDetectedTimeText,
        temperatureSource: scanResult.temperatureSource,
        originalDetectedTemperatureText: scanResult.originalDetectedTemperatureText,
        tint: style.tint
    )
}

private func teaProfile(from savedTea: SavedScannedTea) -> TeaProfile {
    let style = teaStylePreset(id: savedTea.styleId)
    return TeaProfile(
        id: savedTea.id,
        name: savedTea.teaName,
        category: style.category,
        temperature: savedTea.detectedTemperature?.isEmpty == false ? savedTea.detectedTemperature! : style.temperature,
        steepSeconds: savedTea.suggestedBrewTime,
        caffeine: style.caffeine,
        flavor: savedTea.teaType,
        detail: savedTea.notes ?? "Saved tea. You can use it again without scanning.",
        imageName: style.imageName,
        origin: savedTea.brandName ?? "Scanned label",
        process: style.process,
        character: style.character,
        source: "saved-scan",
        productId: savedTea.id.uuidString,
        producer: savedTea.brandName,
        brewTimeSource: savedTea.brewTimeSource ?? "default",
        originalDetectedTimeText: savedTea.originalDetectedTimeText,
        temperatureSource: savedTea.temperatureSource ?? "default",
        originalDetectedTemperatureText: savedTea.originalDetectedTemperatureText,
        tint: style.tint
    )
}

private extension Int {
    var formattedTime: String {
        let minutes = self / 60
        let seconds = self % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    var minuteText: String {
        let minutes = self / 60
        let seconds = self % 60
        if seconds == 0 {
            return "\(minutes) min"
        }
        return formattedTime
    }

    var shareTimeText: String {
        let minutes = self / 60
        let seconds = self % 60
        if seconds == 0 {
            return "\(minutes) min"
        }
        if minutes == 0 {
            return "\(seconds) sec"
        }
        return "\(minutes) min \(seconds) sec"
    }
}

private let teaProfiles: [TeaProfile] = [
    TeaProfile(
        name: "Green Tea",
        category: "Fresh",
        temperature: "80 C",
        steepSeconds: 150,
        caffeine: "Medium",
        flavor: "Grassy, bright, lightly sweet",
        detail: "Most green teas come from China and Japan. The leaves are heated soon after picking, which keeps their color fresh and their taste clean.",
        imageName: "green-tea-leaves",
        origin: "China / Japan",
        process: "Unoxidized",
        character: "Fresh",
        source: "default",
        tint: Color(red: 0.45, green: 0.86, blue: 0.53)
    ),
    TeaProfile(
        name: "Black Tea",
        category: "Bold",
        temperature: "95 C",
        steepSeconds: 240,
        caffeine: "High",
        flavor: "Malty, rich, full-bodied",
        detail: "Black tea is common in India, Sri Lanka, Kenya, and China. Full oxidation gives it a darker leaf, stronger aroma, and more body.",
        imageName: "black-tea-leaves",
        origin: "India / Ceylon",
        process: "Fully oxidized",
        character: "Bold",
        source: "default",
        tint: Color(red: 0.95, green: 0.67, blue: 0.28)
    ),
    TeaProfile(
        name: "White Tea",
        category: "Soft",
        temperature: "75 C",
        steepSeconds: 180,
        caffeine: "Low",
        flavor: "Honeyed, gentle, clean",
        detail: "White tea is especially associated with Fujian, China. Young buds and leaves are minimally processed, giving a soft and delicate cup.",
        imageName: "white-tea-leaves",
        origin: "Fujian",
        process: "Minimal",
        character: "Delicate",
        source: "default",
        tint: Color(red: 0.92, green: 0.88, blue: 0.70)
    ),
    TeaProfile(
        name: "Herbal",
        category: "Calm",
        temperature: "100 C",
        steepSeconds: 300,
        caffeine: "None",
        flavor: "Aromatic, soothing, expressive",
        detail: "Herbal tea is not true tea from Camellia sinensis. It can blend flowers, mint, roots, spices, and fruit for caffeine-free infusions.",
        imageName: "herbal-tea-leaves",
        origin: "Botanical",
        process: "Infusion",
        character: "Calm",
        source: "default",
        tint: Color(red: 0.83, green: 0.55, blue: 0.88)
    ),
    TeaProfile(
        name: "Infusion",
        category: "Botanical",
        temperature: "100 C",
        steepSeconds: 300,
        caffeine: "None",
        flavor: "Botanical, gentle, caffeine-free",
        detail: "Infusions use herbs, flowers, spices, or fruit rather than true tea leaves. They usually do well with boiling water and a longer steep.",
        imageName: "herbal-tea-leaves",
        origin: "Botanical blend",
        process: "Infusion",
        character: "Botanical",
        source: "default",
        tint: Color(red: 0.70, green: 0.62, blue: 0.90)
    ),
    TeaProfile(
        name: "Matcha",
        category: "Vivid",
        temperature: "75 C",
        steepSeconds: 90,
        caffeine: "High",
        flavor: "Vivid, grassy, concentrated",
        detail: "Matcha is powdered green tea whisked into water rather than steeped like loose leaves.",
        imageName: "green-tea-leaves",
        origin: "Japan",
        process: "Powdered",
        character: "Vivid",
        source: "default",
        tint: Color(red: 0.40, green: 0.82, blue: 0.38)
    ),
    TeaProfile(
        name: "Oolong",
        category: "Layered",
        temperature: "90 C",
        steepSeconds: 210,
        caffeine: "Medium",
        flavor: "Floral, toasted, silky",
        detail: "Oolong is strongly linked to Taiwan and Fujian, China. It sits between green and black tea, often with floral, roasted, or creamy notes.",
        imageName: "oolong-tea-leaves",
        origin: "Taiwan / Fujian",
        process: "Part oxidized",
        character: "Layered",
        source: "default",
        tint: Color(red: 0.70, green: 0.84, blue: 0.68)
    ),
    TeaProfile(
        name: "Rooibos",
        category: "Soft",
        temperature: "100 C",
        steepSeconds: 300,
        caffeine: "None",
        flavor: "Round, naturally sweet, smooth",
        detail: "Rooibos is a caffeine-free South African infusion that handles boiling water well.",
        imageName: "herbal-tea-leaves",
        origin: "South Africa",
        process: "Infusion",
        character: "Naturally sweet",
        source: "default",
        tint: Color(red: 0.88, green: 0.42, blue: 0.26)
    ),
    TeaProfile(
        name: "Chai",
        category: "Spiced",
        temperature: "95 C",
        steepSeconds: 300,
        caffeine: "High",
        flavor: "Spiced, warming, aromatic",
        detail: "Chai and spiced teas often combine black tea with cinnamon, cardamom, ginger, and other spices.",
        imageName: "black-tea-leaves",
        origin: "Spiced blend",
        process: "Blend",
        character: "Warming",
        source: "default",
        tint: Color(red: 0.90, green: 0.55, blue: 0.25)
    ),
    TeaProfile(
        name: "Fruit Infusion",
        category: "Bright",
        temperature: "100 C",
        steepSeconds: 300,
        caffeine: "None",
        flavor: "Fruity, bright, caffeine-free",
        detail: "Fruit infusions usually need hot water and a longer steep to extract fruit and hibiscus flavor.",
        imageName: "herbal-tea-leaves",
        origin: "Fruit blend",
        process: "Infusion",
        character: "Bright",
        source: "default",
        tint: Color(red: 0.92, green: 0.36, blue: 0.48)
    )
]

struct ContentView: View {
    @AppStorage("savedCustomTeas") private var savedCustomTeasData = "[]"
    @AppStorage("savedTeaMoments") private var savedTeaMomentsData = "[]"
    @AppStorage("savedScannedTeas") private var savedScannedTeasData = "[]"
    @AppStorage("activeTeaTimerSession") private var activeTeaTimerSessionData = ""
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTea = teaProfiles[0]
    @State private var customTeas: [TeaProfile] = []
    @State private var savedScannedTeas: [SavedScannedTea] = []
    @State private var teaMoments: [TeaMoment] = []
    @State private var activeSessionDraft: TeaSessionDraft?
    @State private var activeTimerSession: ActiveTeaTimerSession?
    @State private var editableTimerSeconds = teaProfiles[0].steepSeconds
    @State private var remainingSeconds = teaProfiles[0].steepSeconds
    @State private var isRunning = false
    @State private var isShowingScanTea = false
    @State private var isShowingSavedTeas = false
    @State private var isShowingProfileSettings = false
    @State private var isShowingThoughtSheet = false
    @State private var isShowingTeaMoments = false
    @State private var isShowingReviewSheet = false
    @State private var showThoughtBanner = false
    @State private var showCompletionBanner = false
    @State private var didShowThoughtBannerForSession = false
    @State private var didSaveLatestMoment = false
    @State private var timerCompletionPulse = false
    @State private var lastSavedMoment: TeaMoment?
    @State private var teaPendingDeletion: TeaProfile?
    @State private var savedScannedTeaPendingDeletion: SavedScannedTea?
    @State private var scannerResultMessage: String?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var appLanguage: TeaTimerLanguage {
        TeaTimerLanguage(rawValue: languageRaw) ?? .english
    }

    private func t(_ key: LocalizedTextKey) -> String {
        localizedText(key, language: appLanguage)
    }

    private var availableTeas: [TeaProfile] {
        teaProfiles + customTeas
    }

    private var progress: Double {
        guard editableTimerSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(editableTimerSeconds)
    }

    private var timeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    private var selectedTeaProductMoments: [TeaMoment] {
        if let productId = selectedTea.productId {
            return teaMoments.filter { $0.productId == productId }
        }

        guard selectedTea.source == "personalized" || selectedTea.source == "scanned" || selectedTea.source == "saved-scan" else { return [] }
        return teaMoments.filter { $0.teaName == selectedTea.name && $0.source == selectedTea.source }
    }

    private var selectedTeaMemoryText: String? {
        let moments = selectedTeaProductMoments
        guard !moments.isEmpty else { return nil }

        let countText: String
        let recentText: String
        switch appLanguage {
        case .english:
            countText = moments.count == 1 ? "once before" : "\(moments.count) times before"
            recentText = "recently"
        case .italian:
            countText = moments.count == 1 ? "una volta" : "\(moments.count) volte"
            recentText = "di recente"
        case .french:
            countText = moments.count == 1 ? "une fois" : "\(moments.count) fois"
            recentText = "récemment"
        case .spanish:
            countText = moments.count == 1 ? "una vez" : "\(moments.count) veces"
            recentText = "recientemente"
        }
        let lastDate = moments.sorted { $0.date > $1.date }.first?.date.formatted(date: .abbreviated, time: .omitted) ?? recentText
        let ratings = moments.compactMap(\.rating)

        if ratings.isEmpty {
            switch appLanguage {
            case .english:
                return "You drank this tea \(countText). Last time: \(lastDate)."
            case .italian:
                return "Hai bevuto questo tè \(countText). Ultima volta: \(lastDate)."
            case .french:
                return "Vous avez bu ce thé \(countText). Dernière fois : \(lastDate)."
            case .spanish:
                return "Tomaste este té \(countText). Última vez: \(lastDate)."
            }
        }

        let average = Double(ratings.reduce(0, +)) / Double(ratings.count)
        let averageText = String(format: "%.1f", average)
        switch appLanguage {
        case .english:
            return "You drank this tea \(countText). Last time: \(lastDate). Avg \(averageText)/5."
        case .italian:
            return "Hai bevuto questo tè \(countText). Ultima volta: \(lastDate). Media \(averageText)/5."
        case .french:
            return "Vous avez bu ce thé \(countText). Dernière fois : \(lastDate). Moyenne \(averageText)/5."
        case .spanish:
            return "Tomaste este té \(countText). Última vez: \(lastDate). Media \(averageText)/5."
        }
    }

    var body: some View {
        ZStack {
            PremiumBackground(tea: selectedTea)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    teaSelector
                    timerPanel
                    teaThoughtPrompt
                    statsGrid
                    teaInfo
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack {
                if showCompletionBanner, let lastSavedMoment {
                    CompletionNotificationBanner(moment: lastSavedMoment, tint: selectedTea.tint) {
                        showCompletionBanner = false
                        isShowingTeaMoments = true
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                } else
                if showThoughtBanner, activeSessionDraft != nil {
                    ThoughtNotificationBanner(tint: selectedTea.tint) {
                        showThoughtBanner = false
                        isShowingThoughtSheet = true
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.36, dampingFraction: 0.84), value: showThoughtBanner)
        .animation(.spring(response: 0.36, dampingFraction: 0.84), value: showCompletionBanner)
        .alert(
            t(.deletePersonalizedTimer),
            isPresented: Binding(
                get: { teaPendingDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        teaPendingDeletion = nil
                    }
                }
            )
        ) {
            Button(t(.remove), role: .destructive) {
                if let tea = teaPendingDeletion {
                    deleteCustomTea(tea)
                }
                teaPendingDeletion = nil
            }
            Button(t(.cancel), role: .cancel) {
                teaPendingDeletion = nil
            }
        } message: {
            Text(t(.savedTimerRemoval))
        }
        .alert(
            t(.teaFound),
            isPresented: Binding(
                get: { scannerResultMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        scannerResultMessage = nil
                    }
                }
            )
        ) {
            Button(t(.close), role: .cancel) {
                scannerResultMessage = nil
            }
        } message: {
            Text(scannerResultMessage ?? "")
        }
        .alert(
            t(.deleteSavedTeaAlert),
            isPresented: Binding(
                get: { savedScannedTeaPendingDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        savedScannedTeaPendingDeletion = nil
                    }
                }
            )
        ) {
            Button(t(.remove), role: .destructive) {
                if let tea = savedScannedTeaPendingDeletion {
                    deleteSavedScannedTea(tea)
                }
                savedScannedTeaPendingDeletion = nil
            }
            Button(t(.cancel), role: .cancel) {
                savedScannedTeaPendingDeletion = nil
            }
        } message: {
            Text(t(.savedTeaRemoval))
        }
        .onAppear {
            loadCustomTeas()
            loadSavedScannedTeas()
            loadTeaMoments()
            loadActiveTimerSession()
            refreshActiveTimer()
        }
        .onChange(of: selectedTea) { _, newTea in
            guard activeTimerSession == nil else { return }
            editableTimerSeconds = newTea.steepSeconds
            remainingSeconds = newTea.steepSeconds
            isRunning = false
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshActiveTimer()
            }
        }
        .sheet(isPresented: $isShowingScanTea) {
            ScanTeaSheet(
                tint: selectedTea.tint,
                knownProducts: knownTeaProducts,
                onDetectProduct: { product in
                    selectTea(teaProfile(from: product))
                    isShowingScanTea = false
                },
                isScannedTeaSaved: { scanResult in
                    savedScannedTeaIndex(for: scanResult) != nil
                },
                onUseScannedTea: { scanResult in
                    if let index = savedScannedTeaIndex(for: scanResult) {
                        savedScannedTeas[index].lastUsedDate = Date()
                        savedScannedTeas[index].usageCount += 1
                        let savedTea = savedScannedTeas[index]
                        saveScannedTeas(savedScannedTeas)
                        selectTea(teaProfile(from: savedTea))
                    } else {
                        selectTea(teaProfile(from: scanResult))
                    }
                    if let brandName = scanResult.brandName {
                        scannerResultMessage = "\(brandName) detected - suggested tea type: \(scanResult.detectedName)."
                    }
                    isShowingScanTea = false
                },
                onSaveScannedTea: { scanResult in
                    saveScannedTea(scanResult)
                },
                onRefreshSavedScannedTea: { scanResult in
                    refreshSavedScannedTeaIfBetter(scanResult)
                },
                onSaveCustomTea: { tea in
                    addCustomTea(tea)
                    selectTea(tea)
                    isShowingScanTea = false
                }
            )
        }
        .sheet(isPresented: $isShowingSavedTeas) {
            SavedScannedTeasSheet(
                teas: savedScannedTeas.sorted { $0.lastUsedDate > $1.lastUsedDate },
                onUseTea: { tea in
                    useSavedScannedTea(tea)
                    isShowingSavedTeas = false
                },
                onUpdateTea: { editedTea, originalTea in
                    updateSavedScannedTea(editedTea, originalTea: originalTea)
                },
                onDeleteTea: { tea in
                    savedScannedTeaPendingDeletion = tea
                }
            )
        }
        .sheet(isPresented: $isShowingProfileSettings) {
            ProfileSettingsSheet(tint: selectedTea.tint)
        }
        .sheet(isPresented: $isShowingThoughtSheet) {
            if let draft = activeSessionDraft {
                TeaThoughtSheet(draft: draft, tint: selectedTea.tint) { mood, note, photoFilename in
                    updateActiveSessionThought(mood: mood, note: note, photoFilename: photoFilename)
                }
            }
        }
        .sheet(isPresented: $isShowingTeaMoments) {
                TeaMomentsHistorySheet(
                    moments: teaMoments.sorted { $0.date > $1.date },
                    tint: selectedTea.tint,
                    onUpdate: { moment, mood, note, rating, review, photoFilename in
                        updateTeaMoment(moment, mood: mood, note: note, rating: rating, review: review, photoFilename: photoFilename)
                    },
                    onDelete: { moment in
                        deleteTeaMoment(moment)
                    }
            )
        }
        .sheet(isPresented: $isShowingReviewSheet) {
            if let lastSavedMoment {
                TeaMomentReviewSheet(moment: lastSavedMoment, tint: selectedTea.tint) { rating, review, photoFilename in
                    updateTeaMoment(lastSavedMoment, mood: lastSavedMoment.mood, note: lastSavedMoment.note, rating: rating, review: review, photoFilename: photoFilename)
                    isShowingReviewSheet = false
                }
            }
        }
        .onReceive(timer) { _ in
            refreshActiveTimer()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(t(.appTitle))
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.42), radius: 12, x: 0, y: 6)

                Text(t(.tagline))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    isShowingProfileSettings = true
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(selectedTea.tint)
                        .frame(width: 48, height: 48)
                        .background(.black.opacity(0.28), in: Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(t(.profile))

                Button {
                    isShowingTeaMoments = true
                } label: {
                    Image(systemName: "book.closed")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(selectedTea.tint)
                        .frame(width: 48, height: 48)
                        .background(.black.opacity(0.28), in: Circle())
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(t(.diary))
            }
        }
    }

    private var teaSelector: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(availableTeas) { tea in
                        let isCustomTea = customTeas.contains { $0.id == tea.id }

                        Button {
                            selectTea(tea)
                        } label: {
                            VStack(spacing: 10) {
                                ZStack(alignment: .topTrailing) {
                                    TeaPortrait(tea: tea, isSelected: selectedTea == tea)

                                    if isCustomTea {
                                        Button {
                                            teaPendingDeletion = tea
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(.white)
                                                .frame(width: 24, height: 24)
                                                .background(.black.opacity(0.64), in: Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(.white.opacity(0.16), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .offset(x: 4, y: -4)
                        .accessibilityLabel(t(.deletePersonalizedTimer))
                                    }
                                }

                                Text(localizedDefaultTeaName(tea, language: appLanguage, shorten: true))
                                    .font(.system(size: 15, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.76)
                                    .foregroundStyle(selectedTea == tea ? tea.tint : .white.opacity(0.62))
                            }
                            .frame(width: 78, height: 104, alignment: .top)
                        }
                        .buttonStyle(.plain)
                        .disabled(isRunning)
                    }

                    Button {
                        isRunning = false
                        isShowingSavedTeas = true
                    } label: {
                        SavedTeasSelectorCard(
                            tint: selectedTea.tint,
                            count: savedScannedTeas.count
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isRunning)

                    Button {
                        isRunning = false
                        isShowingScanTea = true
                    } label: {
                        VStack(spacing: 10) {
                            ScanTeaPortrait(tint: selectedTea.tint)

                            Text(t(.scanTea))
                                .font(.system(size: 15, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)
                                .foregroundStyle(.white.opacity(0.72))
                        }
                        .frame(width: 78, height: 104, alignment: .top)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .scrollClipDisabled()
        }
    }

    private var timerPanel: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .black.opacity(0.38),
                                .black.opacity(0.28),
                                .black.opacity(0.16)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 170
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.42), radius: 28, x: 0, y: 16)

                Circle()
                    .stroke(selectedTea.tint.opacity(0.25), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(colors: [selectedTea.tint, Color(red: 1.0, green: 0.74, blue: 0.32), selectedTea.tint], center: .center),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: progress)

                VStack(spacing: 10) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(selectedTea.tint.opacity(0.9))

                    Text(localizedDefaultTeaName(selectedTea, language: appLanguage))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(selectedTea.tint)

                    Text(timeText)
                        .font(.system(size: 72, weight: .regular, design: .serif))
                        .monospacedDigit()
                        .foregroundStyle(.white)

                    Text(remainingSeconds == 0 && didSaveLatestMoment ? t(.teaIsReady) : t(.min))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.48))

                    Label(selectedTea.temperature, systemImage: "thermometer.medium")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selectedTea.tint)
                }
            }
            .frame(maxWidth: 336)
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .scaleEffect(timerCompletionPulse ? 1.035 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.42).repeatCount(3, autoreverses: true), value: timerCompletionPulse)

            timerAdjuster

            HStack(spacing: 12) {
                Button {
                    handleStartPause()
                } label: {
                    Label(isRunning ? t(.pause) : t(.startTimer), systemImage: isRunning ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                }
                .buttonStyle(PrimaryTeaButtonStyle(tint: selectedTea.tint))

                Button {
                    resetTimer()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline)
                        .frame(width: 62, height: 62)
                }
                .buttonStyle(SecondaryTeaButtonStyle())
                .accessibilityLabel(t(.reset))
            }
            .padding(.horizontal, 22)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var teaThoughtPrompt: some View {
        if isRunning, activeSessionDraft != nil {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(selectedTea.tint.opacity(0.14))

                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selectedTea.tint)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(t(.takeMoment))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)

                    Text(t(.addThoughtBrewing))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer()

                Button {
                    isShowingThoughtSheet = true
                } label: {
                    Text(t(.addThought))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black.opacity(0.82))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .background(selectedTea.tint, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(.black.opacity(0.30), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedTea.tint.opacity(0.22), lineWidth: 1)
            )
        } else if didSaveLatestMoment {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selectedTea.tint)

                Text(t(.savedMomentMessage))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.78))

                Spacer()

                if let lastSavedMoment, !hasReviewForSameTea(as: lastSavedMoment) {
                    Button {
                        isShowingReviewSheet = true
                    } label: {
                        Text(t(.rate))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.black.opacity(0.82))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedTea.tint, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.10), lineWidth: 1)
            )
        }
    }

    private var timerAdjuster: some View {
        HStack(spacing: 14) {
            Button {
                adjustTimer(by: -15)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(AdjustTimerButtonStyle(tint: selectedTea.tint, isDisabled: isRunning))
            .disabled(isRunning)
            .accessibilityLabel(t(.reduceTimer15))

            VStack(spacing: 3) {
                Text(t(.customTimer))
                    .font(.system(size: 12, weight: .semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.50))

                Text(t(.timer15SecSteps))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isRunning ? .white.opacity(0.34) : selectedTea.tint.opacity(0.92))
            }
            .frame(maxWidth: 136)

            Button {
                adjustTimer(by: 15)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(AdjustTimerButtonStyle(tint: selectedTea.tint, isDisabled: isRunning))
            .disabled(isRunning)
            .accessibilityLabel(t(.timer15SecSteps))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.black.opacity(0.24), in: Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .opacity(isRunning ? 0.58 : 1)
    }

    private func adjustTimer(by seconds: Int) {
        guard !isRunning else { return }
        let newDuration = min(max(editableTimerSeconds + seconds, 15), 30 * 60)
        editableTimerSeconds = newDuration
        remainingSeconds = newDuration
        activeSessionDraft = nil
        clearActiveTimerSession()
        showThoughtBanner = false
        showCompletionBanner = false
        didShowThoughtBannerForSession = false
        didSaveLatestMoment = false
    }

    private func selectTea(_ tea: TeaProfile) {
        guard !isRunning else { return }
        clearActiveTimerSession()
        selectedTea = tea
        editableTimerSeconds = tea.steepSeconds
        remainingSeconds = tea.steepSeconds
        isRunning = false
        activeSessionDraft = nil
        showThoughtBanner = false
        showCompletionBanner = false
        didShowThoughtBannerForSession = false
        didSaveLatestMoment = false
    }

    private func handleStartPause() {
        if isRunning {
            pauseActiveTimer()
            return
        }

        if remainingSeconds == 0 {
            remainingSeconds = editableTimerSeconds
        }

        if let session = activeTimerSession, session.timerState == "paused" {
            resumeActiveTimer()
        } else {
            startActiveTimer()
        }
    }

    private func resetTimer() {
        remainingSeconds = editableTimerSeconds
        isRunning = false
        activeSessionDraft = nil
        clearActiveTimerSession()
        showThoughtBanner = false
        didShowThoughtBannerForSession = false
        didSaveLatestMoment = false
    }

    private func makeTeaSessionDraft(id: UUID = UUID(), infusionTimeUsed: Int? = nil) -> TeaSessionDraft {
        TeaSessionDraft(
            id: id,
            teaName: selectedTea.name,
            infusionTimeUsed: infusionTimeUsed ?? editableTimerSeconds,
            suggestedInfusionTime: selectedTea.steepSeconds,
            waterTemperature: selectedTea.temperature,
            caffeineLevel: selectedTea.caffeine,
            teaImageName: selectedTea.imageName,
            teaCategory: selectedTea.category,
            source: selectedTea.source,
            productId: selectedTea.productId,
            producer: selectedTea.producer,
            qrCodeValue: selectedTea.qrCodeValue,
            barcodeValue: selectedTea.barcodeValue,
            mood: nil,
            note: nil,
            photoFilename: nil,
            didSaveMoment: false
        )
    }

    private func startActiveTimer() {
        let now = Date()
        let duration = remainingSeconds > 0 ? remainingSeconds : editableTimerSeconds
        let draft = makeTeaSessionDraft(id: UUID(), infusionTimeUsed: duration)
        let session = makeActiveTimerSession(
            id: draft.id,
            durationSeconds: duration,
            remainingSeconds: duration,
            startDate: now,
            endDate: now.addingTimeInterval(TimeInterval(duration)),
            timerState: "running",
            draft: draft
        )

        activeSessionDraft = draft
        activeTimerSession = session
        editableTimerSeconds = duration
        remainingSeconds = duration
        isRunning = true
        didSaveLatestMoment = false
        didShowThoughtBannerForSession = false
        showCompletionBanner = false
        persistActiveTimerSession(session)
        scheduleTeaReadyNotification(for: session)
        startLiveActivity(for: session)
        showThoughtBannerIfNeeded()
    }

    private func resumeActiveTimer() {
        guard var session = activeTimerSession else { return }
        let now = Date()
        let duration = max(remainingSeconds, 1)
        session.remainingSeconds = duration
        session.endDate = now.addingTimeInterval(TimeInterval(duration))
        session.timerState = "running"
        session.didSaveMoment = false
        activeTimerSession = session
        activeSessionDraft = draft(from: session)
        isRunning = true
        persistActiveTimerSession(session)
        scheduleTeaReadyNotification(for: session)
        startLiveActivity(for: session)
        showThoughtBannerIfNeeded()
    }

    private func pauseActiveTimer() {
        refreshActiveTimer(allowCompletion: false)
        guard var session = activeTimerSession else {
            isRunning = false
            cancelTeaReadyNotification()
            return
        }

        session.remainingSeconds = remainingSeconds
        session.timerState = "paused"
        activeTimerSession = session
        isRunning = false
        persistActiveTimerSession(session)
        cancelTeaReadyNotification()
        endLiveActivity(for: session, finalState: "paused", dismissalPolicy: .immediate)
    }

    private func refreshActiveTimer(allowCompletion: Bool = true) {
        guard var session = activeTimerSession else { return }

        if session.timerState == "running" {
            let secondsLeft = max(0, Int(ceil(session.endDate.timeIntervalSinceNow)))
            session.remainingSeconds = secondsLeft
            activeTimerSession = session
            editableTimerSeconds = session.durationSeconds
            remainingSeconds = secondsLeft
            isRunning = secondsLeft > 0

            if secondsLeft == 0, allowCompletion {
                completeTeaSession()
            }
        } else if session.timerState == "paused" {
            editableTimerSeconds = session.durationSeconds
            remainingSeconds = session.remainingSeconds
            isRunning = false
        }
    }

    private func makeActiveTimerSession(
        id: UUID,
        durationSeconds: Int,
        remainingSeconds: Int,
        startDate: Date,
        endDate: Date,
        timerState: String,
        draft: TeaSessionDraft
    ) -> ActiveTeaTimerSession {
        ActiveTeaTimerSession(
            id: id,
            teaName: selectedTea.name,
            teaType: selectedTea.flavor,
            durationSeconds: durationSeconds,
            remainingSeconds: remainingSeconds,
            startDate: startDate,
            endDate: endDate,
            timerState: timerState,
            suggestedInfusionTime: draft.suggestedInfusionTime,
            waterTemperature: draft.waterTemperature,
            caffeineLevel: draft.caffeineLevel,
            teaImageName: draft.teaImageName,
            teaCategory: draft.teaCategory,
            source: draft.source,
            productId: draft.productId,
            producer: draft.producer,
            qrCodeValue: draft.qrCodeValue,
            barcodeValue: draft.barcodeValue,
            origin: selectedTea.origin,
            process: selectedTea.process,
            character: selectedTea.character,
            detail: selectedTea.detail,
            brewTimeSource: selectedTea.brewTimeSource,
            originalDetectedTimeText: selectedTea.originalDetectedTimeText,
            mood: draft.mood,
            note: draft.note,
            photoFilename: draft.photoFilename,
            didSaveMoment: draft.didSaveMoment
        )
    }

    private func activeTeaProfile(from session: ActiveTeaTimerSession) -> TeaProfile {
        TeaProfile(
            id: session.productId.flatMap(UUID.init(uuidString:)) ?? session.id,
            name: session.teaName,
            category: session.teaCategory,
            temperature: session.waterTemperature,
            steepSeconds: session.suggestedInfusionTime,
            caffeine: session.caffeineLevel,
            flavor: session.teaType,
            detail: session.detail,
            imageName: session.teaImageName,
            origin: session.origin,
            process: session.process,
            character: session.character,
            source: session.source,
            productId: session.productId,
            producer: session.producer,
            qrCodeValue: session.qrCodeValue,
            barcodeValue: session.barcodeValue,
            brewTimeSource: session.brewTimeSource,
            originalDetectedTimeText: session.originalDetectedTimeText,
            tint: teaStylePreset(id: styleId(forTeaTypeName: session.teaType)).tint
        )
    }

    private func draft(from session: ActiveTeaTimerSession) -> TeaSessionDraft {
        TeaSessionDraft(
            id: session.id,
            teaName: session.teaName,
            infusionTimeUsed: session.durationSeconds,
            suggestedInfusionTime: session.suggestedInfusionTime,
            waterTemperature: session.waterTemperature,
            caffeineLevel: session.caffeineLevel,
            teaImageName: session.teaImageName,
            teaCategory: session.teaCategory,
            source: session.source,
            productId: session.productId,
            producer: session.producer,
            qrCodeValue: session.qrCodeValue,
            barcodeValue: session.barcodeValue,
            mood: session.mood,
            note: session.note,
            photoFilename: session.photoFilename,
            didSaveMoment: session.didSaveMoment
        )
    }

    private func persistActiveTimerSession(_ session: ActiveTeaTimerSession) {
        if let data = try? JSONEncoder().encode(session),
           let json = String(data: data, encoding: .utf8) {
            activeTeaTimerSessionData = json
        }
    }

    private func loadActiveTimerSession() {
        guard let data = activeTeaTimerSessionData.data(using: .utf8),
              let session = try? JSONDecoder().decode(ActiveTeaTimerSession.self, from: data) else {
            return
        }

        selectedTea = activeTeaProfile(from: session)
        activeTimerSession = session
        activeSessionDraft = draft(from: session)
        editableTimerSeconds = session.durationSeconds
        remainingSeconds = session.remainingSeconds
        isRunning = session.timerState == "running"
    }

    private func clearActiveTimerSession() {
        activeTimerSession = nil
        activeTeaTimerSessionData = ""
        cancelTeaReadyNotification()
        endAllLiveActivities(finalState: "cancelled", dismissalPolicy: .immediate)
    }

    private func scheduleTeaReadyNotification(for session: ActiveTeaTimerSession) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [teaReadyNotificationIdentifier])

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                addTeaReadyNotification(for: session)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted {
                        addTeaReadyNotification(for: session)
                    }
                }
            default:
                break
            }
        }
    }

    private func addTeaReadyNotification(for session: ActiveTeaTimerSession) {
        let secondsUntilReady = max(1, session.endDate.timeIntervalSinceNow)
        let content = UNMutableNotificationContent()
        content.title = "TeaTimer"
        content.body = localizedTeaReadyNotificationBody(
            for: session,
            teaName: notificationTeaName(for: session, language: appLanguage),
            language: appLanguage
        )
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsUntilReady, repeats: false)
        let request = UNNotificationRequest(identifier: teaReadyNotificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func notificationTeaName(for session: ActiveTeaTimerSession, language: TeaTimerLanguage) -> String {
        let teaName = localizedDefaultTeaName(name: session.teaName, source: session.source, language: language)
        guard let producer = session.producer?.trimmingCharacters(in: .whitespacesAndNewlines),
              !producer.isEmpty,
              !teaName.localizedCaseInsensitiveContains(producer) else {
            return teaName
        }

        return "\(producer) \(teaName)"
    }

    private func cancelTeaReadyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [teaReadyNotificationIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [teaReadyNotificationIdentifier])
    }

    private func startLiveActivity(for session: ActiveTeaTimerSession) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        Task {
            await endAllLiveActivities(finalState: "cancelled", dismissalPolicy: .immediate)

            let attributes = TeaTimerActivityAttributes(timerId: session.id.uuidString)
            let state = liveActivityState(for: session, timerState: session.timerState)
            do {
                _ = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: state, staleDate: session.endDate),
                    pushType: nil
                )
            } catch {
                // Local notifications remain the reliable fallback if ActivityKit refuses the request.
            }
        }
    }

    private func updateLiveActivity(for session: ActiveTeaTimerSession, timerState: String) {
        Task {
            let state = liveActivityState(for: session, timerState: timerState)
            for activity in Activity<TeaTimerActivityAttributes>.activities where activity.attributes.timerId == session.id.uuidString {
                await activity.update(
                    ActivityContent(state: state, staleDate: session.endDate)
                )
            }
        }
    }

    private func endLiveActivity(
        for session: ActiveTeaTimerSession,
        finalState: String,
        dismissalPolicy: ActivityUIDismissalPolicy
    ) {
        Task {
            let state = liveActivityState(for: session, timerState: finalState)
            for activity in Activity<TeaTimerActivityAttributes>.activities where activity.attributes.timerId == session.id.uuidString {
                await activity.end(
                    ActivityContent(state: state, staleDate: nil),
                    dismissalPolicy: dismissalPolicy
                )
            }
        }
    }

    private func endAllLiveActivities(finalState: String, dismissalPolicy: ActivityUIDismissalPolicy) async {
        for activity in Activity<TeaTimerActivityAttributes>.activities {
            let state = TeaTimerActivityAttributes.ContentState(
                teaName: localizedDefaultTeaName(selectedTea, language: appLanguage),
                teaType: selectedTea.flavor,
                endDate: Date(),
                timerState: finalState,
                brewingLabel: localizedText(.brewing, language: appLanguage),
                brewingMessage: localizedText(.brewingYourTea, language: appLanguage),
                remainingLabel: localizedText(.remaining, language: appLanguage)
            )
            await activity.end(
                ActivityContent(state: state, staleDate: nil),
                dismissalPolicy: dismissalPolicy
            )
        }
    }

    private func endAllLiveActivities(finalState: String, dismissalPolicy: ActivityUIDismissalPolicy) {
        Task {
            await endAllLiveActivities(finalState: finalState, dismissalPolicy: dismissalPolicy)
        }
    }

    private func liveActivityState(
        for session: ActiveTeaTimerSession,
        timerState: String
    ) -> TeaTimerActivityAttributes.ContentState {
        TeaTimerActivityAttributes.ContentState(
            teaName: localizedDefaultTeaName(name: session.teaName, source: session.source, language: appLanguage),
            teaType: session.teaType,
            endDate: session.endDate,
            timerState: timerState == "completed" ? "ready" : timerState,
            brewingLabel: localizedText(.brewing, language: appLanguage),
            brewingMessage: localizedText(.brewingYourTea, language: appLanguage),
            remainingLabel: localizedText(.remaining, language: appLanguage)
        )
    }

    private func updateActiveSessionThought(mood: String?, note: String?, photoFilename: String?) {
        activeSessionDraft?.mood = mood
        activeSessionDraft?.note = note
        activeSessionDraft?.photoFilename = photoFilename
        activeTimerSession?.mood = mood
        activeTimerSession?.note = note
        activeTimerSession?.photoFilename = photoFilename
        if let activeTimerSession {
            persistActiveTimerSession(activeTimerSession)
        }
    }

    private func hasReviewForSameTea(as moment: TeaMoment) -> Bool {
        let identity = teaReviewIdentity(for: moment)
        return teaMoments.contains { savedMoment in
            savedMoment.id != moment.id &&
            teaReviewIdentity(for: savedMoment) == identity &&
            isTeaMomentReviewed(savedMoment)
        }
    }

    private func showThoughtBannerIfNeeded() {
        guard !didShowThoughtBannerForSession else { return }
        showThoughtBanner = true
        didShowThoughtBannerForSession = true

        Task {
            try? await Task.sleep(for: .seconds(5))
            await MainActor.run {
                showThoughtBanner = false
            }
        }
    }

    private func completeTeaSession() {
        guard var draft = activeSessionDraft, !draft.didSaveMoment else { return }

        let moment = TeaMoment(
            id: UUID(),
            teaName: draft.teaName,
            date: Date(),
            infusionTimeUsed: draft.infusionTimeUsed,
            suggestedInfusionTime: draft.suggestedInfusionTime,
            waterTemperature: draft.waterTemperature,
            caffeineLevel: draft.caffeineLevel,
            mood: draft.mood,
            note: draft.note,
            teaImageName: draft.teaImageName,
            teaCategory: draft.teaCategory,
            source: draft.source,
            rating: nil,
            review: nil,
            productId: draft.productId,
            producer: draft.producer,
            qrCodeValue: draft.qrCodeValue,
            barcodeValue: draft.barcodeValue,
            photoFilename: draft.photoFilename
        )

        draft.didSaveMoment = true
        activeSessionDraft = draft
        activeTimerSession?.didSaveMoment = true
        activeTimerSession?.timerState = "completed"
        teaMoments.insert(moment, at: 0)
        saveTeaMoments(teaMoments)
        lastSavedMoment = moment
        let completedSession = activeTimerSession
        remainingSeconds = 0
        isRunning = false
        activeTimerSession = nil
        activeTeaTimerSessionData = ""
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [teaReadyNotificationIdentifier])
        if let completedSession {
            endLiveActivity(for: completedSession, finalState: "ready", dismissalPolicy: .immediate)
        } else {
            endAllLiveActivities(finalState: "ready", dismissalPolicy: .immediate)
        }
        showThoughtBanner = false
        showCompletionBanner = true
        didSaveLatestMoment = true
        triggerCompletionFeedback()

        Task {
            try? await Task.sleep(for: .seconds(6))
            await MainActor.run {
                showCompletionBanner = false
            }
        }
    }

    private func triggerCompletionFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        timerCompletionPulse = true

        Task {
            try? await Task.sleep(for: .milliseconds(900))
            await MainActor.run {
                timerCompletionPulse = false
            }
        }
    }

    private func addCustomTea(_ tea: TeaProfile) {
        customTeas.append(tea)
        saveCustomTeas(customTeas)
    }

    private func savedScannedTeaIndex(for scanResult: TeaTextScanResult) -> Int? {
        let identity = savedScannedTeaIdentity(brandName: scanResult.brandName, teaName: scanResult.detectedName)
        return savedScannedTeas.firstIndex {
            savedScannedTeaIdentity(brandName: $0.brandName, teaName: $0.teaName) == identity
        }
    }

    @discardableResult
    private func saveScannedTea(_ scanResult: TeaTextScanResult) -> Bool {
        let alreadySaved = savedScannedTeaIndex(for: scanResult) != nil
        if let index = savedScannedTeaIndex(for: scanResult) {
            savedScannedTeas[index].teaName = scanResult.detectedName
            savedScannedTeas[index].brandName = scanResult.brandName
            savedScannedTeas[index].teaType = scanResult.teaTypeName
            savedScannedTeas[index].styleId = scanResult.styleId
            savedScannedTeas[index].lastUsedDate = Date()
            savedScannedTeas[index].usageCount += 1
            savedScannedTeas[index].scannedText = scanResult.rawText
            savedScannedTeas[index].notes = scanResult.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? scanResult.notes : savedScannedTeas[index].notes
            if scanResult.brewTimeSource == "manual" || scanResult.brewTimeSource == "package" || savedScannedTeas[index].brewTimeSource != "package" {
                savedScannedTeas[index].suggestedBrewTime = scanResult.suggestedBrewTime
                savedScannedTeas[index].brewTimeSource = scanResult.brewTimeSource
                savedScannedTeas[index].originalDetectedTimeText = scanResult.originalDetectedTimeText
            }
            if scanResult.temperatureSource == "manual" || scanResult.temperatureSource == "package" || savedScannedTeas[index].temperatureSource != "package" {
                savedScannedTeas[index].detectedTemperature = scanResult.suggestedTemperature
                savedScannedTeas[index].temperatureSource = scanResult.temperatureSource
                savedScannedTeas[index].originalDetectedTemperatureText = scanResult.originalDetectedTemperatureText
            }
            if !savedScannedTeas[index].detectionKeywords.contains(scanResult.matchedKeyword) {
                savedScannedTeas[index].detectionKeywords.append(scanResult.matchedKeyword)
            }
        } else {
            savedScannedTeas.insert(savedScannedTea(from: scanResult), at: 0)
        }

        saveScannedTeas(savedScannedTeas)
        return alreadySaved
    }

    private func useSavedScannedTea(_ savedTea: SavedScannedTea) {
        guard let index = savedScannedTeas.firstIndex(where: { $0.id == savedTea.id }) else {
            selectTea(teaProfile(from: savedTea))
            return
        }

        savedScannedTeas[index].lastUsedDate = Date()
        savedScannedTeas[index].usageCount += 1
        let updatedTea = savedScannedTeas[index]
        saveScannedTeas(savedScannedTeas)
        selectTea(teaProfile(from: updatedTea))
    }

    private func refreshSavedScannedTeaIfBetter(_ scanResult: TeaTextScanResult) {
        guard (scanResult.brewTimeSource == "package" || scanResult.temperatureSource == "package"),
              let index = savedScannedTeaIndex(for: scanResult) else {
            return
        }

        if scanResult.brewTimeSource == "package" {
            savedScannedTeas[index].suggestedBrewTime = scanResult.suggestedBrewTime
            savedScannedTeas[index].brewTimeSource = scanResult.brewTimeSource
            savedScannedTeas[index].originalDetectedTimeText = scanResult.originalDetectedTimeText
        }
        if scanResult.temperatureSource == "package" {
            savedScannedTeas[index].detectedTemperature = scanResult.suggestedTemperature
            savedScannedTeas[index].temperatureSource = scanResult.temperatureSource
            savedScannedTeas[index].originalDetectedTemperatureText = scanResult.originalDetectedTemperatureText
        }
        savedScannedTeas[index].scannedText = scanResult.rawText
        if !savedScannedTeas[index].detectionKeywords.contains(scanResult.matchedKeyword) {
            savedScannedTeas[index].detectionKeywords.append(scanResult.matchedKeyword)
        }
        saveScannedTeas(savedScannedTeas)
    }

    private func updateSavedScannedTea(_ editedTea: SavedScannedTea, originalTea: SavedScannedTea) {
        var teaToSave = editedTea
        teaToSave.lastUsedDate = Date()

        let editedIdentity = savedScannedTeaIdentity(brandName: teaToSave.brandName, teaName: teaToSave.teaName)
        let duplicateIndex = savedScannedTeas.firstIndex { tea in
            tea.id != originalTea.id &&
            savedScannedTeaIdentity(brandName: tea.brandName, teaName: tea.teaName) == editedIdentity
        }
        let originalIndex = savedScannedTeas.firstIndex { $0.id == originalTea.id }

        if let duplicateIndex {
            let existingTea = savedScannedTeas[duplicateIndex]
            teaToSave.id = existingTea.id
            teaToSave.dateAdded = existingTea.dateAdded
            teaToSave.usageCount = max(existingTea.usageCount, originalTea.usageCount) + 1
            teaToSave.detectionKeywords = Array(Set(existingTea.detectionKeywords + originalTea.detectionKeywords + teaToSave.detectionKeywords)).sorted()
            savedScannedTeas[duplicateIndex] = teaToSave

            if let originalIndex {
                savedScannedTeas.remove(at: originalIndex)
            }
        } else if let originalIndex {
            teaToSave.id = originalTea.id
            teaToSave.dateAdded = originalTea.dateAdded
            teaToSave.usageCount = originalTea.usageCount
            savedScannedTeas[originalIndex] = teaToSave
        }

        saveScannedTeas(savedScannedTeas)

        if selectedTea.source == "saved-scan",
           selectedTea.productId == originalTea.id.uuidString || selectedTea.productId == teaToSave.id.uuidString {
            selectTea(teaProfile(from: teaToSave))
        }
    }

    private func deleteSavedScannedTea(_ savedTea: SavedScannedTea) {
        savedScannedTeas.removeAll { $0.id == savedTea.id }
        saveScannedTeas(savedScannedTeas)

        if selectedTea.source == "saved-scan", selectedTea.productId == savedTea.id.uuidString {
            selectTea(teaProfiles[0])
        }
    }

    private func loadSavedScannedTeas() {
        guard let data = savedScannedTeasData.data(using: .utf8),
              let teas = try? JSONDecoder().decode([SavedScannedTea].self, from: data) else {
            return
        }
        savedScannedTeas = teas
    }

    private func saveScannedTeas(_ teas: [SavedScannedTea]) {
        if let data = try? JSONEncoder().encode(teas),
           let json = String(data: data, encoding: .utf8) {
            savedScannedTeasData = json
        }
    }

    private func deleteCustomTea(_ tea: TeaProfile) {
        customTeas.removeAll { $0.id == tea.id }
        saveCustomTeas(customTeas)

        if selectedTea.id == tea.id {
            selectTea(teaProfiles[0])
        }
    }

    private func loadCustomTeas() {
        guard let data = savedCustomTeasData.data(using: .utf8),
              let savedTeas = try? JSONDecoder().decode([SavedTeaProfile].self, from: data) else {
            return
        }
        customTeas = savedTeas.map(\.teaProfile)
    }

    private func saveCustomTeas(_ teas: [TeaProfile]) {
        let savedTeas = teas.map { tea -> SavedTeaProfile in
            let preset = teaStylePresets.first { $0.imageName == tea.imageName } ?? teaStylePresets[0]
            return SavedTeaProfile(from: tea, tintRGB: preset.tintRGB)
        }

        if let data = try? JSONEncoder().encode(savedTeas),
           let json = String(data: data, encoding: .utf8) {
            savedCustomTeasData = json
        }
    }

    private func loadTeaMoments() {
        guard let data = savedTeaMomentsData.data(using: .utf8),
              let savedMoments = try? JSONDecoder().decode([TeaMoment].self, from: data) else {
            return
        }
        teaMoments = savedMoments.sorted { $0.date > $1.date }
    }

    private func saveTeaMoments(_ moments: [TeaMoment]) {
        if let data = try? JSONEncoder().encode(moments),
           let json = String(data: data, encoding: .utf8) {
            savedTeaMomentsData = json
        }
    }

    private func updateTeaMoment(_ moment: TeaMoment, mood: String?, note: String?, rating: Int?, review: String?, photoFilename: String?) {
        guard let index = teaMoments.firstIndex(where: { $0.id == moment.id }) else { return }
        let updatedMoment = TeaMoment(
            id: moment.id,
            teaName: moment.teaName,
            date: moment.date,
            infusionTimeUsed: moment.infusionTimeUsed,
            suggestedInfusionTime: moment.suggestedInfusionTime,
            waterTemperature: moment.waterTemperature,
            caffeineLevel: moment.caffeineLevel,
            mood: mood,
            note: note,
            teaImageName: moment.teaImageName,
            teaCategory: moment.teaCategory,
            source: moment.source,
            rating: rating,
            review: review,
            productId: moment.productId,
            producer: moment.producer,
            qrCodeValue: moment.qrCodeValue,
            barcodeValue: moment.barcodeValue,
            photoFilename: photoFilename
        )

        let oldPhotoFilename = teaMoments[index].photoFilename
        teaMoments[index] = updatedMoment
        if let oldPhotoFilename,
           oldPhotoFilename != photoFilename,
           !teaMoments.contains(where: { $0.id != moment.id && $0.photoFilename == oldPhotoFilename }) {
            deleteTeaMomentPhoto(filename: oldPhotoFilename)
        }
        if lastSavedMoment?.id == moment.id {
            lastSavedMoment = updatedMoment
        }
        saveTeaMoments(teaMoments)
    }

    private func deleteTeaMoment(_ moment: TeaMoment) {
        teaMoments.removeAll { $0.id == moment.id }
        if let photoFilename = moment.photoFilename,
           !teaMoments.contains(where: { $0.photoFilename == photoFilename }) {
            deleteTeaMomentPhoto(filename: photoFilename)
        }
        if lastSavedMoment?.id == moment.id {
            lastSavedMoment = nil
            didSaveLatestMoment = false
        }
        saveTeaMoments(teaMoments)
    }

    private var statsGrid: some View {
        HStack(spacing: 10) {
            TeaStat(title: t(.water), value: selectedTea.temperature, iconName: "drop", tint: selectedTea.tint)
            TeaStat(title: t(.infusionLabel), value: selectedTea.steepTime, iconName: "clock", tint: selectedTea.tint)
            TeaStat(title: t(.caffeine), value: localizedCaffeineLevel(selectedTea.caffeine, languageRaw: languageRaw), iconName: "bolt", tint: selectedTea.tint)
        }
    }

    private var teaInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 9) {
                        Image(systemName: "leaf")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(selectedTea.tint)

                        Text(selectedTea.source == "scanned" || selectedTea.source == "saved-scan" ? t(.teaDetails) : t(.flavorNotes))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(selectedTea.tint)
                    }

                    if selectedTea.source == "scanned" || selectedTea.source == "saved-scan" {
                        scannedTeaDetails
                    } else {
                        Text(localizedDefaultTeaFlavor(selectedTea, language: appLanguage))
                            .font(.title3.weight(.bold))
                            .lineSpacing(2)
                            .foregroundStyle(.white)

                        Text(localizedDefaultTeaDetail(selectedTea, language: appLanguage))
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(.white.opacity(0.66))
                    }

                    if let selectedTeaMemoryText {
                        HStack(spacing: 9) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(selectedTea.tint)

                            Text(selectedTeaMemoryText)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.68))
                                .lineSpacing(3)
                        }
                        .padding(12)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(selectedTea.tint.opacity(0.12))

                    Image(systemName: "leaf")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(selectedTea.tint)
                }
                .frame(width: 84, height: 84)
                .padding(.top, 24)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.30))

                selectedTea.tint.opacity(0.18)
                    .blur(radius: 62)
                    .frame(width: 170, height: 150)
                    .offset(x: 52, y: -44)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        colors: [selectedTea.tint.opacity(0.55), .white.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var scannedTeaDetails: some View {
        VStack(alignment: .leading, spacing: 9) {
            if let brand = selectedTea.producer, !brand.isEmpty {
                ScannedTeaDetailRow(label: t(.brand), value: brand, tint: selectedTea.tint)
            }

            ScannedTeaDetailRow(label: t(.tea), value: selectedTea.name, tint: selectedTea.tint)
            ScannedTeaDetailRow(label: t(.type), value: localizedTeaCategoryLabel(selectedTea.flavor, languageRaw: languageRaw), tint: selectedTea.tint)
            ScannedTeaDetailRow(
                label: t(.timer),
                value: selectedTea.brewTimeSource == "package" ? "\(selectedTea.steepSeconds.minuteText) · \(t(.fromPackage))" : "\(selectedTea.steepSeconds.minuteText) · \(t(.defaultFor)) \(localizedTeaCategoryLabel(selectedTea.flavor, languageRaw: languageRaw))",
                tint: selectedTea.tint
            )
            ScannedTeaDetailRow(
                label: t(.water),
                value: selectedTea.temperatureSource == "package" ? "\(selectedTea.temperature) · \(t(.fromPackage))" : "\(selectedTea.temperature) · \(t(.defaultLabel))",
                tint: selectedTea.tint
            )

            Text(selectedTea.detail)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.66))
                .padding(.top, 3)
        }
    }
}

private struct TeaPortrait: View {
    let tea: TeaProfile
    let isSelected: Bool

    var body: some View {
        ZStack {
            teaImage

            Circle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 74, height: 74)

            Circle()
                .stroke(.white.opacity(isSelected ? 0.24 : 0.14), lineWidth: 1)

            Circle()
                .stroke(tea.tint.opacity(isSelected ? 0.96 : 0.0), lineWidth: 4)
                .padding(2)
        }
        .frame(width: 76, height: 76)
        .shadow(color: isSelected ? tea.tint.opacity(0.48) : .black.opacity(0.35), radius: isSelected ? 18 : 8, x: 0, y: 8)
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isSelected)
    }

    @ViewBuilder
    private var teaImage: some View {
        if let url = Bundle.main.url(forResource: tea.imageName, withExtension: "png"),
           let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 74, height: 74)
                .clipShape(Circle())
                .overlay(.black.opacity(isSelected ? 0.0 : 0.08))
        } else {
            Circle()
                .fill(tea.tint.opacity(0.26))
                .overlay {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(tea.tint)
                }
        }
    }
}

private struct ScanTeaPortrait: View {
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.12), .black.opacity(0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .stroke(.white.opacity(0.16), lineWidth: 1)

            Circle()
                .stroke(tint.opacity(0.34), lineWidth: 2)
                .padding(5)

            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 27, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 76, height: 76)
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 8)
    }
}

private struct SavedTeasSelectorCard: View {
    let tint: Color
    let count: Int
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.08))

                RoundedRectangle(cornerRadius: 8)
                    .stroke(tint.opacity(0.30), lineWidth: 1)

                VStack(spacing: 5) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(tint)

                    Text(count == 0 ? "No saved yet" : "\(count) saved")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.54))
                        .lineLimit(1)
                }
            }
            .frame(width: 92, height: 76)
            .shadow(color: .black.opacity(0.30), radius: 8, x: 0, y: 8)

            VStack(spacing: 2) {
                Text(localizedText(.savedTeas, languageRaw: languageRaw))
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
                    .foregroundStyle(.white.opacity(0.72))

                Text(localizedText(.scannedBefore, languageRaw: languageRaw))
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(.white.opacity(0.42))
            }
        }
        .frame(width: 104, height: 110, alignment: .top)
        .accessibilityLabel(localizedText(.savedTeas, languageRaw: languageRaw))
    }
}

private struct SavedScannedTeaCard: View {
    let tea: SavedScannedTea
    let tint: Color
    let onTap: () -> Void
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    init(
        tea: SavedScannedTea,
        tint: Color,
        onTap: @escaping () -> Void,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.tea = tea
        self.tint = tint
        self.onTap = onTap
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                onTap()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 38, height: 38)
                        .background(tint.opacity(0.14), in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        if let brandName = tea.brandName, !brandName.isEmpty {
                            Text(brandName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.54))
                        }

                        Text(tea.teaName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(tea.teaType)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.56))
                            .lineLimit(1)

                        Text(tea.brewTimeSourceLabel)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.46))
                            .lineLimit(1)

                        if !tea.temperatureSourceLabel.isEmpty {
                            Text("\(localizedText(.water, languageRaw: languageRaw)): \(tea.temperatureSourceLabel)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.42))
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    Text(tea.suggestedBrewTime.formattedTime)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(tint)
                }
            }
            .buttonStyle(.plain)

            if onEdit != nil || onDelete != nil {
                VStack(spacing: 8) {
                    if let onEdit {
                        Button {
                            onEdit()
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(tint)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.07), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(localizedText(.edit, languageRaw: languageRaw)) \(tea.teaName)")
                    }

                    if let onDelete {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.62))
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.07), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(localizedText(.remove, languageRaw: languageRaw)) \(tea.teaName)")
                    }
                }
            }
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct ScannedTeaDetailRow: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(label):")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.86))
                .lineLimit(2)
        }
    }
}

private struct ScannedTeaResultCard: View {
    let result: TeaTextScanResult
    let tint: Color
    let isAlreadySaved: Bool
    let message: String?
    let onUseTimer: () -> Void
    let onSaveTea: () -> Void
    let onEdit: () -> Void
    let onScanAgain: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(tint)

                Text(localizedText(.teaFound, languageRaw: languageRaw))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Label(localizedText(.edit, languageRaw: languageRaw), systemImage: "pencil")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(tint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.08), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                if let brandName = result.brandName, !brandName.isEmpty {
                    ScannedTeaDetailRow(label: localizedText(.brand, languageRaw: languageRaw), value: brandName, tint: tint)
                }

                ScannedTeaDetailRow(label: localizedText(.tea, languageRaw: languageRaw), value: result.detectedName, tint: tint)
                ScannedTeaDetailRow(label: localizedText(.type, languageRaw: languageRaw), value: localizedTeaCategoryLabel(result.teaTypeName, languageRaw: languageRaw), tint: tint)
                ScannedTeaDetailRow(label: localizedText(.timer, languageRaw: languageRaw), value: result.brewTimeSourceLabel, tint: tint)
                ScannedTeaDetailRow(label: localizedText(.water, languageRaw: languageRaw), value: result.temperatureSourceLabel, tint: tint)
            }

            Text(message ?? localizedText(.simpleSavedNote, languageRaw: languageRaw))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.62))
                .lineSpacing(3)

            VStack(spacing: 10) {
                Button {
                    onUseTimer()
                } label: {
                    Label(localizedText(.useTimer, languageRaw: languageRaw), systemImage: "timer")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(PrimaryTeaButtonStyle(tint: tint))

                HStack(spacing: 10) {
                    Button {
                        if isAlreadySaved {
                            onUseTimer()
                        } else {
                            onSaveTea()
                        }
                    } label: {
                        Label(isAlreadySaved ? localizedText(.openSavedTea, languageRaw: languageRaw) : localizedText(.saveTea, languageRaw: languageRaw), systemImage: isAlreadySaved ? "bookmark.fill" : "square.and.arrow.down")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(SecondaryTeaButtonStyle())

                    Button {
                        onScanAgain()
                    } label: {
                        Label(localizedText(.scanAgain, languageRaw: languageRaw), systemImage: "camera.viewfinder")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(SecondaryTeaButtonStyle())
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint.opacity(0.24), lineWidth: 1)
        )
    }
}

private struct ScanResultEditSheet: View {
    let result: TeaTextScanResult
    let tint: Color
    let onSave: (TeaTextScanResult) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var teaName: String
    @State private var brandName: String
    @State private var teaType: String
    @State private var brewMinutes: String
    @State private var note: String

    init(
        result: TeaTextScanResult,
        tint: Color,
        onSave: @escaping (TeaTextScanResult) -> Void
    ) {
        self.result = result
        self.tint = tint
        self.onSave = onSave
        _teaName = State(initialValue: result.detectedName)
        _brandName = State(initialValue: result.brandName ?? "")
        _teaType = State(initialValue: editableTeaTypeOptions.contains(result.teaTypeName) ? result.teaTypeName : "Other")
        _brewMinutes = State(initialValue: minutesInputText(for: result.suggestedBrewTime))
        _note = State(initialValue: result.notes ?? "")
    }

    private var parsedBrewSeconds: Int? {
        secondsFromMinutesInput(brewMinutes)
    }

    private var canSave: Bool {
        !teaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && parsedBrewSeconds != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localizedText(.sectionTea, languageRaw: languageRaw)) {
                    TextField(localizedText(.teaName, languageRaw: languageRaw), text: $teaName)
                    TextField(localizedText(.brandName, languageRaw: languageRaw), text: $brandName)

                    Picker(localizedText(.teaType, languageRaw: languageRaw), selection: $teaType) {
                        ForEach(editableTeaTypeOptions, id: \.self) { option in
                            Text(localizedTeaCategoryLabel(option, languageRaw: languageRaw)).tag(option)
                        }
                    }
                }

                Section(localizedText(.timer, languageRaw: languageRaw)) {
                    TextField(localizedText(.minutes, languageRaw: languageRaw), text: $brewMinutes)
                        .keyboardType(.decimalPad)

                    Text(localizedText(.manualTimerNote, languageRaw: languageRaw))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(localizedText(.note, languageRaw: languageRaw)) {
                    TextField(localizedText(.optionalShortNote, languageRaw: languageRaw), text: $note, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                }
            }
            .navigationTitle(localizedText(.editScan, languageRaw: languageRaw))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedText(.cancel, languageRaw: languageRaw)) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(localizedText(.saveChanges, languageRaw: languageRaw)) {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func saveChanges() {
        guard let brewSeconds = parsedBrewSeconds else { return }

        var editedResult = result
        editedResult.detectedName = teaName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBrandName = brandName.trimmingCharacters(in: .whitespacesAndNewlines)
        editedResult.brandName = cleanBrandName.isEmpty ? nil : cleanBrandName
        editedResult.detectedTeaTypeName = teaType
        editedResult.styleId = styleId(forTeaTypeName: teaType)

        if brewSeconds != result.suggestedBrewTime {
            editedResult.editedBrewTimeSeconds = brewSeconds
        } else {
            editedResult.editedBrewTimeSeconds = result.editedBrewTimeSeconds
        }

        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        editedResult.notes = cleanNote.isEmpty ? nil : cleanNote
        onSave(editedResult)
        dismiss()
    }
}

private struct SavedScannedTeaEditSheet: View {
    let tea: SavedScannedTea
    let tint: Color
    let onSave: (SavedScannedTea) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var teaName: String
    @State private var brandName: String
    @State private var teaType: String
    @State private var brewMinutes: String
    @State private var note: String

    init(
        tea: SavedScannedTea,
        tint: Color,
        onSave: @escaping (SavedScannedTea) -> Void
    ) {
        self.tea = tea
        self.tint = tint
        self.onSave = onSave
        _teaName = State(initialValue: tea.teaName)
        _brandName = State(initialValue: tea.brandName ?? "")
        _teaType = State(initialValue: editableTeaTypeOptions.contains(tea.teaType) ? tea.teaType : "Other")
        _brewMinutes = State(initialValue: minutesInputText(for: tea.suggestedBrewTime))
        _note = State(initialValue: tea.notes ?? "")
    }

    private var parsedBrewSeconds: Int? {
        secondsFromMinutesInput(brewMinutes)
    }

    private var canSave: Bool {
        !teaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && parsedBrewSeconds != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localizedText(.sectionTea, languageRaw: languageRaw)) {
                    TextField(localizedText(.teaName, languageRaw: languageRaw), text: $teaName)
                    TextField(localizedText(.brandName, languageRaw: languageRaw), text: $brandName)

                    Picker(localizedText(.teaType, languageRaw: languageRaw), selection: $teaType) {
                        ForEach(editableTeaTypeOptions, id: \.self) { option in
                            Text(localizedTeaCategoryLabel(option, languageRaw: languageRaw)).tag(option)
                        }
                    }
                }

                Section(localizedText(.timer, languageRaw: languageRaw)) {
                    TextField(localizedText(.minutes, languageRaw: languageRaw), text: $brewMinutes)
                        .keyboardType(.decimalPad)

                    Text(localizedText(.manualTimerNote, languageRaw: languageRaw))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section(localizedText(.note, languageRaw: languageRaw)) {
                    TextField(localizedText(.optionalShortNote, languageRaw: languageRaw), text: $note, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                }
            }
            .navigationTitle(localizedText(.editSavedTea, languageRaw: languageRaw))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedText(.cancel, languageRaw: languageRaw)) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(localizedText(.saveChanges, languageRaw: languageRaw)) {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func saveChanges() {
        guard let brewSeconds = parsedBrewSeconds else { return }

        var editedTea = tea
        editedTea.teaName = teaName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBrandName = brandName.trimmingCharacters(in: .whitespacesAndNewlines)
        editedTea.brandName = cleanBrandName.isEmpty ? nil : cleanBrandName
        editedTea.teaType = teaType
        editedTea.styleId = styleId(forTeaTypeName: teaType)
        editedTea.suggestedBrewTime = brewSeconds
        if brewSeconds != tea.suggestedBrewTime {
            editedTea.brewTimeSource = "manual"
        }

        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        editedTea.notes = cleanNote.isEmpty ? nil : cleanNote
        onSave(editedTea)
        dismiss()
    }
}

private struct SavedScannedTeasSheet: View {
    let teas: [SavedScannedTea]
    let onUseTea: (SavedScannedTea) -> Void
    let onUpdateTea: (SavedScannedTea, SavedScannedTea) -> Void
    let onDeleteTea: (SavedScannedTea) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var editingTea: SavedScannedTea?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.045, blue: 0.035),
                    Color(red: 0.005, green: 0.008, blue: 0.006)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.savedTeas, languageRaw: languageRaw))
                                .font(.system(size: 32, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedText(.useScannedBefore, languageRaw: languageRaw))
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white.opacity(0.62))
                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white.opacity(0.72))
                                .frame(width: 38, height: 38)
                                .background(.white.opacity(0.08), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(localizedText(.close, languageRaw: languageRaw))
                    }

                    if teas.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "bookmark")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.42))

                            Text(localizedText(.noSavedTeasYet, languageRaw: languageRaw))
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)

                            Text(localizedText(.noSavedTeasDetail, languageRaw: languageRaw))
                                .font(.system(size: 14, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.56))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 34)
                        .padding(.horizontal, 18)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.10), lineWidth: 1)
                        )
                    } else {
                        VStack(spacing: 10) {
                            ForEach(teas) { tea in
                                SavedScannedTeaCard(
                                    tea: tea,
                                    tint: teaStylePreset(id: tea.styleId).tint,
                                    onTap: {
                                        onUseTea(tea)
                                    },
                                    onEdit: {
                                        editingTea = tea
                                    },
                                    onDelete: {
                                        onDeleteTea(tea)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .sheet(item: $editingTea) { tea in
            SavedScannedTeaEditSheet(tea: tea, tint: teaStylePreset(id: tea.styleId).tint) { editedTea in
                onUpdateTea(editedTea, tea)
            }
        }
    }
}

private struct ThoughtNotificationBanner: View {
    let tint: Color
    let onTap: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))

                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text(localizedText(.takeMoment, languageRaw: languageRaw))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Text(localizedText(.addThoughtBrewing, languageRaw: languageRaw))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.36), radius: 22, x: 0, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(localizedText(.addThought, languageRaw: languageRaw))
    }
}

private struct CompletionNotificationBanner: View {
    let moment: TeaMoment
    let tint: Color
    let onTap: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))

                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(tint)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(moment.teaName) · \(localizedText(.teaIsReady, languageRaw: languageRaw))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(localizedText(.savedMomentMessage, languageRaw: languageRaw))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.36), radius: 22, x: 0, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(localizedText(.savedMomentMessage, languageRaw: languageRaw))
    }
}

private struct ScanTeaSheet: View {
    let tint: Color
    let knownProducts: [KnownTeaProduct]
    let onDetectProduct: (KnownTeaProduct) -> Void
    let isScannedTeaSaved: (TeaTextScanResult) -> Bool
    let onUseScannedTea: (TeaTextScanResult) -> Void
    let onSaveScannedTea: (TeaTextScanResult) -> Bool
    let onRefreshSavedScannedTea: (TeaTextScanResult) -> Void
    let onSaveCustomTea: (TeaProfile) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var didTapStartScan = false
    @State private var isShowingLiveScanner = false
    @State private var isShowingCustomForm = false
    @State private var scannedResult: TeaTextScanResult?
    @State private var editingScannedResult: TeaTextScanResult?
    @State private var scannedResultIsSaved = false
    @State private var savedResultMessage: String?
    @State private var notFoundCode: String?
    @State private var unclearScannedText: String?
    @State private var scannerStatusMessage: String?

    private var groupedProducts: [(TeaStylePreset, [KnownTeaProduct])] {
        teaStylePresets.compactMap { style in
            let products = knownProducts
                .filter { $0.styleId == style.id }
                .sorted { $0.teaName < $1.teaName }
            return products.isEmpty ? nil : (style, products)
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.045, blue: 0.035),
                    Color(red: 0.005, green: 0.008, blue: 0.006)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.14))
                        .frame(width: 104, height: 104)

                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 46, weight: .semibold))
                        .foregroundStyle(tint)
                }
                .padding(.top, 18)

                VStack(spacing: 10) {
                    Text(localizedText(.scanTea, languageRaw: languageRaw))
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(.white)

                    Text(localizedText(.scannerSubtitle, languageRaw: languageRaw))
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .foregroundStyle(.white.opacity(0.68))
                        .padding(.horizontal, 16)
                }

                VStack(spacing: 12) {
                    Button {
                        didTapStartScan = true
                        scannedResult = nil
                        editingScannedResult = nil
                        scannedResultIsSaved = false
                        savedResultMessage = nil
                        unclearScannedText = nil
                        scannerStatusMessage = nil
                        isShowingLiveScanner = true
                    } label: {
                        Label(localizedText(.startScan, languageRaw: languageRaw), systemImage: "camera.viewfinder")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(PrimaryTeaButtonStyle(tint: tint))

                    if let scannedResult {
                        ScannedTeaResultCard(
                            result: scannedResult,
                            tint: teaStylePreset(id: scannedResult.styleId).tint,
                            isAlreadySaved: scannedResultIsSaved,
                            message: savedResultMessage,
                            onUseTimer: {
                                onUseScannedTea(scannedResult)
                            },
                            onSaveTea: {
                                let wasAlreadySaved = onSaveScannedTea(scannedResult)
                                scannedResultIsSaved = true
                                savedResultMessage = wasAlreadySaved ? localizedText(.alreadySavedTea, languageRaw: languageRaw) : localizedText(.savedTeaMessage, languageRaw: languageRaw)
                            },
                            onEdit: {
                                editingScannedResult = scannedResult
                            },
                            onScanAgain: {
                                self.scannedResult = nil
                                editingScannedResult = nil
                                scannedResultIsSaved = false
                                savedResultMessage = nil
                                didTapStartScan = true
                                unclearScannedText = nil
                                scannerStatusMessage = nil
                                isShowingLiveScanner = true
                            }
                        )
                    } else if let notFoundCode {
                        VStack(spacing: 8) {
                            Text(localizedText(.notFoundDatabase, languageRaw: languageRaw))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)

                            Text(String(format: localizedText(.scannedCodePrompt, languageRaw: languageRaw), notFoundCode))
                                .font(.system(size: 13, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.58))
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                    } else if didTapStartScan {
                        scanStatusView
                    }

                    Button {
                        isShowingCustomForm = true
                    } label: {
                        Label(localizedText(.createPersonalizedTea, languageRaw: languageRaw), systemImage: "square.and.pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                    .buttonStyle(SecondaryTeaButtonStyle())
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(localizedText(.starterDatabase, languageRaw: languageRaw))
                        .font(.system(size: 13, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundStyle(.white.opacity(0.48))

                    ForEach(groupedProducts, id: \.0.id) { style, products in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedTeaCategoryLabel(style.title, languageRaw: languageRaw))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(style.tint)

                            ForEach(products) { product in
                                Button {
                                    matchScannedCode(product.qrCodeValue)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "barcode.viewfinder")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(style.tint)
                                            .frame(width: 34, height: 34)
                                            .background(.white.opacity(0.08), in: Circle())

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(product.producer)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(.white.opacity(0.54))

                                            Text(product.teaName)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)

                                            Text(product.qrCodeValue)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.36))
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        Text(product.suggestedInfusionTime.formattedTime)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(style.tint)
                                    }
                                    .padding(12)
                                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.white.opacity(0.08), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text(localizedText(.close, languageRaw: languageRaw))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.62))
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            }
        }
        .sheet(isPresented: $isShowingCustomForm) {
            PersonalizedTeaForm(tint: tint, onSave: onSaveCustomTea)
        }
        .sheet(item: $editingScannedResult) { result in
            ScanResultEditSheet(result: result, tint: teaStylePreset(id: result.styleId).tint) { editedResult in
                scannedResult = editedResult
                scannedResultIsSaved = isScannedTeaSaved(editedResult)
                savedResultMessage = scannedResultIsSaved ? localizedText(.alreadySavedTea, languageRaw: languageRaw) : localizedText(.previewUpdated, languageRaw: languageRaw)
            }
        }
        .fullScreenCover(isPresented: $isShowingLiveScanner) {
            LiveTeaTextScannerScreen(tint: tint) { scannedText in
                handleScannedText(scannedText)
            } onCancel: { scannedText in
                isShowingLiveScanner = false
                handleFinishedScan(scannedText)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var scanStatusView: some View {
        VStack(spacing: 8) {
            if let scannerStatusMessage {
                Text(scannerStatusMessage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            } else {
                Text(localizedText(.pointCamera, languageRaw: languageRaw))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            if let unclearScannedText {
                Text("\(localizedText(.detectedText, languageRaw: languageRaw)): \(unclearScannedText)")
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.58))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }

    private func matchScannedCode(_ code: String) {
        if let match = knownTeaProduct(matching: code, in: knownProducts) {
            notFoundCode = nil
            unclearScannedText = nil
            scannerStatusMessage = nil
            onDetectProduct(match)
        } else {
            notFoundCode = code
            didTapStartScan = false
            unclearScannedText = nil
            scannerStatusMessage = nil
        }
    }

    private func handleScannedText(_ scannedText: String) {
        let cleanText = scannedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        if let result = teaTextScanResult(from: cleanText) {
            isShowingLiveScanner = false
            scannedResult = result
            scannedResultIsSaved = isScannedTeaSaved(result)
            if scannedResultIsSaved {
                onRefreshSavedScannedTea(result)
            }
            savedResultMessage = scannedResultIsSaved ? localizedText(.alreadySavedTea, languageRaw: languageRaw) : nil
            didTapStartScan = false
            unclearScannedText = nil
            scannerStatusMessage = nil
        }
    }

    private func handleFinishedScan(_ scannedText: String) {
        let cleanText = scannedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        didTapStartScan = true
        notFoundCode = nil
        unclearScannedText = cleanText

        if let brandName = teaBrandName(from: cleanText) {
            scannerStatusMessage = String(format: localizedText(.scannerBrandDetectedManual, languageRaw: languageRaw), brandName)
        } else if cleanText.count > 6 {
            scannerStatusMessage = localizedText(.scannerUnclear, languageRaw: languageRaw)
        }
    }
}

private struct LiveTeaTextScannerScreen: View {
    let tint: Color
    let onRecognizedText: (String) -> Void
    let onCancel: (String) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @State private var accumulatedText = ""

    var body: some View {
        ZStack(alignment: .top) {
            if #available(iOS 16.0, *), DataScannerViewController.isSupported, DataScannerViewController.isAvailable {
                LiveTeaTextScannerView { scannedText in
                    let mergedText = rememberScannedText(scannedText)
                    onRecognizedText(mergedText)
                }
                    .ignoresSafeArea()
            } else {
                scannerUnavailableView
            }

            VStack(spacing: 14) {
                HStack {
                    Button {
                        onCancel(accumulatedText)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 42, height: 42)
                            .background(.black.opacity(0.45), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(localizedText(.close, languageRaw: languageRaw))

                    Spacer()
                }

                VStack(spacing: 6) {
                    Text(localizedText(.scanTeaLabel, languageRaw: languageRaw))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text(localizedText(.centerTeaText, languageRaw: languageRaw))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.black.opacity(0.46), in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .preferredColorScheme(.dark)
    }

    private func rememberScannedText(_ scannedText: String) -> String {
        let cleanText = scannedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return accumulatedText }

        if accumulatedText.isEmpty {
            accumulatedText = cleanText
        } else if !normalizedTeaScanText(accumulatedText).contains(normalizedTeaScanText(cleanText)) {
            accumulatedText = "\(accumulatedText) \(cleanText)"
        }

        return accumulatedText
    }

    private var scannerUnavailableView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.025, green: 0.035, blue: 0.030),
                    Color(red: 0.005, green: 0.008, blue: 0.006)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(tint)

                Text(localizedText(.cameraUnavailable, languageRaw: languageRaw))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)

                Text(localizedText(.cameraUnavailableDetail, languageRaw: languageRaw))
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.64))
                    .padding(.horizontal, 28)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct LiveTeaTextScannerView: UIViewControllerRepresentable {
    let onRecognizedText: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onRecognizedText: onRecognizedText)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator

        Task { @MainActor in
            do {
                try scanner.startScanning()
            } catch {
                context.coordinator.onRecognizedText("")
            }
        }

        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onRecognizedText: (String) -> Void
        private var lastRecognizedText = ""

        init(onRecognizedText: @escaping (String) -> Void) {
            self.onRecognizedText = onRecognizedText
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            handleRecognizedItems(allItems)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            handleRecognizedItems(allItems)
        }

        private func handleRecognizedItems(_ items: [RecognizedItem]) {
            let recognizedText = items.compactMap { item -> String? in
                if case .text(let text) = item {
                    return text.transcript
                }
                return nil
            }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !recognizedText.isEmpty, recognizedText != lastRecognizedText else { return }
            lastRecognizedText = recognizedText
            onRecognizedText(recognizedText)
        }
    }
}

private struct PersonalizedTeaForm: View {
    let tint: Color
    let onSave: (TeaProfile) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brand = ""
    @State private var selectedStyleId = "green"
    @State private var temperature = "80"
    @State private var minutes = 2
    @State private var seconds = 30
    @State private var caffeine = "Medium"
    @State private var notes = ""

    private var selectedStyle: TeaStylePreset {
        teaStylePreset(id: selectedStyleId)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.createPersonalizedTea, languageRaw: languageRaw))
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedText(.personalizedTeaSubtitle, languageRaw: languageRaw))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.64))
                        }

                        VStack(spacing: 12) {
                            PremiumTextField(title: localizedText(.teaName, languageRaw: languageRaw), text: $name, placeholder: "Jasmine Green")
                            PremiumTextField(title: localizedText(.brand, languageRaw: languageRaw), text: $brand, placeholder: "Twinings")

                            VStack(alignment: .leading, spacing: 8) {
                                Text(localizedText(.teaStyle, languageRaw: languageRaw))
                                    .font(.system(size: 13, weight: .bold))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white.opacity(0.46))

                                Picker(localizedText(.teaStyle, languageRaw: languageRaw), selection: $selectedStyleId) {
                                    ForEach(teaStylePresets) { style in
                                        Text(localizedTeaCategoryLabel(style.title, languageRaw: languageRaw)).tag(style.id)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: selectedStyleId) { _, newStyleId in
                                    let style = teaStylePreset(id: newStyleId)
                                    temperature = style.temperature.replacingOccurrences(of: " C", with: "")
                                    caffeine = style.caffeine
                                }
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text(localizedText(.suggestedInfusion, languageRaw: languageRaw))
                                    .font(.system(size: 13, weight: .bold))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.white.opacity(0.46))

                                HStack(spacing: 10) {
                                    Stepper("\(minutes) \(localizedText(.min, languageRaw: languageRaw))", value: $minutes, in: 0...30)
                                    Stepper("\(seconds) \(localizedText(.sec, languageRaw: languageRaw))", value: $seconds, in: 0...45, step: 15)
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            }
                            .padding(14)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

                            HStack(spacing: 10) {
                                PremiumTextField(title: localizedText(.waterC, languageRaw: languageRaw), text: $temperature, placeholder: "80")
                                    .keyboardType(.numberPad)
                                PremiumTextField(title: localizedText(.caffeine, languageRaw: languageRaw), text: $caffeine, placeholder: localizedText(.medium, languageRaw: languageRaw))
                            }

                            PremiumTextField(title: localizedText(.notes, languageRaw: languageRaw), text: $notes, placeholder: localizedText(.optionalShortNote, languageRaw: languageRaw))
                        }

                        Button {
                            saveTea()
                        } label: {
                            Label(localizedText(.saveTea, languageRaw: languageRaw), systemImage: "checkmark")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(PrimaryTeaButtonStyle(tint: selectedStyle.tint))
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.45)
                    }
                    .padding(22)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.close, languageRaw: languageRaw)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveTea() {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let totalSeconds = max((minutes * 60) + seconds, 15)
        let tempText = temperature.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTemperature = tempText.isEmpty ? selectedStyle.temperature : "\(tempText) C"
        let brandText = cleanBrand.isEmpty ? localizedText(.personalized, languageRaw: languageRaw) : cleanBrand

        let tea = TeaProfile(
            name: cleanName,
            category: selectedStyle.category,
            temperature: finalTemperature,
            steepSeconds: totalSeconds,
            caffeine: caffeine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? selectedStyle.caffeine : caffeine,
            flavor: cleanNotes.isEmpty ? localizedText(.personalizedBrewingProfile, languageRaw: languageRaw) : cleanNotes,
            detail: String(format: localizedText(.savedFromPersonalizedSettings, languageRaw: languageRaw), brandText),
            imageName: selectedStyle.imageName,
            origin: brandText,
            process: selectedStyle.process,
            character: selectedStyle.character,
            source: "personalized",
            tint: selectedStyle.tint
        )

        onSave(tea)
        dismiss()
    }
}

private let teaMomentMessages: [String: [String]] = [
    "Peaceful": [
        "Peace grows when you give it space.",
        "A quiet cup can soften a loud day.",
        "Slow moments are still progress.",
        "Let this calm stay with you.",
        "Your breath knows the way back.",
        "Small pauses can change the whole day.",
        "Peace is built one moment at a time.",
        "You are allowed to move slowly.",
        "Stillness can be a form of strength.",
        "Let the tea carry the noise away.",
        "Calm is something you can return to.",
        "This moment is enough.",
        "Your mind deserves gentle space.",
        "A soft pause can reset everything.",
        "Peace begins with noticing.",
        "The day can wait for one quiet sip.",
        "You do not have to rush this moment.",
        "Let silence do some of the work.",
        "One calm minute matters.",
        "Keep this quiet feeling close."
    ],
    "Focused": [
        "One clear thought can guide the whole day.",
        "Focus grows when distractions fade.",
        "Do one thing with full attention.",
        "Your energy knows where to go.",
        "Small focus creates big movement.",
        "Let this cup sharpen your intention.",
        "Clarity often arrives quietly.",
        "Stay with the next right step.",
        "A focused mind is a calm mind.",
        "Progress begins with attention.",
        "Give this moment your full presence.",
        "Your direction is becoming clearer.",
        "Focus is a gift you give yourself.",
        "One step is enough to begin again.",
        "Let the noise fall behind you.",
        "Your attention has power.",
        "Simple actions can build strong days.",
        "Keep your mind on what matters.",
        "You are closer when you are present.",
        "Let this tea bring you back to center."
    ],
    "Cozy": [
        "Comfort can be found in small rituals.",
        "Warmth is a kind of quiet happiness.",
        "This cup is a little home for the moment.",
        "Soft moments make strong memories.",
        "Let yourself enjoy the simple things.",
        "Cozy is a feeling worth protecting.",
        "A warm pause can change the mood.",
        "Small comforts are not small.",
        "Let the day feel softer now.",
        "You deserve this gentle moment.",
        "Warm tea, quiet heart.",
        "Make space for what feels good.",
        "This moment can be simple and enough.",
        "Rest inside the warmth.",
        "Let comfort meet you here.",
        "A little softness goes a long way.",
        "This is your small corner of calm.",
        "Let the cup warm more than your hands.",
        "Simple rituals make the day kinder.",
        "Stay here for one more breath."
    ],
    "Tired": [
        "Rest is not wasted time.",
        "You have done enough for this moment.",
        "Even tired steps still count.",
        "Your body is asking for kindness.",
        "Pause before you push again.",
        "You are allowed to slow down.",
        "Recovery is part of strength.",
        "A tired day still deserves softness.",
        "Let this cup be a small reset.",
        "You do not need to carry everything now.",
        "Breathe first, continue later.",
        "Gentle rest can rebuild energy.",
        "It is okay to be human today.",
        "One quiet moment can help.",
        "Do less, but do it with care.",
        "Your energy will return.",
        "Listen to what your body needs.",
        "Let the day become lighter.",
        "Rest now, rise better.",
        "You are still moving forward."
    ],
    "Grateful": [
        "Gratitude makes ordinary moments shine.",
        "Notice what is already here.",
        "A simple cup can hold a lot of thanks.",
        "Small blessings become big memories.",
        "Let appreciation warm the moment.",
        "What you notice, grows.",
        "Gratitude turns pause into presence.",
        "There is something good in this day.",
        "Thankfulness can soften the mind.",
        "Hold one good thing close.",
        "This moment is a gift too.",
        "Let gratitude slow the day down.",
        "The little things are not little.",
        "A thankful heart sees more light.",
        "Remember what made you smile today.",
        "There is beauty in enough.",
        "Gratitude is a quiet kind of joy.",
        "Let this cup remind you of what matters.",
        "One good thought can change the mood.",
        "Appreciate the pause."
    ],
    "Reflective": [
        "Every quiet moment teaches you something.",
        "Reflection turns experience into wisdom.",
        "Listen to what the day is trying to say.",
        "A calm mind can see deeper.",
        "Some answers arrive slowly.",
        "This pause can reveal what matters.",
        "Notice the thought that keeps returning.",
        "Your inner voice gets clearer in quiet.",
        "Looking back can help you move forward.",
        "Let the moment speak before you rush.",
        "Wisdom often starts with a pause.",
        "Ask gently, listen honestly.",
        "This cup can hold more than tea.",
        "Reflection is a way of caring.",
        "The day leaves clues.",
        "Give your thoughts room to breathe.",
        "Quiet questions can open new paths.",
        "You are learning from your own life.",
        "Sometimes clarity is a slow steep.",
        "Let this moment become meaning."
    ],
    "General": [
        "A small pause can become a memory.",
        "This tea moment belongs to you.",
        "Take the moment slowly.",
        "A quiet sip can reset the day.",
        "Let this cup mark the moment.",
        "Your thoughts have a place here.",
        "Simple rituals make life richer.",
        "One moment of presence is enough.",
        "Keep this small memory close.",
        "The day feels different when you pause."
    ]
]

private func teaMomentMessage(for mood: String?) -> String {
    let key = mood ?? "General"
    return (teaMomentMessages[key] ?? teaMomentMessages["General"] ?? []).randomElement() ?? "This tea moment belongs to you."
}

private struct TeaThoughtSheet: View {
    let draft: TeaSessionDraft
    let tint: Color
    let onSave: (String?, String?, String?) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: String?
    @State private var note: String
    @State private var photoFilename: String?
    @State private var inspirationMessage: String?
    @State private var didSaveThought = false

    private let moods = ["Peaceful", "Focused", "Cozy", "Tired", "Grateful", "Reflective"]

    init(draft: TeaSessionDraft, tint: Color, onSave: @escaping (String?, String?, String?) -> Void) {
        self.draft = draft
        self.tint = tint
        self.onSave = onSave
        _selectedMood = State(initialValue: draft.mood)
        _note = State(initialValue: draft.note ?? "")
        _photoFilename = State(initialValue: draft.photoFilename)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.teaMoment, languageRaw: languageRaw))
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedText(.addThoughtBrewing, languageRaw: languageRaw))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.64))
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(draft.teaName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(tint)

                            Text("\(draft.infusionTimeUsed.formattedTime) \(localizedText(.infusion, languageRaw: languageRaw)) · \(localizedText(.suggested, languageRaw: languageRaw)) \(draft.suggestedInfusionTime.formattedTime)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.72))

                            Text("\(draft.waterTemperature) · \(localizedCaffeineLevel(draft.caffeineLevel, languageRaw: languageRaw)) \(localizedText(.caffeine, languageRaw: languageRaw).lowercased()) · \(localizedTeaCategoryLabel(draft.teaCategory, languageRaw: languageRaw))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

                        MoodPicker(moods: moods, selectedMood: $selectedMood, tint: tint)

                        MomentPhotoEditor(photoFilename: $photoFilename, tint: tint)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(localizedText(.thought, languageRaw: languageRaw))
                                .font(.system(size: 13, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.46))

                            TextEditor(text: $note)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 132)
                                .padding(10)
                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                                .overlay(alignment: .topLeading) {
                                    if note.isEmpty {
                                        Text(localizedText(.thoughtPlaceholder, languageRaw: languageRaw))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.34))
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 18)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }

                        Button {
                            let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
                            onSave(selectedMood, cleanNote.isEmpty ? nil : cleanNote, photoFilename)
                            inspirationMessage = localizedTeaMomentMessage(for: selectedMood, languageRaw: languageRaw)
                            didSaveThought = true

                            Task {
                                try? await Task.sleep(for: .seconds(3))
                                await MainActor.run {
                                    dismiss()
                                }
                            }
                        } label: {
                            Label(localizedText(.saveThought, languageRaw: languageRaw), systemImage: "checkmark")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(PrimaryTeaButtonStyle(tint: tint))
                        .disabled(didSaveThought)
                        .opacity(didSaveThought ? 0.55 : 1)
                    }
                    .padding(22)
                }

                if let inspirationMessage {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(tint.opacity(0.16))

                            Image(systemName: "leaf")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(tint)
                        }
                        .frame(width: 64, height: 64)

                        Text(inspirationMessage)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .foregroundStyle(.white)

                        Text(localizedText(.thoughtSaved, languageRaw: languageRaw))
                            .font(.system(size: 13, weight: .bold))
                            .textCase(.uppercase)
                            .foregroundStyle(tint.opacity(0.86))
                    }
                    .padding(24)
                    .frame(maxWidth: 320)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.14), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.44), radius: 26, x: 0, y: 14)
                    .transition(.scale(scale: 0.94).combined(with: .opacity))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.close, languageRaw: languageRaw)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct TeaMomentsHistorySheet: View {
    let moments: [TeaMoment]
    let tint: Color
    let onUpdate: (TeaMoment, String?, String?, Int?, String?, String?) -> Void
    let onDelete: (TeaMoment) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var momentPendingDeletion: TeaMoment?
    @State private var momentPendingEdit: TeaMoment?
    @State private var momentPendingReview: TeaMoment?
    @State private var selectedSection = "Moments"

    private let sections = ["Moments", "Stats", "Reviews"]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.teaMoments, languageRaw: languageRaw))
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedText(.historySubtitle, languageRaw: languageRaw))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.64))
                        }

                        Picker(localizedText(.teaMoments, languageRaw: languageRaw), selection: $selectedSection) {
                            ForEach(sections, id: \.self) { section in
                                Text(localizedSectionTitle(section)).tag(section)
                            }
                        }
                        .pickerStyle(.segmented)

                        if moments.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 34, weight: .semibold))
                                    .foregroundStyle(tint)

                                Text(localizedText(.noTeaMomentsYet, languageRaw: languageRaw))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)

                                Text(localizedText(.completeTimerFirst, languageRaw: languageRaw))
                                    .font(.system(size: 15, weight: .medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white.opacity(0.58))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(28)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                        } else {
                            if selectedSection == "Moments" {
                                ForEach(moments) { moment in
                                    TeaMomentCard(moment: moment, tint: tint) {
                                        momentPendingEdit = moment
                                    } onDelete: {
                                        momentPendingDeletion = moment
                                    }
                                }
                            } else if selectedSection == "Stats" {
                                TeaStatsView(moments: moments, tint: tint)
                            } else {
                                TeaReviewsView(
                                    moments: moments,
                                    tint: tint,
                                    onReview: { moment in
                                        momentPendingReview = moment
                                    },
                                    onEditReview: { moment in
                                        momentPendingReview = moment
                                    }
                                )
                            }
                        }
                    }
                    .padding(22)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.close, languageRaw: languageRaw)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .sheet(item: $momentPendingEdit) { moment in
            TeaMomentEditSheet(moment: moment, tint: tint) { mood, note, rating, review, photoFilename in
                onUpdate(moment, mood, note, rating, review, photoFilename)
                momentPendingEdit = nil
            }
        }
        .sheet(item: $momentPendingReview) { moment in
            TeaMomentReviewSheet(moment: moment, tint: tint) { rating, review, photoFilename in
                onUpdate(moment, moment.mood, moment.note, rating, review, photoFilename)
                momentPendingReview = nil
            }
        }
        .alert(
            localizedText(.deleteMomentAlert, languageRaw: languageRaw),
            isPresented: Binding(
                get: { momentPendingDeletion != nil },
                set: { isPresented in
                    if !isPresented {
                        momentPendingDeletion = nil
                    }
                }
            )
        ) {
            Button(localizedText(.delete, languageRaw: languageRaw), role: .destructive) {
                if let moment = momentPendingDeletion {
                    onDelete(moment)
                }
                momentPendingDeletion = nil
            }
            Button(localizedText(.cancel, languageRaw: languageRaw), role: .cancel) {
                momentPendingDeletion = nil
            }
        } message: {
            Text(localizedText(.deleteMomentMessage, languageRaw: languageRaw))
        }
    }

    private func localizedSectionTitle(_ section: String) -> String {
        switch section {
        case "Stats":
            return localizedText(.stats, languageRaw: languageRaw)
        case "Reviews":
            return localizedText(.reviews, languageRaw: languageRaw)
        default:
            return localizedText(.moments, languageRaw: languageRaw)
        }
    }
}

private struct TeaMomentCard: View {
    let moment: TeaMoment
    let tint: Color
    let onEdit: () -> Void
    let onDelete: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                TeaMomentThumbnail(filename: moment.photoFilename, fallbackIcon: "leaf", tint: tint, size: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(moment.teaName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.54))
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.64))
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.07), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(localizedText(.editMoment, languageRaw: languageRaw))

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.56))
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.07), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(localizedText(.deleteMomentAlert, languageRaw: languageRaw))
                }
            }

            if let mood = moment.mood {
                Text(localizedMood(mood, languageRaw: languageRaw))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black.opacity(0.82))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(tint, in: Capsule())
            }

            Text("\(moment.infusionTimeUsed.formattedTime) \(localizedText(.infusion, languageRaw: languageRaw)) · \(localizedText(.suggested, languageRaw: languageRaw)) \(moment.suggestedInfusionTime.formattedTime)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white.opacity(0.82))

            Text("\(moment.waterTemperature) · \(localizedCaffeineLevel(moment.caffeineLevel, languageRaw: languageRaw)) \(localizedText(.caffeine, languageRaw: languageRaw).lowercased()) · \(localizedTeaCategoryLabel(moment.teaCategory, languageRaw: languageRaw))")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.58))

            if let source = moment.source {
                Text(source.capitalized)
                    .font(.system(size: 12, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(tint.opacity(0.86))
            }

            if let note = moment.note {
                Text("\"\(note)\"")
                    .font(.system(size: 15, weight: .medium))
                    .lineSpacing(3)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(4)
            }

            if let rating = moment.rating {
                HStack(spacing: 8) {
                    RatingStarsView(rating: rating, tint: tint)

                    if let review = moment.review {
                        Text(review)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.62))
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct TeaMomentEditSheet: View {
    let moment: TeaMoment
    let tint: Color
    let onSave: (String?, String?, Int?, String?, String?) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: String?
    @State private var note: String
    @State private var rating: Int?
    @State private var review: String
    @State private var photoFilename: String?

    private let moods = ["Peaceful", "Focused", "Cozy", "Tired", "Grateful", "Reflective"]

    init(moment: TeaMoment, tint: Color, onSave: @escaping (String?, String?, Int?, String?, String?) -> Void) {
        self.moment = moment
        self.tint = tint
        self.onSave = onSave
        _selectedMood = State(initialValue: moment.mood)
        _note = State(initialValue: moment.note ?? "")
        _rating = State(initialValue: moment.rating)
        _review = State(initialValue: moment.review ?? "")
        _photoFilename = State(initialValue: moment.photoFilename)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.editMoment, languageRaw: languageRaw))
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedText(.editMomentSubtitle, languageRaw: languageRaw))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.64))
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(moment.teaName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(tint)

                            Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.72))

                            Text("\(moment.infusionTimeUsed.formattedTime) \(localizedText(.infusion, languageRaw: languageRaw)) · \(localizedText(.suggested, languageRaw: languageRaw)) \(moment.suggestedInfusionTime.formattedTime)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.52))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

                        MoodPicker(moods: moods, selectedMood: $selectedMood, tint: tint)

                        MomentPhotoEditor(photoFilename: $photoFilename, tint: tint)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(localizedText(.thought, languageRaw: languageRaw))
                                .font(.system(size: 13, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.46))

                            TextEditor(text: $note)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 132)
                                .padding(10)
                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                                .overlay(alignment: .topLeading) {
                                    if note.isEmpty {
                                        Text(localizedText(.thoughtPlaceholder, languageRaw: languageRaw))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.34))
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 18)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(localizedText(.review, languageRaw: languageRaw))
                                .font(.system(size: 13, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.46))

                            StarRatingPicker(rating: $rating, tint: tint)

                            TextEditor(text: $review)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 96)
                                .padding(10)
                                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                                .overlay(alignment: .topLeading) {
                                    if review.isEmpty {
                                        Text(localizedText(.reviewPlaceholder, languageRaw: languageRaw))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.34))
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 18)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }

                        Button {
                            let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
                            let cleanReview = review.trimmingCharacters(in: .whitespacesAndNewlines)
                            onSave(selectedMood, cleanNote.isEmpty ? nil : cleanNote, rating, cleanReview.isEmpty ? nil : cleanReview, photoFilename)
                            dismiss()
                        } label: {
                            Label(localizedText(.saveChanges, languageRaw: languageRaw), systemImage: "checkmark")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(PrimaryTeaButtonStyle(tint: tint))
                    }
                    .padding(22)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.close, languageRaw: languageRaw)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct TeaMomentReviewSheet: View {
    let moment: TeaMoment
    let tint: Color
    let onSave: (Int?, String?, String?) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int?
    @State private var review: String
    @State private var photoFilename: String?

    init(moment: TeaMoment, tint: Color, onSave: @escaping (Int?, String?, String?) -> Void) {
        self.moment = moment
        self.tint = tint
        self.onSave = onSave
        _rating = State(initialValue: moment.rating)
        _review = State(initialValue: moment.review ?? "")
        _photoFilename = State(initialValue: moment.photoFilename)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localizedText(.rateThisTea, languageRaw: languageRaw))
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundStyle(.white)

                        Text(localizedText(.reviewSubtitle, languageRaw: languageRaw))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.64))
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(moment.teaName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(tint)

                        Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.62))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 10) {
                        Text(localizedText(.rating, languageRaw: languageRaw))
                            .font(.system(size: 13, weight: .bold))
                            .textCase(.uppercase)
                            .foregroundStyle(.white.opacity(0.46))

                        StarRatingPicker(rating: $rating, tint: tint)
                    }

                    MomentPhotoEditor(photoFilename: $photoFilename, tint: tint)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(localizedText(.review, languageRaw: languageRaw))
                            .font(.system(size: 13, weight: .bold))
                            .textCase(.uppercase)
                            .foregroundStyle(.white.opacity(0.46))

                        TextEditor(text: $review)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 126)
                            .padding(10)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                            .overlay(alignment: .topLeading) {
                                if review.isEmpty {
                                    Text(localizedText(.reviewPlaceholder, languageRaw: languageRaw))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.34))
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 18)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    Button {
                        let cleanReview = review.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(rating, cleanReview.isEmpty ? nil : cleanReview, photoFilename)
                        dismiss()
                    } label: {
                        Label(localizedText(.saveReview, languageRaw: languageRaw), systemImage: "star.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(PrimaryTeaButtonStyle(tint: tint))

                    Spacer()
                }
                .padding(22)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.close, languageRaw: languageRaw)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct MomentPhotoEditor: View {
    @Binding var photoFilename: String?
    let tint: Color
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCamera = false

    private var hasCamera: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localizedText(.addPhoto, languageRaw: languageRaw))
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.46))

            HStack(spacing: 12) {
                TeaMomentThumbnail(filename: photoFilename, fallbackIcon: "camera", tint: tint, size: 58)

                VStack(alignment: .leading, spacing: 8) {
                    Text(photoFilename == nil ? localizedText(.addPhotoShort, languageRaw: languageRaw) : localizedText(.photoAttached, languageRaw: languageRaw))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 8) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(localizedText(.chooseFromLibrary, languageRaw: languageRaw), systemImage: "photo")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.08), in: Capsule())
                        }
                        .buttonStyle(.plain)

                        Button {
                            isShowingCamera = true
                        } label: {
                            Label(localizedText(.takePhoto, languageRaw: languageRaw), systemImage: "camera")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.08), in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .disabled(!hasCamera)
                        .opacity(hasCamera ? 1 : 0.45)

                        if photoFilename != nil {
                            Button {
                                photoFilename = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.68))
                                    .frame(width: 30, height: 30)
                                    .background(.white.opacity(0.08), in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(localizedText(.removePhoto, languageRaw: languageRaw))
                        }
                    }
                    .foregroundStyle(.white.opacity(0.78))
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data),
                      let filename = saveTeaMomentPhoto(image) else {
                    return
                }

                await MainActor.run {
                    replacePhoto(with: filename)
                    selectedPhotoItem = nil
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraPhotoPicker { image in
                if let filename = saveTeaMomentPhoto(image) {
                    replacePhoto(with: filename)
                }
                isShowingCamera = false
            }
            .ignoresSafeArea()
        }
    }

    private func replacePhoto(with filename: String) {
        photoFilename = filename
    }
}

private struct TeaMomentThumbnail: View {
    let filename: String?
    let fallbackIcon: String
    let tint: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            if let image = teaMomentPhotoImage(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(tint.opacity(0.12))

                Image(systemName: fallbackIcon)
                    .font(.system(size: max(16, size * 0.46), weight: .semibold))
                    .foregroundStyle(tint)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct CameraPhotoPicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        let dismiss: DismissAction

        init(onImagePicked: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImagePicked = onImagePicked
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImagePicked(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

private struct MoodPicker: View {
    let moods: [String]
    @Binding var selectedMood: String?
    let tint: Color
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localizedText(.mood, languageRaw: languageRaw))
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.46))

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(moods, id: \.self) { mood in
                    Button {
                        selectedMood = selectedMood == mood ? nil : mood
                    } label: {
                        Text(localizedMood(mood, languageRaw: languageRaw))
                            .font(.system(size: 14, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .foregroundStyle(selectedMood == mood ? .black.opacity(0.82) : .white.opacity(0.74))
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(selectedMood == mood ? tint : .white.opacity(0.07), in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedMood == mood ? .white.opacity(0.18) : .white.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct StarRatingPicker: View {
    @Binding var rating: Int?
    let tint: Color
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating = rating == star ? nil : star
                } label: {
                    Image(systemName: (rating ?? 0) >= star ? "star.fill" : "star")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle((rating ?? 0) >= star ? tint : .white.opacity(0.28))
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityLabel(localizedText(.teaRating, languageRaw: languageRaw))
    }
}

private struct RatingStarsView: View {
    let rating: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: rating >= star ? "star.fill" : "star")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(rating >= star ? tint : .white.opacity(0.28))
            }
        }
    }
}

private struct TeaStatsView: View {
    let moments: [TeaMoment]
    let tint: Color
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @State private var isShowingCalendar = false

    private var lastSevenDaysCount: Int {
        guard let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        return moments.filter { $0.date >= start }.count
    }

    private var averageRatingText: String {
        let ratings = moments.compactMap(\.rating)
        guard !ratings.isEmpty else { return localizedText(.noRatings, languageRaw: languageRaw) }
        let average = Double(ratings.reduce(0, +)) / Double(ratings.count)
        return String(format: "%.1f/5", average)
    }

    private var mostCommonCategory: String {
        mostCommonValue(moments.map { localizedTeaCategoryLabel($0.teaCategory, languageRaw: languageRaw) }) ?? localizedText(.notYet, languageRaw: languageRaw)
    }

    private var mostCommonTea: String {
        mostCommonValue(moments.map(\.teaName)) ?? localizedText(.notYet, languageRaw: languageRaw)
    }

    private var mostCommonMood: String {
        mostCommonValue(moments.compactMap { moment in
            guard let mood = moment.mood else { return nil }
            return localizedMood(mood, languageRaw: languageRaw)
        }) ?? localizedText(.notYet, languageRaw: languageRaw)
    }

    private var caffeineBreakdown: String {
        let groups = Dictionary(grouping: moments, by: \.caffeineLevel)
        guard !groups.isEmpty else { return localizedText(.noData, languageRaw: languageRaw) }
        return groups
            .map { "\(localizedCaffeineLevel($0.key, languageRaw: languageRaw)): \($0.value.count)" }
            .sorted()
            .joined(separator: " · ")
    }

    private var badges: [(String, String, String, Bool)] {
        [
            (localizedText(.greenRitual, languageRaw: languageRaw), localizedText(.greenRitualDetail, languageRaw: languageRaw), "leaf.fill", greenRitualUnlocked),
            (localizedText(.loyalSipper, languageRaw: languageRaw), localizedText(.loyalSipperDetail, languageRaw: languageRaw), "heart.fill", loyalSipperUnlocked),
            (localizedText(.teaExplorer, languageRaw: languageRaw), localizedText(.teaExplorerDetail, languageRaw: languageRaw), "sparkles", teaExplorerUnlocked),
            (localizedText(.fiveStarFavorite, languageRaw: languageRaw), localizedText(.fiveStarFavoriteDetail, languageRaw: languageRaw), "star.fill", fiveStarFavoriteUnlocked)
        ]
    }

    private var greenRitualUnlocked: Bool {
        guard let start = Calendar.current.date(byAdding: .day, value: -10, to: Date()) else { return false }
        return moments.filter { $0.date >= start && $0.teaCategory == "Fresh" }.count >= 5
    }

    private var loyalSipperUnlocked: Bool {
        let keys = moments.map { $0.productId ?? $0.teaName }
        return Dictionary(grouping: keys, by: { $0 }).values.contains { $0.count >= 3 }
    }

    private var teaExplorerUnlocked: Bool {
        Set(moments.map { $0.productId ?? $0.teaName }).count >= 5
    }

    private var fiveStarFavoriteUnlocked: Bool {
        moments.contains { $0.rating == 5 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                StatTile(title: localizedText(.totalMoments, languageRaw: languageRaw), value: "\(moments.count)", iconName: "book.closed", tint: tint)
                Button {
                    isShowingCalendar = true
                } label: {
                    StatTile(title: localizedText(.last7Days, languageRaw: languageRaw), value: "\(lastSevenDaysCount)", iconName: "calendar", tint: tint)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(localizedText(.openTeaCalendar, languageRaw: languageRaw))
                StatTile(title: localizedText(.topType, languageRaw: languageRaw), value: mostCommonCategory, iconName: "leaf", tint: tint)
                StatTile(title: localizedText(.avgRating, languageRaw: languageRaw), value: averageRatingText, iconName: "star", tint: tint)
            }

            VStack(alignment: .leading, spacing: 8) {
                DetailRow(title: localizedText(.mostConsumedTea, languageRaw: languageRaw), value: mostCommonTea, tint: tint)
                DetailRow(title: localizedText(.mostCommonMood, languageRaw: languageRaw), value: mostCommonMood, tint: tint)
                DetailRow(title: localizedText(.caffeine, languageRaw: languageRaw), value: caffeineBreakdown, tint: tint)
            }
            .padding(16)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))

            Text(localizedText(.badges, languageRaw: languageRaw))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            ForEach(badges, id: \.0) { badge in
                BadgeCard(title: badge.0, detail: badge.1, iconName: badge.2, isUnlocked: badge.3, tint: tint)
            }
        }
        .sheet(isPresented: $isShowingCalendar) {
            TeaStatsCalendarSheet(moments: moments, tint: tint)
        }
    }

    private func mostCommonValue(_ values: [String]) -> String? {
        Dictionary(grouping: values, by: { $0 })
            .max { $0.value.count < $1.value.count }?
            .key
    }
}

private enum TeaCalendarMode: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"

    var id: String { rawValue }

    func localizedTitle(languageRaw: String) -> String {
        switch self {
        case .week:
            return localizedText(.week, languageRaw: languageRaw)
        case .month:
            return localizedText(.month, languageRaw: languageRaw)
        }
    }
}

private struct TeaStatsCalendarSheet: View {
    let moments: [TeaMoment]
    let tint: Color
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    @State private var mode: TeaCalendarMode = .week
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    private var visibleDays: [Date] {
        switch mode {
        case .week:
            let interval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)
            let start = interval?.start ?? selectedDate
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        case .month:
            guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
                  let daysRange = calendar.range(of: .day, in: .month, for: selectedDate) else {
                return []
            }
            let leadingBlankCount = calendar.component(.weekday, from: monthInterval.start) - calendar.firstWeekday
            let normalizedLeadingBlankCount = (leadingBlankCount + 7) % 7
            let blanks = (0..<normalizedLeadingBlankCount).compactMap { offset in
                calendar.date(byAdding: .day, value: offset - normalizedLeadingBlankCount, to: monthInterval.start)
            }
            let monthDays = daysRange.compactMap { day -> Date? in
                var components = calendar.dateComponents([.year, .month], from: selectedDate)
                components.day = day
                return calendar.date(from: components)
            }
            return blanks + monthDays
        }
    }

    private var selectedDayMoments: [TeaMoment] {
        moments
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }
    }

    private var titleText: String {
        selectedDate.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.025, green: 0.035, blue: 0.030),
                        Color(red: 0.005, green: 0.008, blue: 0.006)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(localizedText(.teaCalendar, languageRaw: languageRaw))
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundStyle(.white)

                            Text(localizedText(.teaCalendarSubtitle, languageRaw: languageRaw))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.64))
                        }

                        Picker(localizedText(.calendarView, languageRaw: languageRaw), selection: $mode) {
                            ForEach(TeaCalendarMode.allCases) { mode in
                                Text(mode.localizedTitle(languageRaw: languageRaw)).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        calendarHeader
                        calendarGrid
                        selectedDayDetails
                    }
                    .padding(22)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localizedText(.close, languageRaw: languageRaw)) {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.72))
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
    }

    private var calendarHeader: some View {
        HStack {
            Button {
                moveCalendar(by: mode == .week ? -7 : -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(titleText)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                moveCalendar(by: mode == .week ? 7 : 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.07), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white.opacity(0.78))
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.42))
                    .frame(maxWidth: .infinity)
            }

            ForEach(visibleDays, id: \.self) { day in
                CalendarDayButton(
                    date: day,
                    isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                    isCurrentMonth: calendar.isDate(day, equalTo: selectedDate, toGranularity: .month),
                    momentCount: moments.filter { calendar.isDate($0.date, inSameDayAs: day) }.count,
                    tint: tint
                ) {
                    selectedDate = day
                }
            }
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var selectedDayDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)

            if selectedDayMoments.isEmpty {
                Text(localizedText(.noMomentsOnDay, languageRaw: languageRaw))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
            } else {
                ForEach(selectedDayMoments) { moment in
                    CalendarMomentCard(moment: moment, tint: tint)
                }
            }
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        return Array(symbols[firstIndex...] + symbols[..<firstIndex])
    }

    private func moveCalendar(by value: Int) {
        let component: Calendar.Component = mode == .week ? .day : .month
        if let date = calendar.date(byAdding: component, value: value, to: selectedDate) {
            selectedDate = date
        }
    }
}

private struct CalendarDayButton: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let momentCount: Int
    let tint: Color
    let onTap: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? .black.opacity(0.82) : .white.opacity(isCurrentMonth ? 0.82 : 0.28))

                Circle()
                    .fill(momentCount > 0 ? (isSelected ? .black.opacity(0.68) : tint) : .clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? tint : .white.opacity(momentCount > 0 ? 0.07 : 0.03), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted)), \(momentCount) \(localizedText(.teaMoments, languageRaw: languageRaw))")
    }
}

private struct CalendarMomentCard: View {
    let moment: TeaMoment
    let tint: Color
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            TeaMomentThumbnail(filename: moment.photoFilename, fallbackIcon: "cup.and.saucer", tint: tint, size: 44)

            VStack(alignment: .leading, spacing: 5) {
                Text(moment.teaName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)

                Text("\(localizedTeaCategoryLabel(moment.teaCategory, languageRaw: languageRaw)) · \(moment.date.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.54))

                if let rating = moment.rating, rating > 0 {
                    RatingStarsView(rating: rating, tint: tint)
                }

                if let note = moment.note?.trimmingCharacters(in: .whitespacesAndNewlines), !note.isEmpty {
                    Text(note)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(2)
                } else if let review = moment.review?.trimmingCharacters(in: .whitespacesAndNewlines), !review.isEmpty {
                    Text(review)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(2)
                }

                if let mood = moment.mood {
                    Text(localizedMood(mood, languageRaw: languageRaw))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tint)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private enum ReviewSortOrder: String, CaseIterable, Identifiable {
    case newest = "Newest First"
    case oldest = "Oldest First"
    case highest = "Highest Rating"
    case lowest = "Lowest Rating"

    var id: String { rawValue }

    func localizedTitle(languageRaw: String) -> String {
        switch self {
        case .newest:
            return localizedText(.newestFirst, languageRaw: languageRaw)
        case .oldest:
            return localizedText(.oldestFirst, languageRaw: languageRaw)
        case .highest:
            return localizedText(.highestToLowest, languageRaw: languageRaw)
        case .lowest:
            return localizedText(.lowestToHighest, languageRaw: languageRaw)
        }
    }
}

private struct TeaReviewsView: View {
    let moments: [TeaMoment]
    let tint: Color
    let onReview: (TeaMoment) -> Void
    let onEditReview: (TeaMoment) -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue
    @State private var sortOrder: ReviewSortOrder = .newest

    private var pendingMoments: [TeaMoment] {
        let reviewedIdentities = Set(reviewedMoments.map { teaReviewIdentity(for: $0) })
        return newestUniqueMoments(
            from: moments.filter { moment in
                !reviewedIdentities.contains(teaReviewIdentity(for: moment)) &&
                !isTeaMomentReviewed(moment)
            }
        )
    }

    private var reviewedMoments: [TeaMoment] {
        let uniqueMoments = newestUniqueMoments(from: moments.filter(isTeaMomentReviewed))
        switch sortOrder {
        case .newest:
            return uniqueMoments.sorted { $0.date > $1.date }
        case .oldest:
            return uniqueMoments.sorted { $0.date < $1.date }
        case .highest:
            return uniqueMoments.sorted {
                let leftRating = $0.rating ?? 0
                let rightRating = $1.rating ?? 0
                return leftRating == rightRating ? $0.date > $1.date : leftRating > rightRating
            }
        case .lowest:
            return uniqueMoments.sorted {
                let leftRating = $0.rating ?? 0
                let rightRating = $1.rating ?? 0
                return leftRating == rightRating ? $0.date > $1.date : leftRating < rightRating
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if moments.isEmpty {
                ReviewEmptyState(
                    iconName: "star",
                    title: localizedText(.noTeaReviewsYet, languageRaw: languageRaw),
                    detail: localizedText(.completeTimerFirst, languageRaw: languageRaw),
                    tint: tint
                )
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ReviewSectionHeader(
                        title: localizedText(.teaMomentsToReview, languageRaw: languageRaw),
                        count: pendingMoments.count,
                        tint: tint
                    )

                    if pendingMoments.isEmpty {
                        ReviewInlineEmptyState(text: localizedText(.noPendingReviews, languageRaw: languageRaw))
                    } else {
                        ForEach(pendingMoments) { moment in
                            PendingReviewCard(moment: moment, tint: tint) {
                                onReview(moment)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    ReviewSectionHeader(
                        title: localizedText(.reviewedTeas, languageRaw: languageRaw),
                        count: reviewedMoments.count,
                        tint: tint
                    )

                    Picker(localizedText(.reviewSortOrder, languageRaw: languageRaw), selection: $sortOrder) {
                        ForEach(ReviewSortOrder.allCases) { order in
                            Text(order.localizedTitle(languageRaw: languageRaw)).tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(tint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    )

                    if reviewedMoments.isEmpty {
                        ReviewEmptyState(
                            iconName: "star.leadinghalf.filled",
                            title: localizedText(.noReviewsYet, languageRaw: languageRaw),
                            detail: localizedText(.noReviewsDetail, languageRaw: languageRaw),
                            tint: tint
                        )
                    } else {
                        ForEach(reviewedMoments) { moment in
                            ReviewedTeaCard(moment: moment, tint: tint) {
                                onEditReview(moment)
                            }
                        }
                    }
                }
            }
        }
    }

    private func newestUniqueMoments(from sourceMoments: [TeaMoment]) -> [TeaMoment] {
        let sortedMoments = sourceMoments.sorted { $0.date > $1.date }
        var seenIdentities = Set<String>()
        var uniqueMoments: [TeaMoment] = []

        for moment in sortedMoments {
            let identity = teaReviewIdentity(for: moment)
            guard !seenIdentities.contains(identity) else { continue }
            seenIdentities.insert(identity)
            uniqueMoments.append(moment)
        }

        return uniqueMoments
    }
}

private struct ReviewSectionHeader: View {
    let title: String
    let count: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)

            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.black.opacity(0.78))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tint, in: Capsule())

            Spacer()
        }
    }
}

private struct PendingReviewCard: View {
    let moment: TeaMoment
    let tint: Color
    let onReview: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        Button {
            onReview()
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    TeaMomentThumbnail(filename: moment.photoFilename, fallbackIcon: "star.bubble", tint: tint, size: 46)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(moment.teaName) \(localizedText(.review, languageRaw: languageRaw))")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)

                        if let producer = moment.producer, !producer.isEmpty {
                            Text(producer)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(tint.opacity(0.82))
                        }

                        Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.52))
                    }

                    Spacer()
                }

                Text("\(localizedText(.infusionLabel, languageRaw: languageRaw)): \(moment.infusionTimeUsed.formattedTime) · \(moment.waterTemperature)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.76))

                Text(localizedText(.notReviewedYet, languageRaw: languageRaw))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))

                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13, weight: .semibold))

                    Text(localizedText(.reviewTea, languageRaw: languageRaw))
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.black.opacity(0.82))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(tint, in: RoundedRectangle(cornerRadius: 8))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [.white.opacity(0.085), tint.opacity(0.045)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(tint.opacity(0.20), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(localizedText(.review, languageRaw: languageRaw)) \(moment.teaName)")
    }
}

private func reviewShareText(for moment: TeaMoment, languageRaw: String) -> String {
    let language = TeaTimerLanguage(rawValue: languageRaw) ?? .english
    var parts: [String] = []
    let producer = moment.producer?.trimmingCharacters(in: .whitespacesAndNewlines)
    let teaTitle = [producer, moment.teaName]
        .compactMap { value -> String? in
            guard let value, !value.isEmpty else { return nil }
            return value
        }
        .joined(separator: " ")

    var firstLine: String
    switch language {
    case .english:
        firstLine = "I tried \(teaTitle) with TeaTimer."
    case .italian:
        firstLine = "Ho provato \(teaTitle) con TeaTimer."
    case .french:
        firstLine = "J'ai essayé \(teaTitle) avec TeaTimer."
    case .spanish:
        firstLine = "Probé \(teaTitle) con TeaTimer."
    }
    if let rating = moment.rating, rating > 0 {
        firstLine += " \(localizedText(.rating, language: language)): \(rating)/5."
    }
    firstLine += " \(localizedText(.timer, language: language)): \(moment.infusionTimeUsed.shareTimeText)."
    parts.append(firstLine)

    if let review = moment.review?.trimmingCharacters(in: .whitespacesAndNewlines), !review.isEmpty {
        parts.append("\(localizedText(.review, language: language)): \(review)")
    }

    if let note = moment.note?.trimmingCharacters(in: .whitespacesAndNewlines), !note.isEmpty {
        parts.append("\(localizedText(.note, language: language)): \(note)")
    }

    return parts.joined(separator: "\n")
}

private struct ReviewedTeaCard: View {
    let moment: TeaMoment
    let tint: Color
    let onEdit: () -> Void
    @AppStorage("teaTimerLanguage") private var languageRaw = TeaTimerLanguage.english.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                TeaMomentThumbnail(filename: moment.photoFilename, fallbackIcon: "star", tint: tint, size: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(moment.teaName) \(localizedText(.review, languageRaw: languageRaw))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    if let producer = moment.producer, !producer.isEmpty {
                        Text(producer)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(tint.opacity(0.78))
                    }

                    Text(moment.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.50))
                }

                Spacer()

                if let rating = moment.rating, rating > 0 {
                    RatingStarsView(rating: rating, tint: tint)
                }
            }

            Text("\(moment.infusionTimeUsed.formattedTime) \(localizedText(.infusion, languageRaw: languageRaw)) · \(moment.waterTemperature)")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.50))

            if let review = moment.review?.trimmingCharacters(in: .whitespacesAndNewlines), !review.isEmpty {
                Text(review)
                    .font(.system(size: 15, weight: .medium))
                    .lineSpacing(3)
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(4)
            }

            HStack(spacing: 8) {
                Button {
                    onEdit()
                } label: {
                    Label(localizedText(.edit, languageRaw: languageRaw), systemImage: "pencil")
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                ShareLink(item: reviewShareText(for: moment, languageRaw: languageRaw)) {
                    Label(localizedText(.share, languageRaw: languageRaw), systemImage: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(.white.opacity(0.78))
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityLabel("\(localizedText(.edit, languageRaw: languageRaw)) \(moment.teaName) \(localizedText(.review, languageRaw: languageRaw))")
    }
}

private struct ReviewEmptyState: View {
    let iconName: String
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(tint)

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(detail)
                .font(.system(size: 15, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.58))
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ReviewInlineEmptyState: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white.opacity(0.58))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
    }
}

private struct StatTile: View {
    let title: String
    let value: String
    let iconName: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)

            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.52))

            Text(value)
                .font(.system(size: 21, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        )
    }
}

private struct DetailRow: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.56))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(tint)
        }
    }
}

private struct BadgeCard: View {
    let title: String
    let detail: String
    let iconName: String
    let isUnlocked: Bool
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(isUnlocked ? tint : .white.opacity(0.28))
                .frame(width: 40, height: 40)
                .background((isUnlocked ? tint.opacity(0.14) : .white.opacity(0.05)), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.46))

                Text(detail)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.48))
            }

            Spacer()
        }
        .padding(14)
        .background(.white.opacity(isUnlocked ? 0.07 : 0.035), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isUnlocked ? tint.opacity(0.18) : .white.opacity(0.07), lineWidth: 1)
        )
    }
}

private struct PremiumTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.46))

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .textInputAutocapitalization(.words)
                .padding(14)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        }
    }
}

private struct PremiumBackground: View {
    let tea: TeaProfile

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                teaBackgroundImage
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()

                LinearGradient(
                    colors: [
                        .black.opacity(0.48),
                        .black.opacity(0.38),
                        .black.opacity(0.76)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                LinearGradient(
                    colors: [
                        Color(red: 0.02, green: 0.025, blue: 0.025).opacity(0.62),
                        .black.opacity(0.12),
                        Color(red: 0.015, green: 0.015, blue: 0.018).opacity(0.80)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                RadialGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.68)
                    ],
                    center: .center,
                    startRadius: 120,
                    endRadius: 520
                )

                tea.tint.opacity(0.22)
                    .blur(radius: 95)
                    .frame(width: 320, height: 320)
                    .offset(x: 120, y: -180)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.32), value: tea.id)
    }

    @ViewBuilder
    private var teaBackgroundImage: some View {
        if let url = Bundle.main.url(forResource: tea.imageName, withExtension: "png"),
           let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.10)
                .blur(radius: 2.5)
                .saturation(0.88)
                .contrast(0.96)
                .opacity(0.92)
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.05, blue: 0.05),
                    Color(red: 0.08, green: 0.09, blue: 0.08),
                    Color(red: 0.02, green: 0.02, blue: 0.025)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

private struct TeaStat: View {
    let title: String
    let value: String
    let iconName: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(tint)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Text(value)
                .font(.system(size: 25, weight: .bold))
                .minimumScaleFactor(0.72)
                .lineLimit(1)
                .foregroundStyle(title == "Water" ? tint : (title == "Caffeine" ? tint : .white))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.black.opacity(0.30), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
    }
}

private struct PrimaryTeaButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.82), tint.opacity(0.56)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(configuration.isPressed ? 0.72 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
    }
}

private struct AdjustTimerButtonStyle: ButtonStyle {
    let tint: Color
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isDisabled ? .white.opacity(0.34) : tint)
            .background(
                Circle()
                    .fill(.white.opacity(configuration.isPressed ? 0.16 : 0.08))
            )
            .overlay(
                Circle()
                    .stroke(isDisabled ? .white.opacity(0.08) : tint.opacity(0.22), lineWidth: 1)
            )
    }
}

private struct SecondaryTeaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(configuration.isPressed ? 0.16 : 0.09))
            )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}
