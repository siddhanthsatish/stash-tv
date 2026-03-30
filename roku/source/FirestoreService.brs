function FetchShelf(userId as string) as object
    config = GetConfig()
    url = config.firebase_base_url + "/shelves/" + userId + "/movies?key=" + config.firebase_api_key

    print "FirestoreService: Fetching shelf for " + userId
    print "FirestoreService: URL " + url

    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.AddHeader("Content-Type", "application/json")

    response = request.GetToString()
    parsed = ParseJSON(response)

    print "FirestoreService: Got response"

    movies = []

    if parsed = invalid
        print "FirestoreService: Failed to parse response"
        return movies
    end if

    if parsed.documents = invalid
        print "FirestoreService: No documents found"
        return movies
    end if

    for each doc in parsed.documents
        fields = doc.fields
        if fields <> invalid
            movie = {}
            movie.tmdbId = Val(fields.tmdbId.integerValue)
            movie.title = fields.title.stringValue
            movie.posterPath = fields.posterPath.stringValue
            movie.backdropPath = fields.backdropPath.stringValue
            movie.overview = fields.overview.stringValue
            movie.releaseDate = fields.releaseDate.stringValue
            movie.voteAverage = 0.0
            if fields.voteAverage <> invalid
                dv = fields.voteAverage.doubleValue
                iv = fields.voteAverage.integerValue
                if dv <> invalid
                    if type(dv) = "String" or type(dv) = "roString"
                        movie.voteAverage = Val(dv)
                    else
                        movie.voteAverage = dv
                    end if
                else if iv <> invalid
                    if type(iv) = "String" or type(iv) = "roString"
                        movie.voteAverage = Val(iv)
                    else
                        movie.voteAverage = iv
                    end if
                end if
            end if
            movies.Push(movie)
        end if
    end for

    print "FirestoreService: Loaded " + movies.Count().toStr() + " movies from shelf"
    return movies
end function

sub RunFirestoreTask()
    print "FirestoreTask: Starting..."
    config = GetConfig()
    movies = FetchShelf(config.user_id)
    m.top.shelf = {movies: movies}
    print "FirestoreTask: Done"
end sub