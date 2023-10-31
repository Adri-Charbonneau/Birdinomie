# Téléchargement et extraction des lignes du journal
$clements = Invoke-WebRequest -Method GET -Uri "https://www.birds.cornell.edu/clementschecklist/introduction/updateindex/"
$clements -match "a class=`"article-item-link`" href=`"https://www.birds.cornell.edu/clementschecklist/introduction/updateindex/(.*?)/"
$element = $matches[1]

$old = (Select-String -Path "./SOURCES/CLEMENTS.txt" -Pattern "(.*)").Matches.Groups[1].Value
if ( $old -eq $element ) {
    "Pas de mise à jour"
} else {


    # Enregistrement de la nouvelle version
    $element | Out-File "./SOURCES/CLEMENTS.txt"

        # Envoi d'une notification Télégram
    $tmtext = "<b>Clements Checklist</b> : <a href=`"https://www.birds.cornell.edu/clementschecklist/introduction/updateindex/$element`">$element</a>"
    $tmtoken = "$env:TELEGRAM"
    $tmchatid = "$env:CHAT_ID"
    Invoke-RestMethod -Uri "https://api.telegram.org/bot$tmtoken/sendMessage?chat_id=$tmchatid&parse_mode=HTML&text=$tmtext"
}

# git and create tag
git config user.name 'github-actions[bot]'
git config user.email 'github-actions[bot]@users.noreply.github.com'
git add .
git commit -m "[Bot] Update Clements Checklist"
git push -f