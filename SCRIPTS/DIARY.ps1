# Téléchargement et extraction des lignes du journal
$diary = Invoke-WebRequest -Method GET -Uri "https://www.worldbirdnames.org/new/updates/update-diary/"
$paragraphs = $diary.ParsedHtml.getElementsByTagName('p')
$elements = $paragraphs | Foreach-Object { $_.innerHtml }

# Remplacement des espaces et des retours à la ligne
$Source = $elements -replace '(&nbsp;( )?)+' , ' '
$Source = $Source -replace '<br>\n<\/(.*?)>' , '</$1>'
$Source = $Source -replace '$' , '<br>'

# Comparaison avec l'ancienne version
$diff = (compare-object $Source $(Get-content "IOC.html") | Where-Object SideIndicator -eq '<=').InputObject

# Enregistrement de la nouvelle version
$Source | Out-File "IOC.html"

if ($diff -eq $NULL) {
    "Pas de mise à jour"
} else {
    "Mise à jour"

    $text = "`n"
    Foreach($d in $diff) { 
        $d = $d -replace "<br>",""
        $text += "• $d `n"
    }

    # Envoi d'une notification Télégram
    $tmtext = "<b>Journal de l'IOC</b> :
$text
<a href=`"https://www.worldbirdnames.org/new/updates/update-diary/`">IOC-Diary</a>"
    $tmtoken = "$env:TELEGRAM"
    $tmchatid = "$env:CHAT_ID"
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$tmtoken/sendMessage?chat_id=$tmchatid&parse_mode=HTML&text=$tmtext"
}

# git and create tag
git config user.name 'github-actions[bot]'
git config user.email 'github-actions[bot]@users.noreply.github.com'
git add .
git commit -m "[Bot] Update diary"
git push -f