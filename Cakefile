fs = require "fs"

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
    {parser, uglify} = require "uglify"

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

task "compile", "compile all the coffee files to js", ->
    invoke "create-output-dir"
    try
        compile "subscriber"
        compile "status"
        compile "timeline"
        compile "twitter"
        compile "facebook"
        compile "friendfeed"
        compile "wordpress"
        compile "github"
        console.log "compilation succeeded"
    catch err
        console.log "compilation failed: #{err}"

task "create-output-dir", "creates `dist`", () ->
    try
        fs.mkdirSync "dist", 0777
        console.log "Created the dist directory"
    catch err
        console.log "The dist directory already exists, but that's fine"

task "compress", "", ->
    invoke "compile"
    try
        compress "subscriber"
        compress "status"
        compress "timeline"
        compress "twitter"
        compress "facebook"
        compress "friendfeed"
        compress "wordpress"
        compress "github"
        console.log "compression succeeded"

    catch err
        console.log "compression failed: #{err}"
