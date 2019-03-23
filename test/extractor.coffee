suite 'Extractor', ->
  extractor = require("../src/extractor")
  cheerio = require("cheerio")

  test 'exists', ->
    ok extractor

  test 'returns a blank title', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    title = extractor.title(doc)
    eq title, ""

  test 'returns a simple title', ->
    doc = cheerio.load("<html><head><title>Hello!</title></head></html>")
    title = extractor.title(doc)
    eq title, "Hello!"

  test 'returns a simple title chunk', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns a soft title chunk without truncation', ->
      doc = cheerio.load("<html><head><title>University Budgets: Where Your Fees Go | Top Universities</title></head></html>")
      title = extractor.softTitle(doc)
      eq title, "University Budgets: Where Your Fees Go"

  test 'prefers the meta tag title', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"Open graph title\"></head></html>")
    title = extractor.title(doc)
    eq title, "Open graph title"

  test 'falls back to title if empty meta tag', ->
    doc = cheerio.load("<html><head><title>This is my page - mysite</title><meta property=\"og:title\" content=\"\"></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns another simple title chunk', ->
    doc = cheerio.load("<html><head><title>coolsite.com: This is my page</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns a title chunk without &#65533;', ->
    doc = cheerio.load("<html><head><title>coolsite.com: &#65533; This&#65533; is my page</title></head></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'returns the first title;', ->
    doc = cheerio.load("<html><head><title>This is my page</title></head><svg xmlns=\"http://www.w3.org/2000/svg\"><title>svg title</title></svg></html>")
    title = extractor.title(doc)
    eq title, "This is my page"

  test 'handles missing favicons', ->
    doc = cheerio.load("<html><head><title></title></head></html>")
    favicon = extractor.favicon(doc)
    eq undefined, favicon

  test 'returns the article published meta date', ->
    doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>")
    date = extractor.date(doc)
    eq date, "2014-10-15T00:01:03+00:00"

  test 'doesnt take date from tag with update', ->
    doc = cheerio.load("<html><head><title></title></head><body><time datetime=\"2014-10-15T00:01:03+00:00\">text</time><p class=\"last-update\">bad text</p></body></html>")
    date = extractor.date(doc)
    eq date, "2014-10-15T00:01:03+00:00"

  test 'returns the article dublin core meta date', ->
      doc = cheerio.load("<html><head><meta name=\"DC.date.issued\" content=\"2014-10-15T00:01:03+00:00\" /></head></html>")
      date = extractor.date(doc)
      eq date, "2014-10-15T00:01:03+00:00"

  test 'returns the date in the <time> element', ->
    doc = cheerio.load("<html><head></head><body><time>24 May, 2010</time></body></html>")
    date = extractor.date(doc)
    eq date, "24 May, 2010"

  test 'returns the date in the div.submitted element', ->
    doc = cheerio.load("<html><head></head><body><div class=\"submitted\">24 May, 2010</div></body></html>")
    date = extractor.date(doc)
    eq date, "24 May, 2010"

  test 'returns the date in the span.*Date element', ->
    doc = cheerio.load("<html><head></head><body><span class=\"publishDate\" data-date=\"06.10.2017 15:57\">06.10.2017 15:57</span></body></html>")
    date = extractor.date(doc)
    eq date, "06.10.2017 15:57"

  test 'returns the date in the div.fl-right element in div.article-meta-data parent', ->
    doc = cheerio.load("<html><head></head><body><div class=\"article-meta-data\"><div class=\"fl-right\">24 May, 2010</div></div></body></html>")
    date = extractor.date(doc)
    eq date, "24 May, 2010"

  test 'returns the date in the <time> element datetime attribute', ->
    doc = cheerio.load("<html><head></head><body><time datetime=\"2010-05-24T13:47:52+0000\">24 May, 2010</time></body></html>")
    date = extractor.date(doc)
    eq date, "2010-05-24T13:47:52+0000"

  test 'retunrs the date in <time> element with highest precedence', ->
    doc = cheerio.load('<html><head></head><body><div class="header-date" id="header-day"><span class="day" id="header-date-day"></span><span class="date" id="header-date-date"></span><a class="reader-link" href="xxx" title="Dzisiejsze wydanie"><span class="reader-link-text" id="header-reader-link">Dzisiejsze wydanie papierowe</span></a></div><div class="art-author-meta-container"><time id="art-datetime" class="art-datetime" datetime="2019-03-08">8 marca 2019 | 14:06</time></div></body></html>')
    date = extractor.date(doc)
    eq date, "2019-03-08"

  test 'returns the date in span#article_disp_date', ->
    doc = cheerio.load('<html><head></head><body><small class="article-date grey-light"><span id="article_disp_date">2018-11-30</span><a href="#comments">Komentarze:</a></span></small></body></html>')
    date = extractor.date(doc)
    eq date, "2018-11-30"

  test 'returns nothing if date eq "null"', ->
    doc = cheerio.load("<html><head><meta property=\"article:published_time\" content=\"null\" /></head></html>")
    date = extractor.date(doc)
    eq date, null

  test 'returns date in class news_date', ->
    doc = cheerio.load('<html><head></head><body><div id="Div2" class="vx_text intro"><p>20 marca 2019</p></div></body></html>')
    date = extractor.date(doc)
    eq date, '20 marca 2019'

  test 'returns date with magic', ->
    doc = cheerio.load('<html><head></head><body><h1 class="ui header" style="font-size:2rem"><div class="content">Konsekwencje Brexitu w wariancie No Deal<div class="sub header">Utworzona: 2019-01-28</div></div></h1></body></html>')
    date = extractor.date(doc)
    eq date, 'Utworzona: 2019-01-28'

  test 'returns date with magic 2', ->
    doc = cheerio.load('<html><head></head><body><div id="sobiItemDetailInfo"><b>Buskerud, Lierskogen</b>&nbsp; | &nbsp;21-02-2019 15:16 &nbsp; | &nbsp;Numer ogłoszenia: 87856</div></body></html>')
    date = extractor.date(doc)
    eq date, '| 21-02-2019 15:16 | Numer ogłoszenia: 87856'

  test 'returns date with magic 3', ->
    doc = cheerio.load('<html><head></head><body><div class="wiadSzczegol"><p><span>| </span>inf. pras.  <span class="kropka">⚫</span> źródło: Budimex <span class="kropka">⚫</span> 01.02.2019 <span class="kropka">⚫</span> <span class="kom"><a href="https://www.rynekinfrastruktury.pl/wiadomosci/drogi/kolejny-odcinek-obwodnicy-olsztyna-oddany-budimex-znow-przed-terminem--65875.html#disqus_thread" data-disqus-identifier="65875">skomentowano 3 razy</a> </span><span>▶</span> </p></div></body></html>')
    date = extractor.date(doc)
    eq date, '| inf. pras. ⚫ źródło: Budimex ⚫ 01.02.2019 ⚫ skomentowano 3 razy ▶'

  test 'returns the copyright line element', ->
    doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul><li class='copyright'><!-- // some garbage -->© 2016 The World Bank Group, All Rights Reserved.</li></ul></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, "2016 The World Bank Group"

  test 'returns the copyright found in the text', ->
    doc = cheerio.load("<html><head></head><body><div>Some stuff</div><ul>© 2016 The World Bank Group, All Rights Reserved\nSome garbage following</li></ul></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, "2016 The World Bank Group"

  test 'returns nothing if no copyright in the text', ->
    doc = cheerio.load("<html><head></head><body></body></html>")
    copyright = extractor.copyright(doc)
    eq copyright, null

  test 'returns the article published meta author', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Joe Bloggs"])

  test 'returns the meta author', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"Sarah Smith\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Sarah Smith", "Joe Bloggs"])

  test 'returns the named author in the text as fallback', ->
      doc = cheerio.load("<html><head></head><body><span class=\"author\"><a href=\"/author/gary-trust-6318\" class=\"article__author-link\">Gary Trust</a></span></body></html>")
      author = extractor.author(doc)
      eq JSON.stringify(author), JSON.stringify(["Gary Trust"])

  test 'returns the meta author but ignore "null" value', ->
    doc = cheerio.load("<html><head><meta property=\"article:author\" content=\"null\" /><meta name=\"author\" content=\"Joe Bloggs\" /></head></html>")
    author = extractor.author(doc)
    eq JSON.stringify(author), JSON.stringify(["Joe Bloggs"])

  test 'returns the meta publisher', ->
    doc = cheerio.load("<html><head><meta property=\"og:site_name\" content=\"Polygon\" /><meta name=\"author\" content=\"Griffin McElroy\" /></head></html>")
    publisher = extractor.publisher(doc)
    eq publisher, "Polygon"

  test 'returns nothing if publisher eq "null"', ->
    doc = cheerio.load("<html><head><meta property=\"og:site_name\" content=\"null\" /></head></html>")
    publisher = extractor.publisher(doc)
    eq publisher, null

  test 'returns nothing if image eq "null"', ->
    doc = cheerio.load("<html><head><meta property=\"og:image\" content=\"null\" /></head></html>")
    image = extractor.image(doc)
    eq image, null

  test 'returns logo if image not found 1', ->
    doc = cheerio.load('<html><head></head><body><h1 class="logotyp columns small-4 medium-4"><a href="https://gazetawroclawska.pl" data-gtm="naglowek/Gazeta-Wrocławska"><img src="https://s-pt.ppstatic.pl/g/logo_naglowek/gazetawroclawska.svg?6523594" alt="Gazeta Wrocławska"></a></h1></body></html>')
    image = extractor.image(doc)
    eq image, 'https://s-pt.ppstatic.pl/g/logo_naglowek/gazetawroclawska.svg?6523594'

  test 'returns logo if image not found 2', ->
    doc = cheerio.load('<html><head></head><body><div class="imgw"><a id="LinkArea:winieta" href="http://wyborcza.pl/0,0.html" title="Wyborcza.pl"><img src="http://static.im-g.pl/i/obrazki/wyborcza2017/winiety_themes/logo_wyborcza_play.svg" data-fallback="//bi.im-g.pl/im/7/22716/m22716587.png" alt="Wyborcza.pl"></a></div></body></html>')
    image = extractor.image(doc)
    eq image, 'http://static.im-g.pl/i/obrazki/wyborcza2017/winiety_themes/logo_wyborcza_play.svg'

  test 'returns image from meta', ->
    doc = cheerio.load("<!doctype html ><!--[if IE 8]> <html class=\"ie8\" lang=\"en\"> <![endif]--><!--[if IE 9]> <html class=\"ie9\" lang=\"en\"> <![endif]--><!--[if gt IE 8]><!--> <html lang=\"bg-BG\" prefix=\"og: http://ogp.me/ns#\"> <!--<![endif]--><head> <title>Спипаха шофьор без книжка - Козлодуй - новини</title> <meta charset=\"UTF-8\" /> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"> <link rel=\"pingback\" href=\"https://kozloduy-bg.info/xmlrpc.php\" /> <meta property=\"og:image\" content=\"https://kozloduy-bg.info/wp-content/uploads/2018/04/SPO.jpg\" /><link rel=\"icon\" type=\"image/png\" href=\"https://kozloduy-bg.info/wp-content/uploads/2017/05/fav.ico\"><!-- This site is optimized with the Yoast SEO plugin v7.6.1 - https://yoast.com/wordpress/plugins/seo/ --><link rel=\"canonical\" href=\"https://kozloduy-bg.info/90358/spipaha-shofor-bez-knizhka-2/\" /><meta property=\"og:locale\" content=\"bg_BG\" /><meta property=\"og:type\" content=\"article\" /><meta property=\"og:title\" content=\"Спипаха шофьор без книжка - Козлодуй - новини\" /><meta property=\"og:description\" content=\"По време на специализирана операция на територията на РУ-Козлодуй на 11 февруари, в 18.15 часа на улица в града е спрян за проверка лек автомобил „Опел“. Колата е била управлявана от 28-годишен жител на Козлодуй, за който е установено, че е неправоспособен водач. Регистрационните табели на колата са свалени.\" /><meta property=\"og:url\" content=\"https://kozloduy-bg.info/90358/spipaha-shofor-bez-knizhka-2/\" /><meta property=\"og:site_name\" content=\"Козлодуй - новини\" /><meta property=\"article:section\" content=\"112\" /><meta property=\"article:published_time\" content=\"2019-02-12T07:41:40+02:00\" /><meta property=\"article:modified_time\" content=\"2019-02-12T09:43:55+02:00\" /><meta property=\"og:updated_time\" content=\"2019-02-12T09:43:55+02:00\" /><meta property=\"og:image\" content=\"https://kozloduy-bg.info/wp-content/uploads/2018/04/SPO-1024x683.jpg\" /><meta property=\"og:image:secure_url\" content=\"https://kozloduy-bg.info/wp-content/uploads/2018/04/SPO-1024x683.jpg\" /><meta property=\"og:image:width\" content=\"1024\" /><meta property=\"og:image:height\" content=\"683\" /><meta name=\"twitter:card\" content=\"summary\" /><meta name=\"twitter:description\" content=\"По време на специализирана операция на територията на РУ-Козлодуй на 11 февруари, в 18.15 часа на улица в града е спрян за проверка лек автомобил „Опел“. Колата е била управлявана от 28-годишен жител на Козлодуй, за който е установено, че е неправоспособен водач. Регистрационните табели на колата са свалени.\" /><meta name=\"twitter:title\" content=\"Спипаха шофьор без книжка - Козлодуй - новини\" /><meta name=\"twitter:image\" content=\"https://kozloduy-bg.info/wp-content/uploads/2018/04/SPO.jpg\" /><!-- / Yoast SEO plugin. --><link rel='dns-prefetch' href='//fonts.googleapis.com' /><link rel='dns-prefetch' href='//s.w.org' /><link rel=\"alternate\" type=\"application/rss+xml\" title=\"Козлодуй - новини &raquo; Хранилка\" href=\"https://kozloduy-bg.info/feed/\" /><link rel=\"alternate\" type=\"application/rss+xml\" title=\"Козлодуй - новини &raquo; Хранилка за коментари\" href=\"https://kozloduy-bg.info/comments/feed/\" /></head><body>Test</body></html>")
    image = extractor.image(doc)
    eq image, 'https://kozloduy-bg.info/wp-content/uploads/2018/04/SPO.jpg'
