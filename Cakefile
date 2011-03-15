{readFileSync, writeFileSync} = fs = require "fs"

coffee_files = [
    "chorus.core",
    "twitter",
    "facebook",
    "friendfeed",
    "wordpress",
    "ihackernews",
    "github",
    "buzz",
    "embedly"
]

task "compile", "compile all the coffee files to js", ->
    invoke "create-output-dir"

    try
        compile file for file in coffee_files
        compile_less "styles"
        concat "chorus.core", "twitter", "chorus.twitter"
        concat "chorus.core", "twitter", "wordpress", "chorus.wordpress"
        concat "chorus.core", "friendfeed", "chorus.friendfeed"
        concat "chorus.core", "github", "chorus.github"
        concat "chorus.core", "facebook", "chorus.facebook"
        concat "chorus.core", "buzz", "chorus.buzz"
        console.log "compilation succeeded"

    catch err
        console.log "compilation failed: #{err}"

task "create-output-dir", "creates `dist`", ->
    try
        fs.mkdirSync "dist", 0777
        console.log "Created the dist directory"

    catch err
        console.log "The dist directory already exists, but that's fine"

task "compress", "compress the javascript files", ->
    invoke "compile"

    try
        compress name for name in coffee_files
        compress "chorus.core"
        compress "chorus.github"
        compress "chorus.twitter"
        compress "chorus.facebook"
        compress "chorus.friendfeed"
        console.log "compression succeeded"

    catch err
        console.log "compression failed: #{err}"

compile = (name) ->
    coffee = require "coffee-script"
    src = fs.readFileSync "src/#{name}.coffee", "utf-8"

    try
        out = coffee.compile(src)
        fs.writeFileSync "dist/#{name}.js", out, "utf-8"
        console.log "compiled #{name}.coffee"
    catch err
        console.log "failed to compile #{name}.coffee "
        throw err

compress = (name) ->
    {parser, uglify} = require "uglify-js"

    try
        src = fs.readFileSync "dist/#{name}.js", "utf-8"
        ast = parser.parse src
        ast = uglify.ast_mangle ast  # mangle var names etc.
        ast = uglify.ast_squeeze ast # remove whitespace
        out = uglify.gen_code ast    # generate js source

        fs.writeFileSync "dist/#{name}.min.js", out, "utf-8"

        console.log "compressed #{name}.js"

    catch err
        console.log "failed to compress #{name}"
        throw err

concat = (files..., out) ->
    src = for file in files
        readFileSync "dist/#{file}.js"

    writeFileSync "dist/#{out}.js", src.join("\n")

compile_less = (name) ->
    less = require "less"
    src = readFileSync "src/#{name}.less", "utf-8"

    less.render src, (errs, css) ->
        if errs
            console.log "error compiling #{name}.less:\n #{errs}"
        else
            writeFileSync "dist/#{name}.css", css
            console.log "compile #{name}.less"
