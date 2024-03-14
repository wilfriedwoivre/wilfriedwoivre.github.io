$ErrorActionPreference = "Stop"

$currentDate = Get-Date

$startDate = $currentDate.AddMonths(-1).ToString("yyyy-MM-01")
$endDate = (Get-Date($startDate)).AddMonths(1).AddDays(-1).ToString("yyyy-MM-dd")


$news = gh issue list --repo wilfriedwoivre/feedly -L 1000  --state closed --search "label:publish created:$startDate..$endDate" --json title,body,createdAt | convertfrom-json 

Write-Output "Found $($news.Length) news"

$currentMonth = Get-Date($startDate) -UFormat %m
$month = (Get-Culture -Name "fr-FR").DateTimeFormat.GetMonthName($currentMonth)
$title = "Articles - Ce qu'il ne fallait pas oublier de lire en $month $((Get-Date($startDate)).ToString('yyyy'))"

$category = '"Divers"'

$newPost = "---
layout: post
title: $title
date: $((Get-Date($endDate)).AddDays(1).ToString('yyyy-MM-dd'))
categories: [ $category ]
githubcommentIdtoreplace: 
---

Voici un résumé des différents articles que j'ai partagé sur les réseaux sociaux en $month $((Get-Date($startDate)).ToString('yyyy')).

C'est un peu en vrac, mais je vais voir pour essayer de mettre des catégories pour les prochains mois.
"

foreach ($new in $news | Sort-Object -Property createdAt) {
    $newPost += "- [$($new.title)]($($new.body))"
    $newPost += [System.Environment]::NewLine
}


$fileName = "$((Get-Date($endDate)).AddDays(1).ToString('yyyy-MM-dd'))-";
$temp = $title.ToLowerInvariant().Normalize([System.Text.NormalizationForm]::FormD)

$temp.ToCharArray() | %{ 
    $unicodeCategory = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_)
    
    $character = $_

    switch ( $unicodeCategory ) {
        LowercaseLetter { $fileName += $character }
        DecimalDigitNumber { $fileName += $character }
        SpaceSeparator { if ($fileName[$fileName.Length - 1] -ne '-') { $fileName += '-' }}
    }
}

if ($fileName[$fileName.Length - 1] -eq '-') {
    $fileName = $fileName.Remove($fileName.Length - 1, 1)
}

$fileName += ".md"

$newPost = $newPost -replace 'ΓÇô', '-'


$filePath = "$PSScriptRoot\..\_posts\$fileName"

New-Item $filePath -Force

$newPost | Out-File $filePath -Encoding utf8