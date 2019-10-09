public class sampleChatButtons_Ctl {
    
    public List<wrapperLiveChat> Rec {get;set;}
    public string orgId {get;set;}
    public string DepId {get;set;}
    public sampleChatButtons_Ctl(){
        string body = '';
        Integer i=0;
        orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15);
        Rec = new List<wrapperLiveChat>();
        List<LiveChatButton> lstLC = [Select id,DeveloperName,MasterLabel,LastModifiedDate
                                      From LiveChatButton];
        DepId = [select Id from LiveChatDeployment Limit 1].Id;
        DepId = DepId.substring(0,15);
        String statResourceURL = GetResourceURL('Chat_Images');
            
            for(LiveChatButton record:lstLC){
                i++;            
                string imgOnline = statResourceURL+'/'+record.DeveloperName+'_online.png';
                string imgOffline =  statResourceURL+'/'+record.DeveloperName+'_offline.png';
                if(imgOffline.contains('Grohe')){
                    imgOffline =  statResourceURL+'/'+record.DeveloperName+'_offline.gif';
                }
                Rec.add(new wrapperLiveChat(record,i,imgOnline,imgOffline,DepId,OrgId));
            }
    }
    public static String GetResourceURL(String resourceName) {
        
        List<StaticResource> resourceList = [
            SELECT Name, NamespacePrefix, SystemModStamp 
            FROM StaticResource 
            WHERE Name = :resourceName
        ];
        
        if (resourceList.size() == 1) {
            String namespace = resourceList[0].NamespacePrefix;
            return 'https://'+System.Url.getSalesforceBaseUrl().getHost()+'/resource/' 
                + resourceList[0].SystemModStamp.getTime() + '/' 
                + (namespace != null && namespace != '' ? namespace + '__' : '') 
                + resourceName; 
        } else return '';
        
    }
    public class wrapperLiveChat{
        Public Integer SR {get;set;}
        Public String ChatId {get;set;}
        Public String DeveloperName {get;set;}
        Public String MasterLabel {get;set;}
        Public String Status {get;set;}
        Public DateTime LastModifiedDate {get;set;}
        Public string DeploymentCode {get;set;}
        public wrapperLiveChat( LiveChatButton P, Integer PNumber, String imgOnline, String imgOffline, string DepId, string OrgId){
            SR = PNumber;            
            string t =  P.id;
            ChatId = t.substring(0, 15);            
            DeveloperName = P.DeveloperName;
            MasterLabel = P.MasterLabel;
            LastModifiedDate = P.LastModifiedDate;
            Status = '<img id="liveagent_button_online_'+ChatId+'" href="javascript://Chat"'+
            			  '  style="display: none; border: 0px none; cursor: pointer" alt="Online" src="'+imgOnline+'" onclick="window.open(\'/LiveAgentChat_Launcher?id='+ChatId+'&wdepid='+DepId+'&orgid='+OrgId+'&wfavicon='+imgOnline.replace('online.png','favicon.ico')+'\',\'popup\',\'width=420,height=480,toolbar=0,menubar=0,location=0,scrollbars=0\')"/>'+
                       ' <img id="liveagent_button_offline_'+ChatId+'" alt="Offline" style="display: none; border: 0px none; " src="'+imgOffline+'" />';                        
                        
            DeploymentCode = '<html>'+
                '<body>'+
                '<table class="slds-table slds-table_cell-buffer slds-table_bordered">'+
                '        <thead>'+
                '           <tr class="slds-line-height_reset">'+
                '                <th class="slds-text-title_caps" scope="col">'+
                '                    <div class="slds-truncate" title="Name">Name</div>'+
                '                </th>'+
                '                <th class="slds-text-title_caps" scope="col">'+
                '                    <div class="slds-truncate" title="Status">Status</div>'+
                '                </th>'+
                '                <th class="slds-text-title_caps" scope="col">'+
                '                    <div class="slds-truncate" title="Date">Last Update Date</div>'+
                '                </th>'+
                '            </tr>'+
                '        </thead>'+
                '        <tbody>'+
                '            <tr class="slds-hint-parent">'+
                '                <td data-label="Name" scope="row">'+
                '                    <div class="slds-truncate" title="'+P.MasterLabel+'">'+                   
                '                        '+P.MasterLabel+
                '                    </div>'+
                '                </td>'+
                '                <td data-label="Status">'+
                
                '                    <!-- Chat Button Start Need -->'+
                '                    <img id="liveagent_button_online_'+ChatId+'" href="javascript://Chat"'+ 
                '                       style="display: none; border: 0px none; cursor: pointer" alt="Online" src="'+imgOnline+'" onclick="window.open(\'https://'+System.Url.getSalesforceBaseUrl().getHost()+'/LiveAgentChat_Launcher?id='+ChatId+'\',\'popup\',\'width=420,height=480,toolbar=0,menubar=0,location=0,scrollbars=0 \')"/>'+
                '                    <img id="liveagent_button_offline_'+ChatId+'" alt="Offline" style="display: none; border: 0px none; " src="'+imgOffline+'"/>'+
                '                    <script type="text/javascript">'+
                '                    if (!window._laq) { window._laq = []; }'+
                '                    window._laq.push(function(){liveagent.showWhenOnline(\''+ChatId+'\', document.getElementById(\'liveagent_button_online_'+ChatId+'\'));'+
                '                                                liveagent.showWhenOffline(\''+ChatId+'\', document.getElementById(\'liveagent_button_offline_'+ChatId+'\'));'+
                '                                               });</script>'+
                '                    <!-- Chat End Start -->'+
                '                </td>'+
                '                <td>'+P.LastModifiedDate+'</td>'+
                '            </tr>'+                
                '        </tbody>'+
                '    </table>'+
                '    <script type=\'text/javascript\' src=\'https://c.la2-c2cs-iad.salesforceliveagent.com/content/g/js/45.0/deployment.js\'></script>'+
                '    <script type=\'text/javascript\'>'+
                '    liveagent.init(\'https://d.la2-c2cs-iad.salesforceliveagent.com/chat\', \''+DepId+'\', \''+OrgId+'\');'+
                '    </script>'+
                '</body>'+
                '</html>';
          
        }
    }
}