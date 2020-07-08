<#
.SYNOPSIS
    Function is getting ProjectTask informations from GLPI
.DESCRIPTION
    Function is based on ProjectTaskID which you can find in GLPI website
    Returns object with property's of ProjectTask
.PARAMETER All
    This parameter will return all ProjectTasks from GLPI
.PARAMETER ProjectTaskId
    This parameter can take pipline input, either, you can use this function with -ProjectTaskId keyword.
    Provide to this param ProjectTask ID from GLPI ProjectTasks Bookmark
.PARAMETER Raw
    Parameter which you can use with ProjectTaskId Parameter.
    ProjectTaskId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProjectTaskName
    Provide to this param ProjectTask Name from GLPI ProjectTasks Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with ProjectTaskName Parameter.
    If you want Search for ProjectTask name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with ProjectTaskId Parameter. 
    If you want to get additional parameter of ProjectTask object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsProjectTasks
    Function gets ProjectTaskID from GLPI from Pipline, and return ProjectTask object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsProjectTasks
    Function gets ProjectTaskID from GLPI from Pipline (u can pass many ID's like that), and return ProjectTask object
.EXAMPLE
    PS C:\> Get-GlpiToolsProjectTasks -ProjectTaskId 326
    Function gets ProjectTaskID from GLPI which is provided through -ProjectTaskId after Function type, and return ProjectTask object
.EXAMPLE 
    PS C:\> Get-GlpiToolsProjectTasks -ProjectTaskId 326, 321
    Function gets ProjectTaskID from GLPI which is provided through -ProjectTaskId keyword after Function type (u can provide many ID's like that), and return ProjectTask object
.EXAMPLE
    PS C:\> Get-GlpiToolsProjectTasks -ProjectTaskId 234 -Raw
    Example will show ProjectTask with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsProjectTasks -Raw
    Example will show ProjectTask with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsProjectTasks -ProjectTaskName glpi
    Example will return glpi ProjectTask, but what is the most important, ProjectTask will be shown exacly as you see in glpi ProjectTasks tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsProjectTasks -ProjectTaskName glpi -SearchInTrash Yes
    Example will return glpi ProjectTask, but from trash
.INPUTS
    ProjectTask ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of ProjectTasks from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsProjectTasks
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
        [string]$ProjectTaskName,
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
            "WithProjectTasks",
            "WithProjectTasks",
            "WithProjectTasks",
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
            WithProjectTasks { $ParamValue = "?with_ProjectTasks=true" } 
            WithProjectTasks { $ParamValue = "?with_ProjectTasks=true" }
            WithProjectTasks { $ParamValue = "?with_ProjectTasks=true" }
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
                
                $GlpiProjectAll = Invoke-Webrequest @params #-Verbose:$false

                foreach ($GlpiProject in $GlpiProjectAll)
                {
                    $ProjectHash = [ordered]@{ }
                    $TaskProperties = $GlpiProject.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($TaskProp in $TaskProperties)
                    {
                        $ProjectHash.Add($TaskProp.Name, $TaskProp.Value)
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
                    Write-Verbose "Processing $CID"
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Project/$($CId)/Projecttask$ParamValue"
                    }

                    Try
                    {
                        Write-Verbose "Invoke-RestMethod"
                        $GlpiProject = (Invoke-RestMethod @params -ErrorAction Stop | Select-Object SyncRoot ).SyncRoot

                        if ($Raw)
                        {
                            $TaskHash = [ordered]@{ }
                            $TaskProperties = $GlpiProject.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TaskProp in $TaskProperties)
                            {
                                $ProjectHash.Add($TaskProp.Name, $TaskProp.Value)
                            }
                            $object = [pscustomobject]$ProjectHash
                            $ProjectObjectArray.Add($object)
                        }
                        else
                        {
                            $ProjectHash = [ordered]@{ }
                            $TaskProperties = $GlpiProject.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($TaskProp in $TaskProperties)
                            {

                                switch ($TaskProp.Name)
                                {
                                    entities_id { $TaskPropNewValue = $TaskProp.Value | Get-GlpiToolsEntities | Select-Object -ExpandProperty CompleteName }
                                    users_id_recipient { $TaskPropNewValue = $TaskProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname, $_.realname } }
                                    users_id_lastupdater { $TaskPropNewValue = $TaskProp.Value | Get-GlpiToolsUsers | Select-Object realname, firstname | ForEach-Object { "{0} {1}" -f $_.firstname, $_.realname } }
                                    Default
                                    {
                                        $TaskPropNewValue = $TaskProp.Value
                                    }
                                }
                                
                                $ProjectHash.Add($TaskProp.Name, $TaskPropNewValue)
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
                Search-GlpiToolsItems -SearchFor Project -SearchType contains -SearchValue $ProjectTaskName -SearchInTrash $SearchInTrash
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