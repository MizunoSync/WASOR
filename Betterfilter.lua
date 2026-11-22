-- BETTER FILTER FOR CHATHUB.


--[[
    UniversalModeration.lua
    Roblox Luau | Multilingual moderation keyword filter

    Usage:
        local Filter = require(path.To.UniversalModeration)
        local blocked, matched = Filter.IsBlocked(message)

    NOTE:
        Supplemental keyword filter only.
        Use Roblox TextService for official chat filtering.
        Review matches before issuing account-level punishments.
]]

local Filter = {}

local FilterWords = {
    -- PORTUGUESE: RACIAL / ETHNIC HARASSMENT
    "preto imundo", "preto fedorento", "negro imundo",
    "filho de macaco", "volta pra senzala", "volte pra senzala",
    "macaco imundo", "macaco sujo", "negro sujo",
    "preto sujo", "raça inferior", "volta para a africa",
    "crioulo", "crioula", "crioulos", "macaco", "macacos",
    "macaca", "macacas",

    -- PORTUGUESE: PROFANITY
    "filho da puta", "filha da puta", "filhos da puta",
    "filhas da puta", "filhodaputa", "filhadaputa",
    "vai tomar no seu cu", "vai tomar no cu",
    "tomar no seu cu", "tomar no cu", "vai se foder",
    "vai se fuder", "vai pro inferno", "puta que pariu",
    "vai pra puta que pariu", "arrombado", "arrombada",
    "arrombados", "arrombadas", "desgraçado", "desgracado",
    "desgraçada", "desgracada", "vagabundo", "vagabunda",
    "vagabundos", "vagabundas", "vadia", "vadias",
    "piranha", "piranhas", "buceta", "bucetas", "boceta",
    "bocetas", "caralho", "caralhos", "cacete", "porra",
    "merda", "merdas", "bosta", "bostas", "cuzão", "cuzao",
    "pau no cu", "foda-se", "fodase", "fudido", "fudida",
    "putaria", "corno", "corna", "babaca", "otário", "otario",
    "imbecil", "escroto", "escrota", "nojento", "nojenta",
    "fdp", "vtnc", "vsf", "tmnc", "tnc", "pqp", "krl", "crl",

    -- PORTUGUESE: HOMOPHOBIC / TRANSPHOBIC SLURS
    "viadinho", "viadão", "viadao", "viado", "traveco",
    "boiola", "bicha", "bichinha", "baitola", "maricas",
    "sapatão", "sapatao",

    -- PORTUGUESE: DISABILITY-RELATED INSULTS
    "retardado", "retardada", "retardados", "retardadas",
    "mongoloide", "débil mental", "debil mental",
    "aleijado", "aleijada",

    -- ENGLISH: RACIAL / ETHNIC SLURS
    "nigger", "niggers", "nigga", "niggas",
    "n1gger", "n1gga", "ni99er", "ni99a",
    "chink", "gook", "kike", "wetback", "spic",
    "raghead", "towelhead", "cracker", "coon",
    "darkie", "darky", "sambo", "beaner", "honky",

    -- ENGLISH: HOMOPHOBIC / TRANSPHOBIC SLURS
    "faggot", "faggots", "fag", "fags", "dyke",
    "tranny", "shemale", "homo trash",

    -- ENGLISH: PROFANITY / HARASSMENT
    "motherfucker", "motherfuckers", "mother fucker",
    "fuck", "fucks", "fucked", "fucking", "fucker",
    "fuckers", "fuck off", "fuck you", "fuck u",
    "f u", "fuk", "fuking", "phuck", "shit", "shits",
    "shitty", "bullshit", "horseshit", "shithead",
    "dipshit", "shitface", "asshole", "assholes",
    "arsehole", "bitch", "bitches", "bitchy",
    "son of a bitch", "bastard", "bastards", "dickhead",
    "dickwad", "dickweed", "dickface", "dumbass",
    "jackass", "smartass", "dumb fuck", "dumbfuck",
    "cunt", "cunts", "twat", "wanker", "bellend",
    "prick", "piss off", "stfu", "gtfo",

    -- ENGLISH: SEXUAL INSULTS
    "cockhead", "cock sucker", "cocksucker",
    "dick sucker", "dicksucker", "cumdump", "cumslut",
    "slut", "sluts", "whore", "whores", "skank",
    "hoes", "thots",

    -- SPANISH
    "hijo de puta", "hija de puta", "hijos de puta",
    "hijas de puta", "chinga tu madre", "chingatumadre",
    "vete a la mierda", "vete al carajo",
    "vete a la chingada", "conchetumare", "conchesumadre",
    "concha tu madre", "puta madre", "puto", "puta",
    "putos", "putas", "joder", "jodete", "jodido",
    "coño", "cabrón", "cabron", "cabrona", "gilipollas",
    "maricón", "maricon", "pendejo", "pendeja",
    "culero", "culera", "mierda", "verga", "chingada",
    "chingado", "malparido", "malparida", "gonorrea",
    "hdp", "ctm", "qliao",

    -- FRENCH
    "putain", "putain de merde", "bordel", "connard",
    "connasse", "enculé", "encule", "enculée", "enculee",
    "salaud", "salopard", "salope", "ta gueule",
    "nique ta mère", "nique ta mere", "ntm", "fdp",
    "fils de pute", "fille de pute", "merde", "tapette",
    "gouine", "bâtard", "batard",

    -- GERMAN
    "scheiße", "scheisse", "scheiss", "fick dich",
    "ficken", "gefickt", "wichser", "arschloch",
    "arschlöcher", "arschloecher", "hurensohn",
    "hurentochter", "fotze", "schlampe", "hure",
    "schwuchtel", "kanake", "spast", "vollidiot",
    "missgeburt", "verpiss dich", "halt die fresse",
    "heil hitler",

    -- ITALIAN
    "vaffanculo", "fanculo", "figlio di puttana",
    "figlia di puttana", "pezzo di merda", "stronzo",
    "stronza", "stronzi", "bastardo", "bastarda",
    "coglione", "coglioni", "minchione", "troia",
    "puttana", "puttane", "frocio", "ricchione", "finocchio",

    -- DUTCH
    "kankerhoer", "kankerlijer", "kanker", "teringlijer",
    "godverdomme", "klootzak", "lul", "eikel", "kut",
    "hoer", "flikker", "tyfuslijer",

    -- POLISH
    "kurwa", "kurwy", "chuj", "cipa", "pizda", "jebac",
    "jebać", "jebany", "jebana", "spierdalaj",
    "wypierdalaj", "skurwysyn", "sukinsyn", "pedał",
    "ciota", "debil", "pojeb",

    -- RUSSIAN TRANSLITERATION
    "blyat", "blyad", "blyadi", "suka", "suki",
    "sukin syn", "mudak", "pidor", "pizda", "khuy",
    "hui", "ebat", "yebat", "eblan", "dolboeb",
    "zalupa", "shlyukha", "govno", "gandon", "ublyudok",

    -- TURKISH
    "orospu", "orospu cocugu", "orospu çocuğu",
    "siktir", "sikik", "amk", "amina koyim",
    "amına koyayım", "piç", "ibne", "göt", "got",
    "yarrak", "kahpe", "pezevenk", "şerefsiz",
    "serefsiz", "gerizekalı", "gerizekali",

    -- ARABIC TRANSLITERATION
    "sharmouta", "sharmuta", "ibn el kalb",
    "ibn al kalb", "khawal", "ahbal", "kuss ummak",

    -- HINDI / URDU TRANSLITERATION
    "bhenchod", "behenchod", "madarchod", "chutiya",
    "chutiye", "gaand", "gandu", "randi", "harami",
    "haramzada", "bhosdike", "bhosdiwala", "lavde",

    -- CHINESE
    "cao ni ma", "cao nima", "sha bi", "shabi",
    "ni ma de", "wang ba dan", "傻逼", "操你妈",
    "他妈的", "狗屎", "王八蛋",

    -- JAPANESE
    "死ね", "しね", "くたばれ", "くそ", "クソ",
    "ばか", "バカ", "あほ", "アホ", "きもい",
    "きしょい", "ちんかす", "くそったれ", "ふざけんな",

    -- KOREAN
    "씨발", "시발", "씨팔", "병신", "개새끼",
    "새끼", "좆", "지랄", "닥쳐", "꺼져", "엿먹어",

    -- INDONESIAN / MALAY
    "kontol", "memek", "bangsat", "anjing", "babi",
    "asu", "jancok", "ngentot", "brengsek", "kampret",
    "keparat", "pukimak",

    -- FILIPINO / TAGALOG
    "putang ina", "putangina", "tangina", "gago",
    "gaga", "ulol", "tarantado", "leche", "punyeta",
    "inutil", "hayop ka",

    -- GREEK
    "malaka", "malakas", "skata", "poustis",
    "gamoto", "gamise", "katharma",

    -- ROMANIAN
    "muie", "futu-ti", "fututi", "pizda", "cacat",
    "tampit", "curve",

    -- NORDIC LANGUAGES
    "hora", "fitta", "kuk", "jævla", "jaevla",
    "helvete", "faen", "fitte", "röv", "rov",
    "skithuvud", "røvhul",

    -- ADULT CONTENT / PORNOGRAPHY
    "porn", "porno", "p0rn", "pr0n", "pornography",
    "pornographic", "pornhub", "hentai", "rule34",
    "rule 34", "nsfw", "not safe for work",
    "adult content", "adult website", "x-rated",
    "explicit content", "sexual content", "nude",
    "nudes", "naked", "nudity", "lewd", "erotic",
    "erotica", "onlyfans", "only fans", "camgirl",
    "sex tape", "porn site", "porn link", "free porn",
    "watch porn", "send nudes", "send me nudes",

    -- ADULT IMAGE SITES
    "e621", "e926", "danbooru", "gelbooru",
    "rule34.xxx", "rule34.paheal", "realbooru",
    "safebooru", "konachan", "yande.re",
    "adult booru", "explicit booru",

    -- SEXUAL ACTIVITY / SOLICITATION
    "blowjob", "blow job", "handjob", "hand job",
    "footjob", "foot job", "deepthroat", "deep throat",
    "cum", "cumming", "cumshot", "semen",
    "ejaculate", "ejaculation", "masturbate",
    "masturbation", "orgasm", "fetish", "bdsm",
    "sex toy", "sexual services", "escort service",
    "hookup", "hook up", "send explicit pictures",

    -- CHILD SAFETY / EXPLOITATION
    "children", "child", "minor", "minors", "underage",
    "under age", "under 18", "under eighteen",
    "child exploitation", "child abuse",
    "child sexual abuse", "child pornography",
    "child porn", "csam", "grooming", "online grooming",
    "sexual predator", "pedophile", "pedophilia",
    "paedophile", "paedophilia", "sexualizing minors",
    "minor nudes", "underage nudes", "jailbait",
    "loli", "lolicon", "shota", "shotacon",

    -- URL SCHEMES / GENERAL LINKS
    "http://", "https://", "http:", "https:",
    "hxxp://", "hxxps://", "ttps://",
    "www.", "://", "tor://",

    -- DOMAIN EXTENSIONS
    ".com", ".net", ".org", ".io", ".gg", ".co",
    ".me", ".biz", ".info", ".xyz", ".top", ".site",
    ".online", ".live", ".link", ".click", ".icu",
    ".shop", ".store", ".app", ".dev", ".cloud",
    ".website", ".pro", ".vip", ".lol", ".fun",
    ".pw", ".tk", ".ml", ".ga", ".cf", ".gq",
    ".ru", ".su", ".cn", ".to", ".cc", ".ws",
    ".bz", ".in", ".uk", ".de", ".fr", ".br",
    ".jp", ".kr", ".onion", ".com.br", ".net.br",
    ".org.br", ".gov.br", ".edu.br", ".co.uk",
    ".org.uk", ".ac.uk", ".com.au", ".co.jp", ".co.in",

    -- URL SHORTENERS
    "bit.ly", "tinyurl.com", "t.co", "goo.gl",
    "ow.ly", "is.gd", "cutt.ly", "rb.gy",
    "shorturl.at", "tiny.cc", "buff.ly", "rebrand.ly",
    "short.io", "lnkd.in", "soo.gd", "s.id", "v.gd",
    "clck.ru",

    -- URL OBFUSCATION
    "hxxp", "hxxps", "dot com", "dotcom",
    "dot onion", "dotonion", "[.]com", "[.]net",
    "[.]org", "[.]onion", "(.)com", "(.)onion",
    "com slash", "onion slash", "https colon",
    "http colon", "www dot", "www[.]",
    "\\.com", "\\.onion",

    -- LINK SHARING / SUSPICIOUS SOLICITATION
    "visit my website", "check my website",
    "join my server", "link in bio", "click this link",
    "click here", "free robux link", "free nitro link",
    "download here", "download now", "porn link",
    "nsfw link", "adult link", "uncensored link",
    "leaked nudes", "leaked pictures", "private pictures",
    "click for nudes", "free adult content",
    "join my nsfw server", "nsfw discord",
    "adult discord server", "telegram porn",
    "discord porn", "download porn", "watch hentai",
    "free hentai", "free onlyfans", "leaked onlyfans",

    -- HATE / THREATS
    "kill yourself", "kys", "go die",
    "nobody likes you", "you are worthless",
    "you are trash", "you are disgusting",
    "go back to where you came from",
    "i hate your race", "white power", "race traitor",
    "gas the jews", "heil hitler",
}

