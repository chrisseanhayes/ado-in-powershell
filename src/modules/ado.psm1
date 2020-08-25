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
function get-ado-url-functions([string]$version, [string]$organization) {
    $baseapiurl = "https://dev.azure.com/$organization"
    $functions = @{}
    $functions.add('projects', { return "$baseapiurl/_apis/projects?api-version=$version" }.GetNewClosure())
    $functions.add('queries', { param($projectid) return "$baseapiurl/$projectid/_apis/wit/queries?api-version=$version"}.GetNewClosure())

    return $functions
}
$urlfunctions = get-ado-url-functions $currentversion $organization

function getadoobjectwithclient($client){
    return {
        param($url) 
        $response = $client.GetAsync($url).Result

        $result = $response.Content.ReadAsStringAsync().Result
        
        $object = ConvertFrom-Json $result
        
        return $object
    }.GetNewClosure()
}
$function:getadoobject = getadoobjectwithclient $(get-ado-web-client)

function Get-AdoObject($url) { return getadoobject $url }
function Get-AdoUrl {
    param(
        [validateset('projects','queries')]
        [string]
        $request,
        $projectid
    )
    
    if($request -eq 'projects'){ 
        $cmd = $urlfunctions['projects']
        $url = & $cmd
    }
    if($request -eq 'queries'){ 
        $cmd = $urlfunctions['queries'] 
        $url = & $cmd $projectid 
    }

    return $url 
}

Export-ModuleMember -Function 'Get-AdoObject'
Export-ModuleMember -Function 'Get-AdoUrl'