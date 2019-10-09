public class CaseControllerExt {
    private final Case acase;
    public Blob afile {get; set;}
    public String contentType {get; set;}
    public String fileName {get; set;}
    public CaseControllerExt(ApexPages.StandardController stdController){
        this.acase=(Case)stdController.getRecord();
        acase.Status = 'Open';
        acase.Origin = 'Web';
    }
    public PageReference createCaseWithAttachment() {
        try{
            insert(acase);
        }catch(System.DMLException e){
            ApexPages.addMessages(e);
        }
        if(afile!=null){
            Attachment attach=new Attachment();
            attach.Body=afile;
            attach.Name=filename;
            attach.ContentType=contentType;
            attach.ParentID=acase.id;
            try {
                insert(attach);
            } catch(System.DMLException e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        PageReference p = Page.Confirmpage;
        p.setRedirect(true);
        return p;                    
    }        
}