local AccentMap = {
    ["á"]="a", ["à"]="a", ["â"]="a", ["ã"]="a",
    ["ä"]="a", ["å"]="a", ["ā"]="a", ["ă"]="a",
    ["æ"]="ae", ["ç"]="c", ["ć"]="c", ["č"]="c",
    ["ď"]="d", ["é"]="e", ["è"]="e", ["ê"]="e",
    ["ë"]="e", ["ē"]="e", ["ė"]="e", ["ę"]="e",
    ["í"]="i", ["ì"]="i", ["î"]="i", ["ï"]="i",
    ["ī"]="i", ["į"]="i", ["ñ"]="n", ["ń"]="n",
    ["ó"]="o", ["ò"]="o", ["ô"]="o", ["õ"]="o",
    ["ö"]="o", ["ø"]="o", ["ō"]="o", ["ú"]="u",
    ["ù"]="u", ["û"]="u", ["ü"]="u", ["ū"]="u",
    ["ý"]="y", ["ÿ"]="y", ["š"]="s", ["ş"]="s",
    ["ś"]="s", ["ž"]="z", ["ź"]="z", ["ż"]="z",
    ["ł"]="l", ["đ"]="d", ["ð"]="d", ["þ"]="th",
    ["ß"]="ss",
}

local ConfusableMap = {
    ["а"]="a", ["е"]="e", ["о"]="o", ["р"]="p",
    ["с"]="c", ["х"]="x", ["у"]="y", ["і"]="i",
    ["ј"]="j", ["к"]="k", ["м"]="m", ["т"]="t",
    ["в"]="b", ["н"]="h",
    ["α"]="a", ["ο"]="o", ["ρ"]="p",
    ["ι"]="i", ["κ"]="k", ["τ"]="t",
}

