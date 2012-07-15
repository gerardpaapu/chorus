{Status, Timeline, extend, jsonp} = Chorus = @Chorus

class GithubCommit extends Status
    constructor: (id, username, avatar, date, text, raw) ->
        super id, username, avatar, date, text, raw

    getUrl: -> @getStreamUrl()

    getStreamUrl: -> "https://github.com/#{@username}"

    @from = (json) ->
        {url, commit, sha, author} = json
        {message} = commit
        {login} = author

        new GithubCommit sha, login, author.avatar_url, commit.author.date, message, json

class GithubCommits extends Timeline
    constructor: (@username, @repo, options) ->
        @queryUrl = "https://api.github.com/repos/#{@username}/#{@repo}/commits"
        super options

    fetch: -> jsonp 
        url: @queryUrl
        callback: (data) => @update data

    statusesFromData: (data) -> GithubCommit.from item for item in data.data

Timeline.shorthands.unshift
    pattern: /^GH:([a-z-_]+)\/([a-z-_]+)/i,
    fun: (_, name, project) -> new GithubCommits name, project

Timeline.shorthands.unshift
    pattern: /^GH:([^\/]+)\/([^\/]+)\/([^\/]+)/i,
    fun: (_, name, project, branch) ->
        new GithubCommits name, project, branch: branch

extend Chorus, {GithubCommit, GithubCommits}