sub init()
    m.subLabel = m.top.findNode("subLabel")
    m.detailScene = m.top.findNode("detailScene")
    m.subLabel.text = "Loading your shelf..."
    m.inDetail = false
    m.inBrowse = false
    m.activeRow = 0
    m.rows = []
    m.categoryData = []

    ' Get row references
    m.rows.Push(m.top.findNode("row0"))
    m.rows.Push(m.top.findNode("row1"))
    m.rows.Push(m.top.findNode("row2"))
    m.rows.Push(m.top.findNode("row3"))

    m.firestoreTask = CreateObject("roSGNode", "FirestoreTask")
    m.firestoreTask.functionName = "RunFirestoreTask"
    m.firestoreTask.observeField("shelf", "OnShelfLoaded")
    m.firestoreTask.control = "RUN"
end sub

sub OnShelfLoaded()
    shelf = m.firestoreTask.shelf
    if shelf <> invalid and shelf.movies.Count() > 0
        m.subLabel.text = ""
        BuildCategories(shelf.movies)
    else
        m.subLabel.text = "Shelf empty — add movies on stash web"
        LoadTrending()
    end if
end sub

sub BuildCategories(movies as object)
    categoryMap = {}
    categoryOrder = []

    for each movie in movies
        if movie.categories <> invalid and movie.categories.Count() > 0
            for each cat in movie.categories
                if categoryMap[cat] = invalid
                    categoryMap[cat] = []
                    categoryOrder.Push(cat)
                end if
                categoryMap[cat].Push(movie)
            end for
        else
            if categoryMap["Uncategorized"] = invalid
                categoryMap["Uncategorized"] = []
                categoryOrder.Push("Uncategorized")
            end if
            categoryMap["Uncategorized"].Push(movie)
        end if
    end for

    m.categoryData = []
    for each cat in categoryOrder
        m.categoryData.Push({title: cat, movies: categoryMap[cat]})
    end for

    m.pageOffset = 0
    RenderRows()
    ActivateRow(0)
end sub

sub RenderRows()
    for i = 0 to 3
        catIndex = m.pageOffset + i
        if catIndex < m.categoryData.Count()
            m.rows[i].visible = true
            m.rows[i].rowData = m.categoryData[catIndex]
        else
            m.rows[i].visible = false
        end if
    end for
end sub

sub ActivateRow(index as integer)
    for i = 0 to 3
        m.rows[i].active = false
    end for
    m.activeRow = index
    m.rows[index].active = true
end sub

sub LoadTrending()
    m.task = CreateObject("roSGNode", "TMDBTask")
    m.task.functionName = "RunTMDBTask"
    m.task.observeField("movies", "OnMoviesLoaded")
    m.task.control = "RUN"
end sub

sub OnMoviesLoaded()
    movies = m.task.movies
    if movies <> invalid and movies.results <> invalid and movies.results.Count() > 0
        m.categoryData = [{title: "Trending This Week", movies: movies.results}]
        m.pageOffset = 0
        RenderRows()
        ActivateRow(0)
    end if
end sub

' Layout map:
' [0][1]
' [2][3]

function GetRowAbove(current as integer) as integer
    if current = 2 then return 0
    if current = 3 then return 1
    return -1
end function

function GetRowBelow(current as integer) as integer
    if current = 0 then return 2
    if current = 1 then return 3
    return -1
end function

function GetRowLeft(current as integer) as integer
    if current = 1 then return 0
    if current = 3 then return 2
    return -1
end function

function GetRowRight(current as integer) as integer
    if current = 0 then return 1
    if current = 2 then return 3
    return -1
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if m.inDetail
        if key = "back"
            HideDetail()
            return true
        end if
        return false
    end if

    if m.inBrowse
        if key = "back"
            m.inBrowse = false
            return true
        else if key = "left"
            idx = m.rows[m.activeRow].findNode("rowGrid").itemFocused
            if idx > 0
                m.rows[m.activeRow].findNode("rowGrid").jumpToItem = idx - 1
            end if
            return true
        else if key = "right"
            idx = m.rows[m.activeRow].findNode("rowGrid").itemFocused
            m.rows[m.activeRow].findNode("rowGrid").jumpToItem = idx + 1
            return true
        else if key = "OK"
            focusedIndex = m.rows[m.activeRow].focusedIndex
            catIndex = m.pageOffset + m.activeRow
            if catIndex < m.categoryData.Count()
                movies = m.categoryData[catIndex].movies
                if focusedIndex >= 0 and focusedIndex < movies.Count()
                    ShowDetail(movies[focusedIndex])
                    return true
                end if
            end if
        end if
    else
        if key = "up"
            nextRow = GetRowAbove(m.activeRow)
            if nextRow >= 0
                ActivateRow(nextRow)
            else if m.pageOffset > 0
                m.pageOffset = m.pageOffset - 4
                RenderRows()
                ActivateRow(2)
            end if
            return true
        else if key = "down"
            nextRow = GetRowBelow(m.activeRow)
            if nextRow >= 0 and (m.pageOffset + nextRow) < m.categoryData.Count()
                ActivateRow(nextRow)
            else if m.pageOffset + 4 < m.categoryData.Count()
                m.pageOffset = m.pageOffset + 4
                RenderRows()
                ActivateRow(0)
            end if
            return true
        else if key = "left"
            nextRow = GetRowLeft(m.activeRow)
            if nextRow >= 0 and nextRow < m.categoryData.Count()
                ActivateRow(nextRow)
            end if
            return true
        else if key = "right"
            nextRow = GetRowRight(m.activeRow)
            if nextRow >= 0 and nextRow < m.categoryData.Count()
                ActivateRow(nextRow)
            end if
            return true
        else if key = "OK"
            m.inBrowse = true
            return true
        end if
    end if
    return false
end function

sub ShowDetail(movie as object)
    m.inDetail = true
    m.detailScene.movie = movie
    m.detailScene.visible = true
    for i = 0 to 3
        m.rows[i].visible = false
    end for
    m.top.findNode("headerLabel").visible = false
    m.top.findNode("subLabel").visible = false
end sub

sub HideDetail()
    m.inDetail = false
    m.inBrowse = false
    m.detailScene.visible = false
    for i = 0 to 3
        if m.pageOffset + i < m.categoryData.Count()
            m.rows[i].visible = true
        end if
    end for
    m.top.findNode("headerLabel").visible = true
end sub