local function replaceMap(text, map)
    for source, replacement in pairs(map) do
        text = text:gsub(source, replacement)
    end
    return text
end

local function normalize(text)
    text = string.lower(text)
    text = replaceMap(text, AccentMap)
    text = replaceMap(text, ConfusableMap)

    local invisible = {
        "\226\128\139", -- Zero-width space
        "\226\128\140", -- Zero-width non-joiner
        "\226\128\141", -- Zero-width joiner
        "\226\129\160", -- Word joiner
        "\239\187\191", -- BOM
    }

    for _, char in ipairs(invisible) do
        text = text:gsub(char, "")
    end

    -- Common leetspeak substitutions
    text = text:gsub("0", "o")
    text = text:gsub("1", "i")
    text = text:gsub("3", "e")
    text = text:gsub("4", "a")
    text = text:gsub("5", "s")
    text = text:gsub("7", "t")
    text = text:gsub("@", "a")
    text = text:gsub("%$", "s")

    -- Replace punctuation with spaces
    text = text:gsub("[%p%c]", " ")
    text = text:gsub("%s+", " ")
    text = text:match("^%s*(.-)%s*$") or text

    return text
end

local function compact(text)
    return text:gsub("%s+", "")
end

local NormalizedWords = {}
local CompactPhrases = {}

