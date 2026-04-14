const MASTER_NUMBERS = new Set([11, 22, 33]);
const KARMIC_DEBT_NUMBERS = new Set([13, 14, 16, 19]);
const VOWELS = new Set(["A", "E", "I", "O", "U"]);

const PYTHAGOREAN_VALUES: Record<string, number> = {
  A: 1,
  B: 2,
  C: 3,
  D: 4,
  E: 5,
  F: 6,
  G: 7,
  H: 8,
  I: 9,
  J: 1,
  K: 2,
  L: 3,
  M: 4,
  N: 5,
  O: 6,
  P: 7,
  Q: 8,
  R: 9,
  S: 1,
  T: 2,
  U: 3,
  V: 4,
  W: 5,
  X: 6,
  Y: 7,
  Z: 8,
};

interface NumberMeaning {
  archetype: string;
  essence: string;
  gifts: string[];
  shadows: string[];
  guidance: string;
}

const NUMBER_MEANINGS: Record<number, NumberMeaning> = {
  0: {
    archetype: "Punto neutro",
    essence: "Una zona de menor fricción donde el aprendizaje no se concentra en un único número.",
    gifts: ["fluidez", "margen de maniobra", "adaptación"],
    shadows: ["subestimar el proceso", "falta de foco"],
    guidance:
      "Cuando aparece 0 conviene leer el resto del mapa, porque la tensión principal está en otras áreas.",
  },
  1: {
    archetype: "Iniciador",
    essence: "Impulso, autonomía y liderazgo.",
    gifts: ["iniciativa", "determinación", "originalidad"],
    shadows: ["apuro", "autosuficiencia rigida", "dificultad para delegar"],
    guidance:
      "Te conviene actuar con decisión, pero sin aislarte ni cerrar la escucha.",
  },
  2: {
    archetype: "Mediador",
    essence: "Sensibilidad, cooperación y armonía.",
    gifts: ["empatía", "diplomacia", "capacidad de asociarte"],
    shadows: ["indecisión", "hipersensibilidad", "dependencia emocional"],
    guidance:
      "Tu fortaleza aparece cuando sostienes vínculos claros sin perder tu centro.",
  },
  3: {
    archetype: "Expresor",
    essence: "Creatividad, voz y expansión emocional.",
    gifts: ["comunicación", "carisma", "imaginación"],
    shadows: ["dispersión", "drama", "falta de seguimiento"],
    guidance:
      "Canaliza tu expresión en una práctica concreta para no diluir tu energía.",
  },
  4: {
    archetype: "Constructor",
    essence: "Orden, método y base estable.",
    gifts: ["disciplina", "constancia", "organización"],
    shadows: ["rigidez", "control", "miedo al cambio"],
    guidance:
      "Lo material se fortalece cuando combinas estructura con flexibilidad real.",
  },
  5: {
    archetype: "Explorador",
    essence: "Movimiento, cambio y libertad.",
    gifts: ["adaptabilidad", "curiosidad", "versatilidad"],
    shadows: ["impulsividad", "exceso", "inquietud permanente"],
    guidance:
      "Tu expansión mejora cuando eliges experiencias con dirección, no solo intensidad.",
  },
  6: {
    archetype: "Cuidador",
    essence: "Responsabilidad, belleza y vinculo.",
    gifts: ["cuidado", "sentido estético", "compromiso"],
    shadows: ["sobre-responsabilidad", "culpa", "control afectivo"],
    guidance:
      "Sirves mejor cuando ayudas sin cargar con todo ni salvar a los demás.",
  },
  7: {
    archetype: "Buscador",
    essence: "Análisis, profundidad y sabiduría interior.",
    gifts: ["intuición", "investigación", "discernimiento"],
    shadows: ["aislamiento", "escepticismo", "frialdad"],
    guidance:
      "Necesitas espacios de introspección, pero sin desconectarte del mundo humano.",
  },
  8: {
    archetype: "Gestor",
    essence: "Poder, logro y administración.",
    gifts: ["liderazgo material", "eficiencia", "capacidad ejecutiva"],
    shadows: ["dureza", "obsesion por resultados", "tension con el control"],
    guidance:
      "Tu potencial crece cuando haces que ambición y ética trabajen juntas.",
  },
  9: {
    archetype: "Humanitario",
    essence: "Servicio, cierre de ciclos y mirada amplia.",
    gifts: ["compasión", "visión", "capacidad de soltar"],
    shadows: ["desgaste", "idealizacion", "sacrificio excesivo"],
    guidance:
      "Tu aprendizaje es dar con amplitud sin abandonar tus propios límites.",
  },
  11: {
    archetype: "Canal",
    essence: "Inspiración, intuición afinada y visión.",
    gifts: ["percepción sutil", "inspiración", "capacidad de elevar a otros"],
    shadows: ["ansiedad", "nerviosismo", "sobrecarga energética"],
    guidance:
      "Necesitas tierra y rutina para que tu intuición no se convierta en ruido.",
  },
  22: {
    archetype: "Arquitecto maestro",
    essence: "Visión grande con capacidad concreta de materialización.",
    gifts: ["construccion a gran escala", "impacto colectivo", "estrategia"],
    shadows: ["presión excesiva", "miedo a fallar", "parálisis por magnitud"],
    guidance:
      "Tu maestría aparece cuando conviertes una visión alta en pasos sostenibles.",
  },
  33: {
    archetype: "Servidor maestro",
    essence: "Compasión, enseñanza y servicio de alto voltaje.",
    gifts: ["sanación", "inspiración afectiva", "guía"],
    shadows: ["martirio", "agotamiento", "autoexigencia extrema"],
    guidance:
      "El servicio real no pide inmolarte; pide sostener tu energía con madurez.",
  },
};

const KARMIC_LESSON_TEXT: Record<number, string> = {
  1: "Desarrollar iniciativa, autonomía y decisión propia.",
  2: "Aprender cooperación, tacto y escucha emocional.",
  3: "Soltar la autocrítica y expresar con alegría y espontaneidad.",
  4: "Construir orden, constancia y disciplina.",
  5: "Usar la libertad con dirección y responsabilidad.",
  6: "Madurar en compromiso, cuidado y armonía vincular.",
  7: "Confiar en tu voz interior y profundizar sin aislarte.",
  8: "Relacionarte mejor con poder, dinero y autoridad.",
  9: "Abrirte a una mirada más compasiva y desapegada.",
};

const NUMEROLOGY_REFERENCES = [
  {
    label: "Hans Decoz - Core Numbers",
    url: "https://www.worldnumerology.com/numerology-articles/numerology-core-numbers.html",
    note:
      "Base conceptual para Life Path, Expression, Soul Urge, Personality y Birthday.",
  },
  {
    label: "Hans Decoz - Soul Urge",
    url: "https://www.worldnumerology.com/numerology-soul-urge/",
    note:
      "Referencia para cálculo por vocales, uso del nombre de nacimiento y tratamiento de la Y.",
  },
  {
    label: "Hans Decoz - Personal Years & Essence",
    url: "https://www.worldnumerology.com/personal-numerology-forecast/personal-years-and-essence-cycles.html",
    note:
      "Base para año, mes y día personal y para entender ciclos externos.",
  },
  {
    label: "Hans Decoz - Karmic Lessons",
    url: "https://www.worldnumerology.com/numerology-karmic-lessons/",
    note:
      "Referencia para lecciones kármicas como números ausentes en el nombre.",
  },
];

export interface NumerologyProfileInput {
  birthName?: string;
  currentName?: string;
  birthDate?: string;
  targetDate?: string;
}

export interface NumerologyGuideResult {
  version: string;
  system: string;
  concepts: Array<{
    id: string;
    title: string;
    summary: string;
  }>;
  references: typeof NUMEROLOGY_REFERENCES;
}

export interface NumerologyCard {
  title: string;
  value: number;
  reduced: number;
  rawTotal: number;
  displayValue: string;
  isMaster: boolean;
  isKarmicDebt: boolean;
  archetype: string;
  essence: string;
  gifts: string[];
  shadows: string[];
  guidance: string;
}

export interface NumerologyProfileResult {
  version: string;
  system: string;
  input: {
    birthName: string;
    currentName: string;
    birthDate: string;
    targetDate: string;
  };
  coreNumbers: {
    lifePath: NumerologyCard;
    expression: NumerologyCard;
    soulUrge: NumerologyCard;
    personality: NumerologyCard;
    birthday: NumerologyCard;
    maturity: NumerologyCard;
    attitude: NumerologyCard;
    currentNameExpression: NumerologyCard | null;
    currentNameSoulUrge: NumerologyCard | null;
    currentNamePersonality: NumerologyCard | null;
  };
  cycles: {
    universalYear: NumerologyCard;
    personalYear: NumerologyCard;
    personalMonth: NumerologyCard;
    personalDay: NumerologyCard;
    pinnacleCycles: Array<{
      label: string;
      ageRange: string;
      focus: string;
      number: NumerologyCard;
    }>;
    challengeCycles: Array<{
      label: string;
      ageRange: string;
      focus: string;
      number: NumerologyCard;
    }>;
  };
  patterns: {
    dominantNumbers: Array<{
      value: number;
      count: number;
      archetype: string;
    }>;
    hiddenPassion: NumerologyCard | null;
    karmicLessons: NumerologyCard[];
    cornerstone: {
      letter: string;
      value: number;
      meaning: string;
    };
    capstone: {
      letter: string;
      value: number;
      meaning: string;
    };
    firstVowel: {
      letter: string;
      value: number;
      meaning: string;
    } | null;
  };
  narrative: {
    summary: string;
    vocation: string;
    relationships: string;
    timing: string;
  };
  references: typeof NUMEROLOGY_REFERENCES;
}

function normalizeBirthDateInput(value?: string): string {
  const raw = (value ?? "").trim();
  const isoMatch = raw.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (isoMatch) {
    return raw;
  }

  const dayFirstMatch = raw.match(/^(\d{2})-(\d{2})-(\d{4})$/);
  if (dayFirstMatch) {
    return `${dayFirstMatch[3]}-${dayFirstMatch[2]}-${dayFirstMatch[1]}`;
  }

  throw new Error("La fecha de nacimiento debe estar en formato DD-MM-YYYY o YYYY-MM-DD.");
}

function parseIsoDate(value: string): Date {
  const date = new Date(`${value}T00:00:00Z`);
  if (Number.isNaN(date.getTime())) {
    throw new Error("No se pudo interpretar la fecha de nacimiento.");
  }

  return date;
}

