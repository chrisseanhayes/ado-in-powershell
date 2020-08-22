function convert-to-base64([string]$value){
    $base64val = [Convert]::ToBase64String([System.Text.ASCIIEncoding]::ASCII.GetBytes($value))
    return $base64val
}

function get-pat-auth-header($pat){
    $base64authheader = convert-to-base64 ":$pat"
    $auth = new-object System.Net.Http.Headers.AuthenticationHeaderValue -ArgumentList ("Basic", $base64authheader)
    return $auth
}

function get-json-accept-header{
    return new-object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue -ArgumentList "application/json"
}

function get-ado-web-client{
    $client = new-object System.Net.Http.HttpClient
    #accept header for json
    $client.DefaultRequestHeaders.Accept.Clear()
    $client.DefaultRequestHeaders.Accept.Add($(get-json-accept-header))
    
    #auth header
    $client.DefaultRequestHeaders.Authorization = get-pat-auth-header $env:PAT
    return $client
}
$currentversion = "5.1"
$organization = "chrisseanhayes"
$getadoprojecturlwithversion = {
    param([string]$version, [string]$organization) `
        return {
                return "https://dev.azure.com/$organization/_apis/projects?api-version=$version"
        }.GetNewClosure()
    }
$getadoprojecturl = & $getadoprojecturlwithversion $currentversion $organization
$function:getprojecturl = $getadoprojecturl

$getadoobjectwithclient = {
    param($client) `
        return {
            return { param($url) {
                $response = $client.GetAsync($url).Result

                $result = $response.Content.ReadAsStringAsync().Result
                
                $object = ConvertFrom-Json $result
                
                return $object
            }}.GetNewClosure()
        }
}
$client = get-ado-web-client
$getadoobject = & $getadoobjectwithclient $client
$function:getadoobject = $getadoobject

$project = getadoobject getprojecturl

$project