for _, word in ipairs(FilterWords) do
    local normalized = normalize(word)

    if normalized ~= "" then
        NormalizedWords[normalized] = true

        local compactWord = compact(normalized)
        if #compactWord >= 5 then
            CompactPhrases[compactWord] = true
        end
    end
end

function Filter.Normalize(text)
    return normalize(tostring(text or ""))
end

function Filter.IsBlocked(message)
    if type(message) ~= "string" then
        return false, nil
    end

    local normalized = normalize(message)
    local padded = " " .. normalized .. " "

    for word in pairs(NormalizedWords) do
        -- Exact word / phrase matching
        if padded:find(" " .. word .. " ", 1, true) then
            return true, word
        end

        -- URL tokens and distinctive phrases can occur
        -- within longer messages.
        if word:find("%.", 1, true)
            or word:find("://", 1, true)
            or word:find(" ", 1, true) then

            if normalized:find(word, 1, true) then
                return true, word
            end
        end
    end

    -- Detect selected terms with inserted spaces.
    local joined = compact(normalized)

    for phrase in pairs(CompactPhrases) do
        if joined:find(phrase, 1, true) then
            return true, phrase
        end
    end

    return false, nil
end

Filter.FilterWords = FilterWords


local SortedFilterWords = {}
for _, w in ipairs(FilterWords) do
    table.insert(SortedFilterWords, string.lower(w))
