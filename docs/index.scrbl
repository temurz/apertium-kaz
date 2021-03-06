#lang scribble/manual

@title{@tt{APERTIUM-KAZ}: A MORPHOLOGICAL TRANSDUCER AND DISAMBIGUATOR FOR
 KAZAKH}

@margin-note{WARNING: this is an early draft.}

What follows is the documentation for @tt{apertium-kaz} -- a morphological
transducer and disambiguator for Kazakh. First draft of this documentation was
written, or, rather, assembled from various writings on
@hyperlink["https://wiki.apertium.org"]{Apertium's wiki} and then extended with
more details by @hyperlink["http://github.com/IlnarSelimcan"]{selimcan} on
September-October 2018 for members of the `Deep Learning for Sequential Models
in Natural Language Processing with Applications to Kazakh'
(@italic{dlsmnlpak}) research group at Nazarbayev University and
elsewhere. That being said, I hope that it will be useful for anyone who uses
@code{apertium-kaz} and maybe wants or needs to extend it with more stems or
other features. Most of the things said in this guide should be applicable to
Apertium's transducers for other Turkic languages as well.

@tt{Apertium-kaz} is a morphological transducer and disambiguator for Kazakh,
currently under development. It is intended to be compatible with transducers
for other Turkic languages so that they can be translated between. It's used in
the following translators (at various stages of development):

@itemize[

@item{@hyperlink["https://github.com/apertium/apertium-kaz-tat"]{Kazakh and Tatar}}

@item{@hyperlink["https://github.com/apertium/apertium-eng-kaz"]{English and
  Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-rus"]{Kazakh and
  Russian}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-kir"]{Kazakh and Kyrgyz}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-kaa"]{Kazakh and
  Karakalpak}}

@item{@hyperlink["https://github.com/apertium/apertium-khk-kaz"]{Khalkha and
  Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-kum"]{Kazakh and
Kumyk}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-tur"]{Kazakh and
Turkish}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-tyv"]{Kazakh and
Tuvan}}

@item{@hyperlink["https://github.com/apertium/apertium-nog-kaz"]{Nogai and Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-sah"]{Kazakh and
Sakha}}

@item{@hyperlink["https://github.com/apertium/apertium-fin-kaz"]{Finnish and
  Kazakh}}

@item{@hyperlink["https://github.com/apertium/apertium-kaz-uig"]{Kazakh and
Uyghur}}

]

@section{Extending @tt{apertium-kaz}}

To extend apertium-kaz with new words, we need to know their lemmas and their
categories. Below we list the possible categories of words (we ignore the
so-called closed-class words here, as their likelihood to appear among
unrecognized words at this stage is negligible, and simplify some of the
categories of open-class words purposefully).

@tabular[#:style 'boxed
         #:column-properties '(left left)
(list (list @bold{Category} @bold{Comment} @bold{Examples (from @tt{apertium-kaz.kaz.lexc} file)})
      (list @bold{Nouns} "" "")
      (list "N1" "common nouns" "алма:алма N1 ; ! “apple”")
      (list "" "" "жылқы:жылқы N1 ; ! “horse”")
      (list "N5" "nouns which are loanwords from Russian (and therefore potentially with exceptions in phonology)" "артист:артист N5 ; ! \"\"")
      (list "" "" "баррель:баррель N5 ; ! \"\"")
      (list "N6" "Linking nouns like акт, субъект, эффект to N6 forces apertium-kaz to analyse both акт and акті as noun, nominative; both актты and актіні as noun, accusative etc. The latter forms are the default — that is, акті and актіні are  generated for акт<n><nom> and акт<n><acc>, respectively, if apertium-kaz is used as a morphological generator." "")
      (list "N1-ABBR" "Abbreviated nouns" "ДНҚ:ДНҚ%{а%} N1-ABBR ; ! \"DNA\"")
      (list "" "" "млн:млн%{а%}%{з%} N1-ABBR ; ! \"million\"")
      (list "" "" "млрд:млрд%{а%}%{с%} N1-ABBR ; ! \"billion\"")
      (list "" "" "км:км%{э%}%{з%} N1-ABBR ; ! \"km\"")
      (list @bold{Verbs} "" "")
      (list "V-TV" "transitive verbs" "")
      (list "V-IV" "intransitve verbs" "")
      (list "" "If the verb can take a direct object with -НЫ, then it's not IV; otherwise it is TV" "")
      (list @bold{Proper nouns} "" "")
      (list "NP-ANT-F" "feminine anthroponyms" @italic{Сәмиға})
      (list "NP-ANT-M" "masculine anthroponyms" @italic{Чыңғыз})
      (list "NP-COG-OB" "family names ending with -ов or -ев" @italic{Мусаев})
      (list "NP-COG-IN" "family names ending with -ин" @italic{Нуруллин})
      (list "NP-COG-M" "family names not ending with -ов, -ев or -in; masculine" @italic{Галицкий})
      (list "NP-COG-F" "family names not ending with -ов, -ев or -in; feminine" @italic{Толстая})
      (list "NP-COG-MF" "family names not ending with -ов, -ев or -in which can be both masculine and feminine" @italic{Гайдар})
      (list "NP-PAT-VICH" "patronymes ending with -вич (and thus which can also take the -вна ending)" @italic{Васильевич:Василье NP-PAT-VICH ; ! \"\"})
      (list "NP-TOP" "toponyms (river names should go here too)" @italic{Берлин})
      (list "NP-ORG" "organization names" @italic{Қазпошта})
      (list "NP-ORG-LAT" "organization names written in Latin characters" @italic{Microsoft})
      (list "NP-AL" "proper names not belonging to one of the above NP-* classes" @italic{Протон-М})
      (list "A1" "adjectives which can modify both nouns (жақсы адам) and verbs (жақсы оқиды)" "")
      (list "A2" "all other adjectives" @italic{көктемгі})
      (list "ADV" "adverbs" @italic{әбден})
      (list "" "If you want to add an adverb, first think whether the word is really an adjective that can be used like an adverb. If this is the case, then add it as an A1 adjective." ""))]

Figuring the lemma of an unrecognized word should be straightforward. Except
for verbs, where the lemmas in @tt{apertium-kaz} are 2nd person singular
imperative forms such as @tt{бар}, @tt{кел}, @tt{ал} etc (i.e. not @tt{бару},
@tt{келу}, @tt{алу} as in print dictionaries), the lemmas are what you would
expect to see in print dictionaries of Kazakh.

Still, there are some things to keep in mind (we use the word ``stem'' and
``lemma'' interchangeably below):

@itemize[

@item{Many stems exhibit a voicing alternation like п/б, к/г, қ/ғ. This is
processed automatically by @tt{apertium-kaz.kaz.twol}, and such stems must be
added with the voiceless consonant (п, к, қ) to @tt{apertium-kaz.kaz.lexc}, e.g
@tt{тақ:тақ V-TV ;}}


@item{Stems from Russian that end with one of the voiced consonants (б, г),
such as геолог should be entered as spelled, but should be put in the right
category for foreign words (e.g., if a noun, then N5).}

@item{Words that have an inserted ‹ы› or ‹і› in some forms should get %{y%} in
that spot on the right side, e.g. орын:ор%{y%}н N1 ;}

@item{There should be no infinitival final -у or -ю. It is best to take the
part of the verb before -GAн or -DI in those forms.}

@item{Infinitives ending in -ю should end in ‹й› instead, e.g ‹сүю› should be
entered as сүй}

@item{Some verbs have a "hidden" ‹ы› or ‹і› under the ‹у›, for example ері,
аршы, аңды, etc. These verb stems should be added with the ‹ы› or ‹і›.}

@item{Of course, verbs with ‹у› in the stem should keep the ‹у›, like жу, қу,
жау, etc.}

@item{Do not add passive or cooperative forms of verb stems (e.g., ‹тартыл› is
passive of ‹тарт›, and ‹тартыс› is cooperative).}]
