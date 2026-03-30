sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    ' Fetch trending movies and show first title
    movies = FetchTrendingMovies()
    if movies.Count() > 0
        label = scene.findNode("statusLabel")
        label.text = "TMDB Connected! First trending movie: " + movies[0].title
    else
        label = scene.findNode("statusLabel")
        label.text = "TMDB connection failed"
    end if

    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub