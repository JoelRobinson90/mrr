# typed: true
# frozen_string_literal: true

module PatientConstants
  extend ActiveSupport::Concern
  included do
    SEXES = %w[Male Female Intersex Unknown Other].freeze

    NEEDS_SCHEDULING_STATUS = "Referred: Needs Scheduling"
    STATUSES = [
      "Created",
      NEEDS_SCHEDULING_STATUS,
      "Referred: Scheduled",
      "Care Complete",
      "Scheduled with Issue",
      "Referred: Cancelled",
      "Archived"
    ].freeze

    GENDERS = [
      "Woman",
      "Man",
      "Trans Woman",
      "Trans Man",
      "Agender",
      "Non-Binary",
      "Genderfluid",
      "Two-Spirit",
      "Unknown",
      "Male to Female",
      "Female to Male",
      "Other"
    ].freeze

    # ADL.org list of Preferred Pronouns
    # Stated to be an incomplete listing
    PREFERRED_PRONOUNS = [
      "she/her/hers",
      "he/him/his",
      "they/them/theirs",
      "ze/zir/zirs",
      "ze/hir/hirs"
    ].freeze

    DIAGNOSES = %w[
      Diabetes
      CHF
      COPD
      Asthma
      COVID-19
    ].freeze

    RACES = [
      "American Indian or Alaska Native",
      "Asian",
      "Native Hawaiian or Other Pacific Islander",
      "Black or African-American",
      "White",
      "Other Race",
      "Prefer Not to Say",
      "Unknown"
    ].freeze

    ETHNICITY = [
      "Hispanic or Latino",
      "Not Hispanic or Latino",
      "Unknown",
      "Prefer Not to Say"
    ].freeze

    # ISO 639-2 code languages and synonyms
    # Plus Traditional Chinese and Mandarin
    LANGUAGES = {"English" => "eng", "Traditional Chinese" => "zho", "Mandarin" => "zho", "Spanish" => "spa", "Hindi"  =>"hin", "Abkhazian" => "abk", "Afar" => "aar", "Afrikaans" => "afr",
                 "Akan" => "aka", "Albanian" => "sqi", "Amharic" => "amh", "Arabic" => "ara", "Aragonese" => "arg", "Armenian" => "hye", "Assamese" => "asm", "Avaric" => "ava", "Avestan"  =>"ave",
                 "Aymara" => "aym", "Azerbaijani" => "aze", "Bambara" => "bam", "Bashkir" => "bak", "Basque" => "eus", "Belarusian" => "bel", "Bengali" => "ben", "Bihari languages" => "bih",
                 "Bislama" => "bis", "Bosnian" => "bos", "Breton" => "bre", "Bulgarian" => "bul", "Burmese" => "mya", "Cantonese" => "zho", "Catalan" => "cat", "Chamorro" => "cha", "Chechen" => "che",
                 "Chichewa" => "nya", "Chewa" => "nya", "Chinese" => "zho", "Chuvash" => "chv", "Cornish" => "cor", "Corsican" => "cos", "Cree" => "cre", "Creole" => "crp", "Croatian" => "hrv",
                 "Czech" => "ces", "Danish" => "dan", "Divehi" => "div", "Dhivehi" => "div", "Dutch" => "nld", "Dzongkha" => "dzo", "Esperanto" => "epo", "Estonian" => "est", "Ewe" => "ewe",
                 "Faroese" => "fao", "Fijian" => "fij", "Finnish" => "fin", "Flemish" => "nld", "French" => "fra", "French Creole" => "cpf", "Fulah" => "ful", "Galician" => "glg", "Georgian" => "kat",
                 "German" => "deu", "Greenlandic" => "kal", "Greek" => "ell", "Guarani" => "grn", "Gujarati" => "guj", "Haitian" => "hat", "Haitian Creole" => "hat", "Hausa" => "hau", "Hebrew" => "heb",
                 "Herero" => "her", "Hiri Motu" => "hmo", "Hungarian" => "hun", "Interlingua" => "ile", "Indonesian" => "ind", "Irish" => "gle", "Igbo" => "ibo", "Inupiaq" => "ipk", "Ido" => "ido",
                 "Icelandic" => "isl", "Italian" => "ita", "Inuktitut" => "iku", "Japanese" => "jpn", "Javanese" => "jav", "Kalaallisut" => "kal", "Kannada" => "kan", "Kanuri" => "kau",
                 "Kashmiri" => "kas", "Kazakh" => "kaz", "Central Khmer" => "khm", "Kikuyu" => "kik", "Gikuyu" => "kik", "Kinyarwanda" => "kin", "Kirghiz" => "kir", "Kyrgyz" => "kir",
                 "Komi" => "kom", "Kongo" => "kon", "Korean" => "kor", "Kurdish" => "kur", "Kuanyama" => "kua", "Kwanyama" => "kua", "Latin" => "lat", "Luxembourgish" => "ltz", "Letzeburgesch" => "ltz",
                 "Ganda" => "lug", "Limburgan" => "lim", "Limburger" => "lim", "Limburgish" => "lim", "Lingala" => "lin", "Lao" => "lao", "Lithuanian" => "lit", "Luba-Katanga" => "lub",
                 "Latvian" => "lav", "Manx" => "glv", "Macedonian" => "mkd", "Malagasy" => "mlg", "Malay" => "msa", "Malayalam" => "mal", "Maldivian" => "div", "Maltese" => "mlt", "Maori" => "mri",
                 "Marathi" => "mar", "Marshallese" => "mah", "Mongolian" => "mon", "Nauru" => "nau", "Navajo" => "nav", "Navaho" => "nav", "North Ndebele" => "nde", "Nepali" => "nep",
                 "Ndonga" => "ndo", "Norwegian Bokmål" => "nob", "Norwegian Nynorsk" => "nno", "Norwegian" => "nor", "Nuosu" => "iii", "Nyanja" => "nya", "Sichuan Yi" => "iii",
                 "South Ndebele" => "nbl", "Occitan" => "oci", "Ojibwa" => "oji", "Church Slavic" => "chu", "Old Slavonic" => "chu", "Church Slavonic" => "chu", "Old Bulgarian" => "chu",
                 "Old Church Slavonic" => "chu", "Oromo" => "orm", "Oriya" => "ori", "Ossetian" => "oss", "Ossetic" => "oss", "Punjabi" => "pan", "Panjabi" => "pan", "Pali" => "pli",
                 "Persian" => "fas", "Polish" => "pol", "Pashto" => "pus", "Pushto" => "pus", "Portuguese" => "por", "Quechua" => "que", "Romansh" => "roh", "Rundi" => "run", "Romanian" => "ron",
                 "Moldavian" => "ron", "Moldovan" => "ron", "Russian" => "rus", "Sanskrit" => "san", "Sardinian" => "srd", "Sindhi" => "snd", "Northern Sami" => "sme", "Samoan" => "smo",
                 "Sango" => "sag", "Serbian" => "srp", "Gaelic" => "gla", "Scottish Gaelic" => "gla", "Shona" => "sna", "Sinhala" => "sin", "Sinhalese" => "sin", "Slovak" => "slk",
                 "Slovenian" => "slv", "Somali" => "som", "Southern Sotho" => "sot", "Castilian" => "spa", "Sundanese" => "ara", "Swahili" => "swa", "Swati" => "ssw", "Swedish" => "swe",
                 "Tamil" => "tam", "Telugu" => "tel", "Tajik" => "tgk", "Thai" => "tha", "Tigrinya" => "tir", "Tibetan" => "bod", "Turkmen" => "tuk", "Tagalog" => "tgl", "Tswana" => "tsn",
                 "Tonga" => "ton", "Turkish" => "tur", "Tsonga" => "tso", "Tatar" => "tat", "Twi" => "twi", "Tahitian" => "tah", "Uighur" => "uig", "Uyghur" => "uig", "Ukrainian" => "ukr",
                 "Urdu" => "urd", "Uzbek" => "uzb", "Valencian" => "cat", "Venda" => "ven", "Vietnamese" => "vie", "Volapük" => "vol", "Walloon" => "wln", "Welsh" => "cym", "Wolof" => "wol",
                 "Western Frisian" => "fry", "Xhosa" => "xho", "Yiddish" => "yid", "Yoruba" => "yor", "Zhuang" => "zha", "Chuang" => "zha", "Zulu" => "zul", "Unknown" => ""}.freeze

    LANGUAGES_LONGFORM = LANGUAGES.keys.freeze

    PHONE_TYPES = %w[
      Cell
      Home
      Work
    ].freeze
  end
end
