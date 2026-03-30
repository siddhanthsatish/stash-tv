sub Init()
    m.movieGrid = m.top.findNode("movieGrid")
    m.focusedTitle = m.top.findNode("focusedTitle")
    m.subLabel = m.top.findNode("subLabel")
    m.subLabel.text = "Loading..."

    m.task = CreateObject("roSGNode", "TMDBTask")
    m.task.functionName = "RunTask"
    m.task.observeField("movies", "OnMoviesLoaded")
    m.task.control = "RUN"
end sub

sub OnMoviesLoaded()
    print "ShelfScene: OnMoviesLoaded fired"
    movies = m.task.movies
    if movies <> invalid and movies.results <> invalid and movies.results.Count() > 0
        m.movies = movies.results
        m.subLabel.text = "Trending This Week"
        LoadPosters(m.movies)
        m.movieGrid.observeField("itemFocused", "OnMovieFocused")
        m.movieGrid.SetFocus(true)
    else
        print "ShelfScene: movies invalid or empty"
        m.subLabel.text = "Failed to load movies"
    end if
end sub

sub LoadPosters(movies as object)
    config = GetConfig()
    contentList = CreateObject("roSGNode", "ContentNode")

    for each movie in movies
        item = CreateObject("roSGNode", "ContentNode")
        item.title = movie.title
        item.HDPosterUrl = config.tmdb_image_base_url + movie.poster_path
        contentList.appendChild(item)
    end for

    m.movieGrid.content = contentList
end sub

sub OnMovieFocused()
    index = m.movieGrid.itemFocused
    if index >= 0 and index < m.movies.Count()
        m.focusedTitle.text = m.movies[index].title
    end if
end sub