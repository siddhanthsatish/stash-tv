sub CategoryInit()
    m.border = m.top.findNode("border")
    m.rowLabel = m.top.findNode("rowLabel")
    m.rowGrid = m.top.findNode("rowGrid")
end sub

sub OnRowDataSet()
    data = m.top.rowData
    if data = invalid then return

    ' Initialize nodes here in case init hasn't run yet
    if m.rowLabel = invalid then m.rowLabel = m.top.findNode("rowLabel")
    if m.rowGrid = invalid then m.rowGrid = m.top.findNode("rowGrid")
    if m.border = invalid then m.border = m.top.findNode("border")

    m.rowLabel.text = data.title
    m.movies = data.movies

    config = GetConfig()
    contentList = CreateObject("roSGNode", "ContentNode")
    for each movie in data.movies
        item = CreateObject("roSGNode", "ContentNode")
        item.title = movie.title
        poster = movie.posterPath
        if poster = invalid or poster = "" then poster = movie.poster_path
        if poster <> invalid and poster <> ""
            item.HDPosterUrl = config.tmdb_image_base_url + poster
        end if
        contentList.appendChild(item)
    end for
    m.rowGrid.content = contentList
end sub

sub OnActiveChanged()
    if m.top.active
        m.border.opacity = 1
        m.rowLabel.color = "0xFFFFFFFF"
        m.rowGrid.SetFocus(true)
        m.rowGrid.observeField("itemFocused", "OnItemFocused")
    else
        m.border.opacity = 0
        m.rowLabel.color = "0xAAAAAAFF"
    end if
end sub

sub OnItemFocused()
    m.top.itemSelected = m.rowGrid.itemFocused
    m.top.focusedIndex = m.rowGrid.itemFocused
end sub


function GetFocusedMovie() as object
    idx = m.rowGrid.itemFocused
    if idx >= 0 and idx < m.movies.Count()
        return m.movies[idx]
    end if
    return invalid
end function