function FetchTrendingMovies() as object
    config = GetConfig()
    url = config.tmdb_base_url + "/trending/movie/week"

    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.AddHeader("Authorization", "Bearer " + config.tmdb_read_access_token)
    request.AddHeader("accept", "application/json")

    response = request.GetToString()
    parsed = ParseJSON(response)

    if parsed <> invalid and parsed.results <> invalid
        return parsed.results
    end if

    return []
end function