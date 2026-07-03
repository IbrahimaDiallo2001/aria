// ============================================================
//  Aria — Internationalisation (i18n) + dates localisées.
// ============================================================

// ── Multilingue (i18n simple) ────────────────────────────────
String gLang = 'fr';

String tr(String fr) {
  if (gLang == 'fr') return fr;
  return kI18n[fr]?[gLang] ?? fr;
}

const kLangs = [
  {'code': 'fr', 'nom': 'Français', 'flag': '🇫🇷'},
  {'code': 'en', 'nom': 'English', 'flag': '🇬🇧'},
  {'code': 'es', 'nom': 'Español', 'flag': '🇪🇸'},
  {'code': 'ar', 'nom': 'العربية', 'flag': '🇸🇦'},
  {'code': 'wo', 'nom': 'Wolof', 'flag': '🇸🇳'},
];

const Map<String, Map<String, String>> kI18n = {
  'Bonjour': {'en': 'Hello', 'es': 'Hola', 'ar': 'صباح الخير', 'wo': 'Naka suba'},
  'Bon après-midi': {'en': 'Good afternoon', 'es': 'Buenas tardes', 'ar': 'مساء الخير', 'wo': 'Naka bëccëg'},
  'Bonsoir': {'en': 'Good evening', 'es': 'Buenas noches', 'ar': 'مساء الخير', 'wo': 'Naka ngoon'},
  'Ta journée': {'en': 'Your day', 'es': 'Tu día', 'ar': 'يومك', 'wo': 'Sa bés'},
  'Ton chemin': {'en': 'Your path', 'es': 'Tu camino', 'ar': 'مسارك', 'wo': 'Sa yoon'},
  'Tes progrès': {'en': 'Your progress', 'es': 'Tu progreso', 'ar': 'تقدّمك', 'wo': 'Sa yokkute'},
  'Ton espace': {'en': 'Your space', 'es': 'Tu espacio', 'ar': 'مساحتك', 'wo': 'Sa bérab'},
  'Journal du soir': {'en': 'Evening journal', 'es': 'Diario nocturno', 'ar': 'يوميات المساء', 'wo': 'Téere ngoon'},
  'Ton équilibre du jour': {'en': 'Your balance today', 'es': 'Tu equilibrio de hoy', 'ar': 'توازنك اليوم', 'wo': 'Sa yemoo bés bi'},
  'équilibre': {'en': 'balance', 'es': 'equilibrio', 'ar': 'توازن', 'wo': 'yemoo'},
  'pratiques': {'en': 'practices', 'es': 'prácticas', 'ar': 'ممارسات', 'wo': 'jëf'},
  'TES PILIERS': {'en': 'YOUR PILLARS', 'es': 'TUS PILARES', 'ar': 'ركائزك', 'wo': 'SA CËSLAAY YI'},
  '« Le progrès, pas la perfection. Chaque petit pas compte. »': {
    'en': '"Progress, not perfection. Every small step counts."',
    'es': '«Progreso, no perfección. Cada pequeño paso cuenta.»',
    'ar': '«التقدّم لا الكمال. كل خطوة صغيرة تُحتسب.»',
    'wo': '« Jëm kanam, du mat. Jéego bu ndaw bu nekk am na solo. »'
  },
  '— Ton intention du jour': {'en': '— Your intention today', 'es': '— Tu intención de hoy', 'ar': '— نيّتك لهذا اليوم', 'wo': '— Sa yéene bés bi'},
  // Écran de bienvenue
  'Commencer': {'en': 'Begin', 'es': 'Comenzar', 'ar': 'ابدأ', 'wo': 'Tàmbali'},
  "Ton chemin vers l'équilibre": {'en': 'Your path to balance', 'es': 'Tu camino hacia el equilibrio', 'ar': 'طريقك إلى التوازن', 'wo': 'Sa yoon jëm ci yemoo'},
  '« Deviens qui tu es, un jour à la fois. »': {
    'en': '"Become who you are, one day at a time."',
    'es': '«Conviértete en quien eres, un día a la vez.»',
    'ar': '«كن من أنت، يوماً بعد يوم.»',
    'wo': '« Doon ki nga di, bés bu nekk. »'
  },
  '« La discipline est le pont entre les rêves et la réalité. »': {
    'en': '"Discipline is the bridge between dreams and reality."',
    'es': '«La disciplina es el puente entre los sueños y la realidad.»',
    'ar': '«الانضباط جسر بين الأحلام والواقع.»',
    'wo': '« Takkute mooy pon bi diggante gént ak dëgg. »'
  },
  '« Chaque matin est une nouvelle page de ton histoire. »': {
    'en': '"Every morning is a new page of your story."',
    'es': '«Cada mañana es una nueva página de tu historia.»',
    'ar': '«كل صباح صفحة جديدة من قصتك.»',
    'wo': '« Suba su nekk ab xët bu bees ci sa taariix. »'
  },
  "« Un petit pas aujourd'hui, un grand chemin demain. »": {
    'en': '"A small step today, a long way tomorrow."',
    'es': '«Un pequeño paso hoy, un gran camino mañana.»',
    'ar': '«خطوة صغيرة اليوم، طريق طويل غداً.»',
    'wo': '« Jéego bu ndaw tey, yoon wu réy suba. »'
  },
  'Accueil': {'en': 'Home', 'es': 'Inicio', 'ar': 'الرئيسية', 'wo': 'Kër'},
  'Journal': {'en': 'Journal', 'es': 'Diario', 'ar': 'اليوميات', 'wo': 'Téere'},
  'Progrès': {'en': 'Progress', 'es': 'Progreso', 'ar': 'التقدّم', 'wo': 'Yokkute'},
  "📝 Qu'as-tu appris aujourd'hui ?": {'en': '📝 What did you learn today?', 'es': '📝 ¿Qué aprendiste hoy?', 'ar': '📝 ماذا تعلّمت اليوم؟', 'wo': '📝 Lan nga jàng tey ?'},
  'Écris librement…': {'en': 'Write freely…', 'es': 'Escribe libremente…', 'ar': 'اكتب بحرية…', 'wo': 'Bind bu yaatu…'},
  '🙏 3 gratitudes du jour': {'en': '🙏 3 gratitudes today', 'es': '🙏 3 gratitudes del día', 'ar': '🙏 ثلاث امتنانات اليوم', 'wo': '🙏 3 cant ci bés bi'},
  'Entrée enregistrée ✓': {'en': 'Entry saved ✓', 'es': 'Entrada guardada ✓', 'ar': 'تم حفظ المدخلة ✓', 'wo': 'Denc na ✓'},
  'ENTRÉES PRÉCÉDENTES': {'en': 'PREVIOUS ENTRIES', 'es': 'ENTRADAS ANTERIORES', 'ar': 'مدخلات سابقة', 'wo': 'YI JIITU'},
  'Supprimer cette entrée ?': {'en': 'Delete this entry?', 'es': '¿Eliminar esta entrada?', 'ar': 'حذف هذه المدخلة؟', 'wo': 'Far bind bii ?'},
  'Retour': {'en': 'Back', 'es': 'Atrás', 'ar': 'رجوع', 'wo': 'Dellu'},
  'Corps': {'en': 'Body', 'es': 'Cuerpo', 'ar': 'الجسد', 'wo': 'Yaram'},
  'Esprit': {'en': 'Mind', 'es': 'Mente', 'ar': 'العقل', 'wo': 'Xel'},
  'Habitudes': {'en': 'Habits', 'es': 'Hábitos', 'ar': 'العادات', 'wo': 'Aada'},
  'Âme': {'en': 'Soul', 'es': 'Alma', 'ar': 'الروح', 'wo': 'Ruu'},
  'Futur': {'en': 'Future', 'es': 'Futuro', 'ar': 'المستقبل', 'wo': 'Ëllëg'},
  "Boire 8 verres d'eau": {'en': 'Drink 8 glasses of water', 'es': 'Beber 8 vasos de agua', 'ar': 'اشرب 8 أكواب ماء', 'wo': 'Naan 8 kaas ndox'},
  'Hydratation du jour': {'en': 'Daily hydration', 'es': 'Hidratación del día', 'ar': 'ترطيب اليوم', 'wo': 'Naan ndox bu doy'},
  'Séance de sport': {'en': 'Workout', 'es': 'Sesión de ejercicio', 'ar': 'حصة رياضة', 'wo': 'Yëngu-yëngu'},
  '30 minutes': {'en': '30 minutes', 'es': '30 minutos', 'ar': '30 دقيقة', 'wo': '30 simili'},
  'Manger sainement': {'en': 'Eat healthy', 'es': 'Comer sano', 'ar': 'تناول طعاماً صحياً', 'wo': 'Lekk lu baax'},
  'Légumes à chaque repas': {'en': 'Vegetables at every meal', 'es': 'Verduras en cada comida', 'ar': 'خضروات مع كل وجبة', 'wo': 'Legim ci ñam bu nekk'},
  'Bien dormir': {'en': 'Sleep well', 'es': 'Dormir bien', 'ar': 'نَم جيداً', 'wo': 'Nelaw bu baax'},
  'Coucher avant 23h': {'en': 'Bed before 11pm', 'es': 'Acostarse antes de las 23h', 'ar': 'النوم قبل الـ11 مساءً', 'wo': 'Tëdd balaa 23h'},
  'Méditer': {'en': 'Meditate', 'es': 'Meditar', 'ar': 'تأمّل', 'wo': 'Xalaat'},
  '10 minutes': {'en': '10 minutes', 'es': '10 minutos', 'ar': '10 دقائق', 'wo': '10 simili'},
  'Tenir son journal': {'en': 'Keep a journal', 'es': 'Llevar un diario', 'ar': 'كتابة اليوميات', 'wo': 'Bind sa téere'},
  'Le soir': {'en': 'In the evening', 'es': 'Por la noche', 'ar': 'في المساء', 'wo': 'Ci ngoon'},
  'Lire': {'en': 'Read', 'es': 'Leer', 'ar': 'اقرأ', 'wo': 'Jàng'},
  '20 pages': {'en': '20 pages', 'es': '20 páginas', 'ar': '20 صفحة', 'wo': '20 xët'},
  'Gratitude': {'en': 'Gratitude', 'es': 'Gratitud', 'ar': 'امتنان', 'wo': 'Cant'},
  '3 choses positives': {'en': '3 positive things', 'es': '3 cosas positivas', 'ar': '3 أشياء إيجابية', 'wo': '3 mbir yu baax'},
  'Routine du matin': {'en': 'Morning routine', 'es': 'Rutina matinal', 'ar': 'روتين الصباح', 'wo': 'Aada suba'},
  'Réveil, eau, étirements': {'en': 'Wake up, water, stretching', 'es': 'Despertar, agua, estiramientos', 'ar': 'الاستيقاظ، ماء، تمدّد', 'wo': 'Yeewu, ndox, tàllal'},
  'Planifier sa journée': {'en': 'Plan your day', 'es': 'Planificar el día', 'ar': 'تخطيط اليوم', 'wo': 'Tëral sa bés'},
  '3 priorités': {'en': '3 priorities', 'es': '3 prioridades', 'ar': '3 أولويات', 'wo': '3 mbir yu jëkk'},
  'Suivre ses habitudes': {'en': 'Track your habits', 'es': 'Seguir tus hábitos', 'ar': 'تتبّع عاداتك', 'wo': 'Topp sa aada yi'},
  'Cocher au fil du jour': {'en': 'Check off through the day', 'es': 'Marcar durante el día', 'ar': 'علّم خلال اليوم', 'wo': 'Màrke ci bés bi'},
  'Routine du soir': {'en': 'Evening routine', 'es': 'Rutina nocturna', 'ar': 'روتين المساء', 'wo': 'Aada ngoon'},
  'Déconnexion, lecture': {'en': 'Disconnect, reading', 'es': 'Desconexión, lectura', 'ar': 'انفصال، قراءة', 'wo': 'Tëj telefon, jàng'},
  // Pilier Âme
  'Prière ou intention': {'en': 'Prayer or intention', 'es': 'Oración o intención', 'ar': 'صلاة أو نيّة', 'wo': 'Julli walla yéene'},
  'Un moment de recueillement': {'en': 'A moment of reflection', 'es': 'Un momento de recogimiento', 'ar': 'لحظة تأمّل', 'wo': 'Waxtu bu dal'},
  'Contempler la nature': {'en': 'Contemplate nature', 'es': 'Contemplar la naturaleza', 'ar': 'تأمّل الطبيعة', 'wo': 'Xool mbindeef'},
  'Respirer dehors': {'en': 'Breathe outside', 'es': 'Respirar al aire libre', 'ar': 'تنفّس في الخارج', 'wo': 'Noyyi ci biti'},
  'Acte de bonté': {'en': 'Act of kindness', 'es': 'Acto de bondad', 'ar': 'عمل لطيف', 'wo': 'Jëf ju baax'},
  "Aider quelqu'un": {'en': 'Help someone', 'es': 'Ayudar a alguien', 'ar': 'ساعد أحدهم', 'wo': 'Dimbali kenn'},
  'Se reconnecter': {'en': 'Reconnect', 'es': 'Reconectar', 'ar': 'إعادة الاتصال', 'wo': 'Jokkoo ak sa bopp'},
  'Loin des écrans': {'en': 'Away from screens', 'es': 'Lejos de las pantallas', 'ar': 'بعيداً عن الشاشات', 'wo': 'Sori ekraan yi'},
  // Pilier Futur
  'Visualiser ses objectifs': {'en': 'Visualize your goals', 'es': 'Visualizar tus objetivos', 'ar': 'تصوّر أهدافك', 'wo': 'Gis sa jubluwaay yi'},
  'Où je veux être': {'en': 'Where I want to be', 'es': 'Dónde quiero estar', 'ar': 'أين أريد أن أكون', 'wo': 'Fu ma bëgg a nekk'},
  'Apprendre une compétence': {'en': 'Learn a skill', 'es': 'Aprender una habilidad', 'ar': 'تعلّم مهارة', 'wo': 'Jàng benn xam-xam'},
  '15 minutes': {'en': '15 minutes', 'es': '15 minutos', 'ar': '15 دقيقة', 'wo': '15 simili'},
  'Avancer sur un projet': {'en': 'Progress on a project', 'es': 'Avanzar en un proyecto', 'ar': 'التقدّم في مشروع', 'wo': 'Jëm kanam ci projet'},
  'Une petite étape': {'en': 'One small step', 'es': 'Un pequeño paso', 'ar': 'خطوة صغيرة', 'wo': 'Ab jéego bu ndaw'},
  'Épargner': {'en': 'Save money', 'es': 'Ahorrar', 'ar': 'ادّخر', 'wo': 'Denc xaalis'},
  'Mettre de côté': {'en': 'Set aside', 'es': 'Apartar', 'ar': 'خصّص جانباً', 'wo': 'Teg ci wet'},
  'tout est accompli !': {'en': 'all done!', 'es': '¡todo cumplido!', 'ar': 'تمّ كل شيء!', 'wo': 'lépp jeex na !'},
  'Langue': {'en': 'Language', 'es': 'Idioma', 'ar': 'اللغة', 'wo': 'Làkk'},
  // Personnalisation
  'Ajouter une pratique': {'en': 'Add a practice', 'es': 'Añadir una práctica', 'ar': 'إضافة ممارسة', 'wo': 'Yokk jëf'},
  'Nouvelle pratique': {'en': 'New practice', 'es': 'Nueva práctica', 'ar': 'ممارسة جديدة', 'wo': 'Jëf bu bees'},
  'Titre': {'en': 'Title', 'es': 'Título', 'ar': 'العنوان', 'wo': 'Tur'},
  'Sous-titre (facultatif)': {'en': 'Subtitle (optional)', 'es': 'Subtítulo (opcional)', 'ar': 'العنوان الفرعي (اختياري)', 'wo': 'Sostitr (soo ko bëggee)'},
  'Ajouter': {'en': 'Add', 'es': 'Añadir', 'ar': 'إضافة', 'wo': 'Yokk'},
  'Annuler': {'en': 'Cancel', 'es': 'Cancelar', 'ar': 'إلغاء', 'wo': 'Bàyyi'},
  'Supprimer cette pratique ?': {'en': 'Delete this practice?', 'es': '¿Eliminar esta práctica?', 'ar': 'حذف هذه الممارسة؟', 'wo': 'Far jëf bii ?'},
  'Supprimer': {'en': 'Delete', 'es': 'Eliminar', 'ar': 'حذف', 'wo': 'Far'},
  'Glisse vers la gauche pour supprimer': {'en': 'Swipe left to delete', 'es': 'Desliza a la izquierda para eliminar', 'ar': 'اسحب لليسار للحذف', 'wo': 'Xëcc ci càmmoñ ngir far'},
  // Module Projets
  'Projets': {'en': 'Projects', 'es': 'Proyectos', 'ar': 'المشاريع', 'wo': 'Projet yi'},
  'Tes projets': {'en': 'Your projects', 'es': 'Tus proyectos', 'ar': 'مشاريعك', 'wo': 'Sa projet yi'},
  'Nouveau projet': {'en': 'New project', 'es': 'Nuevo proyecto', 'ar': 'مشروع جديد', 'wo': 'Projet bu bees'},
  'Description (facultatif)': {'en': 'Description (optional)', 'es': 'Descripción (opcional)', 'ar': 'الوصف (اختياري)', 'wo': 'Melokaan (soo ko bëggee)'},
  'Aucun projet pour le moment': {'en': 'No projects yet', 'es': 'Ningún proyecto por ahora', 'ar': 'لا مشاريع بعد', 'wo': 'Amul benn projet ba tey'},
  'Crée ton premier projet et avance étape par étape.': {'en': 'Create your first project and move forward step by step.', 'es': 'Crea tu primer proyecto y avanza paso a paso.', 'ar': 'أنشئ مشروعك الأول وتقدّم خطوة بخطوة.', 'wo': 'Sos sa projet bu njëkk te jëmal kanam benn-benn.'},
  'tâches': {'en': 'tasks', 'es': 'tareas', 'ar': 'مهام', 'wo': 'liggéey'},
  'Supprimer ce projet ?': {'en': 'Delete this project?', 'es': '¿Eliminar este proyecto?', 'ar': 'حذف هذا المشروع؟', 'wo': 'Far projet bii ?'},
  'Nouvelle tâche': {'en': 'New task', 'es': 'Nueva tarea', 'ar': 'مهمة جديدة', 'wo': 'Liggéey bu bees'},
  'projet terminé !': {'en': 'project completed!', 'es': '¡proyecto completado!', 'ar': 'اكتمل المشروع!', 'wo': 'projet bi jeex na !'},
  'Ajouter une tâche': {'en': 'Add a task', 'es': 'Añadir una tarea', 'ar': 'إضافة مهمة', 'wo': 'Yokk liggéey'},
  'Supprimer cette tâche ?': {'en': 'Delete this task?', 'es': '¿Eliminar esta tarea?', 'ar': 'حذف هذه المهمة؟', 'wo': 'Far liggéey bii ?'},
  'Couleur': {'en': 'Color', 'es': 'Color', 'ar': 'اللون', 'wo': 'Melo'},
  'Échéance': {'en': 'Due date', 'es': 'Fecha límite', 'ar': 'الموعد النهائي', 'wo': 'Jamono'},
  'Aucune échéance': {'en': 'No due date', 'es': 'Sin fecha límite', 'ar': 'بدون موعد', 'wo': 'Amul jamono'},
  'Choisir': {'en': 'Choose', 'es': 'Elegir', 'ar': 'اختر', 'wo': 'Tànn'},
  'En retard': {'en': 'Overdue', 'es': 'Atrasado', 'ar': 'متأخر', 'wo': 'Yeex na'},
  "Aujourd'hui": {'en': 'Today', 'es': 'Hoy', 'ar': 'اليوم', 'wo': 'Tey'},
  'Demain': {'en': 'Tomorrow', 'es': 'Mañana', 'ar': 'غداً', 'wo': 'Suba'},
  'Trier': {'en': 'Sort', 'es': 'Ordenar', 'ar': 'ترتيب', 'wo': 'Toftal'},
  'Par défaut': {'en': 'Default', 'es': 'Predeterminado', 'ar': 'افتراضي', 'wo': 'Ni mu deme'},
  'Par échéance': {'en': 'By due date', 'es': 'Por fecha', 'ar': 'حسب الموعد', 'wo': 'Ci jamono'},
  'Par progression': {'en': 'By progress', 'es': 'Por progreso', 'ar': 'حسب التقدّم', 'wo': 'Ci yokkute'},
  'Par nom': {'en': 'By name', 'es': 'Por nombre', 'ar': 'حسب الاسم', 'wo': 'Ci tur'},
  'Ajouter une sous-tâche': {'en': 'Add a subtask', 'es': 'Añadir una subtarea', 'ar': 'إضافة مهمة فرعية', 'wo': 'Yokk liggéey bu ndaw'},
  'Nouvelle sous-tâche': {'en': 'New subtask', 'es': 'Nueva subtarea', 'ar': 'مهمة فرعية جديدة', 'wo': 'Liggéey bu ndaw bu bees'},
  'Supprimer cette sous-tâche ?': {'en': 'Delete this subtask?', 'es': '¿Eliminar esta subtarea?', 'ar': 'حذف هذه المهمة الفرعية؟', 'wo': 'Far liggéey bu ndaw bii ?'},
  "Vue d'ensemble": {'en': 'Overview', 'es': 'Resumen', 'ar': 'نظرة عامة', 'wo': 'Nettali'},
  'Terminés': {'en': 'Completed', 'es': 'Completados', 'ar': 'مكتملة', 'wo': 'Yu jeex'},
  'achevé': {'en': 'completed', 'es': 'completado', 'ar': 'مكتمل', 'wo': 'jeex na'},
  "Ce projet arrive à échéance aujourd'hui.": {'en': 'This project is due today.', 'es': 'Este proyecto vence hoy.', 'ar': 'هذا المشروع مستحق اليوم.', 'wo': 'Projet bii jamono ju mu wàcc mooy tey.'},
  'Modifier le projet': {'en': 'Edit project', 'es': 'Editar proyecto', 'ar': 'تعديل المشروع', 'wo': 'Soppi projet bi'},
  'Modifier': {'en': 'Edit', 'es': 'Editar', 'ar': 'تعديل', 'wo': 'Soppi'},
  'Enregistrer': {'en': 'Save', 'es': 'Guardar', 'ar': 'حفظ', 'wo': 'Denc'},
  // À propos
  'À propos': {'en': 'About', 'es': 'Acerca de', 'ar': 'حول التطبيق', 'wo': 'Ci mbirum app bi'},
  'Version': {'en': 'Version', 'es': 'Versión', 'ar': 'الإصدار', 'wo': 'Sumb'},
  'Créée par': {'en': 'Created by', 'es': 'Creada por', 'ar': 'من تطوير', 'wo': 'Ki ko defar :'},
  'Politique de confidentialité': {'en': 'Privacy policy', 'es': 'Política de privacidad', 'ar': 'سياسة الخصوصية', 'wo': 'Politig sutura'},
  'Tes données restent uniquement sur ton appareil.': {
    'en': 'Your data stays on your device only.',
    'es': 'Tus datos permanecen solo en tu dispositivo.',
    'ar': 'بياناتك تبقى على جهازك فقط.',
    'wo': 'Sa données yi ci sa appareil rekk lañuy des.'
  },
  // Réglages / rappels / export
  'Réglages': {'en': 'Settings', 'es': 'Ajustes', 'ar': 'الإعدادات', 'wo': 'Coppite'},
  'Rappel quotidien': {'en': 'Daily reminder', 'es': 'Recordatorio diario', 'ar': 'تذكير يومي', 'wo': 'Fàttali bés bu nekk'},
  'Désactivé': {'en': 'Off', 'es': 'Desactivado', 'ar': 'معطّل', 'wo': 'Fey na'},
  'Heure du rappel': {'en': 'Reminder time', 'es': 'Hora del recordatorio', 'ar': 'وقت التذكير', 'wo': 'Waxtu fàttali bi'},
  "C'est le moment de tes pratiques du jour.": {'en': "It's time for your practices today.", 'es': 'Es hora de tus prácticas de hoy.', 'ar': 'حان وقت ممارساتك اليوم.', 'wo': 'Jamono ji jot na ngir sa jëf yu bés bi.'},
  'Exporter mes données': {'en': 'Export my data', 'es': 'Exportar mis datos', 'ar': 'تصدير بياناتي', 'wo': 'Génne sama données yi'},
  'Importer des données': {'en': 'Import data', 'es': 'Importar datos', 'ar': 'استيراد البيانات', 'wo': 'Dugal données yi'},
  'Copier': {'en': 'Copy', 'es': 'Copiar', 'ar': 'نسخ', 'wo': 'Kopiye'},
  'Copié !': {'en': 'Copied!', 'es': '¡Copiado!', 'ar': 'تم النسخ!', 'wo': 'Kopiye na !'},
  'Fermer': {'en': 'Close', 'es': 'Cerrar', 'ar': 'إغلاق', 'wo': 'Tëj'},
  'Colle ici ta sauvegarde…': {'en': 'Paste your backup here…', 'es': 'Pega aquí tu copia…', 'ar': 'الصق نسختك الاحتياطية هنا…', 'wo': 'Rendal sa sauvegarde fii…'},
  'Importer': {'en': 'Import', 'es': 'Importar', 'ar': 'استيراد', 'wo': 'Dugal'},
  'Import réussi. Redémarre pour le thème/la langue.': {'en': 'Import successful. Restart for theme/language.', 'es': 'Importación correcta. Reinicia para el tema/idioma.', 'ar': 'تم الاستيراد. أعد التشغيل للسمة/اللغة.', 'wo': 'Import bi baax na. Tàmbaliwaat app bi ngir melo ak làkk bi.'},
  'Fichier invalide.': {'en': 'Invalid file.', 'es': 'Archivo no válido.', 'ar': 'ملف غير صالح.', 'wo': 'Sauvegarde bi baaxul.'},
  'Rien à signaler': {'en': 'All clear', 'es': 'Todo en orden', 'ar': 'لا شيء', 'wo': 'Dara amul'},
  "jour d'affilée": {'en': 'day in a row', 'es': 'día seguido', 'ar': 'يوم متتالٍ', 'wo': 'fan bu topp'},
  "jours d'affilée": {'en': 'days in a row', 'es': 'días seguidos', 'ar': 'أيام متتالية', 'wo': 'fan yu topp'},
  'Commence ta série 💪': {'en': 'Start your streak 💪', 'es': 'Empieza tu racha 💪', 'ar': 'ابدأ سلسلتك 💪', 'wo': 'Tàmbali sa fan yu topp 💪'},
  'Ton historique': {'en': 'Your history', 'es': 'Tu historial', 'ar': 'سِجلّك', 'wo': 'Sa taariix'},
  'Moyenne': {'en': 'Average', 'es': 'Promedio', 'ar': 'المتوسط', 'wo': 'Diggu'},
  'jours': {'en': 'days', 'es': 'días', 'ar': 'أيام', 'wo': 'fan'},
  'il y a': {'en': 'past', 'es': 'hace', 'ar': 'قبل', 'wo': 'bi weesu'},
  'Journée pleine !': {'en': 'Perfect day!', 'es': '¡Día completo!', 'ar': 'يوم كامل!', 'wo': 'Bés bu mat !'},
  'Toutes tes pratiques sont accomplies.': {'en': 'All your practices are done.', 'es': 'Todas tus prácticas están hechas.', 'ar': 'كل ممارساتك مكتملة.', 'wo': 'Sa jëf yépp jeex nañu.'},
  'Continuer': {'en': 'Continue', 'es': 'Continuar', 'ar': 'متابعة', 'wo': 'Kontine'},
  // Jours
  'Lundi': {'en': 'Monday', 'es': 'Lunes', 'ar': 'الإثنين', 'wo': 'Altine'},
  'Mardi': {'en': 'Tuesday', 'es': 'Martes', 'ar': 'الثلاثاء', 'wo': 'Talaata'},
  'Mercredi': {'en': 'Wednesday', 'es': 'Miércoles', 'ar': 'الأربعاء', 'wo': 'Àllarba'},
  'Jeudi': {'en': 'Thursday', 'es': 'Jueves', 'ar': 'الخميس', 'wo': 'Alxamis'},
  'Vendredi': {'en': 'Friday', 'es': 'Viernes', 'ar': 'الجمعة', 'wo': 'Àjjuma'},
  'Samedi': {'en': 'Saturday', 'es': 'Sábado', 'ar': 'السبت', 'wo': 'Gaawu'},
  'Dimanche': {'en': 'Sunday', 'es': 'Domingo', 'ar': 'الأحد', 'wo': 'Dibéer'},
  // Mois
  'janvier': {'en': 'January', 'es': 'enero', 'ar': 'يناير'},
  'février': {'en': 'February', 'es': 'febrero', 'ar': 'فبراير'},
  'mars': {'en': 'March', 'es': 'marzo', 'ar': 'مارس'},
  'avril': {'en': 'April', 'es': 'abril', 'ar': 'أبريل'},
  'mai': {'en': 'May', 'es': 'mayo', 'ar': 'مايو'},
  'juin': {'en': 'June', 'es': 'junio', 'ar': 'يونيو'},
  'juillet': {'en': 'July', 'es': 'julio', 'ar': 'يوليو'},
  'août': {'en': 'August', 'es': 'agosto', 'ar': 'أغسطس'},
  'septembre': {'en': 'September', 'es': 'septiembre', 'ar': 'سبتمبر'},
  'octobre': {'en': 'October', 'es': 'octubre', 'ar': 'أكتوبر'},
  'novembre': {'en': 'November', 'es': 'noviembre', 'ar': 'نوفمبر'},
  'décembre': {'en': 'December', 'es': 'diciembre', 'ar': 'ديسمبر'},
};

// ── Date / salutation ────────────────────────────────────────
const kJoursFr = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
const kMoisFr = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];

String dateFr() {
  final n = DateTime.now();
  return '${tr(kJoursFr[n.weekday - 1])} ${n.day} ${tr(kMoisFr[n.month - 1])}';
}

String salutation() {
  final h = DateTime.now().hour;
  if (h < 12) return tr('Bonjour');
  if (h < 18) return tr('Bon après-midi');
  return tr('Bonsoir');
}

String dateCourte(DateTime d) => '${d.day} ${tr(kMoisFr[d.month - 1])} ${d.year}';

// Étiquette d'échéance relative (En retard / Aujourd'hui / Demain / date).
String labelEcheance(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final jour = DateTime(d.year, d.month, d.day);
  final diff = jour.difference(today).inDays;
  if (diff < 0) return tr('En retard');
  if (diff == 0) return tr("Aujourd'hui");
  if (diff == 1) return tr('Demain');
  return dateCourte(d);
}

bool echeanceEnRetard(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final jour = DateTime(d.year, d.month, d.day);
  return jour.isBefore(today);
}
