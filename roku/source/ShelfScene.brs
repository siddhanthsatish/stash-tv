sub init()
    m.movieGrid = m.top.findNode("movieGrid")
    m.focusedTitle = m.top.findNode("focusedTitle")
    m.subLabel = m.top.findNode("subLabel")
    m.detailScene = m.top.findNode("detailScene")
    m.subLabel.text = "Loading..."
    m.inDetail = false

    m.task = CreateObject("roSGNode", "TMDBTask")
    m.task.functionName = "RunTMDBTask"
    m.task.observeField("movies", "OnMoviesLoaded")
    m.task.control = "RUN"
end sub

sub OnMoviesLoaded()
    movies = m.task.movies
    if movies <> invalid and movies.results <> invalid and movies.results.Count() > 0
        m.movies = movies.results
        m.subLabel.text = "Trending This Week"
        LoadPosters(m.movies)
        m.movieGrid.observeField("itemFocused", "OnMovieFocused")
        m.movieGrid.SetFocus(true)
    else
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

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "OK" and not m.inDetail
            index = m.movieGrid.itemFocused
            if index >= 0 and index < m.movies.Count()
                ShowDetail(m.movies[index])
                return true
            end if
        else if key = "back" and m.inDetail
            HideDetail()
            return true
        end if
    end if
    return false
end function

sub ShowDetail(movie as object)
    m.inDetail = true
    m.detailScene.movie = movie
    m.detailScene.visible = true
    m.movieGrid.visible = false
    m.focusedTitle.visible = false
    m.subLabel.visible = false
    m.top.findNode("headerLabel").visible = false
end sub

sub HideDetail()
    m.inDetail = false
    m.detailScene.visible = false
    m.movieGrid.visible = true
    m.focusedTitle.visible = true
    m.subLabel.visible = true
    m.top.findNode("headerLabel").visible = true
    m.movieGrid.SetFocus(true)
end sub