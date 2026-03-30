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
    if movie.backdrop_path <> invalid and movie.backdrop_path <> ""
        m.backdrop.uri = "https://image.tmdb.org/t/p/w1280" + movie.backdrop_path
    end if

    ' Set title
    m.titleLabel.text = movie.title

    ' Set meta
    year = ""
    if movie.release_date <> invalid and Len(movie.release_date) >= 4
        year = Left(movie.release_date, 4)
    end if
    rating = ""
    if movie.vote_average <> invalid
        rating = "⭐ " + Left(Str(movie.vote_average), 3)
    end if
    m.metaLabel.text = year + "  " + rating

    ' Set overview
    if movie.overview <> invalid
        m.overviewLabel.text = movie.overview
    end if

    ' Fetch streaming info
    FetchStreamingInfo(movie.id)
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