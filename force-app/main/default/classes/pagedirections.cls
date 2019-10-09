public class pagedirections {

    public PageReference urlRedirection() {

          string url = ApexPages.currentPage().getParameters().get('URL');
		  if(string.isBlank(url)) return null;
          PageReference page = new PageReference(url);
          page.setRedirect(true);
          return page;
    }
}