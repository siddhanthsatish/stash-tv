sub DetailInit()
    m.backdrop = m.top.findNode("backdrop")
    m.titleLabel = m.top.findNode("titleLabel")
    m.metaLabel = m.top.findNode("metaLabel")
    m.overviewLabel = m.top.findNode("overviewLabel")
    m.streamingLabel = m.top.findNode("streamingLabel")
    m.whereLabel = m.top.findNode("whereLabel")
end sub

sub OnMovieSet()
    DetailInit()
    movie = m.top.movie
    if movie = invalid then return

    config = GetConfig()

    ' Set backdrop
    if movie.backdropPath <> invalid and movie.backdropPath <> ""
        m.backdrop.uri = "https://image.tmdb.org/t/p/w1280" + movie.backdropPath
    else if movie.backdrop_path <> invalid and movie.backdrop_path <> ""
        m.backdrop.uri = "https://image.tmdb.org/t/p/w1280" + movie.backdrop_path
    end if

    ' Set title
    title = movie.title
    if title = invalid then title = movie.name
    if title <> invalid then m.titleLabel.text = title

    ' Set meta
    year = ""
    releaseDate = movie.releaseDate
    if releaseDate = invalid then releaseDate = movie.release_date
    if releaseDate <> invalid and Len(releaseDate) >= 4
        year = Left(releaseDate, 4)
    end if
    rating = ""
    voteAverage = movie.voteAverage
    if voteAverage = invalid then voteAverage = movie.vote_average
    if voteAverage <> invalid
        rating = "⭐ " + Left(Str(voteAverage), 3)
    end if
    m.metaLabel.text = year + "  " + rating

    ' Set overview
    overview = movie.overview
    if overview <> invalid then m.overviewLabel.text = overview

    ' Get tmdbId from either field
    tmdbId = movie.tmdbId
    if tmdbId = invalid then tmdbId = movie.id
    if tmdbId <> invalid
        FetchStreamingInfo(CInt(tmdbId))
    else
        m.streamingLabel.text = "Streaming info unavailable"
    end if
end sub

sub FetchStreamingInfo(tmdbId as integer)
    m.streamingLabel.text = "Loading streaming info..."
    m.streamingTask = CreateObject("roSGNode", "StreamingTask")
    m.streamingTask.functionName = "RunStreamingTask"
    m.streamingTask.tmdbId = tmdbId
    m.streamingTask.observeField("streamingResults", "OnStreamingLoaded")
    m.streamingTask.control = "RUN"
end sub

sub OnStreamingLoaded()
    results = m.streamingTask.streamingResults
    if results = invalid or results.providers.Count() = 0
        m.streamingLabel.text = "Not available for streaming in US"
        m.whereLabel.text = "Where to Watch"
        return
    end if

    providerText = ""
    for each p in results.providers
        if providerText = ""
            providerText = p
        else
            providerText = providerText + "  •  " + p
        end if
    end for

    m.streamingLabel.text = providerText
end sub