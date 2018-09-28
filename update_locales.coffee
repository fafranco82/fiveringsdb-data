#merge data files from default English with each locale found in translations directory

fs = require 'fs'
path = require 'path'
_ = require 'lodash'

[bin, script, locale] = process.argv

i18nDir = path.join __dirname, 'translations', 'json'


stripProps = (json, props) ->
    _.map json, (item) ->
        _.pick item, props

loadCards = (root) ->
    result = {}
    localeRoot = path.join root, 'Card'
    try
        fs.mkdirSync(localeRoot)
    files = fs.readdirSync localeRoot
    for file in files
        json = JSON.parse fs.readFileSync(path.join(localeRoot, file), 'UTF-8')
        result[file] = stripProps json, ['id','name','text']
    result

merge_data = (defaultLocale, locale) ->
    result = {}
    for file in _.union(_.keys(defaultLocale), _.keys(locale))
        result[file] = _(_.merge({}, _.keyBy(defaultLocale[file] or {}, 'id'), _.keyBy(locale[file] or {}, 'id'))).values().sortBy('id').value()
    result


cards_en = loadCards path.join __dirname, 'json'

codes = fs.readdirSync i18nDir
for code in codes when not locale? or code is locale
    console.log "Updating locale '#{code}'..."
    localeRoot = path.join i18nDir, code

    l_cards = loadCards localeRoot

    m_cards = merge_data(cards_en, l_cards)

    for file in _.keys m_cards
        target = path.join localeRoot, 'Card', file
        if !_.isEqual(l_cards[file], m_cards[file])
            fs.writeFileSync target, JSON.stringify(m_cards[file], null, 4)+"\n"
            console.log "Written #{target}"