function normalizeName(value?: string): string {
  return (value ?? "")
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .replace(/[^A-Za-z\s'-]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function extractWords(value: string): string[] {
  return normalizeName(value)
    .toUpperCase()
    .split(/\s+/)
    .map((word) => word.replace(/[^A-Z]/g, ""))
    .filter((word) => word.length > 0);
}

function sumDigits(value: number): number {
  return String(Math.abs(value))
    .split("")
    .reduce((sum, digit) => sum + Number(digit), 0);
}

function reduceNumber(
  rawTotal: number,
  options: {
    allowMaster?: boolean;
    useKarmicLabel?: boolean;
  } = {},
): NumerologyCard {
  const allowMaster = options.allowMaster ?? true;
  const useKarmicLabel = options.useKarmicLabel ?? true;
  let value = rawTotal;

  while (value > 9 && !(allowMaster && MASTER_NUMBERS.has(value))) {
    value = sumDigits(value);
  }

  let reduced = rawTotal;
  while (reduced > 9) {
    reduced = sumDigits(reduced);
  }

  const isMaster = MASTER_NUMBERS.has(value);
  const isKarmicDebt =
    useKarmicLabel && KARMIC_DEBT_NUMBERS.has(rawTotal) && !isMaster;
  const meaning = NUMBER_MEANINGS[value] ?? NUMBER_MEANINGS[reduced];
  const displayValue = isMaster
    ? `${value}/${reduced}`
    : isKarmicDebt
        ? `${rawTotal}/${reduced}`
        : String(value);

  return {
    title: "",
    value,
    reduced,
    rawTotal,
    displayValue,
    isMaster,
    isKarmicDebt,
    archetype: meaning.archetype,
    essence: meaning.essence,
    gifts: meaning.gifts,
    shadows: meaning.shadows,
    guidance: meaning.guidance,
  };
}

function createNumberCard(
  title: string,
  rawTotal: number,
  options?: { allowMaster?: boolean; useKarmicLabel?: boolean },
): NumerologyCard {
  return {
    ...reduceNumber(rawTotal, options),
    title,
  };
}

function isYVowel(word: string, index: number): boolean {
  if (word[index] !== "Y") {
    return false;
  }

  const previous = index > 0 ? word[index - 1] : "";
  const next = index + 1 < word.length ? word[index + 1] : "";
  const previousIsVowel = VOWELS.has(previous);
  const nextIsVowel = VOWELS.has(next);
  return !previousIsVowel && !nextIsVowel;
}

function isSelectedLetter(
  word: string,
  index: number,
  selection: "all" | "vowels" | "consonants",
): boolean {
  if (selection === "all") {
    return true;
  }

  const char = word[index];
  const isVowel = VOWELS.has(char) || isYVowel(word, index);
  return selection === "vowels" ? isVowel : !isVowel;
}

function getLetterValue(letter: string): number {
  const value = PYTHAGOREAN_VALUES[letter];
  if (!value) {
    throw new Error(`La letra ${letter} no pudo mapearse en el sistema pitagórico.`);
  }

  return value;
}

function calculateNameNumber(
  title: string,
  fullName: string,
  selection: "all" | "vowels" | "consonants",
): NumerologyCard {
  const words = extractWords(fullName);
  if (words.length === 0) {
    throw new Error("El nombre completo al nacer es obligatorio para numerología.");
  }

  const reducedWordTotals = words
    .map((word) => {
      let total = 0;
      for (let index = 0; index < word.length; index += 1) {
        if (isSelectedLetter(word, index, selection)) {
          total += getLetterValue(word[index]);
        }
      }

      return total === 0 ? null : reduceNumber(total);
    })
    .filter((item): item is NumerologyCard => item !== null);

  const finalTotal = reducedWordTotals.reduce((sum, item) => sum + item.value, 0);
  return createNumberCard(title, finalTotal);
}

function calculateLifePath(date: Date): NumerologyCard {
  const month = date.getUTCMonth() + 1;
  const day = date.getUTCDate();
  const year = date.getUTCFullYear();
  const monthValue = reduceNumber(month).value;
  const dayValue = reduceNumber(day).value;
  const yearValue = reduceNumber(sumDigits(year)).value;
  return createNumberCard("Sendero de vida", monthValue + dayValue + yearValue);
}

function calculateBirthday(date: Date): NumerologyCard {
  return createNumberCard("Dia de nacimiento", date.getUTCDate());
}

function calculateAttitude(date: Date): NumerologyCard {
  const month = reduceNumber(date.getUTCMonth() + 1).value;
  const day = reduceNumber(date.getUTCDate()).value;
  return createNumberCard("Actitud", month + day);
}

function calculateUniversalYear(targetDate: Date): NumerologyCard {
  return createNumberCard(
    "Año universal",
    sumDigits(targetDate.getUTCFullYear()),
  );
}

function calculatePersonalYear(
  birthDate: Date,
  targetDate: Date,
): NumerologyCard {
  const month = reduceNumber(birthDate.getUTCMonth() + 1).value;
  const day = reduceNumber(birthDate.getUTCDate()).value;
  const year = calculateUniversalYear(targetDate).value;
  return createNumberCard("Año personal", month + day + year);
}

function calculatePersonalMonth(
  personalYear: NumerologyCard,
  targetDate: Date,
): NumerologyCard {
  return createNumberCard(
    "Mes personal",
    personalYear.value + targetDate.getUTCMonth() + 1,
  );
}

function calculatePersonalDay(
  personalMonth: NumerologyCard,
  targetDate: Date,
): NumerologyCard {
  return createNumberCard(
    "Día personal",
    personalMonth.value + targetDate.getUTCDate(),
  );
}

function findLetterTone(
  sourceName: string,
  selector: "first" | "last" | "firstVowel",
): { letter: string; value: number; meaning: string } | null {
  const letters = extractWords(sourceName).join("");
  if (letters.length === 0) {
    return null;
  }

  let letter = "";
  if (selector === "first") {
    letter = letters[0];
  } else if (selector === "last") {
    letter = letters[letters.length - 1];
  } else {
    for (let index = 0; index < letters.length; index += 1) {
      const current = letters[index];
      if (VOWELS.has(current) || isYVowel(letters, index)) {
        letter = current;
        break;
      }
    }
  }

  if (!letter) {
    return null;
  }

  const value = getLetterValue(letter);
  const meaning = NUMBER_MEANINGS[value]?.essence ?? "Matiz numerologico base.";
  return { letter, value, meaning };
}

function countLetterValues(fullName: string): Map<number, number> {
  const counts = new Map<number, number>();
  const letters = extractWords(fullName).join("");
  for (const letter of letters) {
    const value = getLetterValue(letter);
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }

  return counts;
}

function buildPatterns(fullName: string) {
  const counts = countLetterValues(fullName);
  const dominantNumbers = [...counts.entries()]
    .sort((left, right) => right[1] - left[1] || left[0] - right[0])
    .slice(0, 3)
    .map(([value, count]) => ({
      value,
      count,
      archetype: NUMBER_MEANINGS[value].archetype,
    }));

  const hiddenPassionEntry = [...counts.entries()]
    .filter(([, count]) => count > 1)
    .sort((left, right) => right[1] - left[1] || left[0] - right[0])[0];

  const hiddenPassion = hiddenPassionEntry
    ? createNumberCard("Pasion oculta", hiddenPassionEntry[0])
    : null;

  const karmicLessons = Array.from({ length: 9 }, (_, index) => index + 1)
    .filter((value) => !counts.has(value))
    .map((value) => {
      const card = createNumberCard(`Leccion karmica ${value}`, value, {
        allowMaster: false,
        useKarmicLabel: false,
      });
      return {
        ...card,
        guidance: KARMIC_LESSON_TEXT[value],
      };
    });

  return {
    dominantNumbers,
    hiddenPassion,
    karmicLessons,
    cornerstone: findLetterTone(fullName, "first"),
    capstone: findLetterTone(fullName, "last"),
    firstVowel: findLetterTone(fullName, "firstVowel"),
  };
}

function buildPinnacleCycles(
  birthDate: Date,
  lifePath: NumerologyCard,
) {
  const month = reduceNumber(birthDate.getUTCMonth() + 1).value;
  const day = reduceNumber(birthDate.getUTCDate()).value;
  const year = reduceNumber(sumDigits(birthDate.getUTCFullYear())).value;
  const firstEndAge = 36 - lifePath.reduced;
  const secondEndAge = firstEndAge + 9;
  const thirdEndAge = secondEndAge + 9;
  const first = createNumberCard("Primer pináculo", month + day);
  const second = createNumberCard("Segundo pináculo", day + year);
  const third = createNumberCard("Tercer pináculo", first.value + second.value);
  const fourth = createNumberCard("Cuarto pináculo", month + year);

  return [
    {
      label: "Primer pináculo",
      ageRange: `0 a ${firstEndAge}`,
      focus: "Define el terreno base donde aprendes a afirmarte y crecer.",
      number: first,
    },
    {
      label: "Segundo pináculo",
      ageRange: `${firstEndAge + 1} a ${secondEndAge}`,
      focus: "Expande tu desarrollo social, profesional y vincular.",
      number: second,
    },
    {
      label: "Tercer pináculo",
      ageRange: `${secondEndAge + 1} a ${thirdEndAge}`,
      focus: "Integra experiencia con dirección y mayor madurez.",
      number: third,
    },
    {
      label: "Cuarto pináculo",
      ageRange: `${thirdEndAge + 1}+`,
      focus: "Muestra la vibración de consolidación y legado.",
      number: fourth,
    },
  ];
}

function buildChallengeCycles(
  birthDate: Date,
  lifePath: NumerologyCard,
) {
  const month = reduceNumber(birthDate.getUTCMonth() + 1, {
    allowMaster: false,
  }).reduced;
  const day = reduceNumber(birthDate.getUTCDate(), {
    allowMaster: false,
  }).reduced;
  const year = reduceNumber(sumDigits(birthDate.getUTCFullYear()), {
    allowMaster: false,
  }).reduced;
  const firstEndAge = 36 - lifePath.reduced;
  const secondEndAge = firstEndAge + 9;
  const thirdEndAge = secondEndAge + 9;
  const first = createNumberCard("Primer desafío", Math.abs(day - month), {
    allowMaster: false,
    useKarmicLabel: false,
  });
  const second = createNumberCard("Segundo desafío", Math.abs(day - year), {
    allowMaster: false,
    useKarmicLabel: false,
  });
  const third = createNumberCard(
    "Tercer desafío",
    Math.abs(first.value - second.value),
    { allowMaster: false, useKarmicLabel: false },
  );
  const fourth = createNumberCard("Cuarto desafío", Math.abs(month - year), {
    allowMaster: false,
    useKarmicLabel: false,
  });

  return [
    {
      label: "Primer desafío",
      ageRange: `0 a ${firstEndAge}`,
      focus: "Enseña la tensión inicial que pide maduración temprana.",
      number: first,
    },
    {
      label: "Segundo desafío",
      ageRange: `${firstEndAge + 1} a ${secondEndAge}`,
      focus: "Marca pruebas de consolidación personal y emocional.",
      number: second,
    },
    {
      label: "Tercer desafío",
      ageRange: `${secondEndAge + 1} a ${thirdEndAge}`,
      focus: "Muestra la gran lección integradora de la adultez.",
      number: third,
    },
    {
      label: "Cuarto desafío",
      ageRange: `${thirdEndAge + 1}+`,
      focus: "Describe el reto persistente que afina tu madurez.",
      number: fourth,
    },
  ];
}

function buildNarrative(input: {
  lifePath: NumerologyCard;
  expression: NumerologyCard;
  soulUrge: NumerologyCard;
  personality: NumerologyCard;
  personalYear: NumerologyCard;
  dominantNumbers: Array<{ value: number; count: number; archetype: string }>;
  hiddenPassion: NumerologyCard | null;
}): NumerologyProfileResult["narrative"] {
  const dominant = input.dominantNumbers[0];
  const hiddenPassionText = input.hiddenPassion == null
    ? "No aparece una pasión oculta dominante; el mapa está más repartido."
    : `Tu pasión oculta ${input.hiddenPassion.displayValue} empuja procesos donde ${input.hiddenPassion.essence.toLowerCase()}`;

  return {
    summary:
      `Tu Sendero de Vida ${input.lifePath.displayValue} marca el tono central del camino, mientras tu Expresión ${input.expression.displayValue} describe la forma en que despliegas tus talentos. ` +
      `Tu Alma ${input.soulUrge.displayValue} muestra la motivación profunda y tu Personalidad ${input.personality.displayValue} la primera capa que leen los demás. ` +
      (dominant == null
        ? ""
        : `La frecuencia más repetida de tu nombre es ${dominant.value}, lo que refuerza un estilo ${dominant.archetype.toLowerCase()}.`),
    vocation:
      `Profesionalmente conviene unir la dirección ${input.lifePath.archetype.toLowerCase()} de tu camino con la forma ${input.expression.archetype.toLowerCase()} en que ejecutas. ` +
      `Si honras tu número de Expresión, el trabajo deja de ser solo obligación y se vuelve canal de realización.`,
    relationships:
      `En vínculos pesa especialmente tu Alma ${input.soulUrge.displayValue}, porque ahí se ve lo que realmente necesitas para sentirte reconocido. ` +
      `Tu Personalidad ${input.personality.displayValue} actúa como filtro externo, así que no siempre lo que muestras coincide con lo que deseas por dentro. ` +
      hiddenPassionText,
    timing:
      `El Año Personal ${input.personalYear.displayValue} describe el clima actual de tus decisiones. ` +
      `Toma este ciclo como una capa externa: abre oportunidades y pruebas, pero se expresa mejor cuando la alineas con tus números base.`,
  };
}

export function getNumerologyGuide(): NumerologyGuideResult {
  return {
    version: "0.1.0",
    system: "pitagorico",
    concepts: [
      {
        id: "core",
        title: "Números nucleares",
        summary:
          "Sendero de Vida, Expresión, Alma, Personalidad, Cumpleaños y Madurez forman la columna principal del perfil.",
      },
      {
        id: "cycles",
        title: "Ciclos personales",
        summary:
          "Año, mes y día personal funcionan como clima externo para el momento presente.",
      },
      {
        id: "pinnacles",
        title: "Pináculos y desafíos",
        summary:
          "Los pináculos muestran grandes etapas; los desafíos marcan aprendizajes persistentes.",
      },
      {
        id: "karmic",
        title: "Lecciones kármicas",
        summary:
          "Los números ausentes en el nombre al nacer indican áreas a desarrollar con más conciencia.",
      },
      {
        id: "name",
        title: "Nombre natal vs. nombre actual",
        summary:
          "El nombre de nacimiento sostiene la estructura base. El nombre actual puede matizar como te presentas hoy.",
      },
    ],
    references: NUMEROLOGY_REFERENCES,
  };
}

export function calculateNumerologyProfile(
  input: NumerologyProfileInput,
): NumerologyProfileResult {
  const birthName = normalizeName(input.birthName);
  if (birthName.length === 0) {
    throw new Error("Ingresa el nombre completo al nacer para calcular la numerología.");
  }

  const currentName = normalizeName(input.currentName) || birthName;
  const birthDate = parseIsoDate(normalizeBirthDateInput(input.birthDate));
  const targetDate = input.targetDate == null
    ? new Date()
    : parseIsoDate(normalizeBirthDateInput(input.targetDate));

  const lifePath = calculateLifePath(birthDate);
  const expression = calculateNameNumber("Expresión", birthName, "all");
  const soulUrge = calculateNameNumber("Alma", birthName, "vowels");
  const personality = calculateNameNumber("Personalidad", birthName, "consonants");
  const birthday = calculateBirthday(birthDate);
  const maturity = createNumberCard("Madurez", lifePath.value + expression.value);
  const attitude = calculateAttitude(birthDate);
  const universalYear = calculateUniversalYear(targetDate);
  const personalYear = calculatePersonalYear(birthDate, targetDate);
  const personalMonth = calculatePersonalMonth(personalYear, targetDate);
  const personalDay = calculatePersonalDay(personalMonth, targetDate);
  const patterns = buildPatterns(birthName);
  const currentNameChanged = currentName !== birthName;
  const currentNameExpression = currentNameChanged
    ? calculateNameNumber("Expresión actual", currentName, "all")
    : null;
  const currentNameSoulUrge = currentNameChanged
    ? calculateNameNumber("Alma actual", currentName, "vowels")
    : null;
  const currentNamePersonality = currentNameChanged
    ? calculateNameNumber("Personalidad actual", currentName, "consonants")
    : null;

  return {
    version: "0.1.0",
    system: "pitagorico",
    input: {
      birthName,
      currentName,
      birthDate: normalizeBirthDateInput(input.birthDate),
      targetDate: targetDate.toISOString().slice(0, 10),
    },
    coreNumbers: {
      lifePath,
      expression,
      soulUrge,
      personality,
      birthday,
      maturity,
      attitude,
      currentNameExpression,
      currentNameSoulUrge,
      currentNamePersonality,
    },
    cycles: {
      universalYear,
      personalYear,
      personalMonth,
      personalDay,
      pinnacleCycles: buildPinnacleCycles(birthDate, lifePath),
      challengeCycles: buildChallengeCycles(birthDate, lifePath),
    },
    patterns: {
      dominantNumbers: patterns.dominantNumbers,
      hiddenPassion: patterns.hiddenPassion,
      karmicLessons: patterns.karmicLessons,
      cornerstone: patterns.cornerstone ?? {
        letter: "",
        value: 0,
        meaning: "",
      },
      capstone: patterns.capstone ?? {
        letter: "",
        value: 0,
        meaning: "",
      },
      firstVowel: patterns.firstVowel,
    },
    narrative: buildNarrative({
      lifePath,
      expression,
      soulUrge,
      personality,
      personalYear,
      dominantNumbers: patterns.dominantNumbers,
      hiddenPassion: patterns.hiddenPassion,
    }),
    references: NUMEROLOGY_REFERENCES,
  };
}
