package alert.seccamp

title := input.title if {
    input.title
} else := ""

alert contains {
    "title": title,
}