end
table.sort(SortedFilterWords, function(a, b)
    return #a > #b
end)

local function isAlphaNumericByte(b)
    if not b then return false end
    -- '0'-'9': 48-57, 'A'-'Z': 65-90, '_': 95, 'a'-'z': 97-122
    return (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b == 95) or (b >= 97 and b <= 122)
end

local function normalizeForCensor(text)
    local low = string.lower(text)
    low = low:gsub("0", "o"):gsub("1", "i"):gsub("3", "e"):gsub("4", "a"):gsub("5", "s"):gsub("7", "t"):gsub("@", "a"):gsub("%$", "s")
    return low
end

function Filter.Censor(text)
    if not text or type(text) ~= "string" then return "" end
    local filtered = text
    local norm = normalizeForCensor(filtered)

    for _, word in ipairs(SortedFilterWords) do
        local wLen = #word
        if wLen >= 2 then
            local isPhrase = string.find(word, "%W") ~= nil
            local startIdx = 1
            local safety = 0

            while startIdx <= #norm and safety < 30 do
                safety = safety + 1
                local sIdx, eIdx = string.find(norm, word, startIdx, true)
                if not sIdx then break end

                local validMatch = true
                if not isPhrase then
                    local byteBefore = sIdx > 1 and string.byte(norm, sIdx - 1) or nil
                    local byteAfter = eIdx < #norm and string.byte(norm, eIdx + 1) or nil
                    if isAlphaNumericByte(byteBefore) or isAlphaNumericByte(byteAfter) then
                        validMatch = false
                    end
                end

                if validMatch then
                    local stars = string.rep("*", wLen)
                    filtered = string.sub(filtered, 1, sIdx - 1) .. stars .. string.sub(filtered, eIdx + 1)
                    norm = normalizeForCensor(filtered)
                    startIdx = sIdx + wLen
                else
                    startIdx = sIdx + 1
                end
            end
        end
    end

    return filtered
end

Filter.FilterText = Filter.Censor
_G.BetterFilter = Filter

return Filter