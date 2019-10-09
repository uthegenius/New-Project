public Class checkRecursive{
    private static boolean run = true;
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
 }
    }
    
    
    private static boolean runforodms = true;
    public static boolean runonceforodms(){
    if(runforodms){
     runforodms=false;
     return true;
    }else{
        return runforodms;
 }
    }
    
}