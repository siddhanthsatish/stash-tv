sub RunStreamingTask()
    print "StreamingTask: Starting for tmdbId " + m.top.tmdbId.toStr()
    config = GetConfig()

    url = config.tmdb_base_url + "/movie/" + m.top.tmdbId.toStr() + "/watch/providers"

    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.AddHeader("Authorization", "Bearer " + config.tmdb_read_access_token)
    request.AddHeader("accept", "application/json")

    response = request.GetToString()
    parsed = ParseJSON(response)

    print "StreamingTask: Got response"

    result = {providers: [], link: ""}

    if parsed <> invalid and parsed.results <> invalid
        ' Try US region first
        usData = parsed.results["US"]
        if usData <> invalid
            if usData.link <> invalid
                result.link = usData.link
            end if
            providers = []
            if usData.flatrate <> invalid
                for each p in usData.flatrate
                    providers.Push(p.provider_name)
                end for
            end if
            if usData.rent <> invalid and providers.Count() = 0
                for each p in usData.rent
                    providers.Push(p.provider_name + " (Rent)")
                end for
            end if
            if usData.buy <> invalid and providers.Count() = 0
                for each p in usData.buy
                    providers.Push(p.provider_name + " (Buy)")
                end for
            end if
            result.providers = providers
        end if
    end if

    m.top.streamingResults = result
    print "StreamingTask: Done, found " + result.providers.Count().toStr() + " providers"
end sub