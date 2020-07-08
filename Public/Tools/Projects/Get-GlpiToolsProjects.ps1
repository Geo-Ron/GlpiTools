<#
.SYNOPSIS
    Function is getting Project informations from GLPI
.DESCRIPTION
    Function is based on ProjectID which you can find in GLPI website
    Returns object with property's of Project
.PARAMETER All
    This parameter will return all Projects from GLPI
.PARAMETER ProjectId
    This parameter can take pipline input, either, you can use this function with -ProjectId keyword.
    Provide to this param Project ID from GLPI Projects Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectId Parameter.
    ProjectId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectName
    Provide to this param Project Name from GLPI Projects Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with ProjectName Parameter.
    If you want Search for Project name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with ProjectId Parameter. 
    If you want to get additional parameter of Project object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsProjects
    Function gets ProjectID from GLPI from Pipline, and return Project object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsProjects
    Function gets ProjectID from GLPI from Pipline (u can pass many ID's like that), and return Project object
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -ProjectId 326
    Function gets ProjectID from GLPI which is provided through -ProjectId after Function type, and return Project object
.EXAMPLE 
    PS C:\> Get-GlpiToolsProjects -ProjectId 326, 321
    Function gets ProjectID from GLPI which is provided through -ProjectId keyword after Function type (u can provide many ID's like that), and return Project object
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -ProjectId 234 -Raw
    Example will show Project with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsProjects -Raw
    Example will show Project with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -ProjectName glpi
    Example will return glpi Project, but what is the most important, Project will be shown exacly as you see in glpi Projects tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsProjects -ProjectName glpi -SearchInTrash Yes
    Example will return glpi Project, but from trash
.INPUTS
    Project ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Projects from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsProjects
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProjectId")]
        [alias('PrID')]
        [string[]]$ProjectId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "ProjectName")]
        [alias('CN')]
        [string]$ProjectName,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "ProjectId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
            "WithInfocoms",
            "WithContracts",
            "WithDocuments",
            "WithProjects",
            "WithProjects",
            "WithProjects",
            "WithNotes",
            "WithLogs")]
        [string]$Parameter
    )
    
    begin
    {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProjectObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        switch ($Parameter)
        {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
            WithInfocoms { $ParamValue = "?with_infocoms=true" }
            WithContracts { $ParamValue = "?with_contracts=true" }
            WithDocuments { $ParamValue = "?with_documents=true" }
            WithProjects { $ParamValue = "?with_Projects=true" } 
            WithProjects { $ParamValue = "?with_Projects=true" }
            WithProjects { $ParamValue = "?with_Projects=true" }
            WithNotes { $ParamValue = "?with_notes=true" } 
            WithLogs { $ParamValue = "?with_logs=true" }
            Default { $ParamValue = "" }
        }

    }
    
    process
    {
        switch ($ChoosenParam)
        {
            All
            { 
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'get'
                    uri     = "$($PathToGlpi)/Project/?range=0-9999999999999"
                }
                
                $GLPIProjectsAll = Invoke-RestMethod @params #-Verbose:$false

                foreach ($GlpiProject in $GLPIProjectsAll)
                {
                    $ProjectHash = [ordered]@{ }
                    $ProjectProperties = $GlpiProject.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($ProjectProp in $ProjectProperties)
                    {
                        $ProjectHash.Add($ProjectProp.Name, $ProjectProp.Value)
                    }
                    $object = [pscustomobject]$ProjectHash
                    $ProjectObjectArray.Add($object)
                }
                $ProjectObjectArray
                $ProjectObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProjectId
            { 
                foreach ( $CId in $ProjectID )
                {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Project/$($CId)$ParamValue"
                    }

                    Try
                    {
                        $GlpiProject = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw)
                        {
                            $ProjectHash = [ordered]@{ }
                            $ProjectProperties = $GlpiProject.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectProp in $ProjectProperties)
                            {
                                $ProjectHash.Add($ProjectProp.Name, $ProjectProp.Value)
                            }
                            $object = [pscustomobject]$ProjectHash
                            $ProjectObjectArray.Add($object)
                        }
                        else
                        {
                            $ProjectHash = [ordered]@{ }
                            $ProjectProperties = $GlpiProject.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProjectProp in $ProjectProperties)
                            {

                                switch ($ProjectProp.Name)
                                {
                                    entities_id { $ProjectPropNewValue = $ProjectProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id_recipient { $ProjectPropNewValue = $ProjectProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname, $_.realname } }
                                    users_id_lastupdater { $ProjectPropNewValue = $ProjectProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname, $_.realname } }
                                    Default
                                    {
                                        $ProjectPropNewValue = $ProjectProp.Value
                                    }
                                }
                                
                                $ProjectHash.Add($ProjectProp.Name, $ProjectPropNewValue)
                            }
                            $object = [pscustomobject]$ProjectHash
                            $ProjectObjectArray.Add($object)
                        }
                    }
                    Catch
                    {

                        Write-Verbose -Message "Project ID = $CId is not found"
                        
                    }
                    $ProjectObjectArray
                    $ProjectObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProjectName
            { 
                Search-GlpiToolsItems -SearchFor Project -SearchType contains -SearchValue $ProjectName -SearchInTrash $SearchInTrash
            }
            Default
            {
                
            }
        }
    }
    
    end
    {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}