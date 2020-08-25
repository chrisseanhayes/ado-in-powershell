remove-module $PSScriptRoot\modules\ado.psm1 -erroraction silentlycontinue
import-module $PSScriptRoot\modules\ado.psm1

$projects = get-adoobject $(get-adourl projects)

$projects

$queries = get-adoobject $(get-adourl queries $projects.value[0].id)

$queries