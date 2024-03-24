const urlParams = new URLSearchParams(window.location.search);

if (urlParams.has('search')) {
    var input = urlParams.get('search');

    $("article li").each(function (item) {

        var finding = $(this).text().toLowerCase().includes(input);
        $(this).toggle(finding);
    })
    $("article .card-body")[0].prepend("Cette article est filtré par recherche: " + input + " et contient " + $("article li:visible").length + " news.");
}