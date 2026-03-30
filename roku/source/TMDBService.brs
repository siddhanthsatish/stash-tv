sub RunTMDBTask()
    print "TMDBTask: Starting..."
    movies = FetchTrendingMovies()
    print "TMDBTask: Got " + movies.Count().toStr() + " movies"
    m.top.movies = {results: movies}
    print "TMDBTask: Done"
end sub

function FetchTrendingMovies() as object
    config = GetConfig()
    url = config.tmdb_base_url + "/trending/movie/week"
    print "TMDBTask: Fetching " + url

    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.AddHeader("Authorization", "Bearer " + config.tmdb_read_access_token)
    request.AddHeader("accept", "application/json")

    response = request.GetToString()
    print "TMDBTask: Response length " + len(response).toStr()

    parsed = ParseJSON(response)

    if parsed <> invalid and parsed.results <> invalid
        return parsed.results
    end if

    print "TMDBTask: Parse failed or no results"
    return []
end function